import QtQuick
import Quickshell
import qs.style
import qs.bar.components

Pill {
    id: root

    icon: Icons.calendar
    text: Qt.formatDateTime(clock.date, "ddd d MMM HH:mm:ss")
    reserveText: "Www 00 Www 00:00:00"
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
