import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.style
import qs.bar.services

// One notification banner. Owns its own entry/exit animation and auto-dismiss timer rather than
// relying on ListView's remove transition -- that's what lets a slide-out-right (Dismiss button, or
// the timeout) and a fade-in-place (clicking through to the app) coexist: whichever fires just sets
// `closing`/`closeFade` and the item only actually leaves the model once its own animation has run.
Rectangle {
    id: root

    required property var notification
    required property int index

    property bool _entered: false
    property bool closing: false
    property bool closeFade: false

    radius: Theme.popupRadius
    color: Colors.panel
    border.color: Colors.panelBorder
    border.width: 1
    implicitHeight: body.implicitHeight + Theme.popupPadding * 2

    // Slides in/out from a point Theme.toastSlideDistance to the right of its resting spot rather than
    // a full card-width away -- the popup window is exactly card-width wide, flush against the screen's
    // right edge, so anything further out would just be clipped by that surface instead of visibly
    // sliding. Component.onCompleted flips `_entered` a tick later so the very first frame renders
    // already in that off state instead of animating from it.
    x: (!root._entered || (root.closing && !root.closeFade)) ? Theme.toastSlideDistance : 0
    opacity: (!root._entered || root.closing) ? 0 : 1

    Behavior on x {
        enabled: root._entered
        NumberAnimation { duration: Theme.toastSlideDuration; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        enabled: root._entered
        NumberAnimation { duration: root.closeFade ? Theme.toastFadeDuration : Theme.toastSlideDuration }
    }

    Component.onCompleted: Qt.callLater(() => root._entered = true)

    function _close(fade: bool) {
        if (root.closing)
            return;
        root.closeFade = fade;
        root.closing = true;
        closeTimer.interval = fade ? Theme.toastFadeDuration : Theme.toastSlideDuration;
        closeTimer.start();
    }

    Timer {
        id: closeTimer
        onTriggered: {
            const view = root.ListView.view;
            if (view)
                view.model.remove(root.index);
        }
    }

    Timer {
        interval: Theme.toastAutoDismissMs
        running: root._entered && !root.closing
        onTriggered: root._close(false)
    }

    // The notification can disappear out from under the toast (dismissed elsewhere, withdrawn by its
    // own app, or expired) -- follow it out instead of lingering for the rest of the timeout/animation.
    Connections {
        target: root.notification
        function onClosed() { root._close(false); }
    }

    // Anywhere on the card except the two buttons below: browse to the sending app and fade out.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Notifications.browseToApp(root.notification);
            root._close(true);
        }
    }

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Image {
                visible: source !== ""
                source: root.notification.image !== "" ? root.notification.image : Quickshell.iconPath(root.notification.appIcon, true)
                sourceSize: Qt.size(Theme.iconSize, Theme.iconSize)
                Layout.preferredWidth: Theme.iconSize
                Layout.preferredHeight: Theme.iconSize
            }
            Text {
                Layout.fillWidth: true
                text: root.notification.appName
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                elide: Text.ElideRight
            }
        }
        Text {
            Layout.fillWidth: true
            text: root.notification.summary
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.notification.body
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: 12

            Item { Layout.fillWidth: true }

            Text {
                text: "Dismiss"
                color: dismissArea.containsMouse ? Colors.text : Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1

                MouseArea {
                    id: dismissArea
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._close(false)
                }
            }
            Text {
                text: "Seen"
                color: seenArea.containsMouse ? Colors.text : Colors.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true

                MouseArea {
                    id: seenArea
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Notifications.markSeen(root.notification);
                        root._close(false);
                    }
                }
            }
        }
    }
}
