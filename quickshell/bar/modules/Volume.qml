import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.style
import qs.bar.components

// Left click: slider. Right click: mute. Scroll: +/- 5%.
Pill {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real level: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    function setLevel(value: real) {
        if (sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    icon: Icons.volume(level, muted)
    iconColor: muted ? Colors.textDim : Colors.accent
    text: Math.round(level * 100) + "%"
    reserveText: "100%"
    active: menu.open
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton && sink?.audio)
            sink.audio.muted = !muted;
        else
            menu.toggle();
    }
    wheelEnabled: true
    onScrolled: delta => setLevel(level + (delta > 0 ? 0.05 : -0.05))

    PwObjectTracker { objects: [root.sink] }

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader { text: root.sink?.description ?? "No output" }
        SliderBar {
            Layout.fillWidth: true
            value: root.level
            onMoved: value => root.setLevel(value)
        }
        MenuButton {
            icon: Icons.volumeOff
            text: root.muted ? "Unmute" : "Mute"
            onClicked: if (root.sink?.audio) root.sink.audio.muted = !root.muted
        }
    }
}
