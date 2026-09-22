import QtQuick
import qs.style

// Horizontal 0..1 slider. Emits moved() while dragging; the owner updates `value`.
Item {
    id: root

    property real value: 0
    // Dims the whole slider and blocks dragging (e.g. the volume slider while muted).
    property bool disabled: false
    signal moved(real value)

    implicitWidth: 220
    implicitHeight: 22
    opacity: disabled ? 0.5 : 1

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Colors.itemHover

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: parent.radius
            color: Colors.accent
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: (root.width - width) * Math.max(0, Math.min(1, root.value))
        width: 16
        height: 16
        radius: 8
        color: Colors.text
    }

    MouseArea {
        anchors.fill: parent
        // Kept enabled (rather than disabled) so the forbidden cursor actually shows up while hovering.
        cursorShape: root.disabled ? Qt.ForbiddenCursor : Qt.PointingHandCursor
        function update(mouse) {
            if (root.disabled)
                return;
            root.moved(Math.max(0, Math.min(1, mouse.x / width)));
        }
        onPressed: mouse => update(mouse)
        onPositionChanged: mouse => { if (pressed) update(mouse); }
    }
}
