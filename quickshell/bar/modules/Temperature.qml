import QtQuick
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    icon: Icons.thermometer
    iconColor: SystemStats.cpuTemp > 85 ? Colors.critical : SystemStats.cpuTemp > 70 ? Colors.warn : Colors.accent
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
