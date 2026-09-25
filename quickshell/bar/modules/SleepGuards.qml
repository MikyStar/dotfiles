import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.modules

// Single shared pill for both "something is holding sleep/lock off" indicators: the coffee icon
// (Caffeine.qml, for cafeinate.sh) and the open-lock icon (NoLock.qml, for no-lock.sh). Each icon
// shows, blinks and handles its own click independently -- the pill itself only folds away once
// neither script is running.
Item {
    id: root

    // Folded away, animated, e.g. while the overflow menu is expanded and needs the room.
    property bool compact: false
    readonly property bool hasContent: caffeineIcon.running || noLockIcon.running
    readonly property bool collapsed: compact || !hasContent

    enabled: !collapsed
    opacity: collapsed ? 0 : 1
    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight
    Layout.preferredWidth: collapsed ? 0 : implicitWidth

    Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }

    Item {
        anchors.fill: parent
        clip: true

        Pill {
            id: pill

            Caffeine { id: caffeineIcon }
            NoLock { id: noLockIcon }
        }
    }
}
