pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi state through NetworkManager's nmcli: radio, active connection, nearby networks, connecting.
Singleton {
    id: root

    property bool enabled: true
    property string ssid: ""
    property int signal: 0
    property var networks: []       // [{ ssid, signal, secured, active, known }], active first then by signal
    property bool busy: false       // a connect attempt is running
    property string error: ""
    readonly property bool connected: ssid !== ""

    property var _known: []

    function refresh(rescan: bool) {
        radioProc.running = true;
        knownProc.running = true;
        if (rescan) {
            rescanProc.running = true;
            listTimer.restart();
        } else {
            listProc.running = true;
        }
    }

    function setEnabled(on: bool) {
        radioSet.command = ["nmcli", "radio", "wifi", on ? "on" : "off"];
        radioSet.running = true;
    }

    function connect(name: string, password: string) {
        error = "";
        busy = true;
        connectProc.ssid = name;
        connectProc.hadPassword = password !== "";
        connectProc.command = ["nmcli", "dev", "wifi", "connect", name].concat(password !== "" ? ["password", password] : []);
        connectProc.running = true;
    }

    function disconnect(name: string) {
        downProc.command = ["nmcli", "connection", "down", "id", name];
        downProc.running = true;
    }

    // nmcli -t separates fields with ":" and escapes literal colons and backslashes with a backslash.
    function _fields(line: string): var {
        const fields = [""];
        for (let i = 0; i < line.length; i++) {
            if (line[i] === "\\" && i + 1 < line.length)
                fields[fields.length - 1] += line[++i];
            else if (line[i] === ":")
                fields.push("");
            else
                fields[fields.length - 1] += line[i];
        }
        return fields;
    }

    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.enabled = text.trim() === "enabled"
        }
    }

    Process {
        id: radioSet
        onRunningChanged: if (!running) root.refresh(true)
    }

    Process {
        id: knownProc
        command: ["nmcli", "-t", "-f", "name,type", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: root._known = text.split("\n").map(root._fields)
                .filter(f => f[1] === "802-11-wireless").map(f => f[0])
        }
    }

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "rescan"]
    }

    // Give the rescan a moment to finish before reading the results.
    Timer {
        id: listTimer
        interval: 2500
        onTriggered: listProc.running = true
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "active,signal,security,ssid", "dev", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            onStreamFinished: {
                const best = {};
                for (const line of text.split("\n")) {
                    const [active, signal, security, name] = root._fields(line);
                    if (!name)
                        continue;
                    const entry = {
                        ssid: name,
                        signal: parseInt(signal) || 0,
                        secured: security !== "",
                        active: active === "yes",
                        known: root._known.includes(name)
                    };
                    const prev = best[name];
                    if (!prev || entry.active || (!prev.active && entry.signal > prev.signal))
                        best[name] = entry;
                }
                const list = Object.values(best).sort((a, b) => b.active - a.active || b.signal - a.signal);
                const active = list.find(n => n.active);
                root.networks = list;
                root.ssid = active?.ssid ?? "";
                root.signal = active?.signal ?? 0;
            }
        }
    }

    Process {
        id: connectProc
        property string ssid: ""
        property bool hadPassword: false
        stderr: StdioCollector {
            id: connectErr
        }
        onExited: code => {
            root.busy = false;
            if (code !== 0) {
                root.error = connectErr.text.trim().split("\n")[0] || "Connection failed";
                // A wrong password leaves a broken saved profile behind; drop it so the next try prompts again.
                if (hadPassword) {
                    forgetProc.command = ["nmcli", "connection", "delete", "id", ssid];
                    forgetProc.running = true;
                }
            }
            root.refresh(false);
        }
    }

    Process {
        id: forgetProc
    }

    Process {
        id: downProc
        onRunningChanged: if (!running) root.refresh(false)
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh(false)
    }
}
