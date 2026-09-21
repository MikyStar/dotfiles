import QtQuick
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    icon: Icons.memory
    iconColor: SystemStats.ramUsage > 90 ? Colors.critical : Colors.accent
    text: Math.round(SystemStats.ramUsage) + "%"
    active: menu.open
    onClicked: menu.toggle()

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader { text: "Memory" }
        InfoRow { label: "Used"; value: SystemStats.ramUsedGb.toFixed(1) + " GB" }
        InfoRow { label: "Total"; value: SystemStats.ramTotalGb.toFixed(1) + " GB" }
    }
}
