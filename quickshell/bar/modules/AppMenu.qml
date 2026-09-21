import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.style
import qs.bar.components

// NixOS button: click for the list of applications installed system-wide.
Pill {
    id: root

    readonly property var apps: DesktopEntries.applications.values
        .filter(a => !a.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    icon: Icons.nixos
    active: menu.open
    onClicked: menu.toggle()

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader {
            Layout.minimumWidth: 280
            text: "Applications"
        }

        ScrollList {
            maxRows: 8

            Repeater {
                model: root.apps

                MenuButton {
                    required property var modelData
                    iconSource: Quickshell.iconPath(modelData.icon, true)
                    text: modelData.name
                    onClicked: {
                        menu.close();
                        modelData.execute();
                    }
                }
            }
        }
    }
}
