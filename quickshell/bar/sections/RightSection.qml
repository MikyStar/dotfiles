import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.modules

RowLayout {
    spacing: Theme.sectionSpacing

    Wifi {}
    BluetoothStatus {}
    Volume {}
    Cpu {}
    Ram {}
    Temperature {}
    Battery {}
    Power {}
}
