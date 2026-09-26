pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history menu (SUPER+SHIFT+V), backed by cliphist. `wl-paste --watch cliphist store`
// (started from Hyprland's autostart, alongside quickshell/hyprpaper/hypridle) is what actually records
// copies into cliphist's db -- this singleton only reads from it and copies an entry back out.
Singleton {
    id: root

    property bool visible: false
    property int selectedIndex: -1
    // [{ raw, label }] -- `raw` is cliphist's own "id\tpreview" line, fed back into `cliphist decode`/
    // `delete` unchanged since that's the only input format they accept.
    property var entries: []

    function open() {
        if (visible)
            return;
        visible = true;
        selectedIndex = -1;
        refresh();
    }

    function close() {
        visible = false;
    }

    function toggle() {
        if (visible)
            close();
        else
            open();
    }

    function refresh() {
        listProc.running = true;
    }

    function moveSelection(delta: int) {
        if (entries.length === 0) {
            selectedIndex = -1;
            return;
        }
        selectedIndex = (selectedIndex + delta + entries.length) % entries.length;
    }

    function activateSelected() {
        selectAndCopy(selectedIndex);
    }

    // Copies the entry's full original content to the clipboard -- cliphist's own preview text is
    // truncated/collapsed to one line, so this re-decodes the real bytes from its db rather than just
    // wl-copy'ing the label -- and closes the menu.
    function selectAndCopy(index: int) {
        if (index < 0 || index >= entries.length)
            return;
        copyProc.command = ["sh", "-c", 'printf "%s" "$1" | cliphist decode | wl-copy', "sh", entries[index].raw];
        copyProc.running = true;
        close();
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector { id: listOut }
        onExited: {
            const lines = listOut.text.split("\n").filter(l => l.length > 0);
            root.entries = lines.map(line => {
                const tab = line.indexOf("\t");
                return { raw: line, label: tab >= 0 ? line.substring(tab + 1) : line };
            });
            root.selectedIndex = root.entries.length > 0 ? 0 : -1;
        }
    }

    Process { id: copyProc }
}
