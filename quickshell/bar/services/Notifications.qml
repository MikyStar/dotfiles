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
    // Notifications received and not yet dismissed. Opening/closing the popup does NOT clear this --
    // only dismissing notifications (one by one, or via clear()) does, which is why it's just the
    // arrival count clamped to what's still around rather than a separately tracked "seen" flag.
    readonly property int unseen: Math.min(_unseen, count)
    property int _unseen: 0

    function clear() {
        for (const n of [...server.trackedNotifications.values])
            n.dismiss();
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        onNotification: n => {
            n.tracked = true;
            root._unseen++;
        }
    }
}
