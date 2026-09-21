import QtQuick
import Quickshell.Services.UPower
import qs.style
import qs.bar.components
import qs.bar.services

// Hovering shows the time until full (charging) or until empty (discharging).
Pill {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property real percent: device.percentage * 100
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    readonly property real seconds: charging ? device.timeToFull : device.timeToEmpty

    visible: device.ready && device.isPresent
    icon: Icons.battery(percent, charging)
    iconColor: charging ? Colors.good : percent <= 15 ? Colors.critical : percent <= 30 ? Colors.warn : Colors.accent
    text: Math.round(percent) + "%"

    PopupMenu {
        anchorItem: root
        open: root.hovered
        grabFocus: false

        MenuHeader { text: root.charging ? "Charging" : "On battery" }
        InfoRow {
            label: root.charging ? "Time to full" : "Time remaining"
            value: root.seconds > 0 ? Format.duration(root.seconds) : "Calculating…"
        }
    }
}
