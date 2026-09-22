import QtQuick
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    readonly property bool warnLevel: SystemStats.ramUsage > 60
    readonly property bool critLevel: SystemStats.ramUsage > 80
    readonly property color levelColor: critLevel ? Colors.critical : warnLevel ? Colors.warn : Colors.accent

    icon: Icons.memory
    iconColor: warnLevel ? levelColor : Colors.accent
    textColor: warnLevel ? levelColor : Colors.text
    statusActive: warnLevel
    statusColor: levelColor
    text: Math.round(SystemStats.ramUsage) + "%"
    contentSpacing: Theme.iconTextSpacing
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
