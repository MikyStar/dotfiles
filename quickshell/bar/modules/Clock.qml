import QtQuick
import Quickshell
import qs.style
import qs.bar.components

Pill {
    id: root

    icon: Icons.calendar
    text: Qt.formatDateTime(clock.date, "ddd d MMM HH:mm:ss")
    active: menu.open
    onClicked: menu.toggle()

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    PopupMenu {
        id: menu
        anchorItem: root
        Calendar {}
    }
}
