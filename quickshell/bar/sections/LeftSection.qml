import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.modules

RowLayout {
    id: root

    // Folds away everything but the app menu (NixOS icon), animated, e.g. while the right section's
    // overflow menu is expanded and needs the room.
    property bool compact: false
    // Full width regardless of `compact` -- see CenterSection.fullWidth for why this matters. `mediaMod`
    // only exists while something is playing (see Media.hasPlayer), so unlike the always-shown app menu
    // and workspaces, its width counts only while a player is actually present -- otherwise this wouldn't
    // change when the player appears/disappears, and the overflow menu would never recompute in response.
    readonly property real fullWidth: appMenuMod.implicitWidth + Theme.sectionSpacing + workspacesMod.implicitWidth
        + (mediaMod.hasPlayer ? Theme.sectionSpacing + mediaMod.implicitWidth : 0)
    // Width once folded down to just the app menu icon. Unlike the live `width` (which is itself
    // mid-animation while folding/unfolding), this is known immediately, so a caller animating
    // something to sit right after this section -- the clock, while the overflow menu is expanded --
    // can target it directly instead of chasing a moving value and lagging behind.
    readonly property real compactWidth: appMenuMod.implicitWidth

    spacing: Theme.sectionSpacing

    AppMenu { id: appMenuMod }
    Workspaces {
        id: workspacesMod
        clip: true
        enabled: !root.compact
        opacity: root.compact ? 0 : 1
        Layout.preferredWidth: root.compact ? 0 : implicitWidth
        Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
    }
    Media {
        id: mediaMod
        // Folds away both while compacting and whenever there's no player to show -- animated the same
        // way, so a player appearing/disappearing reflows the rest of the bar (and the center zone
        // chasing after it) smoothly instead of snapping instantly.
        readonly property bool collapsed: root.compact || !hasPlayer
        clip: true
        enabled: !collapsed
        opacity: collapsed ? 0 : 1
        Layout.preferredWidth: collapsed ? 0 : implicitWidth
        Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
    }
}
