import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.services

// Bell with a count badge. Only shown while there are unseen notifications (or its menu is open).
Item {
    id: root

    visible: Notifications.unseen > 0 || menu.open

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    Pill {
        id: pill
        icon: Icons.bell
        active: menu.open
        onClicked: menu.toggle()

        PopupMenu {
            id: menu
            anchorItem: pill
            onOpenChanged: if (open) Notifications.markSeen()

            RowLayout {
                Layout.fillWidth: true
                MenuHeader { text: "Notifications" }
                Text {
                    text: Icons.trash + "  Clear"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.clear()
                    }
                }
            }

            Text {
                visible: Notifications.count === 0
                text: "No notifications"
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            ListView {
                Layout.preferredWidth: 340
                Layout.preferredHeight: Math.min(contentHeight, 420)
                clip: true
                spacing: 6
                model: Notifications.model

                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    implicitHeight: card.implicitHeight + 20
                    radius: 10
                    color: Colors.item

                    ColumnLayout {
                        id: card
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: modelData.appName
                                color: Colors.textDim
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                elide: Text.ElideRight
                            }
                            Text {
                                text: Icons.close
                                color: Colors.textDim
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.dismiss()
                                }
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary
                            color: Colors.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            wrapMode: Text.Wrap
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            text: modelData.body
                            color: Colors.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        visible: Notifications.unseen > 0
        anchors.top: pill.top
        anchors.right: pill.right
        anchors.topMargin: -2
        anchors.rightMargin: -2
        width: Math.max(16, badgeText.implicitWidth + 8)
        height: 16
        radius: 8
        color: Colors.critical

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: Notifications.unseen
            color: "#101018"
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.bold: true
        }
    }
}
