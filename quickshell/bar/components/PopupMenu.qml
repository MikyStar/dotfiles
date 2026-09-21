import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.style
import qs.bar.services

// Blurred submenu shown under `anchorItem`. It is a layer-shell surface, so Hyprland never tiles it
// and blurs it through the "qs-popup" layerrule. Children are laid out in a column inside the panel.
PanelWindow {
    id: root

    required property Item anchorItem
    property bool open: false
    // Click-outside dismissal + one-at-a-time. Disable for hover tooltips.
    property bool grabFocus: true

    default property alias content: body.data

    property real _centerX: 0

    function toggle() { open = !open; }
    function close() { open = false; }

    onOpenChanged: {
        if (!open)
            return;
        _centerX = anchorItem.mapToItem(null, anchorItem.width / 2, 0).x;
        if (grabFocus) {
            if (Popups.current && Popups.current !== root)
                Popups.current.close();
            Popups.current = root;
        }
    }

    screen: anchorItem.QsWindow.window?.screen ?? null
    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qs-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; left: true }
    margins.top: Theme.popupTop
    margins.left: Math.max(Theme.barMargin, Math.min(_centerX - width / 2, (screen?.width ?? 0) - width - Theme.barMargin))

    implicitWidth: surface.implicitWidth
    implicitHeight: surface.implicitHeight

    HyprlandFocusGrab {
        windows: [root, root.anchorItem.QsWindow.window]
        active: root.open && root.grabFocus
        onCleared: root.close()
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        implicitWidth: body.implicitWidth + Theme.popupPadding * 2
        implicitHeight: body.implicitHeight + Theme.popupPadding * 2
        radius: Theme.popupRadius
        color: Colors.panel
        border.color: Colors.panelBorder
        border.width: 1

        ColumnLayout {
            id: body
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.popupSpacing
        }
    }
}
