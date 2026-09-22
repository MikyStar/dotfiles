import QtQuick
import Quickshell.Hyprland
import qs.style

// One workspace: the mapped app glyph when it holds a single window, otherwise a dot
// (filled when this is the focused workspace, hollow otherwise).
Item {
    id: root

    required property var workspace

    // Set by the repeater: whether this is the first/last workspace in the strip, so an icon that
    // needs extra room against the pill's rounded edge (see Icons.needsEdgePadding) gets it on the
    // correct side only.
    property bool isFirst: false
    property bool isLast: false

    readonly property bool focused: workspace.focused
    readonly property var windows: workspace.toplevels.values
    // The Wayland app id is known as soon as the window maps; the IPC object may still be empty then.
    readonly property string appClass: windows.length === 1 ? (windows[0].wayland?.appId || windows[0].lastIpcObject?.["class"] || "") : ""
    readonly property string appIcon: appClass !== "" ? Icons.app(appClass) : ""
    // Inactive workspaces match the color other bar icons use; the active one gets the NixOS logo's color.
    readonly property color tint: focused ? Colors.text : Colors.accent

    readonly property bool needsEdgePadding: root.appIcon !== "" && Icons.needsEdgePadding(root.appIcon)
    readonly property int leftPad: isFirst && needsEdgePadding ? Theme.iconEdgePadding : 0
    readonly property int rightPad: isLast && needsEdgePadding ? Theme.iconEdgePadding : 0
    // Icon stays centered on the original 24px box; the extra width only opens up space on the edge side.
    readonly property real contentOffset: (leftPad - rightPad) / 2

    implicitWidth: 24 + leftPad + rightPad
    implicitHeight: 24

    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.contentOffset
        visible: root.appIcon !== ""
        text: root.appIcon
        color: root.tint
        font.family: Theme.fontFamily
        font.pixelSize: Theme.iconSize + 2
    }

    // No single app to show: a filled dot when focused, a hollow one otherwise.
    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.contentOffset
        visible: root.appIcon === ""
        text: root.focused ? Icons.dot : Icons.dotEmpty
        color: root.tint
        font.family: Theme.fontFamily
        font.pixelSize: root.focused ? 13 : 10
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${root.workspace.id} })`)
    }
}
