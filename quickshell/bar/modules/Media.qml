import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.style
import qs.bar.components

// Now-playing pill: title, elapsed-time progress and transport buttons.
// Clicking the pill focuses the window of the player's application.
Pill {
    id: root

    readonly property var player: Mpris.players.values.find(p => p.isPlaying)
        ?? Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Paused)
        ?? null
    readonly property real progress: player && player.length > 0 ? Math.min(1, player.position / player.length) : 0

    visible: player !== null
    icon: Icons.music
    onClicked: {
        const app = player.desktopEntry || player.identity;
        Hyprland.dispatch(`focuswindow class:(?i)^${app}$`);
    }

    // MPRIS doesn't push position updates, so ask for them while playing.
    Timer {
        interval: 1000
        repeat: true
        running: root.player?.isPlaying ?? false
        onTriggered: root.player.positionChanged()
    }

    ColumnLayout {
        spacing: 2

        Text {
            Layout.maximumWidth: 220
            text: root.player ? (root.player.trackArtist ? `${root.player.trackArtist} - ` : "") + root.player.trackTitle : ""
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.fillWidth: true
            height: 3
            radius: 1.5
            color: Colors.itemHover

            Rectangle {
                width: parent.width * root.progress
                height: parent.height
                radius: parent.radius
                color: Colors.accent
            }
        }
    }

    Repeater {
        model: [
            { glyph: Icons.previous, action: () => root.player.previous(), enabled: root.player?.canGoPrevious ?? false },
            { glyph: root.player?.isPlaying ? Icons.pause : Icons.play, action: () => root.player.togglePlaying(), enabled: root.player?.canTogglePlaying ?? false },
            { glyph: Icons.next, action: () => root.player.next(), enabled: root.player?.canGoNext ?? false }
        ]

        Text {
            required property var modelData
            text: modelData.glyph
            color: modelData.enabled ? Colors.text : Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize - 3

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                enabled: parent.modelData.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: parent.modelData.action()
            }
        }
    }
}
