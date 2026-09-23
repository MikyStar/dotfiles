import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.style
import qs.bar.components

Pill {
    id: root

    icon: Icons.power
    // Whole pill goes red on hover or click, same as a battery running low -- a reminder of what
    // this button leads to, matching the shutdown entry's own color in its menu below.
    iconColor: (hovered || menu.open) ? Colors.critical : Colors.accent
    statusActive: hovered || menu.open
    statusColor: Colors.critical
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
