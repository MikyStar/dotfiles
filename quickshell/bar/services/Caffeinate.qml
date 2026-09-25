pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Tracks whether $HOME/Scripts/cafeinate.sh is currently running (keeping the machine from sleeping).
// The script itself `exec`s into `systemd-inhibit ... sleep infinity`, so its own argv (and thus its
// path) disappears from the process list the moment it starts -- checked instead via systemd-inhibit's
// own inhibitor list, matching on the `--who=` name the script registers itself under.
Singleton {
    id: root

    readonly property string whoName: "cafeinate.sh"
    property bool running: false

    function stop() {
        killProc.running = true;
    }

    Process {
        id: checkProc
        command: ["systemd-inhibit", "--list", "--no-legend"]
        stdout: StdioCollector {
            onStreamFinished: root.running = text.split("\n").some(line => line.trim().split(/\s+/)[0] === root.whoName)
        }
    }

    Process {
        id: killProc
        command: ["pkill", "-f", `who=${root.whoName}`]
        onRunningChanged: if (!running) checkProc.running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkProc.running = true
    }
}
