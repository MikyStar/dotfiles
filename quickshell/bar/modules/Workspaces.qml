import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.style
import qs.bar.components

Pill {
    id: root

    Repeater {
        model: Hyprland.workspaces.values
            .filter(w => w.id > 0)
            .sort((a, b) => a.id - b.id)

        WorkspaceDot {
            required property var modelData
            workspace: modelData
        }
    }
}
