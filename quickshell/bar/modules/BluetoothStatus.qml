import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.style
import qs.bar.components

Pill {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)

    icon: Icons.bluetooth
    iconColor: !adapter?.enabled ? Colors.textDim : connectedDevices.length > 0 ? Colors.accent : Colors.text
    text: connectedDevices.length > 0 ? connectedDevices[0].name : ""
    active: menu.open
    onClicked: menu.toggle()

    PopupMenu {
        id: menu
        anchorItem: root

        RowLayout {
            Layout.fillWidth: true
            MenuHeader { text: "Bluetooth" }
            Text {
                text: root.adapter?.enabled ? "On" : "Off"
                color: root.adapter?.enabled ? Colors.good : Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
                }
            }
        }

        Repeater {
            model: Bluetooth.devices.values.filter(d => d.paired)

            MenuButton {
                required property var modelData
                Layout.minimumWidth: 240
                icon: modelData.connected ? Icons.headphones : Icons.dot
                iconColor: modelData.connected ? Colors.accent : Colors.textDim
                text: modelData.name
                onClicked: modelData.connected = !modelData.connected
            }
        }

        Text {
            visible: !root.adapter || Bluetooth.devices.values.filter(d => d.paired).length === 0
            text: "No paired devices"
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
