import QtQuick
import qs.style

// Horizontal 0..1 slider. Emits moved() while dragging; the owner updates `value`.
Item {
    id: root

    property real value: 0
    signal moved(real value)

    implicitWidth: 220
    implicitHeight: 22

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
        cursorShape: Qt.PointingHandCursor
        function update(mouse) {
            root.moved(Math.max(0, Math.min(1, mouse.x / width)));
        }
        onPressed: mouse => update(mouse)
        onPositionChanged: mouse => { if (pressed) update(mouse); }
    }
}
