import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.style
import qs.bar.components

Pill {
    id: root

    padding: 4
    contentSpacing: 2

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
        model: Hyprland.workspaces.values
            .filter(w => w.id > 0)
            .sort((a, b) => a.id - b.id)

        WorkspaceDot {
            required property var modelData
            workspace: modelData
        }
    }
}
