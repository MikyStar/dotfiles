pragma Singleton
import QtQuick
import Quickshell

// Maps Open-Meteo's WMO weather codes to a transparent SVG icon under icons/, rendered via Image
// rather than a Nerd Font glyph. Several of the glyph codepoints this used to rely on (cloud-sun,
// cloud-moon, rain, fog) simply aren't present in the installed JetBrainsMono Nerd Font -- confirmed
// with `fc-match ":charset=<codepoint>"` falling back to unrelated fonts -- so they always rendered
// as missing-glyph boxes. SVGs sidestep font coverage entirely.
Singleton {
    id: root

    readonly property string _dir: Quickshell.shellPath("widgets/weather/icons")

    readonly property string sun: root._dir + "/sun.svg"
    readonly property string moon: root._dir + "/moon.svg"
    readonly property string cloud: root._dir + "/cloud.svg"
    readonly property string cloudSun: root._dir + "/cloud-sun.svg"
    readonly property string cloudMoon: root._dir + "/cloud-moon.svg"
    readonly property string rain: root._dir + "/rain.svg"
    readonly property string snow: root._dir + "/snow.svg"
    readonly property string fog: root._dir + "/fog.svg"
    readonly property string storm: root._dir + "/storm.svg"
    readonly property string drop: root._dir + "/drop.svg"

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
