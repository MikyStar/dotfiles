import QtQuick
import QtQuick.Layouts
import qs.style

// Clickable row (icon + label) used inside popup menus.
Rectangle {
    id: root

    property string icon: ""
    property string iconSource: ""    // image icon (e.g. an application icon), used instead of `icon` when set
    property string text: ""
    property string detail: ""        // right-aligned secondary text
    property color iconColor: Colors.accent
    property bool highlighted: false  // e.g. the connected item

    signal clicked()

    Layout.fillWidth: true
    implicitWidth: content.implicitWidth + 24
    implicitHeight: 34
    radius: 10
    color: area.containsMouse || highlighted ? Colors.itemHover : Colors.item

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    RowLayout {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Image {
            visible: root.iconSource !== ""
            source: root.iconSource
            sourceSize: Qt.size(Theme.iconSize + 4, Theme.iconSize + 4)
            Layout.preferredWidth: Theme.iconSize + 4
            Layout.preferredHeight: Theme.iconSize + 4
        }
        Text {
            visible: root.icon !== "" && root.iconSource === ""
            text: root.icon
            color: root.iconColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
        }
        Text {
            Layout.fillWidth: true
            text: root.text
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            elide: Text.ElideRight
        }
        Text {
            visible: root.detail !== ""
            text: root.detail
            color: Colors.textDim
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
