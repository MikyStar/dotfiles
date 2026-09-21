import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.style
import qs.bar.components

Pill {
    id: root

    icon: Icons.power
    iconColor: Colors.critical
    active: menu.open
    onClicked: menu.toggle()

    PopupMenu {
        id: menu
        anchorItem: root

        MenuButton {
            Layout.minimumWidth: 160
            icon: Icons.lock
            text: "Lock"
            onClicked: { menu.close(); Quickshell.execDetached(["loginctl", "lock-session"]); }
        }
        MenuButton {
            icon: Icons.reboot
            text: "Reboot"
            onClicked: { menu.close(); Quickshell.execDetached(["systemctl", "reboot"]); }
        }
        MenuButton {
            icon: Icons.shutdown
            iconColor: Colors.critical
            text: "Shutdown"
            onClicked: { menu.close(); Quickshell.execDetached(["systemctl", "poweroff"]); }
        }
    }
}
