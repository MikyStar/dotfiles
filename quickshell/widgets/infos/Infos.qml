import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.services
import qs.bar.components
import qs.widgets.components
import qs.widgets.infos

Card {
    id: root

    CardHeader {
        title: "Infos"
        trailing: Format.timeAgo(InfosService.lastUpdated)
        showRefresh: true
        refreshing: InfosService.loading || InfosService.checkingUpdates || InfosService.gitChecking
        onRefreshClicked: InfosService.refresh()
    }

    InfoRow {
        label: "Last switch"
        value: Format.timeAgo(InfosService.lastGenerationDate)
    }
    InfoRow {
        label: "Generations stored"
        value: String(InfosService.generationCount)
    }

    RowLayout {
        visible: InfosService.gitOk
        Layout.fillWidth: true
        spacing: 24

        Text {
            text: "Git status"
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Item { Layout.fillWidth: true }
        RowLayout {
            spacing: 6

            Text {
                visible: InfosService.gitDirtyCount === 0
                text: Icons.check
                color: Colors.good
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }
            Text {
                text: InfosService.gitDirtyCount === 0 ? "updated" : `${InfosService.gitDirtyCount} dirty files`
                color: InfosService.gitDirtyCount === 0 ? Colors.good : Colors.warn
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            Layout.fillWidth: true
            text: "Updates available"
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        Text {
            id: updatesValue
            text: InfosService.checkingUpdates
                ? "checking…"
                : (InfosService.outdatedInputs === 0
                    ? "up to date"
                    : `${InfosService.outdatedInputs} of ${InfosService.totalInputs} inputs`)
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize

            MouseArea {
                id: updatesArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
            }

            Tooltip {
                anchorItem: updatesValue
                anchorHovered: updatesArea.containsMouse && InfosService.outdatedNames.length > 0

                Text {
                    text: "Outdated inputs"
                    color: Colors.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                }
                Repeater {
                    model: InfosService.outdatedNames

                    Text {
                        required property var modelData
                        text: modelData
                        color: Colors.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                    }
                }
            }
        }

        Text {
            visible: InfosService.outdatedInputs > 0
            text: Icons.download
            color: updateArea.containsMouse ? Colors.text : Colors.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize - 1

            MouseArea {
                id: updateArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: InfosService.openUpdateTerminal()
            }
        }
    }
}
