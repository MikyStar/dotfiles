import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.style
import qs.bar.components
import qs.bar.modules
import qs.bar.services

// Status modules in a row, with the battery and power button pinned to the right. When there isn't
// room for every module, the trailing ones collapse into a menu icon pinned just before the battery:
// hovering it previews what's hidden, clicking it expands everything back into the bar -- which may
// then overlap the center zone, since there's nowhere else to put it once the bar is already full.
RowLayout {
    id: root

    // Width the section may not exceed before modules start collapsing into the overflow menu. Kept
    // deliberately independent of `expanded` (the caller computes it as if always collapsed) so that
    // expanding -- which frees up room elsewhere in the bar -- never feeds back into this budget and
    // therefore never into `hasOverflow`, which would only reset `expanded` right back to false.
    property real maxWidth: Infinity
    // Width available once expanded (room is generally freed elsewhere in the bar for this). Used only
    // to size the scroll fallback below -- never the fit calculation -- so it's safe for this one to
    // reflect the caller's current, `expanded`-aware layout.
    property real expandedMaxWidth: Infinity
    // Ideal width if every module were shown, used by Bar.qml to keep the center zone clear of it.
    readonly property real desiredWidth: _items.reduce((sum, it) => sum + it.implicitWidth, 0)
        + Theme.sectionSpacing * _items.length + pinnedBaseWidth

    readonly property var _items: [wifiMod, btMod, volMod, cpuMod, ramMod, tempMod]
    // Battery + power alone, regardless of whether the overflow icon is currently shown: used for the
    // fit budget below without the icon's own visibility feeding back into that same calculation.
    readonly property real pinnedBaseWidth: batteryMod.implicitWidth + powerMod.implicitWidth + Theme.sectionSpacing
    // Same, but including the overflow icon once it's actually shown -- what `pinned` really measures.
    readonly property real pinnedWidth: pinnedBaseWidth + (hasOverflow ? Theme.sectionSpacing + menuIcon.implicitWidth : 0)

    // How many leading modules currently fit; the rest collapse into the overflow menu.
    readonly property int visibleCount: _computeVisibleCount()
    readonly property bool hasOverflow: visibleCount < _items.length
    // Expanded by clicking the overflow menu: every module shows regardless of fit, overlapping
    // whatever is in the way -- there's nowhere else in the bar to put them. If even that isn't
    // enough room, the strip becomes horizontally scrollable rather than pushing further out.
    property bool expanded: false

    // Read directly (rather than from volMod's children) for the overflow preview below.
    readonly property var _sink: Pipewire.defaultAudioSink
    readonly property bool muted: _sink?.audio?.muted ?? false
    readonly property real volumeLevel: _sink?.audio?.volume ?? 0

    // Warn/critical modules currently folded into the menu tint the menu icon itself, so the
    // warning doesn't disappear along with the module that raised it. Critical wins over warn.
    readonly property bool hiddenCritical: (3 >= visibleCount && cpuMod.critLevel) || (4 >= visibleCount && ramMod.critLevel)
        || (5 >= visibleCount && tempMod.critLevel)
    readonly property bool hiddenWarn: (3 >= visibleCount && cpuMod.warnLevel) || (4 >= visibleCount && ramMod.warnLevel)
        || (5 >= visibleCount && tempMod.warnLevel)

    spacing: Theme.sectionSpacing

    onHasOverflowChanged: if (!hasOverflow) expanded = false;

    // Sizes as many leading modules as fit in `maxWidth`; the rest are left for the caller to hide.
    // Adding the overflow icon itself costs room, so it's only budgeted for once it's actually needed.
    // The modules row always keeps all six children (just some collapsed to zero width) so its own
    // spacing is fixed regardless of how many are shown -- accounted for here as `fixedGaps`.
    function _computeVisibleCount() {
        const widths = _items.map(it => it.implicitWidth);
        const fixedGaps = (widths.length - 1) * Theme.sectionSpacing;
        const budgetFor = pinnedW => root.maxWidth - Theme.sectionSpacing - pinnedW - fixedGaps;

        if (widths.reduce((a, b) => a + b, 0) <= budgetFor(pinnedBaseWidth))
            return widths.length;

        const budget = budgetFor(pinnedBaseWidth + Theme.sectionSpacing + menuIcon.implicitWidth);
        let sum = 0;
        for (let i = 0; i < widths.length; i++) {
            sum += widths[i];
            if (sum > budget)
                return i;
        }
        return widths.length;
    }

    // Scrolls only when even the expanded strip doesn't fit; otherwise its width always matches
    // its content, so this is invisible in the normal (collapsed-to-fit) state.
    Flickable {
        id: modulesFlick
        Layout.preferredWidth: Math.max(0, Math.min(modules.implicitWidth,
            (root.expanded ? root.expandedMaxWidth : root.maxWidth) - Theme.sectionSpacing - root.pinnedWidth))
        Layout.preferredHeight: modules.implicitHeight
        contentWidth: modules.implicitWidth
        contentHeight: height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick

        WheelHandler {
            onWheel: event => {
                const delta = event.angleDelta.x !== 0 ? event.angleDelta.x : event.angleDelta.y;
                modulesFlick.contentX = Math.max(0, Math.min(modulesFlick.contentWidth - modulesFlick.width, modulesFlick.contentX - delta));
            }
        }

        RowLayout {
            id: modules
            height: parent.height
            spacing: Theme.sectionSpacing

            Wifi {
                id: wifiMod
                readonly property bool collapsed: !(root.expanded || 0 < root.visibleCount)
                clip: true
                enabled: !collapsed
                opacity: collapsed ? 0 : 1
                Layout.preferredWidth: collapsed ? 0 : implicitWidth
                Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
            }
            BluetoothStatus {
                id: btMod
                readonly property bool collapsed: !(root.expanded || 1 < root.visibleCount)
                clip: true
                enabled: !collapsed
                opacity: collapsed ? 0 : 1
                Layout.preferredWidth: collapsed ? 0 : implicitWidth
                Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
            }
            VolumeBrightness {
                id: volMod
                readonly property bool collapsed: !(root.expanded || 2 < root.visibleCount)
                clip: true
                enabled: !collapsed
                opacity: collapsed ? 0 : 1
                Layout.preferredWidth: collapsed ? 0 : implicitWidth
                Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
            }
            Cpu {
                id: cpuMod
                readonly property bool collapsed: !(root.expanded || 3 < root.visibleCount)
                clip: true
                enabled: !collapsed
                opacity: collapsed ? 0 : 1
                Layout.preferredWidth: collapsed ? 0 : implicitWidth
                Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
            }
            Ram {
                id: ramMod
                readonly property bool collapsed: !(root.expanded || 4 < root.visibleCount)
                clip: true
                enabled: !collapsed
                opacity: collapsed ? 0 : 1
                Layout.preferredWidth: collapsed ? 0 : implicitWidth
                Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
            }
            Temperature {
                id: tempMod
                readonly property bool collapsed: !(root.expanded || 5 < root.visibleCount)
                clip: true
                enabled: !collapsed
                opacity: collapsed ? 0 : 1
                Layout.preferredWidth: collapsed ? 0 : implicitWidth
                Behavior on Layout.preferredWidth { NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Theme.animSlow } }
            }
        }
    }

    // Always visible: the overflow menu (only while something's hidden), battery and power.
    RowLayout {
        id: pinned
        spacing: Theme.sectionSpacing

        Pill {
            id: menuIcon
            visible: root.hasOverflow
            icon: Icons.overflowMenu
            // A warn/critical module folded in here tints the whole icon, so the warning stays
            // visible even though the module that raised it currently isn't. Critical wins.
            iconColor: root.hiddenCritical ? Colors.critical : root.hiddenWarn ? Colors.warn : Colors.accent
            statusActive: root.hiddenCritical || root.hiddenWarn
            statusColor: root.hiddenCritical ? Colors.critical : Colors.warn
            active: root.expanded
            onClicked: root.expanded = !root.expanded

            // Hover: read-only preview of what's currently hidden. Click: expand it into the bar instead.
            PopupMenu {
                anchorItem: menuIcon
                open: menuIcon.hovered && root.hasOverflow && !root.expanded
                grabFocus: false

                MenuHeader { text: "Hidden" }
                InfoRow { visible: 0 >= root.visibleCount; label: "Wi-Fi"; value: wifiMod.text }
                InfoRow {
                    visible: 1 >= root.visibleCount
                    label: "Bluetooth"
                    value: btMod.text !== "" ? btMod.text : (btMod.adapter?.enabled ? "No device" : "Off")
                }
                InfoRow {
                    visible: 2 >= root.visibleCount
                    label: "Volume"
                    value: root.muted ? "Muted" : Math.round(root.volumeLevel * 100) + "%"
                }
                InfoRow {
                    visible: 2 >= root.visibleCount && Backlight.available
                    label: "Brightness"
                    value: Math.round(Backlight.level * 100) + "%"
                }
                InfoRow { visible: 3 >= root.visibleCount; label: "CPU"; value: cpuMod.text }
                InfoRow { visible: 4 >= root.visibleCount; label: "Memory"; value: ramMod.text }
                InfoRow { visible: 5 >= root.visibleCount; label: "Temperature"; value: tempMod.text }
            }
        }

        Battery { id: batteryMod }
        Power { id: powerMod }
    }
}
