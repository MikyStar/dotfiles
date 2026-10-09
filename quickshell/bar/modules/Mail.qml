import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.style
import qs.bar.components
import qs.bar.services

// Mail icon with an unread-count badge, synced via MailService (direct IMAP polling, works
// without Thunderbird running -- see scripts/mail-sync.py). Hovering lists the unread messages;
// clicking opens Thunderbird. Kept entirely separate from NotificationBell (own service, own
// menu) despite the similar badge + list look.
Item {
    id: root

    // Folded away, animated, e.g. while the overflow menu is expanded and needs the room.
    property bool compact: false
    // Shown for unread mail, but also while an account is erroring (e.g. bad credentials) --
    // otherwise a broken account fails completely silently (count stays 0, nothing to see).
    readonly property bool hasError: MailService.accounts.some(a => a.error)
    readonly property bool hasContent: MailService.count > 0 || hasError
    readonly property bool collapsed: compact || !hasContent

    // Whether the pill or the popup underneath it currently has the mouse. Combined with
    // `closeTimer` below so moving the mouse from the pill down into the popup (crossing the
    // visual gap between them, which belongs to neither and briefly satisfies neither hover)
    // doesn't close the popup before the cursor gets there.
    readonly property bool wantMenuOpen: pill.hovered || bodyHover.hovered

    onWantMenuOpenChanged: {
        if (wantMenuOpen) {
            closeTimer.stop();
            mailMenu.open = true;
        } else {
            closeTimer.restart();
        }
    }

    Timer {
        id: closeTimer
        interval: 300
        onTriggered: mailMenu.open = false
    }

    enabled: !collapsed
    opacity: collapsed ? 0 : 1
    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight
    Layout.preferredWidth: collapsed ? 0 : implicitWidth
    // Own leading gap rather than relying on CenterSection's RowLayout spacing: that stays uniform
    // even while this collapses to zero width, which would otherwise leave its spacing on both sides.
    Layout.leftMargin: collapsed ? 0 : Theme.sectionSpacing

    Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
    Behavior on Layout.leftMargin { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }

    // Clip scoped to this wrapper (not `root`) so the badge below, which pokes slightly past the
    // pill's edge, keeps its full rounded shape instead of being cropped along with the pill itself.
    Item {
        id: clipper
        anchors.fill: parent
        clip: true

        Pill {
            id: pill
            icon: Icons.mail
            statusActive: root.hasError
            statusColor: Colors.critical
            onClicked: Quickshell.execDetached(["thunderbird"])

            PopupMenu {
                id: mailMenu
                anchorItem: pill
                grabFocus: false

                HoverHandler { id: bodyHover }

                MenuHeader { text: "Mail" }

                Text {
                    visible: MailService.messages.length === 0
                    text: "No unread mail"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                ScrollList {
                    Layout.fillWidth: false
                    Layout.preferredWidth: 320
                    visible: MailService.messages.length > 0
                    maxRows: 5
                    rowHeight: 46

                    Repeater {
                        model: MailService.messages

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: msgCol.implicitHeight + 16
                            radius: 10
                            color: Colors.item

                            ColumnLayout {
                                id: msgCol
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.from
                                    color: Colors.textDim
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.subject
                                    color: Colors.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: MailService.accounts.some(a => a.error)
                    text: MailService.accounts.filter(a => a.error).map(a => `${a.name}: ${a.error}`).join("\n")
                    color: Colors.critical
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    // Unread badge, same treatment as NotificationBell's.
    Rectangle {
        visible: MailService.count > 0
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
            text: MailService.count > 99 ? "+99" : MailService.count
            color: "#101018"
            font.family: Theme.fontFamily
            font.pixelSize: 10
            font.bold: true
        }
    }
}
