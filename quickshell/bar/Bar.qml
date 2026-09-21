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
        WlrLayershell.namespace: "qs-bar"

        anchors { top: true; left: true; right: true }

        Item {
            anchors.fill: parent
            anchors.margins: Theme.barMargin

            LeftSection {
                id: left
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
            // Centered on the screen, but pushed aside rather than overlapping the other sections.
            CenterSection {
                x: Math.max(left.x + left.width + Theme.sectionSpacing,
                            Math.min((parent.width - width) / 2, right.x - width - Theme.sectionSpacing))
                anchors.verticalCenter: parent.verticalCenter
            }
            RightSection {
                id: right
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
