import QtQuick
import QtQuick.Layouts
import qs.style

// Icon + right-aligned value inside a pill, sized for `reserveText` so it doesn't resize with the value.
// Scrolling over it emits `scrolled` (and keeps the wheel from reaching the parent strip).
RowLayout {
    id: root

    property string icon: ""
    property string text: ""
    property string reserveText: "100%"
    property color iconColor: Colors.accent
    property color textColor: Colors.text

    signal scrolled(int delta)

    spacing: Theme.iconTextSpacing

    WheelHandler {
        onWheel: event => root.scrolled(event.angleDelta.y)
    }

    Text {
        text: root.icon
        color: root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize
    }

    Text {
        Layout.preferredWidth: Math.max(reserved.advanceWidth, Math.ceil(implicitWidth))
        text: root.text
        color: root.textColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        horizontalAlignment: Text.AlignRight

        TextMetrics {
            id: reserved
            text: root.reserveText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
