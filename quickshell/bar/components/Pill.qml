import QtQuick
import QtQuick.Layouts
import qs.style

// Grey translucent pill with an optional icon + text. Extra children are appended to the row.
Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property color iconColor: Colors.accent
    property bool active: false
    readonly property bool hovered: hover.hovered

    default property alias content: row.data

    signal clicked(var mouse)
    signal scrolled(int delta)

    implicitHeight: Theme.pillHeight
    implicitWidth: row.implicitWidth + Theme.pillPadding * 2
    radius: Theme.pillRadius
    color: hovered || active ? Colors.pillHover : Colors.pill
    border.color: Colors.pillBorder
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    WheelHandler {
        onWheel: event => root.scrolled(event.angleDelta.y)
    }

    // Below the row so interactive children (buttons) receive clicks first.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.pillSpacing

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.iconColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
        }

        Text {
            visible: root.text !== ""
            text: root.text
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
