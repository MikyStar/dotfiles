import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    readonly property bool warnLevel: SystemStats.cpuUsage > 60
    readonly property bool critLevel: SystemStats.cpuUsage > 80
    readonly property color levelColor: critLevel ? Colors.critical : warnLevel ? Colors.warn : Colors.accent

    icon: Icons.cpu
    iconColor: warnLevel ? levelColor : Colors.accent
    textColor: warnLevel ? levelColor : Colors.text
    statusActive: warnLevel
    statusColor: levelColor
    text: Math.round(SystemStats.cpuUsage) + "%"
    contentSpacing: Theme.iconTextSpacing
    reserveText: "100%"

    PopupMenu {
        anchorItem: root
        open: root.hovered
        grabFocus: false

        MenuHeader { text: "CPU" }
        InfoRow { label: "Usage"; value: SystemStats.cpuUsage.toFixed(1) + "%" }
        InfoRow { label: "Load (1m)"; value: SystemStats.load1.toFixed(2) }

        // Two columns once there are many cores, to keep the menu short.
        GridLayout {
            Layout.fillWidth: true
            columns: SystemStats.coreUsage.length > 8 ? 2 : 1
            columnSpacing: 32
            rowSpacing: Theme.popupSpacing

            Repeater {
                // Count only, so the rows aren't rebuilt on every sample.
                model: SystemStats.coreUsage.length

                InfoRow {
                    required property int index
                    Layout.fillWidth: true
                    label: `Core ${index}`
                    value: Math.round(SystemStats.coreUsage[index] ?? 0) + "%"
                }
            }
        }
    }
}
