import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.style
import qs.bar.components

// Blinking mic icon shown only while the default input is actively being recorded from (not merely
// unmuted) -- i.e. some app currently has a live link into it. Same fold-away treatment as
// NotificationBell, so it collapses in `compact` mode like the rest of CenterSection.
Item {
    id: root

    property bool compact: false
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool muted: source?.audio?.muted ?? false
    readonly property bool recording: source !== null && !muted
        && Pipewire.linkGroups.values.some(g => g.source === source && g.state === PwLinkState.Active)
    readonly property bool hasContent: recording
    readonly property bool collapsed: compact || !hasContent

    enabled: !collapsed
    opacity: collapsed ? 0 : 1
    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight
    Layout.preferredWidth: collapsed ? 0 : implicitWidth

    Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }

    PwObjectTracker { objects: root.source ? [root.source] : [] }

    Item {
        anchors.fill: parent
        clip: true

        Pill {
            id: pill
            property color blinkColor: Colors.critical

            icon: Icons.microphone
            iconColor: pill.blinkColor

            SequentialAnimation {
                running: root.recording
                loops: Animation.Infinite

                ColorAnimation { target: pill; property: "blinkColor"; from: Colors.critical; to: Colors.textDim; duration: 500 }
                ColorAnimation { target: pill; property: "blinkColor"; from: Colors.textDim; to: Colors.critical; duration: 500 }
            }

            PopupMenu {
                anchorItem: pill
                open: pill.hovered
                grabFocus: false

                MenuHeader { text: "Microphone" }
                Text {
                    Layout.fillWidth: true
                    text: (root.source?.description ?? "Microphone") + " is recording"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
