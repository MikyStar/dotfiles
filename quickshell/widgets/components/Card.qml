import QtQuick
import QtQuick.Layouts
import qs.style

// Translucent rounded panel used as the outer surface of each desktop widget, matching the bar's
// pills (same colors, lighter/more transparent than the popup panels) with the popups' radius/padding.
// Children are laid out in a column.
Rectangle {
    id: root

    default property alias content: body.data

    implicitWidth: Theme.widgetWidth
    implicitHeight: body.implicitHeight + Theme.widgetPadding * 2
    radius: Theme.widgetRadius
    color: Colors.pill
    border.color: Colors.pillBorder
    border.width: 1
    // Safety net for content that doesn't bound its own width (e.g. unelided text): without this
    // it would render straight through the right inset instead of being held to it, while the left
    // stays padded. Well-behaved rows shouldn't rely on it -- see InfoRow's fillWidth/elide value.
    clip: true

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: Theme.widgetPadding
        spacing: Theme.popupSpacing
    }
}
