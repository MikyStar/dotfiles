pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Current + hourly + 7-day forecast, from Open-Meteo (free, no API key needed), for the location
// configured in config.json's "weather" section.
// https://open-meteo.com/en/docs
Singleton {
    id: root

    readonly property string configPath: Quickshell.shellPath("config.json")

    property string city: ""
    property real latitude: 0
    property real longitude: 0
    property string timezone: "UTC"

    property bool loading: false
    property string error: ""
    property date lastUpdated: new Date(NaN)

    property real currentTemp: 0
    property int currentCode: 0
    property bool currentIsDay: true

    // [{ time, temp, precip, code, isDay }, ...] -- the 24 hours after the current one.
    property var hourly: []
    // [{ date, morning: {temp, precip, code}, afternoon: {temp, precip, code} }, ...] -- next 7 days.
    property var daily: []

    function refresh() {
        if (loading)
            return;
        loading = true;
        error = "";
        configFile.reload();
    }

    FileView {
        id: configFile
        path: root.configPath
        onLoaded: {
            try {
                const w = JSON.parse(text()).weather ?? {};
                root.city = w.city ?? "";
                root.latitude = w.latitude ?? 0;
                root.longitude = w.longitude ?? 0;
                root.timezone = w.timezone ?? "UTC";
            } catch (e) {
                root.error = "Bad config";
                root.loading = false;
                return;
            }
            root._fetch();
        }
    }

    function _fetch() {
        const url = "https://api.open-meteo.com/v1/forecast"
            + `?latitude=${root.latitude}&longitude=${root.longitude}`
            + "&current=temperature_2m,weather_code,is_day"
            + "&hourly=temperature_2m,precipitation_probability,weather_code,is_day"
            + `&timezone=${encodeURIComponent(root.timezone)}&forecast_days=8`;
        fetchProc.command = ["curl", "-s", "--max-time", "10", url];
        fetchProc.running = true;
    }

    function _parse(text: string) {
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            error = "Bad response";
            return;
        }
        if (!data.current || !data.hourly) {
            error = data.reason || "No data";
            return;
        }

        currentTemp = data.current.temperature_2m;
        currentCode = data.current.weather_code;
        currentIsDay = data.current.is_day === 1;

        const h = data.hourly;
        const now = new Date();
        // First hourly slot strictly after the current hour.
        let startIdx = h.time.findIndex(t => new Date(t) > now);
        if (startIdx < 0)
            startIdx = 0;

        const nextHours = [];
        for (let i = startIdx; i < h.time.length && nextHours.length < 24; i++) {
            nextHours.push({
                time: new Date(h.time[i]),
                temp: h.temperature_2m[i],
                precip: h.precipitation_probability[i],
                code: h.weather_code[i],
                isDay: h.is_day[i] === 1,
            });
        }
        hourly = nextHours;

        // Bucket the remaining hourly data by calendar day, then pick the 9:00/15:00 slots for the
        // next 7 days (today, already covered by "current" + the next-24h list above, is skipped).
        const todayKey = h.time[0].slice(0, 10);
        const byDay = {};
        for (let i = 0; i < h.time.length; i++) {
            const key = h.time[i].slice(0, 10);
            if (key === todayKey)
                continue;
            const hour = new Date(h.time[i]).getHours();
            if (hour !== 9 && hour !== 15)
                continue;
            if (!byDay[key])
                byDay[key] = {};
            const slot = { temp: h.temperature_2m[i], precip: h.precipitation_probability[i], code: h.weather_code[i] };
            byDay[key][hour === 9 ? "morning" : "afternoon"] = slot;
        }
        daily = Object.keys(byDay).sort().slice(0, 7).map(key => ({
            date: new Date(key + "T12:00"),
            morning: byDay[key].morning ?? null,
            afternoon: byDay[key].afternoon ?? null,
        }));

        lastUpdated = now;
    }

    Process {
        id: fetchProc
        stdout: StdioCollector {
            id: stdout
        }
        onExited: code => {
            root.loading = false;
            if (code === 0 && stdout.text.trim() !== "")
                root._parse(stdout.text);
            else if (root.error === "")
                root.error = "Fetch failed";
        }
    }

    Timer {
        interval: 3600000 // 1h
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
