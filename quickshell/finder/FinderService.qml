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

    function cycleFilter(delta: int) {
        filterIndex = (filterIndex + delta + filterNames.length) % filterNames.length;
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
        onTriggered: {
            root._runFilter();
            root._startCalc();
        }
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
        // Files and folders are scanned separately so each raw line can be tagged with an f/d prefix,
        // used by _applyResults/_pathIcon to tell folders from files. `fd --type d` terminates every
        // match with a trailing "/" (unlike --type f) -- stripped here, otherwise the awk step below
        // would split the path into an extra trailing empty field and every folder's label (and hence
        // its fuzzy-match text) would come out blank.
        pathsScanProc.command = ["sh", "-c", `mkdir -p "${root.cacheDir}"
            { fd --type f --max-depth ${root.pathScanDepth} ${excludeArgs} . "$HOME" 2>/dev/null | sed 's/^/f\\t/'
              fd --type d --max-depth ${root.pathScanDepth} ${excludeArgs} . "$HOME" 2>/dev/null | sed 's:/$::' | sed 's/^/d\\t/'
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

    // -- Calculator: a synthetic first result when the query itself looks like a math expression,
    // e.g. "8*2+3" -> "= 19". Independent of fzf/the active tab -- prepended whenever it applies,
    // alongside whatever apps/paths/scripts also matched the same text. Evaluated by piping to
    // python3 (with the `math` module) rather than a handwritten parser, so parenthesized priority,
    // exponents (**, or "^" as a friendlier alias) and math functions (sqrt, sin, log, ...) all come
    // for free from Python's own grammar instead of having to be reimplemented here.

    // A short allow-list of `math` module names -- just enough that _looksLikeMath doesn't reject a
    // call to one of them as "not an expression" for containing letters. It's a cheap prefilter to
    // avoid spawning python3 on every non-math keystroke, not a security boundary: that's calcProc's
    // sandboxed eval() below, which is safe regardless of what string reaches it.
    readonly property var _mathFunctions: [
        "sqrt", "cbrt", "pow", "exp", "log2", "log10", "log", "sin", "cos", "tan",
        "asin", "acos", "atan2", "atan", "floor", "ceil", "trunc", "abs", "round",
        "factorial", "hypot", "degrees", "radians", "gcd", "pi", "tau", "e",
    ]

    // True only when `q` is plausibly a full expression: known function/constant names are blanked
    // out first (so "sqrt(16)" or "pi*2" reduce to pure arithmetic syntax), then what's left must be
    // only digits/operators/parens/commas, contain a digit, and have an operator that isn't just a
    // leading sign (so a bare number or path/app text with digits in it, e.g. "vlc-3", isn't treated
    // as math -- plain letters elsewhere already fail the charset check on their own).
    function _looksLikeMath(q: string): bool {
        let s = q.replace(/\s+/g, "");
        if (s.length === 0)
            return false;
        for (const name of root._mathFunctions)
            s = s.split(name).join("0");
        if (!/^[0-9+\-*/^%().,]+$/.test(s) || !/[0-9]/.test(s))
            return false;
        return s.includes("(") || /[0-9)][+\-*/^%]/.test(s);
    }

    // sys.argv[1] (note: NOT argv[0] -- with `python3 -c`, argv[0] is always "-c" itself, unlike
    // `sh -c script arg0`, so no placeholder arg is passed in the command array below) is the
    // expression. Deliberately not a bare `eval(expr, {"__builtins__": {}}, allowed)`: stripping
    // __builtins__ still leaves ordinary attribute access reachable (e.g.
    // "().__class__.__bases__[0].__subclasses__()" walks to every loaded class, __builtins__ or not),
    // so this instead walks the parsed AST itself and only ever evaluates number literals, +-*/%**//,
    // unary +/-, and calls/names from `allowed` -- anything else (attribute access, subscripting,
    // comprehensions, string literals, ...) hits the catch-all `raise` and aborts. Float results are
    // rounded to tame binary-float noise (0.1+0.2) and demoted to int when whole, so e.g. "10/2"
    // prints "5" rather than "5.0".
    readonly property string _calcScript: `
import sys, ast, math, operator as op
ops = {
    ast.Add: op.add, ast.Sub: op.sub, ast.Mult: op.mul, ast.Div: op.truediv,
    ast.Mod: op.mod, ast.Pow: op.pow, ast.FloorDiv: op.floordiv,
    ast.USub: op.neg, ast.UAdd: op.pos,
}
allowed = {k: v for k, v in vars(math).items() if not k.startswith("_")}
allowed.update({"abs": abs, "round": round, "pow": pow})
def ev(node):
    if isinstance(node, ast.Expression):
        return ev(node.body)
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in ops:
        return ops[type(node.op)](ev(node.left), ev(node.right))
    if isinstance(node, ast.UnaryOp) and type(node.op) in ops:
        return ops[type(node.op)](ev(node.operand))
    if isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id in allowed and not node.keywords:
        return allowed[node.func.id](*[ev(a) for a in node.args])
    if isinstance(node, ast.Name) and node.id in allowed:
        return allowed[node.id]
    raise ValueError("disallowed expression")
try:
    result = ev(ast.parse(sys.argv[1], mode="eval"))
    if isinstance(result, float):
        result = round(result, 10)
        if result == int(result):
            result = int(result)
    print(result)
except Exception:
    sys.exit(1)
`

    // Debounced alongside _runFilter (see filterDebounce above), but resolved independently and
    // asynchronously. Mirrors filterProc/_filtering/_filterPending below: a Process whose `command`/
    // `running` is set again while it's still running just silently ignores that (it only re-checks
    // them once the current run exits), so a re-trigger while calcProc is busy is queued via
    // _calcPending and retried from onExited instead, re-reading the live query at that point rather
    // than whatever it was when the retry was queued.
    function _startCalc() {
        if (root._calcRunning) {
            root._calcPending = true;
            return;
        }
        if (!root._looksLikeMath(root.query)) {
            if (root._calcResult !== null) {
                root._calcResult = null;
                root._calcGen++;
                root._composeResults();
            }
            return;
        }
        root._calcRunning = true;
        root._calcGen++;
        calcProc.gen = root._calcGen;
        // A leading "^" is a common calculator convention for exponentiation; Python's own operator
        // for that is "**" (bare "^" means bitwise XOR, silently wrong for this use). The sublabel
        // below keeps showing what was actually typed.
        const expr = root.query.trim().replace(/\^/g, "**");
        calcProc.command = ["python3", "-c", root._calcScript, expr];
        calcProc.running = true;
    }

    Process {
        id: calcProc
        property int gen: 0
        stdout: StdioCollector { id: calcOut }
        onExited: code => {
            root._calcRunning = false;
            if (calcProc.gen === root._calcGen) {
                const value = calcOut.text.trim();
                root._calcResult = (code === 0 && value !== "")
                    ? { kind: "calc", label: "= " + value, sublabel: root.query.trim(), icon: Icons.calculator, value: value }
                    : null;
                root._composeResults();
            } // else: a newer query already superseded this one -- its own result stands.
            if (root._calcPending) {
                root._calcPending = false;
                root._startCalc();
            }
        }
    }

    property var _calcResult: null
    property int _calcGen: 0
    property bool _calcRunning: false
    property bool _calcPending: false
    property var _matchedResults: [] // last fzf-derived [{ kind: app/path/script, ... }, ...], calc excluded

    // Combines the last fzf match list with whatever the calculator has (async and independently of
    // fzf) settled on, calc first. Called after either one changes.
    function _composeResults() {
        const out = root._calcResult ? [root._calcResult, ...root._matchedResults] : root._matchedResults;
        root.results = out;
        root.selectedIndex = out.length > 0 ? 0 : -1;
    }

    function _applyResults(text: string) {
        const lines = text.split("\n").filter(l => l.length > 0);
        const out = [];
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
        root._matchedResults = out;
        root._composeResults();
    }
}
