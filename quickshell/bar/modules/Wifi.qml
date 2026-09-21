import QtQuick
import qs.style
import qs.bar.components
import qs.bar.services

Pill {
    id: root

    icon: Icons.wifi
    iconColor: Network.connected ? Colors.accent : Colors.textDim
    text: `${Icons.arrowDown} ${Format.speed(SystemStats.rxSpeed)}  ${Icons.arrowUp} ${Format.speed(SystemStats.txSpeed)}`
    active: menu.open
    onClicked: menu.toggle()

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader { text: Network.connected ? Network.ssid : "Not connected" }
        InfoRow { visible: Network.connected; label: "Signal"; value: Network.signal + "%" }
        InfoRow { label: "Download"; value: Format.speed(SystemStats.rxSpeed) + "/s" }
        InfoRow { label: "Upload"; value: Format.speed(SystemStats.txSpeed) + "/s" }
    }
}
