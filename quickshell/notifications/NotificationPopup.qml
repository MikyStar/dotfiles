import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.style
import qs.notifications.components
import qs.bar.services

// macOS-style banners for incoming notifications, stacked at the top right above every app window.
// Each banner is a ToastCard, which owns its own slide-in/out and auto-dismiss animation; this window
// just holds the stack and feeds it new arrivals from Notifications.arrived.
PanelWindow {
    id: root

    screen: Quickshell.screens[0] ?? null
    visible: toastModel.count > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qs-notification-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; right: true }
    margins.top: Theme.popupTop
    margins.right: Theme.barMargin

    implicitWidth: Theme.toastWidth
    implicitHeight: list.contentHeight

    ListModel { id: toastModel }

    Connections {
        target: Notifications
        // Newest on top, like macOS.
        function onArrived(n) { toastModel.insert(0, { notification: n }); }
    }

    ListView {
        id: list
        anchors.fill: parent
        model: toastModel
        spacing: Theme.toastGap
        interactive: false

        delegate: ToastCard {
            width: list.width
        }
    }
}
