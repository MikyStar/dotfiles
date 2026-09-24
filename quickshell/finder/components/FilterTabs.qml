import QtQuick
import QtQuick.Layouts
import qs.style
import qs.finder

// Horizontal "All / Applications / Files / Scripts" tab strip. Click to select, or Tab cycles
// through them (handled by the search field in Finder.qml).
RowLayout {
    id: root

    spacing: 6

    Repeater {
        model: FinderService.filterNames

        Rectangle {
            id: tab
            required property string modelData
            required property int index

            readonly property bool active: FinderService.filterIndex === index

            implicitHeight: 26
            implicitWidth: label.implicitWidth + 20
            radius: implicitHeight / 2
            color: active ? Colors.itemHover : Colors.item
            border.color: active ? Colors.accent : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Text {
                id: label
                anchors.centerIn: parent
                text: tab.modelData
                color: tab.active ? Colors.white : Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: FinderService.filterIndex = tab.index
            }
        }
    }

    Item { Layout.fillWidth: true }
}
