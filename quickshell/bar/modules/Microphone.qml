import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.style
import qs.bar.components

// Mic icon shown while some app has a live link into the default input, whether or not it's
// currently muted -- clicking toggles the mute, same as VolumeBrightness's sink mute button, so
// muting from here doesn't strand the user without a way back. Blinks only while actually
// recording (linked and unmuted); sits static once muted. Same fold-away treatment as
// NotificationBell, so it collapses in `compact` mode like the rest of CenterSection.
Item {
    id: root

    property bool compact: false
    readonly property var source: Pipewire.defaultAudioSource
    readonly property bool muted: source?.audio?.muted ?? false
    readonly property var activeLinkGroups: source !== null
        ? Pipewire.linkGroups.values.filter(g => g.source === source && g.state === PwLinkState.Active)
        : []
    readonly property bool recording: !muted && activeLinkGroups.length > 0
    // De-duplicated human-readable names of whatever's linked to the mic, e.g. ["Firefox"].
    readonly property var appNames: [...new Set(activeLinkGroups.map(g =>
        g.target?.properties?.["application.name"] ?? g.target?.description ?? g.target?.name ?? "Unknown app"))]
    readonly property bool hasContent: activeLinkGroups.length > 0
    readonly property bool collapsed: compact || !hasContent

    enabled: !collapsed
    opacity: collapsed ? 0 : 1
    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight
    Layout.preferredWidth: collapsed ? 0 : implicitWidth

    Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }

    // All link groups (and their targets) must be tracked, not just the active ones -- a group's
    // `state` only starts updating once it's tracked, so filtering to `activeLinkGroups` first
    // would mean a group could never be discovered as active in the first place.
    PwObjectTracker {
        objects: root.source
            ? [root.source, ...Pipewire.linkGroups.values, ...Pipewire.linkGroups.values.map(g => g.target).filter(t => t)]
            : []
    }

    Item {
        anchors.fill: parent
        clip: true

        Pill {
            id: pill
            property color blinkColor: Colors.textDim

            icon: root.muted ? Icons.microphoneMuted : Icons.microphone
            iconColor: root.muted ? Colors.textDim : pill.blinkColor

            onClicked: if (root.source) root.source.audio.muted = !root.muted

            SequentialAnimation {
                running: root.recording
                loops: Animation.Infinite

                ColorAnimation { target: pill; property: "blinkColor"; from: Colors.textDim; to: Colors.text; duration: 500 }
                ColorAnimation { target: pill; property: "blinkColor"; from: Colors.text; to: Colors.textDim; duration: 500 }
            }

            PopupMenu {
                anchorItem: pill
                open: pill.hovered
                grabFocus: false

                MenuHeader { text: "Microphone" }
                Text {
                    Layout.fillWidth: true
                    text: (root.muted
                        ? "Access blocked for: "
                        : (root.source?.description ?? "Microphone") + " is recording: ") + root.appNames.join(", ")
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    wrapMode: Text.Wrap
                }
                Text {
                    Layout.fillWidth: true
                    text: root.muted ? "Click to unmute" : "Click to mute and cut off access"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
