pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.style

// Indexes applications (via DesktopEntries), paths (files and folders) under $HOME and scripts under
// $HOME/Scripts, and fuzzy-filters them through `fzf --filter` as the query changes. Each source is
// dumped to its own cache file as "type\tindex\tlabel" lines; filtering re-reads whichever file(s) the
// active tab needs (or all three, concatenated, for "All") and maps the matched lines back to the full
// entry via `index`.
Singleton {
    id: root

    readonly property string cacheDir: "/tmp/quickshell-finder"
    readonly property string appsFile: cacheDir + "/apps.tsv"
    readonly property string scriptsFile: cacheDir + "/scripts.tsv"
    readonly property string pathsFile: cacheDir + "/paths.tsv"

    readonly property var filterNames: ["All", "Applications", "Paths", "Scripts"]
    // fd excludes for the $HOME path scan -- heavy or noisy directories that are rarely what you want
    // from a launcher. fd already skips hidden/gitignored paths by default, hence no ".git"/".cache" here.
    readonly property var pathExcludes: ["node_modules", "target", "dist", "build", ".venv", "venv"]
    readonly property int pathScanDepth: 6
    readonly property int pathScanRefreshMs: 600000 // 10 min

    property bool visible: false
    property string query: ""
    property int filterIndex: 0
    property var results: []
    property int selectedIndex: -1
    property bool pathsIndexing: false

    property var _apps: []    // [{ label, sublabel, iconSource }]
    property var _scripts: [] // [{ label, path }]
    property var _paths: []   // [{ label, path, isDir }]
    property double _pathsIndexedAt: 0

    property bool _filtering: false
    property bool _filterPending: false

    function open() {
        if (visible)
            return;
        query = "";
        filterIndex = 0;
        selectedIndex = -1;
        visible = true;
        _refreshApps();
        _refreshScripts();
        if (_paths.length === 0 || Date.now() - _pathsIndexedAt > pathScanRefreshMs)
            _refreshPaths();
        _runFilter();
    }

    function close() {
        visible = false;
    }

    function toggle() {
        if (visible)
            close();
        else
            open();
    }

    function cycleFilter() {
        filterIndex = (filterIndex + 1) % filterNames.length;
    }

    function moveSelection(delta: int) {
        if (results.length === 0) {
            selectedIndex = -1;
            return;
        }
        selectedIndex = (selectedIndex + delta + results.length) % results.length;
    }

    function activateSelected() {
        if (selectedIndex < 0 || selectedIndex >= results.length)
            return;
        const r = results[selectedIndex];
        if (r.kind === "app")
            r.appEntry.execute();
        else if (r.kind === "path")
            Quickshell.execDetached(["xdg-open", r.path]);
        else if (r.kind === "script")
            Quickshell.execDetached([r.path]);
        else if (r.kind === "calc")
            Quickshell.execDetached(["sh", "-c", "printf '%s' \"$1\" | wl-copy", "sh", r.value]);
        close();
    }

    // For a folder, opens a terminal in the folder itself rather than its parent.
    function openTerminalFor(path: string, isDir: bool) {
        const dir = isDir ? path : (path.substring(0, path.lastIndexOf("/")) || "/");
        Quickshell.execDetached(["kitty", "--directory", dir]);
    }

    function openFilesFor(path: string) {
        Quickshell.execDetached(["nautilus", path]);
    }

    onQueryChanged: filterDebounce.restart()
    onFilterIndexChanged: filterDebounce.restart()

    Timer {
        id: filterDebounce
        interval: 35
        onTriggered: root._runFilter()
    }

    // -- Applications: built straight from DesktopEntries, no scan needed. --

    function _refreshApps() {
        const apps = DesktopEntries.applications.values
            .filter(a => !a.noDisplay)
            .sort((a, b) => a.name.localeCompare(b.name));
        root._apps = apps.map(a => ({
            label: a.name,
            sublabel: a.comment || a.genericName || "",
            iconSource: Quickshell.iconPath(a.icon, true),
            appEntry: a,
        }));
        const content = root._apps.map((a, i) => `app\t${i}\t${a.label}`).join("\n");
        _writeIndexFile(root.appsFile, content, appsWriteProc);
    }

    Process {
        id: appsWriteProc
        onExited: root._runFilter()
    }

    // -- Scripts: flat listing of $HOME/Scripts. -- Paths: depth-capped fd scan of $HOME (files *and*
    // folders), cached and refreshed on a timer rather than rebuilt on every open, since it's the
    // (potentially) slow one.
    //
    // Both scripts share a shape: fd's raw listing is captured on stdout for the JS-side array (label/
    // path per row) *and*, in the same script, piped through awk to generate the "type\tindex\tlabel"
    // index file fzf reads -- entirely shell/file-side, no QML round-trip. (Unlike the small, in-memory
    // apps list below, a path listing can run into the tens of thousands of rows, well past the ~128KB
    // single-argv-string limit a printf-from-QML approach would hit.)

    function _refreshScripts() {
        const raw = root.cacheDir + "/script.raw";
        scriptsScanProc.command = ["sh", "-c", `mkdir -p "${root.cacheDir}"
            fd . "$HOME/Scripts" --type f 2>/dev/null > "${raw}"
            awk -F/ '{ printf "script\\t%d\\t%s\\n", NR - 1, $NF }' "${raw}" > "${root.scriptsFile}"
            cat "${raw}"`];
        scriptsScanProc.running = true;
    }

    Process {
        id: scriptsScanProc
        stdout: StdioCollector { id: scriptsScanOut }
        onExited: {
            const paths = scriptsScanOut.text.split("\n").filter(l => l.length > 0);
            root._scripts = paths.map(p => ({ label: p.split("/").pop(), path: p }));
            root._runFilter();
        }
    }

    function _refreshPaths() {
        root.pathsIndexing = true;
        const excludeArgs = root.pathExcludes.map(e => `-E '${e}'`).join(" ");
        const raw = root.cacheDir + "/path.raw";
        // Files and folders are scanned separately so each raw line can be tagged with an f/d prefix
        // (fd's own output doesn't distinguish them, e.g. via a trailing "/") -- that tag is what tells
        // _applyResults/_pathIcon whether to show a folder icon or a file-type one.
        pathsScanProc.command = ["sh", "-c", `mkdir -p "${root.cacheDir}"
            { fd --type f --max-depth ${root.pathScanDepth} ${excludeArgs} . "$HOME" 2>/dev/null | sed 's/^/f\\t/'
              fd --type d --max-depth ${root.pathScanDepth} ${excludeArgs} . "$HOME" 2>/dev/null | sed 's/^/d\\t/'
            } | head -20000 > "${raw}"
            awk -F'\\t' '{ n = split($2, parts, "/"); printf "path\\t%d\\t%s\\n", NR - 1, parts[n] }' "${raw}" > "${root.pathsFile}"
            cat "${raw}"`];
        pathsScanProc.running = true;
    }

    Process {
        id: pathsScanProc
        stdout: StdioCollector { id: pathsScanOut }
        onExited: {
            root.pathsIndexing = false;
            root._pathsIndexedAt = Date.now();
            const lines = pathsScanOut.text.split("\n").filter(l => l.length > 0);
            root._paths = lines.map(l => {
                const tab = l.indexOf("\t");
                return { label: l.substring(tab + 1).split("/").pop(), path: l.substring(tab + 1), isDir: l.charAt(0) === "d" };
            });
            root._runFilter();
        }
    }

    // Writes `content` to `path` via a plain `printf '%s'` redirect (content passed as argv, never
    // interpolated into the script string, so it's safe regardless of what characters app names etc.
    // contain). Only used for the small, in-memory apps list -- see the scripts/files scans above for
    // why those go through a different, argv-size-safe path (awk, entirely shell/file-side) instead.
    function _writeIndexFile(path: string, content: string, proc) {
        proc.command = ["sh", "-c", 'mkdir -p "$(dirname "$1")" && printf "%s" "$2" > "$1"', "sh", path, content];
        proc.running = true;
    }

    // -- Filtering --

    function _sourceFiles(): var {
        switch (filterIndex) {
        case 1: return [root.appsFile];
        case 2: return [root.pathsFile];
        case 3: return [root.scriptsFile];
        default: return [root.appsFile, root.scriptsFile, root.pathsFile];
        }
    }

    function _runFilter() {
        if (!root.visible)
            return;
        if (root._filtering) {
            root._filterPending = true;
            return;
        }
        root._filtering = true;
        const files = root._sourceFiles().map(f => `"${f}"`).join(" ");
        // --delimiter/--nth restrict matching (and thus scoring) to the label field, so the type/index
        // columns never accidentally influence which rows come back. --filter="$1" (rather than a bare
        // positional) keeps the query unambiguous even if it starts with "-".
        const script = `cat ${files} 2>/dev/null | fzf -i --delimiter="\t" --nth=3 --filter="$1"`;
        filterProc.command = ["sh", "-c", script, "sh", root.query];
        filterProc.running = true;
    }

    Process {
        id: filterProc
        stdout: StdioCollector { id: filterOut }
        onExited: {
            root._filtering = false;
            root._applyResults(filterOut.text);
            if (root._filterPending) {
                root._filterPending = false;
                root._runFilter();
            }
        }
    }

    // Extension groups used by _pathIcon to pick a Nerd Font glyph for a path's left-hand icon.
    readonly property var _imageExts: ["png", "jpg", "jpeg", "gif", "svg", "webp", "bmp", "ico", "heic"]
    readonly property var _videoExts: ["mp4", "mkv", "webm", "mov", "avi", "flv", "wmv", "m4v"]
    readonly property var _audioExts: ["mp3", "flac", "wav", "ogg", "m4a", "opus", "aac"]
    readonly property var _wordExts: ["doc", "docx", "odt"]
    readonly property var _excelExts: ["xls", "xlsx", "ods", "csv"]
    readonly property var _powerpointExts: ["ppt", "pptx", "odp"]
    readonly property var _archiveExts: ["zip", "tar", "gz", "xz", "7z", "rar", "bz2"]

    // Folder icon for a directory; otherwise a Nerd Font glyph for the extension when it's one we
    // recognize (a specific one for images/video/audio/office/archive types, and a language-specific
    // one -- see Icons.language -- for text/code files), falling back to a plain generic-file glyph.
    function _pathIcon(path: string, isDir: bool): string {
        if (isDir)
            return Icons.folder;
        const dot = path.lastIndexOf(".");
        const ext = dot >= 0 ? path.substring(dot + 1).toLowerCase() : "";
        if (root._imageExts.includes(ext))
            return Icons.fileImage;
        if (root._videoExts.includes(ext))
            return Icons.fileVideo;
        if (root._audioExts.includes(ext))
            return Icons.fileAudio;
        if (ext === "pdf")
            return Icons.filePdf;
        if (root._wordExts.includes(ext))
            return Icons.fileWord;
        if (root._excelExts.includes(ext))
            return Icons.fileExcel;
        if (root._powerpointExts.includes(ext))
            return Icons.filePowerpoint;
        if (root._archiveExts.includes(ext))
            return Icons.fileArchive;
        const lang = Icons.language(ext);
        if (lang !== "")
            return lang;
        return Icons.fileGeneric;
    }

    // -- Calculator: a synthetic first result when the query itself looks like an arithmetic
    // expression, e.g. "8*2+3" -> "= 19". Independent of fzf/the active tab -- always prepended
    // when it applies, alongside whatever apps/paths/scripts also matched the same text.

    // True only when `q` is plausibly a full expression (not e.g. a bare number, or a leading "-").
    // Requires an operator that isn't just a leading sign, so path/app searches with digits in them
    // ("file.txt", "vlc-3") don't get treated as math (letters alone already fail the charset check).
    function _looksLikeMath(q: string): bool {
        const s = q.replace(/\s+/g, "");
        if (s.length === 0 || !/^[0-9+\-*/%().]+$/.test(s) || !/[0-9]/.test(s))
            return false;
        return s.includes("(") || /[0-9)][+\-*/%]/.test(s);
    }

    // Tiny recursive-descent evaluator for +, -, *, /, %, parentheses and unary +/- over decimals --
    // deliberately not `eval`/`Function`, so a stray expression can't run arbitrary JS. Returns null
    // on any syntax error, division by zero, or non-finite result (rather than throwing/NaN) so the
    // caller can just skip showing a result.
    function _evalMath(expr: string): var {
        const s = expr.replace(/\s+/g, "");
        let i = 0;
        const peek = () => s[i];

        function parseNumber() {
            const start = i;
            while (i < s.length && ((s[i] >= "0" && s[i] <= "9") || s[i] === "."))
                i++;
            if (i === start)
                throw new Error("expected number");
            const n = Number(s.slice(start, i));
            if (Number.isNaN(n))
                throw new Error("bad number");
            return n;
        }

        function parseFactor() {
            if (peek() === "+") { i++; return parseFactor(); }
            if (peek() === "-") { i++; return -parseFactor(); }
            if (peek() === "(") {
                i++;
                const v = parseExpr();
                if (peek() !== ")")
                    throw new Error("expected )");
                i++;
                return v;
            }
            return parseNumber();
        }

        function parseTerm() {
            let v = parseFactor();
            while (peek() === "*" || peek() === "/" || peek() === "%") {
                const op = s[i++];
                const rhs = parseFactor();
                if (op === "*")
                    v *= rhs;
                else {
                    if (rhs === 0)
                        throw new Error("division by zero");
                    v = op === "/" ? v / rhs : v % rhs;
                }
            }
            return v;
        }

        function parseExpr() {
            let v = parseTerm();
            while (peek() === "+" || peek() === "-")
                v = s[i++] === "+" ? v + parseTerm() : v - parseTerm();
            return v;
        }

        try {
            const result = parseExpr();
            if (i !== s.length || !Number.isFinite(result))
                return null;
            return result;
        } catch (e) {
            return null;
        }
    }

    // Trims float noise (e.g. 0.1+0.2) down to 6 decimal places without padding whole numbers.
    function _formatCalc(n: real): string {
        if (Number.isInteger(n))
            return String(n);
        return n.toFixed(6).replace(/0+$/, "").replace(/\.$/, "");
    }

    function _calcEntry(): var {
        if (!root._looksLikeMath(root.query))
            return null;
        const value = root._evalMath(root.query);
        if (value === null)
            return null;
        return { kind: "calc", label: "= " + root._formatCalc(value), sublabel: root.query.trim(), icon: Icons.calculator, value: root._formatCalc(value) };
    }

    function _applyResults(text: string) {
        const lines = text.split("\n").filter(l => l.length > 0);
        const out = [];
        const calc = root._calcEntry();
        if (calc)
            out.push(calc);
        for (const line of lines) {
            const parts = line.split("\t");
            if (parts.length < 3)
                continue;
            const type = parts[0];
            const idx = Number(parts[1]);
            if (type === "app") {
                const a = root._apps[idx];
                if (a)
                    out.push({ kind: "app", label: a.label, sublabel: a.sublabel, iconSource: a.iconSource, appEntry: a.appEntry });
            } else if (type === "script") {
                const s = root._scripts[idx];
                if (s)
                    out.push({ kind: "script", label: s.label, sublabel: s.path, path: s.path });
            } else if (type === "path") {
                const p = root._paths[idx];
                if (p)
                    out.push({ kind: "path", label: p.label, sublabel: p.path, icon: _pathIcon(p.path, p.isDir), path: p.path, isDir: p.isDir });
            }
            if (out.length >= 200)
                break;
        }
        root.results = out;
        root.selectedIndex = out.length > 0 ? 0 : -1;
    }
}
