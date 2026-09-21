pragma Singleton
import QtQuick
import Quickshell

// Palette. Surfaces are translucent so Hyprland's layerrule blur shows through.
Singleton {
    // Surfaces
    readonly property color pill: Qt.rgba(0.16, 0.16, 0.18, 0.55)
    readonly property color pillHover: Qt.rgba(0.32, 0.32, 0.36, 0.70)
    readonly property color pillBorder: Qt.rgba(1, 1, 1, 0.08)
    readonly property color panel: Qt.rgba(0.12, 0.12, 0.14, 0.72)
    readonly property color panelBorder: Qt.rgba(1, 1, 1, 0.10)
    readonly property color item: Qt.rgba(1, 1, 1, 0.06)
    readonly property color itemHover: Qt.rgba(1, 1, 1, 0.14)

    // Text
    readonly property color text: "#b3b3b3"
    readonly property color textDim: "#7d7d7d"

    readonly property color scrollbar: Qt.rgba(1, 1, 1, 0.35)
    // Glow behind the app icons of the workspace indicator.
    readonly property color iconShadow: "#050505"

    // Accents
    readonly property color accent: "#525252"
    readonly property color good: "#8fd18f"
    readonly property color warn: "#f0c674"
    readonly property color critical: "#f07178"
}
