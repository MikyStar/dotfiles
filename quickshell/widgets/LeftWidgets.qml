import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.style
import qs.widgets.infos
import qs.widgets.disk

// Left-hand-side desktop widget column: infos / disk space, vertically centered, sitting over the
// wallpaper but behind normal application windows (layer "bottom"). Shown once, on the primary
// screen -- unlike the per-screen bar, these are informational dashboards rather than status
// indicators, so they don't need to repeat on every monitor. Mirrors Widgets.qml, anchored left.
PanelWindow {
    id: root

    screen: Quickshell.screens[0] ?? null
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qs-widgets-left"
    WlrLayershell.layer: WlrLayer.Bottom

    // Anchoring left+right would stretch a surface horizontally (see Bar.qml); anchoring top+bottom
    // does the same vertically, stretching this surface to fill the screen minus margins.top instead
    // of centering across the whole screen height. margins.top reserves the bar's own box (pill +
    // its margin on both sides, i.e. Theme.barHeight) so the column below centers only in the space
    // actually left over beneath the bar.
    anchors { left: true; top: true; bottom: true }
    margins.left: Theme.widgetMargin
    margins.top: Theme.barHeight

    implicitWidth: column.implicitWidth

    ColumnLayout {
        id: column
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.widgetSpacing

        Infos {}
        Disk {}
    }
}
