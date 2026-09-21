import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import qs.style
import qs.bar.components
import qs.bar.services

// Now-playing pill: title, elapsed-time progress and transport buttons.
// Left click on the pill focuses the window of the player's application, right click stops the player.
// The chevron folds the title and progress away; the transport buttons always remain.
Pill {
    id: root

    readonly property var player: Mpris.players.values.find(p => p.isPlaying)
        ?? Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Paused)
        ?? null
    // Whether the title and progress bar are shown. The title area has a fixed width (longer titles are elided).
    property bool expanded: true
    readonly property string title: player ? (player.trackArtist ? `${player.trackArtist} - ` : "") + player.trackTitle : ""

    // Elapsed seconds. Players rarely push position updates, so between the values they do report
    // the position is extrapolated from the clock while playing.
    property real elapsed: 0
    readonly property real progress: player && player.length > 0 ? Math.min(1, elapsed / player.length) : 0
    property real _anchorPos: 0
    property real _anchorTime: 0
    property real _lastReported: -1

    function sync() {
        if (!player) {
            elapsed = 0;
            return;
        }
        player.positionChanged();   // makes Quickshell re-read the position from the player
        const reported = player.position;
        const now = Date.now();
        if (reported !== _lastReported || !player.isPlaying) {
            _lastReported = reported;
            _anchorPos = reported;
            _anchorTime = now;
        }
        elapsed = player.isPlaying ? _anchorPos + (now - _anchorTime) / 1000 : reported;
    }

    visible: player !== null
    icon: Icons.music
    onPlayerChanged: sync()
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            player.stop();
            return;
        }
        const app = player.desktopEntry || player.identity;
        Hyprland.dispatch(`hl.dsp.focus({ window = "class:(?i)^${app}$" })`);
    }

    Connections {
        target: root.player
        function onPlaybackStateChanged() { root.sync(); }
        function onTrackTitleChanged() { root.sync(); }
    }

    Timer {
        interval: 500
        repeat: true
        running: root.player !== null
        triggeredOnStart: true
        onTriggered: root.sync()
    }

    // Full media name on hover; the pill itself elides it.
    PopupMenu {
        anchorItem: root
        open: root.hovered
        grabFocus: false

        MenuHeader {
            Layout.maximumWidth: 420
            text: root.title
            wrapMode: Text.Wrap
            elide: Text.ElideNone
        }
        InfoRow {
            visible: root.player?.length > 0
            label: root.player?.identity ?? ""
            value: `${Format.duration(root.elapsed)} / ${Format.duration(root.player?.length ?? 0)}`
        }
    }

    Text {
        text: root.expanded ? Icons.chevronLeft : Icons.chevronRight
        color: Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize - 3

        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    ColumnLayout {
        visible: root.expanded
        spacing: 2

        Text {
            Layout.preferredWidth: 200
            text: root.title
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

    RowLayout {
        id: controls
        spacing: Theme.pillSpacing

        Repeater {
            model: [
                { glyph: Icons.previous, action: () => root.player.previous(), enabled: root.player?.canGoPrevious ?? false },
                { glyph: root.player?.isPlaying ? Icons.pause : Icons.play, action: () => root.player.togglePlaying(), enabled: root.player?.canTogglePlaying ?? false },
                { glyph: Icons.next, action: () => root.player.next(), enabled: root.player?.canGoNext ?? false }
            ]

            Text {
                required property var modelData
                text: modelData.glyph
                color: Colors.accent
                opacity: modelData.enabled ? 1 : 0.4
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
}
