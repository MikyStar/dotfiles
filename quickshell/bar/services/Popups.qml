pragma Singleton
import QtQuick
import Quickshell

// Tracks the open popup so only one click-opened menu is visible at a time.
Singleton {
    property var current: null
}
