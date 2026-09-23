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
    // The player's app id, same lookup `onClicked` uses to focus its window.
    readonly property string appId: player ? (player.desktopEntry || player.identity || "") : ""
    // Nerd Font glyph for the app currently playing (see Icons.app), falling back to the generic
    // music note when there's no mapping for it -- or no player at all.
    readonly property string playerIcon: {
        if (appId === "")
            return Icons.music;
        const mapped = Icons.app(appId);
        return mapped === Icons.appUnknown ? Icons.music : mapped;
    }

    // Elapsed seconds. Players rarely push position updates, so between the values they do report
    // the position is extrapolated from the clock while playing.
    property real elapsed: 0
    property real _anchorPos: 0
    property real _anchorTime: 0
    property real _lastReported: -1

    // The track's real duration, remembered once seen. Some sources (e.g. Firefox's media-session
    // bridge for a web tab) only report a duration for part of the track's life; once
    // lengthSupported drops, player.length silently falls back to mirroring the live position
    // instead of going back to "unknown". Caching the last real reading, keyed by track, means the
    // total keeps showing correctly instead of disappearing or duplicating the elapsed time.
    property real _cachedLength: 0
    property int _cachedLengthTrack: -1
    readonly property real length: player && player.uniqueId === _cachedLengthTrack ? _cachedLength : 0
    readonly property bool hasLength: length > 0
    readonly property real progress: hasLength ? Math.min(1, elapsed / length) : 0

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

        if (player.lengthSupported && player.length > 0) {
            _cachedLength = player.length;
            _cachedLengthTrack = player.uniqueId;
        }
    }

    // Whether there's a player to show at all. Exposed as a plain property rather than driving this
    // item's own `visible`, so LeftSection can fold it away with the same animated width/opacity
    // treatment it already uses for compacting -- an instant `visible` snap here would jump the rest
    // of the bar (and the center zone chasing after it) with no transition to follow.
    readonly property bool hasPlayer: player !== null
    icon: playerIcon
    onPlayerChanged: {
        _cachedLength = 0;
        _cachedLengthTrack = -1;
        sync();
    }
    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            player.stop();
            return;
        }
        Hyprland.dispatch(`hl.dsp.focus({ window = "class:(?i)^${root.appId}$" })`);
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
            // Show the row whenever we have a trustworthy elapsed time at all; the total is
            // appended only once a real duration has actually been seen for this track (see
            // root.length).
            visible: root.player?.positionSupported ?? false
            label: root.player?.identity ?? ""
            value: root.hasLength
                ? `${Format.clock(root.elapsed)} / ${Format.clock(root.length)}`
                : Format.clock(root.elapsed)
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
                    // Stay enabled even when the action itself is unavailable: a disabled
                    // MouseArea is click-through in QtQuick, so clicks would otherwise fall to
                    // the pill's own MouseArea underneath and focus the app instead of no-op'ing.
                    cursorShape: parent.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (parent.modelData.enabled)
                            parent.modelData.action();
                    }
                }
            }
        }
    }
}
