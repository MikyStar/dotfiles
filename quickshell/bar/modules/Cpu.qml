import QtQuick
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    icon: Icons.cpu
    iconColor: SystemStats.cpuUsage > 90 ? Colors.critical : Colors.accent
    text: Math.round(SystemStats.cpuUsage) + "%"
    active: menu.open
    onClicked: menu.toggle()

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader { text: "CPU" }
        InfoRow { label: "Usage"; value: SystemStats.cpuUsage.toFixed(1) + "%" }
        InfoRow { label: "Load (1m)"; value: SystemStats.load1.toFixed(2) }
    }
}
