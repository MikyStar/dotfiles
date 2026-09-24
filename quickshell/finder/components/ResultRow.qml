import QtQuick
import QtQuick.Layouts
import qs.style
import qs.finder

// One result row: icon, label + dim sublabel, and (files only) hover-revealed terminal/folder actions
// at the far right, matching the disk widget's tree rows.
Rectangle {
    id: root

    required property var modelData
    required property int index

    readonly property bool selected: FinderService.selectedIndex === index
    readonly property bool hovered: area.containsMouse
    readonly property bool isFile: modelData.kind === "file"

    Layout.fillWidth: true
    implicitHeight: Theme.finderResultRowHeight
    radius: 10
    color: selected ? Colors.itemHover : (hovered ? Colors.item : "transparent")

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            FinderService.selectedIndex = root.index;
            FinderService.activateSelected();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Image {
            visible: root.modelData.iconSource !== undefined && root.modelData.iconSource !== ""
            source: root.modelData.iconSource ?? ""
            sourceSize: Qt.size(Theme.iconSize + 6, Theme.iconSize + 6)
            Layout.preferredWidth: Theme.iconSize + 6
            Layout.preferredHeight: Theme.iconSize + 6
        }
        Text {
            visible: root.modelData.iconSource === undefined || root.modelData.iconSource === ""
            text: root.isFile ? Icons.folder : Icons.terminal
            color: Colors.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize + 4
            Layout.preferredWidth: Theme.iconSize + 6
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.modelData.label
                color: Colors.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
            }
            Text {
                visible: root.modelData.sublabel !== "" && !(root.isFile && root.hovered)
                Layout.fillWidth: true
                text: root.modelData.sublabel
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideMiddle
            }
        }

        RowLayout {
            visible: root.isFile && root.hovered
            spacing: 8

            Text {
                text: Icons.terminal
                color: termArea.containsMouse ? Colors.text : Colors.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.iconSize - 2

                MouseArea {
                    id: termArea
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: FinderService.openTerminalFor(root.modelData.path)
                }
            }
            Text {
                text: Icons.folder
                color: folderArea.containsMouse ? Colors.text : Colors.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.iconSize - 2

                MouseArea {
                    id: folderArea
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: FinderService.openFilesFor(root.modelData.path)
                }
            }
        }
    }
}
