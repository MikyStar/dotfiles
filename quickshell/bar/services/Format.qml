pragma Singleton
import QtQuick
import Quickshell

// Small formatting helpers shared by modules.
Singleton {
    function speed(bytesPerSec: real): string {
        if (bytesPerSec < 1024)
            return Math.round(bytesPerSec) + "B";
        if (bytesPerSec < 1024 * 1024)
            return Math.round(bytesPerSec / 1024) + "K";
        return (bytesPerSec / 1024 / 1024).toFixed(1) + "M";
    }

    function duration(seconds: real): string {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    // Playback position: m:ss, or h:mm:ss from one hour up.
    function clock(seconds: real): string {
        const total = Math.max(0, Math.floor(seconds));
        const h = Math.floor(total / 3600);
        const m = Math.floor((total % 3600) / 60);
        const s = String(total % 60).padStart(2, "0");
        return h > 0 ? `${h}:${String(m).padStart(2, "0")}:${s}` : `${m}:${s}`;
    }

    // Byte count -> "35.2G" etc, stepping units at 1024.
    function bytes(value: real): string {
        const units = ["B", "K", "M", "G", "T"];
        let n = value, i = 0;
        while (n >= 1024 && i < units.length - 1) {
            n /= 1024;
            i++;
        }
        return (i === 0 ? Math.round(n) : n.toFixed(1)) + units[i];
    }

    // Human-relative distance from `date` to now, e.g. "35 min ago", "3 days ago", "2 months ago".
    function timeAgo(date: date): string {
        if (!date || isNaN(date.getTime()))
            return "never";
        const seconds = Math.max(0, (Date.now() - date.getTime()) / 1000);
        const steps = [
            [60, "just now", null],
            [3600, "min", 60],
            [86400, "hour", 3600],
            [2592000, "day", 86400],
            [31536000, "month", 2592000],
        ];
        for (const [limit, unit, div] of steps) {
            if (seconds < limit)
                return div === null ? unit : `${Math.floor(seconds / div)} ${unit}${Math.floor(seconds / div) !== 1 ? "s" : ""} ago`;
        }
        const years = Math.floor(seconds / 31536000);
        return `${years} year${years !== 1 ? "s" : ""} ago`;
    }
}
