import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import qs.style

// Vertically scrollable column that is always `maxRows` rows (of `rowHeight`) tall, so the popup never
// changes size; rows beyond that are reached by scrolling. The wheel scrolls with easing and a thin
// overlay scrollbar fades in while scrolling, like macOS.
Flickable {
    id: root

    property int maxRows: 5
    property real rowHeight: 34
    property real spacing: 6

    // Keyboard-driven scrolloff: when set (itemCount > 0), changing currentIndex keeps at least
    // `lookAhead` rows visible beyond it in the direction of travel, scrolling just enough to restore
    // that margin -- like vim's 'scrolloff'. Left at -1/0 (the defaults), nothing auto-scrolls and callers
    // drive contentY purely by wheel/drag, as before.
    property int currentIndex: -1
    property int itemCount: 0
    property int lookAhead: 0

    default property alias content: column.data

    // Scrollbar visibility: set on every scroll, cleared shortly after it stops.
    property bool scrolling: false
    property real _target: 0

    function _scrollTo(y: real) {
        _target = Math.max(0, Math.min(contentHeight - height, y));
        glide.stop();
        glide.from = contentY;
        glide.to = _target;
        glide.start();
    }

    function _ensureVisible() {
        if (currentIndex < 0 || itemCount === 0)
            return;
        const step = rowHeight + spacing;
        const lo = Math.max(0, currentIndex - lookAhead);
        const hi = Math.min(itemCount - 1, currentIndex + lookAhead);
        const topNeeded = lo * step;
        const bottomNeeded = hi * step + rowHeight;
        const base = glide.running ? _target : contentY;
        if (topNeeded < base)
            _scrollTo(topNeeded);
        else if (bottomNeeded > base + height)
            _scrollTo(bottomNeeded - height);
    }

    onCurrentIndexChanged: _ensureVisible()
    onItemCountChanged: _ensureVisible()

    Layout.fillWidth: true
    implicitWidth: column.implicitWidth
    implicitHeight: maxRows * rowHeight + (maxRows - 1) * spacing
    contentWidth: width
    contentHeight: column.implicitHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.VerticalFlick

    onContentYChanged: {
        scrolling = true;
        hideTimer.restart();
    }

    // Wheel notches glide to their target; touchpads (pixel deltas) already arrive smooth and move it directly.
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (event.pixelDelta.y !== 0) {
                glide.stop();
                root.contentY = Math.max(0, Math.min(root.contentHeight - root.height, root.contentY - event.pixelDelta.y));
            } else {
                // Notches accumulate on the pending target so fast wheeling keeps building up.
                const base = glide.running ? root._target : root.contentY;
                root._scrollTo(base - event.angleDelta.y * 0.6);
            }
        }
    }

    NumberAnimation {
        id: glide
        target: root
        property: "contentY"
        duration: 220
        easing.type: Easing.OutCubic
    }

    Timer {
        id: hideTimer
        interval: 700
        onTriggered: root.scrolling = false
    }

    ScrollBar.vertical: ScrollBar {
        id: bar
        // Overlaid on the right edge, inside the rows' own padding, so it never takes layout space.
        policy: root.contentHeight > root.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        interactive: true
        implicitWidth: 6
        padding: 1
        rightPadding: 2

        contentItem: Rectangle {
            implicitWidth: 4
            radius: width / 2
            color: Colors.scrollbar
            opacity: root.scrolling || bar.pressed || bar.hovered ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: 250 } }
        }
        background: Item {}
    }

    ColumnLayout {
        id: column
        width: root.width
        spacing: root.spacing
    }
}
