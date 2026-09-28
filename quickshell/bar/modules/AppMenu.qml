import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.finder

// NixOS button: click opens the finder (apps/paths/scripts search), same as its keyboard shortcut.
Pill {
    id: root

    icon: Icons.nixos
    iconColor: Colors.text
    active: FinderService.visible
    onClicked: FinderService.toggle()
}
