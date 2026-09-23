pragma Singleton
import QtQuick
import Quickshell

// Sizes, spacing, fonts and animation constants.
Singleton {
    // Fonts
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int iconSize: 15

    // Bar
    readonly property int barMargin: 6
    readonly property int pillHeight: 30
    readonly property int barHeight: pillHeight + barMargin * 2
    readonly property int pillRadius: pillHeight / 2
    readonly property int pillPadding: 12
    readonly property int pillSpacing: 6
    // Extra room for icons flagged via Icons.needsEdgePadding when they sit against a pill's rounded edge.
    readonly property int iconEdgePadding: 6
    // Gap between the icon and the value in the status pills (volume, CPU, ...).
    readonly property int iconTextSpacing: 3
    readonly property int sectionSpacing: 8
    // Minimum free space between the left, center and right zones.
    readonly property int zoneGap: 24

    // Popups
    readonly property int popupGap: 8
    readonly property int popupTop: barMargin + pillHeight + popupGap
    readonly property int popupRadius: 16
    readonly property int popupPadding: 14
    readonly property int popupSpacing: 8

    // Animation
    readonly property int animFast: 120
    // Overflow menu: modules collapsing into it / expanding back out.
    readonly property int animSlow: 260
}
