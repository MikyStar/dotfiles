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
    Text {
        // fillWidth (rather than a separate spacer Item) so a long value is bounded by the space
        // actually left over instead of pushing past it -- otherwise it renders straight through
        // the card's right inset instead of being held to it (only clipped flush at the very edge
        // by Card's `clip: true`, which reads as the right padding vanishing).
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
        text: parent.value
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
