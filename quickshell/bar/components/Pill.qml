import QtQuick
import QtQuick.Layouts
import qs.style

// Grey translucent pill with an optional icon + text. Extra children are appended to the row.
Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    // Widest value `text` will take (e.g. "100%"): the pill is sized for it, so it doesn't resize as the value changes.
    // The text is right-aligned inside that width.
    property string reserveText: ""
    // Longer text is elided at this width (-1: no limit).
    property real maxTextWidth: -1
    property color iconColor: Colors.accent
    property color textColor: Colors.text
    property int padding: Theme.pillPadding
    property int contentSpacing: Theme.pillSpacing
    property bool active: false
    // Only pills that react to the wheel swallow it; the others let it reach a parent (e.g. a scrolling bar section).
    property bool wheelEnabled: false
    // When set, tints the pill's background and border with statusColor (e.g. a CPU/RAM/battery warning level).
    property bool statusActive: false
    property color statusColor: Colors.accent
    readonly property bool hovered: hover.hovered

    default property alias content: row.data

    signal clicked(var mouse)
    signal scrolled(int delta)

    implicitHeight: Theme.pillHeight
    implicitWidth: row.implicitWidth + padding * 2
    radius: Theme.pillRadius
    color: statusActive
        ? Qt.tint(hovered || active ? Colors.pillHover : Colors.pill, Qt.rgba(statusColor.r, statusColor.g, statusColor.b, 0.35))
        : (hovered || active ? Colors.pillHover : Colors.pill)
    border.color: statusActive ? statusColor : Colors.pillBorder
    border.width: 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    WheelHandler {
        enabled: root.wheelEnabled
        onWheel: event => root.scrolled(event.angleDelta.y)
    }

    // Below the row so interactive children (buttons) receive clicks first.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: root.contentSpacing

        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.iconColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
        }

        Text {
            visible: root.text !== "" || root.reserveText !== ""
            Layout.preferredWidth: {
                const w = Math.max(reserved.advanceWidth, Math.ceil(implicitWidth));
                return root.maxTextWidth > 0 ? Math.min(w, root.maxTextWidth) : w;
            }
            text: root.text
            color: root.textColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight

            TextMetrics {
                id: reserved
                text: root.reserveText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }
        }
    }
}
