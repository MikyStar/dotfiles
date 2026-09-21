import QtQuick
import QtQuick.Layouts
import qs.style

// Clickable row (icon + label) used inside popup menus.
Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property color iconColor: Colors.accent

    signal clicked()

    Layout.fillWidth: true
    implicitWidth: content.implicitWidth + 24
    implicitHeight: 34
    radius: 10
    color: area.containsMouse ? Colors.itemHover : Colors.item

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    RowLayout {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        spacing: 10

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.iconColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
        }
        Text {
            text: root.text
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
