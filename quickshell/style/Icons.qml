pragma Singleton
import QtQuick
import Quickshell

// Nerd Font glyphs (JetBrainsMono Nerd Font), written as \u escapes.
Singleton {
    // Bar modules
    readonly property string calendar: "\uf073"
    readonly property string bell: "\uf0f3"
    readonly property string wifi: "\uf1eb"
    readonly property string bluetooth: "\uf293"
    readonly property string cpu: "\uf2db"
    readonly property string memory: "\udb80\udf5b" // nf-md-memory, outside the BMP so written as a surrogate pair
    readonly property string thermometer: "\uf2c9"
    readonly property string power: "\uf011"
    readonly property string music: "\uf001"

    // Volume
    readonly property string volumeHigh: "\uf028"
    readonly property string volumeLow: "\uf027"
    readonly property string volumeOff: "\uf026"

    // Battery
    readonly property string batteryFull: "\uf240"
    readonly property string battery75: "\uf241"
    readonly property string battery50: "\uf242"
    readonly property string battery25: "\uf243"
    readonly property string batteryEmpty: "\uf244"
    readonly property string bolt: "\uf0e7"

    // Media controls
    readonly property string play: "\uf04b"
    readonly property string pause: "\uf04c"
    readonly property string previous: "\uf048"
    readonly property string next: "\uf051"

    // Power menu
    readonly property string lock: "\uf023"
    readonly property string reboot: "\uf021"
    readonly property string shutdown: "\uf011"

    // Misc
    readonly property string dot: "\uf111"
    readonly property string arrowDown: "\uf063"
    readonly property string arrowUp: "\uf062"
    readonly property string chevronLeft: "\uf053"
    readonly property string chevronRight: "\uf054"
    readonly property string close: "\uf00d"
    readonly property string trash: "\uf1f8"
    readonly property string headphones: "\uf025"

    function volume(level: real, muted: bool): string {
        if (muted || level <= 0)
            return volumeOff;
        return level > 0.5 ? volumeHigh : volumeLow;
    }

    function battery(percent: real, charging: bool): string {
        if (charging)
            return bolt;
        if (percent > 87)
            return batteryFull;
        if (percent > 62)
            return battery75;
        if (percent > 37)
            return battery50;
        if (percent > 12)
            return battery25;
        return batteryEmpty;
    }
}
