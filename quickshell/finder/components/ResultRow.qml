import QtQuick
import QtQuick.Layouts
import qs.style
import qs.finder

// One result row: icon, label + dim sublabel, and (paths only) hover-revealed terminal/folder actions
// at the far right, matching the disk widget's tree rows.
Rectangle {
    id: root

    required property var modelData
    required property int index

    readonly property bool selected: FinderService.selectedIndex === index
    // Union of the row area and the icon areas -- see the same comment in widgets/disk/Disk.qml. The
    // icon MouseAreas below occlude `area` for hover once the pointer is over/between them, which used
    // to flip `hovered` false and hide the icons out from under the pointer in a flicker loop.
    readonly property bool hovered: area.containsMouse || termArea.containsMouse || folderArea.containsMouse
    readonly property bool isPath: modelData.kind === "path"

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
            // Apps carry an iconSource (image); paths carry a Nerd Font glyph in `icon` (folder icon, or
            // a file-type one -- see FinderService._pathIcon); scripts have neither, so fall to terminal.
            visible: root.modelData.iconSource === undefined || root.modelData.iconSource === ""
            text: root.modelData.icon ?? Icons.terminal
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
                // Always shown when there's a sublabel to show -- hiding it on hover (as before) collapsed
                // this row's content and shifted the layout around under the pointer.
                visible: root.modelData.sublabel !== ""
                Layout.fillWidth: true
                text: root.modelData.sublabel
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideMiddle
            }
        }

        RowLayout {
            // `visible` stays keyed only to isPath (not to hover) so this row's width is constant
            // regardless of hover -- toggling `visible` on hover made the label column beside it
            // resize under the cursor the instant it appeared, which could nudge the pointer off the
            // row (or onto/off an icon) and immediately flip `hovered` back, glitching in a loop.
            // Opacity (plus `enabled`, so the hidden icons aren't clickable/hoverable) reveals the
            // same reserved space instead, so nothing ever reflows while hovering.
            visible: root.isPath
            opacity: root.hovered ? 1 : 0
            enabled: root.hovered
            spacing: 8

            Behavior on opacity { NumberAnimation { duration: Theme.animFast } }

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
                    onClicked: FinderService.openTerminalFor(root.modelData.path, root.modelData.isDir === true)
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
