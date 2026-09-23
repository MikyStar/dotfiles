import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.style
import qs.bar.sections

// One bar per screen: left / center / right sections over a transparent, full-width layer surface.
Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData

        screen: modelData
        color: "transparent"
        implicitHeight: Theme.barHeight
        // Reserve only the top margin and the pills: Hyprland's own gap then makes up the space below the bar.
        exclusiveZone: Theme.barMargin + Theme.pillHeight
        WlrLayershell.namespace: "qs-bar"

        anchors { top: true; left: true; right: true }

        Item {
            id: content
            anchors.fill: parent
            anchors.margins: Theme.barMargin

            // The center zone sits equidistant between the left and right zones -- not simply on the screen's
            // middle, since those two zones aren't generally the same width -- unless the left zone is in the
            // way or the right zone needs the room for its modules: then it's clamped to whichever's short of
            // room. The right zone only gets the room left of the center (minus `zoneGap`); when its other
            // modules need more they collapse into its overflow menu.
            //
            // Getting both "right zone shows as much as fits" and "center zone sits equidistant" right takes
            // two passes, in this order (see RightSection.settledWidth too):
            //  1. The right zone's fit budget (`maxWidth` below) is sized as if the center zone were pinned at
            //     its leftmost legal position (`defaultCenterRight`) -- i.e. before it's actually been
            //     centered. This is deliberately computed from `left.fullWidth`/`center.fullWidth` rather than
            //     the not-yet-final `centerX`: feeding the live `centerX` in here would make the right zone's
            //     fit decision depend on its own output (through `rightBoundary`/`centerX` below), which is
            //     exactly the binding loop that used to make RightSection.hasOverflow flip erratically.
            //  2. Once that fit decision has settled (`right.settledWidth`, computed directly from implicit
            //     widths rather than the live, possibly mid-animation `width`), the center zone is centered
            //     for real between `leftBoundary` and the resulting `rightBoundary`. Because `rightBoundary` is
            //     derived *from* that already-decided width, `centerX` can never be clamped past it: the two
            //     zones can end up closer than the generous first pass assumed, but never overlapping.
            readonly property real leftBoundary: left.fullWidth + Theme.zoneGap
            readonly property real defaultCenterRight: leftBoundary + center.fullWidth
            readonly property real rightBoundary: width - right.settledWidth - Theme.zoneGap
            readonly property real centerX: Math.max(leftBoundary,
                Math.min((leftBoundary + rightBoundary - center.fullWidth) / 2, rightBoundary - center.fullWidth))

            LeftSection {
                id: left
                compact: right.expanded
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
            CenterSection {
                id: center
                // While expanded, folds down to just the clock and pins right after the app menu icon,
                // as if it had joined the left zone -- not on top of it -- handing the right zone
                // virtually the rest of the bar. Targets `left.compactWidth` (the left zone's known
                // final folded width) rather than its live, still-animating `width`, so this section's
                // own move animates in lockstep with the left zone's instead of chasing it and lagging.
                x: right.expanded ? left.compactWidth + Theme.sectionSpacing : content.centerX
                compact: right.expanded
                anchors.verticalCenter: parent.verticalCenter

                Behavior on x { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
            }
            RightSection {
                id: right
                maxWidth: content.width - content.defaultCenterRight - Theme.zoneGap
                // How much room is actually free once expanded: this one *is* allowed to reflect the
                // live, already-folded left/center zones, since it only sizes the scroll fallback and
                // never feeds back into the fit calculation above.
                expandedMaxWidth: content.width - center.width - Theme.zoneGap
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
