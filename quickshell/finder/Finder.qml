import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.style
import qs.bar.components
import qs.finder.components

// Rofi replacement: a full-screen, click-catching overlay (dismissible via click-outside or Escape)
// with a centered fuzzy-finder box, styled like the rest of the bar/widgets. Toggled from outside via
// `quickshell ipc call finder toggle` (see the IpcHandler below) -- bound to a Hyprland keyboard
// shortcut instead of rofi's launcher command.
PanelWindow {
    id: root

    // The wlr surface has to stay mapped for the outro fade (below) to actually be visible, so `visible`
    // tracks `_mapped` rather than FinderService.visible directly -- set true the instant it opens, and
    // back to false only once `fade`'s opacity animation finishes closing.
    property bool _mapped: false

    screen: Quickshell.screens[0] ?? null
    visible: _mapped
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qs-finder"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; left: true; right: true; bottom: true }

    IpcHandler {
        target: "finder"

        function toggle() { FinderService.toggle(); }
        function open() { FinderService.open(); }
        function close() { FinderService.close(); }
    }

    // searchField.text isn't bound to FinderService.query (a two-way binding would sever the moment the
    // field's own text-input machinery writes to it on the first keystroke); instead it's reset here,
    // in lockstep with FinderService.open() resetting the query itself, and pushes further edits back
    // via onTextChanged below.
    Connections {
        target: FinderService
        function onVisibleChanged() {
            if (!FinderService.visible)
                return;
            root._mapped = true;
            searchField.text = "";
            searchField.forceActiveFocus();
        }
    }

    // Fades in/out over the same duration in both directions (previously appearing had no explicit
    // animation and rode whatever the compositor defaulted to, slower than disappearing).
    Item {
        id: fade
        anchors.fill: parent
        opacity: FinderService.visible ? 1 : 0
        enabled: FinderService.visible

        Behavior on opacity { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

        onOpacityChanged: if (opacity <= 0) root._mapped = false

        // Dimmed backdrop; click anywhere outside the box dismisses.
        MouseArea {
            anchors.fill: parent
            onClicked: FinderService.close()

            Rectangle {
                anchors.fill: parent
                color: Colors.backdrop
            }
        }

        Rectangle {
            id: box
            width: Theme.finderWidth
            anchors.horizontalCenter: parent.horizontalCenter
            // Fixed fraction of screen height -- deliberately NOT a function of this box's own height,
            // so the search field never shifts on screen as the result list grows/shrinks with the query.
            y: root.height * Theme.finderTopFraction
            // Plain Rectangle/Item don't auto-follow implicitHeight the way Layout children do (there's no
            // Layout above this one -- it's positioned by anchors/y, not managed by a parent Layout) -- so
            // `height` is bound directly rather than through implicitHeight.
            height: body.implicitHeight + Theme.popupPadding * 2
            radius: Theme.popupRadius
            color: Colors.panel
            border.color: Colors.panelBorder
            border.width: 1

            // Swallows clicks so they don't fall through to the backdrop's dismiss handler.
            MouseArea { anchors.fill: parent }

            ColumnLayout {
                id: body
                anchors.fill: parent
                anchors.margins: Theme.popupPadding
                spacing: Theme.popupSpacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: Icons.search
                        color: Colors.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.iconSize
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search apps, paths, scripts, or type a calculation…"
                        placeholderTextColor: Colors.textDim
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 1
                        selectByMouse: true
                        background: null
                        padding: 0

                        onTextChanged: FinderService.query = text

                        Keys.onEscapePressed: FinderService.close()
                        Keys.onTabPressed: FinderService.cycleFilter()
                        Keys.onDownPressed: FinderService.moveSelection(1)
                        Keys.onUpPressed: FinderService.moveSelection(-1)
                        Keys.onReturnPressed: FinderService.activateSelected()
                        Keys.onEnterPressed: FinderService.activateSelected()
                    }

                    Text {
                        visible: FinderService.pathsIndexing
                        text: Icons.refresh
                        color: Colors.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.iconSize

                        RotationAnimation on rotation {
                            running: FinderService.pathsIndexing
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 900
                        }
                    }
                }

                FilterTabs {}

                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

                Item {
                    Layout.fillWidth: true
                    visible: FinderService.results.length === 0
                    implicitHeight: 60

                    Text {
                        anchors.centerIn: parent
                        text: "No results"
                        color: Colors.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }

                ScrollList {
                    visible: FinderService.results.length > 0
                    maxRows: Math.min(Theme.finderMaxResultRows, Math.max(1, FinderService.results.length))
                    rowHeight: Theme.finderResultRowHeight
                    spacing: 2
                    currentIndex: FinderService.selectedIndex
                    itemCount: FinderService.results.length
                    lookAhead: 2

                    Repeater {
                        model: FinderService.results

                        ResultRow {}
                    }
                }
            }
        }
    }
}
