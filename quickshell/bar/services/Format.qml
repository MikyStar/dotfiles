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
}
