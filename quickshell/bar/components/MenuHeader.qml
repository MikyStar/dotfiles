import QtQuick
import QtQuick.Layouts
import qs.style

// Bold title line at the top of a popup menu.
Text {
    Layout.fillWidth: true
    color: Colors.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize + 1
    font.bold: true
    elide: Text.ElideRight
}
