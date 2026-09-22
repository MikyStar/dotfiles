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
    // On mains power. A full battery reports "fully charged" rather than "charging", but should still show the bolt.
    readonly property bool pluggedIn: !UPower.onBattery
    readonly property bool low: !pluggedIn && percent < 20
    readonly property bool warnLevel: !pluggedIn && percent < 30
    readonly property color levelColor: low ? Colors.critical : warnLevel ? Colors.warn : Colors.accent
    readonly property real seconds: charging ? device.timeToFull : device.timeToEmpty

    visible: device.ready && device.isPresent
    icon: Icons.battery(percent, pluggedIn)
    iconColor: warnLevel ? levelColor : Colors.accent
    textColor: warnLevel ? levelColor : Colors.text
    statusActive: warnLevel
    statusColor: levelColor
    text: Math.round(percent) + "%"
    contentSpacing: Theme.iconTextSpacing
    reserveText: "100%"

    PopupMenu {
        anchorItem: root
        open: root.hovered
        grabFocus: false

        MenuHeader { text: root.charging ? "Charging" : root.pluggedIn ? "Plugged in" : "On battery" }
        InfoRow {
            visible: !root.pluggedIn || root.charging
            label: root.charging ? "Time to full" : "Time remaining"
            value: root.seconds > 0 ? Format.duration(root.seconds) : "Calculating…"
        }
    }
}
