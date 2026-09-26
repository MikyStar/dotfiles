import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.style
import qs.bar.components

// Clipboard history menu: SUPER+SHIFT+V (bound in Hyprland) brings up a finder-styled, list-only
// overlay -- same position/backdrop as Finder.qml, minus the search field -- of everything cliphist has
// recorded. Clicking or pressing Enter on an entry copies its full content to the clipboard and closes
// the menu. Toggled via `quickshell ipc call clipboard toggle`, mirroring Finder's IpcHandler.
PanelWindow {
    id: root

    property bool _mapped: false

    screen: Quickshell.screens[0] ?? null
    visible: _mapped
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qs-clipboard"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; left: true; right: true; bottom: true }

    IpcHandler {
        target: "clipboard"

        function toggle() { ClipboardService.toggle(); }
        function open() { ClipboardService.open(); }
        function close() { ClipboardService.close(); }
    }

    Connections {
        target: ClipboardService
        function onVisibleChanged() {
            if (!ClipboardService.visible)
                return;
            root._mapped = true;
            keyGrab.forceActiveFocus();
        }
    }

    Item {
        id: fade
        anchors.fill: parent
        opacity: ClipboardService.visible ? 1 : 0
        enabled: ClipboardService.visible

        Behavior on opacity { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

        onOpacityChanged: if (opacity <= 0) root._mapped = false

        MouseArea {
            anchors.fill: parent
            onClicked: ClipboardService.close()

            Rectangle { anchors.fill: parent; color: Colors.backdrop }
        }

        Rectangle {
            id: box
            width: Theme.finderWidth
            anchors.horizontalCenter: parent.horizontalCenter
            // Same fixed fraction of screen height as the finder -- see Finder.qml's `box.y`.
            y: root.height * Theme.finderTopFraction
            height: body.implicitHeight + Theme.popupPadding * 2
            radius: Theme.popupRadius
            color: Colors.panel
            border.color: Colors.panelBorder
            border.width: 1

            // Swallows clicks so they don't fall through to the backdrop's dismiss handler.
            MouseArea { anchors.fill: parent }

            // Invisible focus target for arrow/enter/escape -- there's no text field here to hold focus.
            Item {
                id: keyGrab
                anchors.fill: parent
                focus: true

                Keys.onEscapePressed: ClipboardService.close()
                Keys.onDownPressed: ClipboardService.moveSelection(1)
                Keys.onUpPressed: ClipboardService.moveSelection(-1)
                Keys.onReturnPressed: ClipboardService.activateSelected()
                Keys.onEnterPressed: ClipboardService.activateSelected()
            }

            ColumnLayout {
                id: body
                anchors.fill: parent
                anchors.margins: Theme.popupPadding
                spacing: Theme.popupSpacing

                MenuHeader { text: "Clipboard" }

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

                Item {
                    Layout.fillWidth: true
                    visible: ClipboardService.entries.length === 0
                    implicitHeight: 60

                    Text {
                        anchors.centerIn: parent
                        text: "No clipboard history"
                        color: Colors.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }

                ScrollList {
                    visible: ClipboardService.entries.length > 0
                    maxRows: Math.min(Theme.clipboardMaxRows, Math.max(1, ClipboardService.entries.length))
                    rowHeight: Theme.clipboardRowHeight
                    spacing: 2
                    currentIndex: ClipboardService.selectedIndex
                    itemCount: ClipboardService.entries.length
                    lookAhead: 2

                    Repeater {
                        model: ClipboardService.entries

                        Rectangle {
                            id: entryRow
                            required property var modelData
                            required property int index

                            readonly property bool selected: ClipboardService.selectedIndex === index
                            readonly property bool hovered: entryArea.containsMouse

                            Layout.fillWidth: true
                            implicitHeight: Theme.clipboardRowHeight
                            radius: 10
                            color: selected ? Colors.itemHover : (hovered ? Colors.item : "transparent")

                            Behavior on color { ColorAnimation { duration: Theme.animFast } }

                            MouseArea {
                                id: entryArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: ClipboardService.selectAndCopy(entryRow.index)
                            }

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                verticalAlignment: Text.AlignVCenter
                                text: entryRow.modelData.label
                                color: Colors.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
