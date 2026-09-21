pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU / RAM / temperature / network throughput, polled from /proc and /sys once per second.
Singleton {
    id: root

    property real cpuUsage: 0      // %
    property var coreUsage: []     // % per core
    property real load1: 0
    property real ramUsage: 0      // %
    property real ramUsedGb: 0
    property real ramTotalGb: 0
    property real cpuTemp: 0       // °C
    property real rxSpeed: 0       // bytes/s
    property real txSpeed: 0       // bytes/s

    property var _lastCpu: null
    property var _lastCores: []
    property var _lastNet: null

    function _updateCpu() {
        statFile.reload();
        // Lines: "cpu  ..." (aggregate) then "cpu0 ...", "cpu1 ...", one per core.
        const times = line => {
            const f = line.trim().split(/\s+/).slice(1).map(Number);
            return { idle: f[3] + f[4], total: f.reduce((a, b) => a + b, 0) };
        };
        const usage = (now, last) => last && now.total > last.total
            ? 100 * (1 - (now.idle - last.idle) / (now.total - last.total)) : 0;

        const lines = statFile.text().split("\n");
        const all = times(lines[0]);
        cpuUsage = _lastCpu ? usage(all, _lastCpu) : cpuUsage;
        _lastCpu = all;

        const cores = lines.filter(l => /^cpu\d/.test(l)).map(times);
        coreUsage = cores.map((c, i) => usage(c, _lastCores[i]));
        _lastCores = cores;

        loadFile.reload();
        load1 = parseFloat(loadFile.text().split(" ")[0]) || 0;
    }

    function _updateMemory() {
        memFile.reload();
        const text = memFile.text();
        const kb = key => parseInt(text.match(new RegExp(`${key}:\\s+(\\d+)`))?.[1] ?? "0");
        const total = kb("MemTotal");
        const used = total - kb("MemAvailable");
        ramTotalGb = total / 1048576;
        ramUsedGb = used / 1048576;
        ramUsage = total > 0 ? 100 * used / total : 0;
    }

    function _updateNetwork() {
        netFile.reload();
        let rx = 0, tx = 0;
        for (const line of netFile.text().split("\n").slice(2)) {
            const [name, data] = line.split(":");
            if (!data || !/^\s*(wl|en|eth)/.test(name))
                continue;
            const f = data.trim().split(/\s+/);
            rx += Number(f[0]);
            tx += Number(f[8]);
        }
        const now = Date.now();
        if (_lastNet) {
            const dt = (now - _lastNet.time) / 1000;
            rxSpeed = Math.max(0, (rx - _lastNet.rx) / dt);
            txSpeed = Math.max(0, (tx - _lastNet.tx) / dt);
        }
        _lastNet = { rx, tx, time: now };
    }

    FileView { id: statFile; path: "/proc/stat" }
    FileView { id: loadFile; path: "/proc/loadavg" }
    FileView { id: memFile; path: "/proc/meminfo" }
    FileView { id: netFile; path: "/proc/net/dev" }

    // Picks the CPU package sensor, falling back to thermal_zone0.
    Process {
        id: tempProc
        command: ["sh", "-c", `
            for z in /sys/class/thermal/thermal_zone*; do
                case "$(cat $z/type)" in
                    x86_pkg_temp|k10temp|coretemp|cpu*) cat $z/temp; exit;;
                esac
            done
            cat /sys/class/thermal/thermal_zone0/temp`]
        stdout: StdioCollector {
            onStreamFinished: root.cpuTemp = (parseInt(text) || 0) / 1000
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._updateCpu();
            root._updateMemory();
            root._updateNetwork();
            tempProc.running = true;
        }
    }
}
