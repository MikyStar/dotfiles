import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.style
import qs.bar.components

// Click: on/off toggle, paired devices and (while open) nearby devices to pair with.
Pill {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property var pairedDevices: Bluetooth.devices.values.filter(d => d.paired)
    // Unpaired devices seen during discovery. Unnamed ones only have a MAC address, so they are skipped.
    readonly property var nearbyDevices: Bluetooth.devices.values.filter(d => !d.paired && d.name !== "" && d.name !== d.address)

    readonly property bool connected: connectedDevices.length > 0
    // Named to avoid shadowing Item's own `enabled` (used elsewhere to collapse/expand this pill).
    readonly property bool btEnabled: adapter?.enabled ?? false
    // While on but not yet connected to anything, the icon blinks once a second between grey and
    // white so an on-but-idle adapter still reads as alive at a glance. Once connected it settles
    // on a solid white; off is a solid grey.
    property color blinkColor: Colors.textDim

    icon: Icons.bluetooth(btEnabled, connected)
    iconColor: !btEnabled ? Colors.textDim : connected ? Colors.white : blinkColor
    text: connectedDevices.length > 0 ? connectedDevices[0].name : ""
    maxTextWidth: 120
    active: menu.open
    onClicked: menu.toggle()

    function activate(device) {
        if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.connect();
        else
            device.pair();
    }

    SequentialAnimation {
        running: root.btEnabled && !root.connected
        loops: Animation.Infinite

        ColorAnimation { target: root; property: "blinkColor"; from: Colors.textDim; to: Colors.white; duration: 500 }
        ColorAnimation { target: root; property: "blinkColor"; from: Colors.white; to: Colors.textDim; duration: 500 }
    }

    PopupMenu {
        id: menu
        anchorItem: root

        // Scan only while the menu is open. Gated on `state` rather than `enabled`: `enabled` flips
        // true optimistically as soon as power-on is requested, but BlueZ silently ignores
        // StartDiscovery while the adapter is still in the "Enabling" transition, which left the
        // nearby-devices list empty until the menu was closed and reopened.
        Binding {
            target: root.adapter
            property: "discovering"
            value: menu.open && (root.adapter?.state === BluetoothAdapterState.Enabled)
            when: root.adapter !== null
            restoreMode: Binding.RestoreNone
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 280
            MenuHeader { text: "Bluetooth" }
            Text {
                text: root.btEnabled ? "On" : "Off"
                color: root.btEnabled ? Colors.good : Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
                }
            }
        }

        Text {
            visible: !root.btEnabled
            text: root.adapter ? "Bluetooth is turned off" : "No Bluetooth adapter"
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.btEnabled
            spacing: 6

            ScrollList {
                Repeater {
                    model: root.pairedDevices

                    MenuButton {
                        required property var modelData
                        icon: modelData.connected ? Icons.headphones : Icons.dot
                        iconColor: modelData.connected ? Colors.accent : Colors.textDim
                        text: modelData.name
                        detail: modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : ""
                        highlighted: modelData.connected
                        onClicked: root.activate(modelData)
                    }
                }

                Text {
                    visible: root.pairedDevices.length === 0
                    text: "No paired devices"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Repeater {
                    model: root.nearbyDevices

                    MenuButton {
                        required property var modelData
                        icon: Icons.dot
                        iconColor: Colors.textDim
                        text: modelData.name
                        detail: modelData.pairing ? "Pairing…" : ""
                        onClicked: root.activate(modelData)
                    }
                }
            }
        }
    }
}
