pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Unread mail across every IMAP account configured in Thunderbird, polled directly over IMAP
// (scripts/mail-sync.py) so it stays in sync without Thunderbird running. See that script's
// docstring for how accounts/credentials are resolved.
Singleton {
    id: root

    property int count: 0
    property var messages: []   // [{ from, subject, date, account }], most recent first
    property var accounts: []   // [{ name, count, error }]
    property bool loading: false

    function refresh() {
        if (loading)
            return;
        loading = true;
        proc.running = true;
    }

    Process {
        id: proc
        command: ["python3", Quickshell.shellPath("scripts/mail-sync.py")]
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                root.loading = false;
                try {
                    const result = JSON.parse(collector.text);
                    root.count = result.count ?? 0;
                    root.messages = result.messages ?? [];
                    root.accounts = result.accounts ?? [];
                } catch (e) {
                    // Parse hiccup (e.g. a transient script crash) -- keep the previous values
                    // rather than blanking the pill until the next successful poll.
                }
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
