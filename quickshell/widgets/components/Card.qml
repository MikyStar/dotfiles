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
    // Without this, a row that runs wide (e.g. the Infos card's update list) renders straight
    // through the right inset instead of being held to it, while the left stays padded -- clip
    // keeps both sides symmetric.
    clip: true

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: Theme.widgetPadding
        spacing: Theme.popupSpacing
    }
}
