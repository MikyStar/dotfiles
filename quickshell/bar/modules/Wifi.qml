import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.services

// Hover: connection + throughput. Click: on/off toggle and the list of nearby networks to connect to.
Pill {
    id: root

    // Speeds are padded to a constant width (the font is monospace) so the bar doesn't shift as they change.
    readonly property string rx: Format.speed(SystemStats.rxSpeed).padStart(5)
    readonly property string tx: Format.speed(SystemStats.txSpeed).padStart(5)

    // Secured network waiting for its password.
    property string pending: ""

    icon: Icons.wifi
    iconColor: Network.connected ? Colors.accent : Colors.textDim
    text: `${Icons.arrowDown}${rx} ${Icons.arrowUp}${tx}`
    active: menu.open
    onClicked: menu.toggle()

    // Rescan when the menu opens; forget any half-entered password when it closes.
    Connections {
        target: menu
        function onOpenChanged() {
            if (menu.open) {
                Network.error = "";
                Network.refresh(true);
            } else
                root.pending = "";
        }
    }

    PopupMenu {
        anchorItem: root
        open: root.hovered && !menu.open
        grabFocus: false

        MenuHeader { text: Network.enabled ? (Network.connected ? Network.ssid : "Not connected") : "Wi-Fi off" }
        InfoRow { visible: Network.connected; label: "Signal"; value: Network.signal + "%" }
        InfoRow { label: "Download"; value: Format.speed(SystemStats.rxSpeed) + "/s" }
        InfoRow { label: "Upload"; value: Format.speed(SystemStats.txSpeed) + "/s" }
    }

    PopupMenu {
        id: menu
        anchorItem: root
        takesKeyboard: root.pending !== ""

        RowLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 280
            MenuHeader { text: "Wi-Fi" }
            Text {
                text: Network.enabled ? "On" : "Off"
                color: Network.enabled ? Colors.good : Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Network.setEnabled(!Network.enabled)
                }
            }
        }

        Text {
            visible: !Network.enabled
            text: "Wi-Fi is turned off"
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: Network.enabled
            spacing: 6

            ScrollList {
                Text {
                    visible: Network.networks.length === 0
                    text: "No networks found"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Repeater {
                    model: Network.networks

                    MenuButton {
                        required property var modelData
                        icon: modelData.secured ? Icons.lock : Icons.wifi
                        iconColor: modelData.active ? Colors.good : Colors.accent
                        text: modelData.ssid
                        detail: modelData.signal + "%"
                        highlighted: modelData.active || root.pending === modelData.ssid
                        onClicked: {
                            root.pending = "";
                            if (modelData.active)
                                Network.disconnect(modelData.ssid);
                            else if (modelData.secured && !modelData.known)
                                root.pending = modelData.ssid;
                            else
                                Network.connect(modelData.ssid, "");
                        }
                    }
                }
            }

            // Password phase for a new secured network.
            Rectangle {
                id: prompt
                Layout.fillWidth: true
                visible: root.pending !== ""
                implicitHeight: 34
                radius: 10
                color: Colors.itemHover

                onVisibleChanged: {
                    if (visible) {
                        field.text = "";
                        field.forceActiveFocus();
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    TextInput {
                        id: field
                        Layout.fillWidth: true
                        echoMode: TextInput.Password
                        color: Colors.text
                        selectionColor: Colors.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        clip: true
                        onAccepted: if (text !== "") {
                            Network.connect(root.pending, text);
                            root.pending = "";
                        }

                        Text {
                            visible: field.text === ""
                            text: `Password for ${root.pending}`
                            color: Colors.textDim
                            font: field.font
                        }
                    }
                    Text {
                        text: "Connect"
                        color: field.text === "" ? Colors.textDim : Colors.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: field.accepted()
                        }
                    }
                }
            }

            Text {
                visible: Network.busy
                text: "Connecting…"
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
            Text {
                Layout.fillWidth: true
                visible: Network.error !== "" && !Network.busy
                text: Network.error
                color: Colors.critical
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                wrapMode: Text.Wrap
            }
        }
    }
}
