pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Last NixOS generation switch + how many generations are kept, and how many flake inputs are
// behind upstream (a proxy for "packages available for update" -- see widget.md's Discussions).
Singleton {
    id: root

    readonly property string flakeDir: "/etc/nixos"

    property bool loading: false
    property date lastUpdated: new Date(NaN)

    property date lastGenerationDate: new Date(NaN)
    property int generationCount: 0

    property int outdatedInputs: 0
    property int totalInputs: 0
    property var outdatedNames: []
    property bool checkingUpdates: false

    function refresh() {
        if (loading)
            return;
        loading = true;
        gensProc.running = true;
    }

    Process {
        id: gensProc
        command: ["nixos-rebuild", "list-generations", "--json"]
        stdout: StdioCollector { id: gensOut }
        onExited: code => {
            root.loading = false;
            if (code !== 0 || gensOut.text.trim() === "")
                return;
            try {
                const gens = JSON.parse(gensOut.text);
                root.generationCount = gens.length;
                const current = gens.find(g => g.current) ?? gens[0];
                if (current)
                    root.lastGenerationDate = new Date(current.date.replace(" ", "T"));
                root.lastUpdated = new Date();
            } catch (e) {
                // leave previous values in place
            }
            root.checkUpdates();
        }
    }

    // Non-destructive: copies flake.nix/flake.lock into a scratch dir and runs `nix flake update`
    // there, so the real /etc/nixos is never touched. Diffs locked revisions per top-level input.
    function checkUpdates() {
        if (checkingUpdates)
            return;
        checkingUpdates = true;
        const script = `
set -e
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cp "${flakeDir}/flake.nix" "${flakeDir}/flake.lock" "$tmp/"
cd "$tmp"
nix --extra-experimental-features "nix-command flakes" flake update --flake . >/dev/null 2>&1 || true
echo "===OLD==="
cat "${flakeDir}/flake.lock"
echo "===NEW==="
cat "$tmp/flake.lock"
`;
        updateProc.command = ["sh", "-c", script];
        updateProc.running = true;
    }

    Process {
        id: updateProc
        stdout: StdioCollector { id: updateOut }
        onExited: code => {
            root.checkingUpdates = false;
            if (code !== 0)
                return;
            const parts = updateOut.text.split("===NEW===");
            if (parts.length !== 2)
                return;
            try {
                const oldLock = JSON.parse(parts[0].replace("===OLD===", "").trim());
                const newLock = JSON.parse(parts[1].trim());
                const inputs = Object.keys(oldLock.nodes.root.inputs);
                const outdated = inputs.filter(name => {
                    const oldRev = oldLock.nodes[name]?.locked?.rev ?? oldLock.nodes[name]?.locked?.narHash;
                    const newRev = newLock.nodes[name]?.locked?.rev ?? newLock.nodes[name]?.locked?.narHash;
                    return oldRev !== newRev;
                });
                root.totalInputs = inputs.length;
                root.outdatedInputs = outdated.length;
                root.outdatedNames = outdated;
            } catch (e) {
                // leave previous values in place
            }
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
