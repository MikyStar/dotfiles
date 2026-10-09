import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.style

// Lightweight hover tooltip anchored just below `anchorItem`'s actual on-screen position. Unlike
// PopupMenu (which always drops from a fixed point under the bar -- fine for bar-triggered dropdowns),
// this tracks the anchor wherever it is, which desktop widgets (e.g. the left-hand widget column) need
// since they don't live in the bar strip. No focus grab: there's nothing here to click.
//
// The caller drives `anchorHovered` (its own MouseArea.containsMouse), not `open`/`visible` directly.
// This is a separate Wayland surface from the anchor's window, so the instant the real cursor crosses
// onto it, the anchor's own MouseArea sees the pointer leave and reports containsMouse: false -- if that
// alone closed the tooltip, hiding it would yank the surface out from under the cursor and the anchor
// could immediately see a re-enter, flickering open/closed in a tight loop. Tracking hover over the
// tooltip's own surface too, and only closing after a short delay with neither side hovered, bridges
// that gap so moving the pointer from the anchor into the tooltip reads as one continuous hover.
PanelWindow {
    id: root

    required property Item anchorItem
    property bool anchorHovered: false
    readonly property bool hovered: surfaceArea.containsMouse
    property bool open: false

    default property alias content: body.data

    property real _x: 0
    property real _y: 0

    readonly property bool wantOpen: anchorHovered || hovered

    onWantOpenChanged: {
        if (wantOpen) {
            closeTimer.stop();
            if (!open)
                _reposition();
            open = true;
        } else {
            closeTimer.restart();
        }
    }

    function _reposition() {
        const pos = anchorItem.mapToItem(null, 0, anchorItem.height);
        _x = pos.x;
        _y = pos.y + 6;
    }

    Timer {
        id: closeTimer
        interval: 150
        onTriggered: root.open = false
    }

    screen: anchorItem.QsWindow.window?.screen ?? null
    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qs-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; left: true }
    margins.top: Math.max(0, Math.min(_y, (screen?.height ?? 0) - height))
    margins.left: Math.max(0, Math.min(_x, (screen?.width ?? 0) - width))

    implicitWidth: surface.implicitWidth
    implicitHeight: surface.implicitHeight

    Rectangle {
        id: surface
        anchors.fill: parent
        implicitWidth: body.implicitWidth + Theme.popupPadding * 2
        implicitHeight: body.implicitHeight + Theme.popupPadding * 2
        radius: Theme.popupRadius
        color: Colors.panel
        border.color: Colors.panelBorder
        border.width: 1

        MouseArea {
            id: surfaceArea
            anchors.fill: parent
            hoverEnabled: true
        }

        ColumnLayout {
            id: body
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.popupSpacing
        }
    }
}
