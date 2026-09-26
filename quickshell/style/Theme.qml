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

    // Desktop widgets (right-hand side column: weather / endpoints; left-hand side: infos / disk)
    readonly property int widgetWidth: 300
    readonly property int widgetMargin: 16
    readonly property int widgetSpacing: 24
    readonly property int widgetRadius: popupRadius
    readonly property int widgetPadding: popupPadding

    // Notification toast popups (top-right corner banners for incoming notifications)
    readonly property int toastWidth: 320
    readonly property int toastGap: 10
    readonly property int toastAutoDismissMs: 5000
    readonly property int toastSlideDuration: 260
    readonly property int toastFadeDuration: 180
    // How far a toast travels during its slide in/out -- deliberately less than toastWidth: the popup
    // window is exactly toastWidth wide (anchored flush to the screen's right edge), so an offset any
    // larger than this would mostly land outside that surface and just get clipped instead of sliding.
    readonly property int toastSlideDistance: 56

    // Clipboard history menu (SUPER+SHIFT+V) -- positioned/sized like the finder overlay below, but
    // its rows are a single line of preview text rather than an icon + label + sublabel.
    readonly property int clipboardMaxRows: 10
    readonly property int clipboardRowHeight: 36

    // Finder overlay
    readonly property int finderWidth: 640
    readonly property int finderMaxResultRows: 8
    readonly property int finderResultRowHeight: 44
    // Fraction of screen height down from the top. Deliberately independent of the box's own (variable,
    // result-count-dependent) height, so the search field never shifts on screen as the list grows/shrinks --
    // see Finder.qml's `box.y`.
    readonly property real finderTopFraction: 0.26
}
