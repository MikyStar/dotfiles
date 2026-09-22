import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.style
import qs.bar.components
import qs.bar.services

// Volume and brightness in one pill. Left click: sliders + mute button. Right click: mute.
// Scrolling over either value changes it by 5%. The brightness half is hidden on machines without a backlight.
Pill {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real level: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    function setLevel(value: real) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !muted;
    }

    active: menu.open
    contentSpacing: Theme.sectionSpacing + 4
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
            toggleMute();
        else
            menu.toggle();
    }

    PwObjectTracker { objects: [root.sink] }

    IconValue {
        icon: Icons.volume(root.level, root.muted)
        iconColor: root.muted ? Colors.textDim : Colors.accent
        text: (root.muted ? 0 : Math.round(root.level * 100)) + "%"
        onScrolled: delta => root.setLevel(root.level + (delta > 0 ? 0.05 : -0.05))
    }

    IconValue {
        visible: Backlight.available
        icon: Icons.brightness(Backlight.level)
        text: Math.round(Backlight.level * 100) + "%"
        onScrolled: delta => Backlight.set(Backlight.level + (delta > 0 ? 0.05 : -0.05))
    }

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader { text: root.sink?.description ?? "No output" }
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.popupSpacing

            Text {
                text: Icons.volumeOff
                // Opposite of the slider track: bright when the track is dimmed (muted), dim when it's active.
                color: root.muted ? Colors.textDim : Colors.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.iconSize

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleMute()
                }
            }
            SliderBar {
                Layout.fillWidth: true
                value: root.level
                disabled: root.muted
                onMoved: value => root.setLevel(value)
            }
        }

        MenuHeader {
            visible: Backlight.available
            text: "Brightness"
        }
        SliderBar {
            visible: Backlight.available
            Layout.fillWidth: true
            value: Backlight.level
            onMoved: value => Backlight.set(value)
        }
    }
}
