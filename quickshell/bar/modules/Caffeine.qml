import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.services

// Coffee-cup icon for the shared sleep-guard pill (see SleepGuards.qml): shown only while
// $HOME/Scripts/cafeinate.sh is running, i.e. sleep is being held off. Blinks grey <-> the same
// color as the NixOS icon (Colors.text) the whole time it's shown -- same treatment the Bluetooth
// pill uses for "on but idle" -- so an active icon still reads as alive at a glance. Click kills it.
Text {
    id: root

    // Exposed so the shared pill can fold itself away once neither icon has anything to show.
    readonly property bool running: Caffeinate.running
    property color blinkColor: Colors.textDim

    visible: running
    text: Icons.coffee
    color: blinkColor
    font.family: Theme.fontFamily
    font.pixelSize: Theme.iconSize - 2

    SequentialAnimation {
        running: root.running
        loops: Animation.Infinite

        ColorAnimation { target: root; property: "blinkColor"; from: Colors.textDim; to: Colors.text; duration: 500 }
        ColorAnimation { target: root; property: "blinkColor"; from: Colors.text; to: Colors.textDim; duration: 500 }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Caffeinate.stop()
    }

    PopupMenu {
        anchorItem: root
        open: area.containsMouse
        grabFocus: false

        MenuHeader { text: "Sleep prevented" }
        Text {
            Layout.fillWidth: true
            text: "cafeinate.sh is running -- click to stop"
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            wrapMode: Text.Wrap
        }
    }
}
