import QtQuick
import QtQuick.Layouts
import qs.style

// Title row shared by the widget cards: bold title, optional dim trailing text (e.g. "35 min ago"),
// optional refresh icon button that spins while `refreshing` is true.
RowLayout {
    id: root

    property string title: ""
    property string trailing: ""
    property bool showRefresh: false
    property bool refreshing: false

    signal refreshClicked()

    Layout.fillWidth: true
    spacing: 8

    Text {
        text: root.title
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 1
        font.bold: true
    }

    Item { Layout.fillWidth: true }

    Text {
        visible: root.trailing !== ""
        text: root.trailing
        color: Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
    }

    Text {
        visible: root.showRefresh
        text: Icons.refresh
        color: refreshArea.containsMouse ? Colors.text : Colors.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize - 1

        RotationAnimation on rotation {
            running: root.refreshing
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 900
        }

        MouseArea {
            id: refreshArea
            anchors.fill: parent
            anchors.margins: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.refreshClicked()
        }
    }
}
