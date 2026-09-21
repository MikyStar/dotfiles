import QtQuick
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    icon: Icons.memory
    iconColor: SystemStats.ramUsage > 90 ? Colors.critical : Colors.accent
    text: Math.round(SystemStats.ramUsage) + "%"
    reserveText: "100%"

    PopupMenu {
        anchorItem: root
        open: root.hovered
        grabFocus: false

        MenuHeader { text: "Memory" }
        InfoRow { label: "Used"; value: SystemStats.ramUsedGb.toFixed(1) + " GB" }
        InfoRow { label: "Total"; value: SystemStats.ramTotalGb.toFixed(1) + " GB" }
    }
}
