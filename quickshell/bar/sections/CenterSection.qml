import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.modules

RowLayout {
    id: root

    // Folds away everything but the clock, animated, e.g. while the right section's overflow menu
    // is expanded and needs the room.
    property bool compact: false
    // Full width regardless of `compact`: callers reserve room using this instead of the live
    // `width`, so that reservation doesn't itself shrink the moment this section folds -- which,
    // for the overflow menu's own fit calculation, would only feed back into itself.
    // `bellMod` only shows once there's something to show (see NotificationBell.visible), so unlike
    // the always-shown clock, its width counts only while it's actually visible -- otherwise this
    // wouldn't change when it appears/disappears, and the overflow menu would never recompute in response.
    readonly property real fullWidth: clockMod.implicitWidth + (bellMod.visible ? Theme.sectionSpacing + bellMod.implicitWidth : 0)

    spacing: Theme.sectionSpacing

    Clock { id: clockMod }
    NotificationBell { id: bellMod; compact: root.compact }
}
