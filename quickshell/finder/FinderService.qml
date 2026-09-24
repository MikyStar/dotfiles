pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Indexes applications (via DesktopEntries), files under $HOME and scripts under $HOME/Scripts, and
// fuzzy-filters them through `fzf --filter` as the query changes. Each source is dumped to its own
// cache file as "type\tindex\tlabel" lines; filtering re-reads whichever file(s) the active tab needs
// (or all three, concatenated, for "All") and maps the matched lines back to the full entry via `index`.
Singleton {
    id: root

    readonly property string cacheDir: "/tmp/quickshell-finder"
    readonly property string appsFile: cacheDir + "/apps.tsv"
    readonly property string scriptsFile: cacheDir + "/scripts.tsv"
    readonly property string filesFile: cacheDir + "/files.tsv"

    readonly property var filterNames: ["All", "Applications", "Files", "Scripts"]
    // fd excludes for the $HOME file scan -- heavy or noisy directories that are rarely what you want
    // from a launcher. fd already skips hidden/gitignored paths by default, hence no ".git"/".cache" here.
    readonly property var fileExcludes: ["node_modules", "target", "dist", "build", ".venv", "venv"]
    readonly property int fileScanDepth: 6
    readonly property int fileScanRefreshMs: 600000 // 10 min

    property bool visible: false
    property string query: ""
    property int filterIndex: 0
    property var results: []
    property int selectedIndex: -1
    property bool filesIndexing: false

    property var _apps: []    // [{ label, sublabel, iconSource }]
    property var _scripts: [] // [{ label, path }]
    property var _files: []   // [{ label, path }]
    property double _filesIndexedAt: 0

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
        if (_files.length === 0 || Date.now() - _filesIndexedAt > fileScanRefreshMs)
            _refreshFiles();
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
        else if (r.kind === "file")
            Quickshell.execDetached(["xdg-open", r.path]);
        else if (r.kind === "script")
            Quickshell.execDetached([r.path]);
        close();
    }

    function openTerminalFor(path: string) {
        const dir = path.substring(0, path.lastIndexOf("/")) || "/";
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

    // -- Scripts: flat listing of $HOME/Scripts. -- Files: depth-capped fd scan of $HOME, cached and
    // refreshed on a timer rather than rebuilt on every open, since it's the (potentially) slow one.
    //
    // Both scripts share a shape: fd's raw path listing is captured on stdout for the JS-side array
    // (label/path per row) *and*, in the same script, piped through awk to generate the "type\tindex\
    // tlabel" index file fzf reads -- entirely shell/file-side, no QML round-trip. (Unlike the small,
    // in-memory apps list below, a file listing can run into the tens of thousands of rows, well past
    // the ~128KB single-argv-string limit a printf-from-QML approach would hit.)

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

    function _refreshFiles() {
        root.filesIndexing = true;
        const excludeArgs = root.fileExcludes.map(e => `-E '${e}'`).join(" ");
        const raw = root.cacheDir + "/file.raw";
        filesScanProc.command = ["sh", "-c", `mkdir -p "${root.cacheDir}"
            fd --type f --max-depth ${root.fileScanDepth} ${excludeArgs} . "$HOME" 2>/dev/null | head -20000 > "${raw}"
            awk -F/ '{ printf "file\\t%d\\t%s\\n", NR - 1, $NF }' "${raw}" > "${root.filesFile}"
            cat "${raw}"`];
        filesScanProc.running = true;
    }

    Process {
        id: filesScanProc
        stdout: StdioCollector { id: filesScanOut }
        onExited: {
            root.filesIndexing = false;
            root._filesIndexedAt = Date.now();
            const paths = filesScanOut.text.split("\n").filter(l => l.length > 0);
            root._files = paths.map(p => ({ label: p.split("/").pop(), path: p }));
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
        case 2: return [root.filesFile];
        case 3: return [root.scriptsFile];
        default: return [root.appsFile, root.scriptsFile, root.filesFile];
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

    // Extension -> icon-theme generic icon name, used to resolve a file's left-hand icon.
    readonly property var _extIconMap: ({
        "png": "image-x-generic", "jpg": "image-x-generic", "jpeg": "image-x-generic",
        "gif": "image-x-generic", "svg": "image-x-generic", "webp": "image-x-generic", "bmp": "image-x-generic",
        "mp4": "video-x-generic", "mkv": "video-x-generic", "webm": "video-x-generic", "mov": "video-x-generic", "avi": "video-x-generic",
        "mp3": "audio-x-generic", "flac": "audio-x-generic", "wav": "audio-x-generic", "ogg": "audio-x-generic",
        "pdf": "application-pdf",
        "zip": "package-x-generic", "tar": "package-x-generic", "gz": "package-x-generic", "xz": "package-x-generic", "7z": "package-x-generic", "rar": "package-x-generic",
        "doc": "x-office-document", "docx": "x-office-document", "odt": "x-office-document",
        "xls": "x-office-spreadsheet", "xlsx": "x-office-spreadsheet", "ods": "x-office-spreadsheet",
        "ppt": "x-office-presentation", "pptx": "x-office-presentation", "odp": "x-office-presentation",
        "json": "text-x-generic", "md": "text-x-generic", "txt": "text-x-generic",
        "yaml": "text-x-generic", "yml": "text-x-generic", "toml": "text-x-generic", "ini": "text-x-generic", "conf": "text-x-generic",
        "js": "text-x-script", "ts": "text-x-script", "py": "text-x-script", "sh": "text-x-script", "qml": "text-x-script", "lua": "text-x-script",
        "c": "text-x-csrc", "h": "text-x-chdr", "cpp": "text-x-c++src", "hpp": "text-x-c++hdr",
        "rs": "text-x-rust", "go": "text-x-go", "java": "text-x-java",
    })

    function _fileIconSource(path: string): string {
        const dot = path.lastIndexOf(".");
        const ext = dot >= 0 ? path.substring(dot + 1).toLowerCase() : "";
        const name = root._extIconMap[ext] ?? "text-x-generic";
        return Quickshell.iconPath(name, true);
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
            } else if (type === "file") {
                const f = root._files[idx];
                if (f)
                    out.push({ kind: "file", label: f.label, sublabel: f.path, iconSource: _fileIconSource(f.path), path: f.path });
            }
            if (out.length >= 200)
                break;
        }
        root.results = out;
        root.selectedIndex = out.length > 0 ? 0 : -1;
    }
}
