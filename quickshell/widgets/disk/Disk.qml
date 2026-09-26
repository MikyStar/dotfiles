import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.services
import qs.widgets.components
import qs.widgets.disk

Card {
    id: root

    CardHeader { title: "Disk space" }

    // Centered spinner in place of the content while the du/df scan is still running.
    Item {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        visible: DiskService.loading
        implicitHeight: 60

        Text {
            anchors.centerIn: parent
            text: Icons.refresh
            color: Colors.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize + 10

            RotationAnimation on rotation {
                running: DiskService.loading
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 900
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: !DiskService.loading
        spacing: Theme.popupSpacing

        // One row per real device/mountpoint: used / total.
        Repeater {
            model: DiskService.devices

            RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: modelData.target
                    color: Colors.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
                Item { Layout.fillWidth: true }
                Text {
                    readonly property real usage: modelData.total > 0 ? modelData.used / modelData.total : 0
                    readonly property bool warnLevel: usage > 0.6
                    readonly property bool critLevel: usage > 0.8

                    text: `${Format.bytes(modelData.used)} / ${Format.bytes(modelData.total)}`
                    color: critLevel ? Colors.critical : warnLevel ? Colors.warn : Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

        // Configured paths as a `tree`-style listing, topped up with the heaviest other $HOME folders.
        Repeater {
            model: DiskService.treeRows

            Item {
                id: row
                required property var modelData
                Layout.fillWidth: true
                implicitHeight: content.implicitHeight

                // Union of the row area and the icon areas -- the icon MouseAreas sit on top of (occlude)
                // rowArea so they get clicks first, but that also means rowArea stops receiving hover the
                // moment the pointer crosses onto/between them, which flipped `hovered` false and hid the
                // icons out from under the pointer (a flicker loop, since hiding them un-occludes rowArea,
                // flipping it back true, reshowing them, ...). Combining all three keeps it stable.
                readonly property bool hovered: rowArea.containsMouse || termArea.containsMouse || folderArea.containsMouse

                // Below the row so interactive children (terminal/folder icons) receive clicks first.
                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                RowLayout {
                    id: content
                    anchors.fill: parent
                    spacing: 4

                    Text {
                        visible: row.modelData.depth > 0
                        text: row.modelData.isLast ? "└── " : "├── "
                        color: Colors.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                    Text {
                        text: row.modelData.label
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.underline: row.hovered
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        visible: !row.hovered
                        text: Format.bytes(row.modelData.size)
                        color: Colors.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                    }
                    RowLayout {
                        visible: row.hovered
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
                                onClicked: DiskService.openTerminal(row.modelData.path)
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
                                onClicked: DiskService.openFiles(row.modelData.path)
                            }
                        }
                    }
                }
            }
        }
    }
}
