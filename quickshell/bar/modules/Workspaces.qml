import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.style
import qs.bar.components

Pill {
    id: root

    padding: 4
    contentSpacing: 2

    readonly property var sortedWorkspaces: Hyprland.workspaces.values
        .filter(w => w.id > 0)
        .sort((a, b) => a.id - b.id)

    // The workspace/window lists and their IPC data are only re-read on some events, so a window
    // opening, closing or moving would leave the icons stale. Re-read them on every such event.
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (/^(openwindow|closewindow|movewindow|movewindowv2|windowtitle|workspace|createworkspace|destroyworkspace)/.test(event.name)) {
                Hyprland.refreshToplevels();
                Hyprland.refreshWorkspaces();
            }
        }
    }

    Repeater {
        model: root.sortedWorkspaces

        WorkspaceDot {
            required property var modelData
            required property int index
            workspace: modelData
            isFirst: index === 0
            isLast: index === root.sortedWorkspaces.length - 1
        }
    }
}
