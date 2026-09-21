import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.style
import qs.bar.sections

// One bar per screen: left / center / right sections over a transparent, full-width layer surface.
Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData

        screen: modelData
        color: "transparent"
        implicitHeight: Theme.barHeight
        // Reserve only the top margin and the pills: Hyprland's own gap then makes up the space below the bar.
        exclusiveZone: Theme.barMargin + Theme.pillHeight
        WlrLayershell.namespace: "qs-bar"

        anchors { top: true; left: true; right: true }

        Item {
            id: content
            anchors.fill: parent
            anchors.margins: Theme.barMargin

            // The center zone stays on the screen's middle unless the left zone is in the way. The right zone
            // only gets the room left of it (minus `zoneGap`); when its modules need more it scrolls.
            readonly property real centerX: Math.max((width - center.width) / 2, left.width + Theme.zoneGap)

            LeftSection {
                id: left
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
            CenterSection {
                id: center
                x: content.centerX
                anchors.verticalCenter: parent.verticalCenter
            }
            RightSection {
                id: right
                maxWidth: content.width - content.centerX - center.width - Theme.zoneGap
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
