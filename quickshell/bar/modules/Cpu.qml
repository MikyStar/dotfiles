import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    icon: Icons.cpu
    iconColor: SystemStats.cpuUsage > 90 ? Colors.critical : Colors.accent
    text: Math.round(SystemStats.cpuUsage) + "%"
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
