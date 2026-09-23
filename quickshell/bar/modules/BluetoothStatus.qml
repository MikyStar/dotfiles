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

    // While active, the icon blinks once a second between its normal ("active") color and the dim
    // ("inactive") one, so an on-but-idle adapter still reads as alive at a glance.
    readonly property color activeColor: connectedDevices.length > 0 ? Colors.accent : Colors.text
    readonly property color inactiveColor: Colors.textDim
    property color blinkColor: activeColor

    icon: Icons.bluetooth
    iconColor: (adapter?.enabled ?? false) ? blinkColor : inactiveColor
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
        running: root.adapter?.enabled ?? false
        loops: Animation.Infinite

        ColorAnimation { target: root; property: "blinkColor"; from: root.activeColor; to: root.inactiveColor; duration: 500 }
        ColorAnimation { target: root; property: "blinkColor"; from: root.inactiveColor; to: root.activeColor; duration: 500 }
    }

    PopupMenu {
        id: menu
        anchorItem: root

        // Scan only while the menu is open.
        Binding {
            target: root.adapter
            property: "discovering"
            value: menu.open && (root.adapter?.enabled ?? false)
            when: root.adapter !== null
            restoreMode: Binding.RestoreNone
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 280
            MenuHeader { text: "Bluetooth" }
            Text {
                text: root.adapter?.enabled ? "On" : "Off"
                color: root.adapter?.enabled ? Colors.good : Colors.textDim
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
            visible: !root.adapter?.enabled
            text: root.adapter ? "Bluetooth is turned off" : "No Bluetooth adapter"
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.adapter?.enabled ?? false
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

                Text {
                    visible: root.nearbyDevices.length > 0 || (root.adapter?.discovering ?? false)
                    text: root.nearbyDevices.length > 0 ? "Nearby" : "Searching…"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
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
