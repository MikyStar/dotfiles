import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import qs.style

// One workspace: the app icon when it holds a single window, otherwise a dot.
Item {
    id: root

    required property var workspace

    readonly property bool focused: workspace.focused
    readonly property var windows: workspace.toplevels.values
    // The Wayland app id is known as soon as the window maps; the IPC object may still be empty then.
    readonly property string appClass: windows.length === 1 ? (windows[0].wayland?.appId || windows[0].lastIpcObject?.["class"] || "") : ""
    readonly property string iconSource: {
        if (appClass === "")
            return "";
        const entry = DesktopEntries.heuristicLookup(appClass);
        return Quickshell.iconPath(entry?.icon ?? appClass.toLowerCase(), true);
    }

    implicitWidth: 24
    implicitHeight: 24

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.focused ? Colors.itemHover : "transparent"
        border.color: root.focused ? Colors.accent : "transparent"
        border.width: 1
    }

    // The icon is drawn as a white silhouette with a dark shadow.
    Image {
        id: icon
        anchors.centerIn: parent
        visible: false
        source: root.iconSource
        width: 16
        height: 16
        sourceSize: Qt.size(32, 32)
    }

    MultiEffect {
        anchors.fill: icon
        visible: root.iconSource !== ""
        source: icon
        colorization: 1.0
        colorizationColor: "white"
        shadowEnabled: true
        shadowColor: Colors.iconShadow
        shadowBlur: 0.8
        shadowOpacity: 1.0
    }

    Text {
        anchors.centerIn: parent
        visible: root.iconSource === ""
        text: Icons.dot
        color: root.focused ? Colors.accent : Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: root.focused ? 9 : 7
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${root.workspace.id} })`)
    }
}
