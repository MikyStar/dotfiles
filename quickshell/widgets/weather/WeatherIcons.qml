pragma Singleton
import QtQuick
import Quickshell

// Maps Open-Meteo's WMO weather codes to Nerd Font (Font Awesome) glyphs.
// https://open-meteo.com/en/docs -> "WMO Weather interpretation codes"
Singleton {
    readonly property string sun: ""
    readonly property string moon: ""
    readonly property string cloud: ""
    readonly property string cloudSun: ""
    readonly property string cloudMoon: ""
    readonly property string rain: ""
    readonly property string snow: ""
    readonly property string fog: ""
    readonly property string storm: ""
    readonly property string drop: ""

    // code: WMO weather code. isDay: whether to pick the day or night variant where one exists.
    function forCode(code: int, isDay: bool): string {
        if (code === 0)
            return isDay ? sun : moon;
        if (code <= 3)
            return isDay ? cloudSun : cloudMoon;
        if (code === 45 || code === 48)
            return fog;
        if (code >= 51 && code <= 67)
            return rain;
        if (code >= 71 && code <= 77)
            return snow;
        if (code >= 80 && code <= 82)
            return rain;
        if (code >= 85 && code <= 86)
            return snow;
        if (code >= 95)
            return storm;
        return cloud;
    }
}
