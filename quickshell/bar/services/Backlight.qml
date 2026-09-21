pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Backlight level (0..1). Reads sysfs; writes go through logind so no root / video group is needed.
Singleton {
    id: root

    property string device: ""
    property int max: 0
    property int raw: 0
    readonly property bool available: device !== "" && max > 0
    readonly property real level: available ? raw / max : 0

    function set(value: real) {
        if (!available)
            return;
        // Never go to 0: that switches the panel off.
        raw = Math.max(1, Math.min(max, Math.round(value * max)));
        setter.command = ["busctl", "--system", "call", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto",
            "org.freedesktop.login1.Session", "SetBrightness", "ssu", "backlight", device, String(raw)];
        setter.running = true;
    }

    Process {
        id: setter
    }

    // First backlight device and its maximum, e.g. "intel_backlight 187".
    Process {
        running: true
        command: ["sh", "-c", "d=$(ls /sys/class/backlight | head -n1); [ -n \"$d\" ] && echo $d $(cat /sys/class/backlight/$d/max_brightness)"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [name, max] = text.trim().split(" ");
                if (name && parseInt(max) > 0) {
                    root.max = parseInt(max);
                    root.device = name;
                }
            }
        }
    }

    FileView {
        id: file
        path: root.available ? `/sys/class/backlight/${root.device}/brightness` : ""
    }

    // Picks up changes made by keybindings or other tools.
    Timer {
        interval: 1000
        running: root.available
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            file.reload();
            const value = parseInt(file.text());
            if (!isNaN(value) && !setter.running)
                root.raw = value;
        }
    }
}
