import QtQuick
import QtQuick.Layouts
import qs.style

// "label ........ value" line for popup menus.
RowLayout {
    property string label: ""
    property string value: ""

    Layout.fillWidth: true
    spacing: 24

    Text {
        text: parent.label
        color: Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
    Item { Layout.fillWidth: true }
    Text {
        text: parent.value
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
