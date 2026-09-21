import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.style

// One workspace: the app icon when it holds a single window, otherwise a dot.
Item {
    id: root

    required property var workspace

    readonly property bool focused: workspace.focused
    readonly property var windows: workspace.toplevels.values
    readonly property string appClass: windows.length === 1 ? (windows[0].lastIpcObject?.["class"] ?? "") : ""
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

    Image {
        anchors.centerIn: parent
        visible: root.iconSource !== ""
        source: root.iconSource
        width: 16
        height: 16
        sourceSize: Qt.size(32, 32)
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
        onClicked: Hyprland.dispatch("workspace " + root.workspace.id)
    }
}
