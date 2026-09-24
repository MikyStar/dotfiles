pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Per-device used/total space, plus a `tree`-style breakdown of configured folder sizes under $HOME
// (see config.json's "disk.paths"), topped up with the 5 next-heaviest folders directly under $HOME.
Singleton {
    id: root

    readonly property string configPath: Quickshell.shellPath("config.json")
    readonly property string home: "/home/user"
    // Local filesystem types that aren't real storage and shouldn't show up as a "device".
    readonly property var excludedFsTypes: ["tmpfs", "devtmpfs", "overlay", "squashfs", "efivarfs", "proc",
        "sysfs", "cgroup2", "tracefs", "debugfs", "securityfs", "pstore", "bpf", "autofs", "mqueue",
        "hugetlbfs", "configfs", "fusectl", "binfmt_misc"]

    property bool loading: false
    property date lastUpdated: new Date(NaN)

    // [{ target, used, total }, ...]
    property var devices: []
    // Flattened for rendering: [{ path, label, size, depth, isLast }, ...]
    property var treeRows: []

    property var _config: []

    function refresh() {
        if (loading)
            return;
        loading = true;
        configFile.reload();
    }

    function openTerminal(path: string) {
        Quickshell.execDetached(["kitty", "--directory", path]);
    }

    function openFiles(path: string) {
        Quickshell.execDetached(["nautilus", path]);
    }

    FileView {
        id: configFile
        path: root.configPath
        onLoaded: {
            try {
                root._config = JSON.parse(text()).disk?.paths ?? [];
            } catch (e) {
                root._config = [];
            }
            root._runScan();
        }
    }

    function _runScan() {
        const exclude = root.excludedFsTypes.map(t => `-x ${t}`).join(" ");
        const paths = root._config.map(e => e.path);
        const lines = [];
        lines.push(`df ${exclude} --local --output=target,used,size -B1 2>/dev/null | tail -n +2 | while read -r t u s; do printf 'DEVICE\\t%s\\t%s\\t%s\\n' "$t" "$u" "$s"; done`);
        for (const entry of root._config) {
            lines.push(`s=$(du -sb "${entry.path}" 2>/dev/null | cut -f1); printf 'PATH\\t%s\\t%s\\n' "${entry.path}" "\${s:-0}"`);
            if (entry.expandChildren) {
                lines.push(`find "${entry.path}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | while read -r c; do cs=$(du -sb "$c" 2>/dev/null | cut -f1); printf 'CHILD\\t%s\\t%s\\t%s\\n' "${entry.path}" "$c" "\${cs:-0}"; done`);
            }
        }
        // The 5 heaviest other folders directly under $HOME, excluding already-configured top-level paths.
        lines.push(`du -x -d 1 -B1 "${root.home}" 2>/dev/null | sort -rn | while read -r s p; do printf 'HOMEDIR\\t%s\\t%s\\n' "$p" "$s"; done`);
        scanProc.command = ["sh", "-c", lines.join("\n")];
        scanProc.running = true;
    }

    Process {
        id: scanProc
        stdout: StdioCollector { id: scanOut }
        onExited: code => {
            root.loading = false;
            root.lastUpdated = new Date();
            if (code !== 0)
                return;
            root._parse(scanOut.text);
        }
    }

    function _parse(text: string) {
        const configured = new Set(root._config.map(e => e.path));
        const devices = [];
        const pathSizes = {};      // path -> size (top-level configured entries)
        const childrenByParent = {}; // parent path -> [{path, size}]
        const homeDirs = [];

        for (const line of text.split("\n")) {
            const f = line.split("\t");
            if (f[0] === "DEVICE" && f.length >= 4) {
                devices.push({ target: f[1], used: Number(f[2]) || 0, total: Number(f[3]) || 0 });
            } else if (f[0] === "PATH" && f.length >= 3) {
                pathSizes[f[1]] = Number(f[2]) || 0;
            } else if (f[0] === "CHILD" && f.length >= 4) {
                if (!childrenByParent[f[1]])
                    childrenByParent[f[1]] = [];
                childrenByParent[f[1]].push({ path: f[2], size: Number(f[3]) || 0 });
            } else if (f[0] === "HOMEDIR" && f.length >= 3) {
                if (f[1] !== root.home && !configured.has(f[1]))
                    homeDirs.push({ path: f[1], size: Number(f[2]) || 0 });
            }
        }

        const rows = [];
        for (const entry of root._config) {
            rows.push({ path: entry.path, label: _label(entry.path), size: pathSizes[entry.path] ?? 0, depth: 0, isLast: false });
            if (entry.expandChildren) {
                const kids = (childrenByParent[entry.path] ?? []).sort((a, b) => b.size - a.size);
                kids.forEach((kid, i) => {
                    rows.push({ path: kid.path, label: _label(kid.path), size: kid.size, depth: 1, isLast: i === kids.length - 1 });
                });
            }
        }
        homeDirs.slice(0, 5).forEach(dir => {
            rows.push({ path: dir.path, label: _label(dir.path), size: dir.size, depth: 0, isLast: false });
        });

        root.devices = devices;
        root.treeRows = rows;
    }

    function _label(path: string): string {
        if (path === "/")
            return "/";
        const parts = path.split("/");
        return parts[parts.length - 1];
    }

    Timer {
        interval: 3600000 // 1h
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
