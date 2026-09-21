pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon. Every incoming notification is kept until dismissed.
// Note: only one daemon can own org.freedesktop.Notifications, so stop mako/dunst/swaync.
Singleton {
    id: root

    readonly property var model: server.trackedNotifications
    readonly property int count: server.trackedNotifications.values.length

    function clear() {
        for (const n of [...server.trackedNotifications.values])
            n.dismiss();
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        onNotification: n => n.tracked = true
    }
}
