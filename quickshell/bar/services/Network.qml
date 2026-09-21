pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Active wifi connection (SSID + signal) via NetworkManager's nmcli.
Singleton {
    id: root

    property string ssid: ""
    property int signal: 0
    readonly property bool connected: ssid !== ""

    Process {
        id: proc
        command: ["nmcli", "-t", "-f", "active,signal,ssid", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                // Lines look like "yes:78:My\:Network"
                const line = text.split("\n").find(l => l.startsWith("yes:"));
                const m = line?.match(/^yes:(\d+):(.*)$/);
                root.signal = m ? parseInt(m[1]) : 0;
                root.ssid = m ? m[2].replace(/\\:/g, ":") : "";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
