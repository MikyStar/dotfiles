pragma Singleton
import QtQuick
import Quickshell

// Nerd Font glyphs (JetBrainsMono Nerd Font), written as \u escapes.
Singleton {
    // Bar modules
    readonly property string calendar: "\uf073"
    readonly property string bell: "\uf0f3"
    readonly property string wifi: "\uf1eb"
    readonly property string bluetoothOff: "\udb80\udcb2"
    readonly property string bluetoothOn: "\uf294"
    readonly property string bluetoothPaired: "\udb80\udcb1"
    readonly property string cpu: "\uf2db"
    readonly property string memory: "\uefc5"
    readonly property string thermometer: "\uf2c9"
    readonly property string power: "\uf011"
    readonly property string music: "\uf001"
    readonly property string nixos: "\uf313"

    // Volume
    readonly property string volumeHigh: "\uf028"
    readonly property string volumeLow: "\uf027"
    readonly property string volumeOff: "\uf026"

    // Brightness (nf-md-brightness_4..7, outside the BMP so written as surrogate pairs)
    readonly property string brightnessLow: "\udb80\udcdd"
    readonly property string brightnessMedium: "\udb80\udcde"
    readonly property string brightnessHigh: "\udb80\udcdf"
    readonly property string brightnessFull: "\udb80\udce0"

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

    // power-profiles-daemon profiles
    readonly property string profilePerformance: "\uf135"
    readonly property string profileBalanced: "\uf24e"
    readonly property string profilePowerSaver: "\uf06c"

    // Misc
    readonly property string overflowMenu: "\uf141"
    readonly property string dot: "\uf111"
    readonly property string dotEmpty: "\uf10c"
    readonly property string arrowDown: "\uf063"
    readonly property string arrowUp: "\uf062"
    readonly property string chevronLeft: "\uf053"
    readonly property string chevronRight: "\uf054"
    readonly property string close: "\uf00d"
    readonly property string trash: "\uf1f8"
    readonly property string headphones: "\uf025"
    readonly property string refresh: "\uf021"
    readonly property string terminal: "\uf120"
    readonly property string folder: "\uf07b"
    readonly property string externalLink: "\uf08e"
    readonly property string search: "\uf002"

    // Finder result icons: generic/default file plus a few type-specific ones, keyed off extension by
    // FinderService._pathIcon. All Font Awesome 4 glyphs (stable across Nerd Font patches).
    readonly property string fileGeneric: "\uf016"
    readonly property string filePdf: "\uf1c1"
    readonly property string fileWord: "\uf1c2"
    readonly property string fileExcel: "\uf1c3"
    readonly property string filePowerpoint: "\uf1c4"
    readonly property string fileImage: "\uf1c5"
    readonly property string fileArchive: "\uf1c6"
    readonly property string fileAudio: "\uf1c7"
    readonly property string fileVideo: "\uf1c8"
    readonly property string calculator: "\uf1ec"

    // Per-extension language glyphs for text/code files in the finder (FinderService._pathIcon), so
    // e.g. a .py file shows the Python logo rather than the generic fileGeneric glyph above. Seti-UI/
    // Devicon/custom Nerd Font glyphs, chosen (and verified against nerd-fonts' glyphnames.json) over
    // Material Design equivalents so each stays a single BMP code point, no surrogate pairs needed.
    readonly property string langPython: "\ue606"
    readonly property string langJavascript: "\ue60c"
    readonly property string langTypescript: "\ue628"
    readonly property string langShell: "\ue691"
    readonly property string langLua: "\ue620"
    readonly property string langC: "\ue649"
    readonly property string langCpp: "\ue646"
    readonly property string langRust: "\ue68b"
    readonly property string langGo: "\ue627"
    readonly property string langJava: "\ue66d"
    readonly property string langKotlin: "\ue634"
    readonly property string langSwift: "\ue699"
    readonly property string langRuby: "\ue739"
    readonly property string langPhp: "\ue73d"
    readonly property string langJson: "\ue60b"
    readonly property string langYaml: "\ue6a8"
    readonly property string langToml: "\ue6b2"
    readonly property string langConfig: "\ue615"
    readonly property string langHtml: "\ue60e"
    readonly property string langCss: "\ue614"
    readonly property string langSass: "\ue603"
    readonly property string langMarkdown: "\ue609"
    readonly property string langXml: "\ue619"
    readonly property string langSql: "\ue64d"
    readonly property string langQml: "\ue87d"

    // Extension (lowercased, no dot) -> language glyph above.
    readonly property var _langMap: ({
        "js": langJavascript, "jsx": langJavascript, "mjs": langJavascript, "cjs": langJavascript,
        "ts": langTypescript, "tsx": langTypescript,
        "py": langPython,
        "sh": langShell, "bash": langShell, "zsh": langShell,
        "qml": langQml,
        "lua": langLua,
        "c": langC, "h": langC,
        "cpp": langCpp, "hpp": langCpp, "cc": langCpp, "cxx": langCpp,
        "rs": langRust,
        "go": langGo,
        "java": langJava,
        "kt": langKotlin,
        "swift": langSwift,
        "rb": langRuby,
        "php": langPhp,
        "json": langJson,
        "yaml": langYaml, "yml": langYaml,
        "toml": langToml,
        "ini": langConfig, "conf": langConfig,
        "html": langHtml,
        "css": langCss,
        "scss": langSass,
        "md": langMarkdown,
        "xml": langXml,
        "sql": langSql,
    })

    // Language-specific glyph for a lowercased file extension, or "" when none is recognized (the
    // caller falls back to a generic file glyph -- see FinderService._pathIcon). Guarded with
    // hasOwnProperty since a bare `_langMap[ext]` would return an inherited Object.prototype member
    // (e.g. a function) for an ext like "constructor" instead of undefined.
    function language(ext: string): string {
        return Object.prototype.hasOwnProperty.call(_langMap, ext) ? _langMap[ext] : "";
    }

    function bluetooth(enabled: bool, paired: bool): string {
        if (!enabled)
            return bluetoothOff;
        return paired ? bluetoothPaired : bluetoothOn;
    }

    function volume(level: real, muted: bool): string {
        if (muted || level <= 0)
            return volumeOff;
        return level > 0.5 ? volumeHigh : volumeLow;
    }

    function brightness(level: real): string {
        if (level > 0.85)
            return brightnessFull;
        if (level > 0.6)
            return brightnessHigh;
        if (level > 0.25)
            return brightnessMedium;
        return brightnessLow;
    }

    // App icons for the workspace indicator (one window per workspace shows its app's glyph instead of a dot).
    readonly property string appFirefox: "\uf269"
    readonly property string appTor: "\uf1d5"
    readonly property string appDocker: "\uf21f"
    readonly property string appTerminal: "\uf120"
    readonly property string appFiles: "\uf07b"
    readonly property string appVlc: "\uf008"
    readonly property string appChrome: "\uf268"
    readonly property string appCode: "\uf0da"
    readonly property string appSpotify: "\uf1bc"
    readonly property string appDiscord: "\uf1ff"
    readonly property string appSteam: "\uf1b6"
    readonly property string appMail: "\uf0e0"
    readonly property string appSettings: "\uf013"
    readonly property string appUnknown: "\uf128"

    // Substring matches against a window's app id/class (lowercased), checked in order. First match wins.
    readonly property var _appMap: [
        [["firefox"], appFirefox],
        [["tor browser", "torbrowser"], appTor],
        [["docker"], appDocker],
        [["kitty", "alacritty", "foot", "wezterm", "xterm", "konsole", "gnome-terminal", "terminal"], appTerminal],
        [["nautilus", "org.gnome.files", "thunar", "nemo", "pcmanfm", "dolphin", "file-manager", "files"], appFiles],
        [["vlc"], appVlc],
        [["chromium", "google-chrome", "chrome"], appChrome],
        [["code", "vscode", "codium"], appCode],
        [["spotify"], appSpotify],
        [["discord"], appDiscord],
        [["steam"], appSteam],
        [["thunderbird", "mail"], appMail],
        [["gnome-control-center", "settings"], appSettings],
    ]

    // Maps a window's app id/class to a Nerd Font glyph, falling back to a question mark when unmapped.
    function app(appClass: string): string {
        const cls = appClass.toLowerCase();
        for (const entry of _appMap) {
            const [patterns, icon] = entry;
            if (patterns.some(p => cls.includes(p)))
                return icon;
        }
        return appUnknown;
    }

    // Icons that look cramped when they land against a pill's rounded edge (e.g. the first/last
    // workspace in the bar) and want a bit more horizontal padding on that side. Add more icons
    // here as the same issue shows up elsewhere.
    readonly property var edgePaddingIcons: [appTerminal]

    function needsEdgePadding(icon: string): bool {
        return edgePaddingIcons.includes(icon);
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
