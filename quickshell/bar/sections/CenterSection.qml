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
    // `bellMod`/`sleepMod` only show once there's something to show (see their `hasContent`), so
    // unlike the always-shown clock, their width counts only while they actually have content --
    // otherwise this wouldn't change when they appear/disappear, and the overflow menu would never
    // recompute in response.
    readonly property real fullWidth: clockMod.implicitWidth
        + (bellMod.hasContent ? Theme.sectionSpacing + bellMod.implicitWidth : 0)
        + (sleepMod.hasContent ? Theme.sectionSpacing + sleepMod.implicitWidth : 0)

    spacing: Theme.sectionSpacing

    Clock { id: clockMod }
    NotificationBell { id: bellMod; compact: root.compact }
    SleepGuards { id: sleepMod; compact: root.compact }
}
