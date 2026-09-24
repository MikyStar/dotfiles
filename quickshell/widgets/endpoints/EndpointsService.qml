pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Batched HTTP status check for the URLs in config.json's "endpoints" -- one `curl` invocation per
// refresh cycle (see widget.md's Discussions) so a single dead/slow endpoint can't stall the others.
Singleton {
    id: root

    readonly property string configPath: Quickshell.shellPath("config.json")

    property bool loading: false
    property date lastUpdated: new Date(NaN)

    // [{ url, code, ok }, ...]
    property var statuses: []

    function refresh() {
        if (loading)
            return;
        loading = true;
        configFile.reload();
    }

    function open(url: string) {
        Quickshell.execDetached(["firefox", url]);
    }

    FileView {
        id: configFile
        path: root.configPath
        onLoaded: {
            let urls = [];
            try {
                urls = JSON.parse(text()).endpoints ?? [];
            } catch (e) {
                urls = [];
            }
            root._check(urls);
        }
    }

    function _check(urls: var) {
        if (urls.length === 0) {
            root.loading = false;
            root.statuses = [];
            return;
        }
        const script = `
for u in "$@"; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$u" 2>/dev/null)
  printf '%s\\t%s\\n' "$u" "\${code:-000}"
done
`;
        checkProc.command = ["sh", "-c", script, "sh"].concat(urls);
        checkProc.running = true;
    }

    Process {
        id: checkProc
        stdout: StdioCollector { id: checkOut }
        onExited: code => {
            root.loading = false;
            root.lastUpdated = new Date();
            const results = [];
            for (const line of checkOut.text.split("\n")) {
                if (line.trim() === "")
                    continue;
                const [url, httpCode] = line.split("\t");
                const n = parseInt(httpCode);
                results.push({ url, code: httpCode, ok: n >= 200 && n < 300 });
            }
            root.statuses = results;
        }
    }

    Timer {
        interval: 300000 // 5min
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
