import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.style
import qs.bar.components
import qs.bar.services

// Bell with a count badge. Only shown while there are unseen notifications (or its menu is open).
Item {
    id: root

    // Folded away, animated, e.g. while the overflow menu is expanded and needs the room.
    property bool compact: false

    visible: Notifications.unseen > 0 || menu.open
    enabled: !compact
    opacity: compact ? 0 : 1
    // Stays the true natural size regardless of `compact`, so callers reserving room for it (e.g.
    // CenterSection.fullWidth) get a stable answer; only the actual layout size collapses.
    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight
    Layout.preferredWidth: compact ? 0 : implicitWidth

    Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }

    // Clip is scoped to this wrapper rather than `root` itself, so the unread badge below (which pokes
    // slightly past the pill's edge) keeps its full rounded shape instead of being cropped by the same
    // bounds that fold the pill away in `compact` mode.
    Item {
        id: clipper
        anchors.fill: parent
        clip: true

        Pill {
            id: pill
            icon: Icons.bell
            active: menu.open
            onClicked: menu.toggle()

            PopupMenu {
                id: menu
                anchorItem: pill

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

                // Fixed-height and scrollable (macOS-style overlay scrollbar, same as AppMenu's list)
                // once notifications outgrow maxRows, instead of an unbounded popup.
                ScrollList {
                    Layout.fillWidth: false
                    Layout.preferredWidth: 340
                    visible: Notifications.count > 0
                    maxRows: 4
                    rowHeight: 100

                    Repeater {
                        model: Notifications.model

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
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
                                    spacing: 6
                                    Image {
                                        visible: source !== ""
                                        source: modelData.image !== "" ? modelData.image : Quickshell.iconPath(modelData.appIcon, true)
                                        sourceSize: Qt.size(Theme.iconSize, Theme.iconSize)
                                        Layout.preferredWidth: Theme.iconSize
                                        Layout.preferredHeight: Theme.iconSize
                                    }
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

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 4
                                    visible: modelData.actions.length > 0
                                    spacing: 6

                                    Repeater {
                                        model: modelData.actions

                                        Rectangle {
                                            required property var modelData
                                            implicitWidth: actionText.implicitWidth + 16
                                            implicitHeight: 22
                                            radius: 8
                                            color: actionArea.containsMouse ? Colors.itemHover : Colors.item

                                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                            Text {
                                                id: actionText
                                                anchors.centerIn: parent
                                                text: modelData.text
                                                color: Colors.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 2
                                            }

                                            MouseArea {
                                                id: actionArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: modelData.invoke()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Unread badge. Left outside `clipper` (see above) and shaped as a horizontal pill -- rather than
    // forced into a fixed circle -- so it can grow to fit "+99" without cropping the digits or the ends.
    Rectangle {
        visible: Notifications.unseen > 0
        // `pill` sits two levels down (inside `clipper`), so it isn't a valid anchor target for this
        // sibling of `clipper`; anchor to `clipper` instead, which shares the exact same bounds.
        anchors.top: clipper.top
        anchors.right: clipper.right
        anchors.topMargin: -2
        anchors.rightMargin: -2
        width: Math.max(16, badgeText.implicitWidth + 8)
        height: 16
        radius: 8
        color: Colors.critical

        Text {
            id: badgeText
            anchors.centerIn: parent
            // Cap the displayed count so the badge never has to grow past 3 characters.
            text: Notifications.unseen > 99 ? "+99" : Notifications.unseen
            color: "#101018"
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.bold: true
        }
    }
}
