pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
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

    // Fired for every incoming notification, in addition to it being tracked -- consumed by the
    // top-right toast popup (NotificationPopup.qml) to show a banner for it.
    signal arrived(var n)

    function clear() {
        for (const n of [...server.trackedNotifications.values])
            n.dismiss();
    }

    // Focuses the window of the application a notification came from -- the same app-id-to-window-
    // class lookup Media.qml uses for the now-playing pill.
    function browseToApp(n) {
        const appId = n.desktopEntry || n.appName || "";
        if (appId !== "")
            Hyprland.dispatch(`hl.dsp.focus({ window = "class:(?i)^${appId}$" })`);
    }

    // "Seen": acknowledged and cleared out of the notification list entirely -- unlike just dismissing
    // the toast popup, which leaves the notification tracked (and still counted as unseen).
    function markSeen(n) {
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
            root.arrived(n);
        }
    }
}
