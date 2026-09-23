import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.style
import qs.bar.components
import qs.bar.services

// Hovering shows the time until full (charging) or until empty (discharging). Clicking opens the
// power-profiles-daemon performance profile picker.
Pill {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property real percent: device.percentage * 100
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    // On mains power. A full battery reports "fully charged" rather than "charging", but should still show the bolt.
    readonly property bool pluggedIn: !UPower.onBattery
    readonly property bool low: !pluggedIn && percent < 20
    readonly property bool warnLevel: !pluggedIn && percent < 30
    readonly property color levelColor: low ? Colors.critical : warnLevel ? Colors.warn : Colors.accent
    readonly property real seconds: charging ? device.timeToFull : device.timeToEmpty

    // Balanced and Power Saver are always available; Performance is left out when the hardware/
    // firmware doesn't support it (PowerProfiles.hasPerformanceProfile).
    readonly property var _profiles: [PowerProfile.Performance, PowerProfile.Balanced, PowerProfile.PowerSaver]
        .filter(p => p !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
    readonly property var _profileIcon: ({
        [PowerProfile.Performance]: Icons.profilePerformance,
        [PowerProfile.Balanced]: Icons.profileBalanced,
        [PowerProfile.PowerSaver]: Icons.profilePowerSaver
    })
    readonly property var _profileLabel: ({
        [PowerProfile.Performance]: "Performance",
        [PowerProfile.Balanced]: "Balanced",
        [PowerProfile.PowerSaver]: "Power Saver"
    })

    visible: device.ready && device.isPresent
    icon: Icons.battery(percent, pluggedIn)
    iconColor: warnLevel ? levelColor : Colors.accent
    textColor: warnLevel ? levelColor : Colors.text
    statusActive: warnLevel
    statusColor: levelColor
    text: Math.round(percent) + "%"
    contentSpacing: Theme.iconTextSpacing
    reserveText: "100%"
    active: menu.open
    onClicked: menu.toggle()

    // Hover: read-only time remaining/to full. Click: switch to the profile picker instead.
    PopupMenu {
        anchorItem: root
        open: root.hovered && !menu.open
        grabFocus: false

        MenuHeader { text: root.charging ? "Charging" : root.pluggedIn ? "Plugged in" : "On battery" }
        InfoRow {
            visible: !root.pluggedIn || root.charging
            label: root.charging ? "Time to full" : "Time remaining"
            value: root.seconds > 0 ? Format.duration(root.seconds) : "Calculating…"
        }
    }

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader { Layout.minimumWidth: 180; text: "Power Profile" }

        Repeater {
            model: root._profiles

            MenuButton {
                required property var modelData
                icon: root._profileIcon[modelData]
                iconColor: highlighted ? Colors.accent : Colors.textDim
                text: root._profileLabel[modelData]
                highlighted: PowerProfiles.profile === modelData
                onClicked: { PowerProfiles.profile = modelData; menu.close(); }
            }
        }
    }
}
