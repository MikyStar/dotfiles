import QtQuick
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    readonly property bool warnLevel: SystemStats.cpuTemp > 70
    readonly property bool critLevel: SystemStats.cpuTemp > 85

    icon: Icons.thermometer
    iconColor: critLevel ? Colors.critical : warnLevel ? Colors.warn : Colors.accent
    text: Math.round(SystemStats.cpuTemp) + "°C"
    contentSpacing: Theme.iconTextSpacing
    reserveText: "100°C"

    PopupMenu {
        anchorItem: root
        open: root.hovered
        grabFocus: false

        MenuHeader { text: "CPU temperature" }
        InfoRow { label: "Current"; value: SystemStats.cpuTemp.toFixed(1) + "°C" }
    }
}
