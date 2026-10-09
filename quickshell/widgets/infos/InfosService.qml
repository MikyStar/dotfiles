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

    // Git status of flakeDir itself (it's commonly tracked in git). gitOk is false when flakeDir
    // isn't a repo at all, in which case the widget just hides the row rather than showing "0 dirty".
    property bool gitOk: false
    property bool gitChecking: false
    property int gitDirtyCount: 0

    function refresh() {
        if (loading)
            return;
        loading = true;
        gensProc.running = true;
        gitChecking = true;
        gitProc.running = true;
    }

    Process {
        id: gitProc
        command: ["git", "-C", flakeDir, "status", "--porcelain"]
        stdout: StdioCollector { id: gitOut }
        onExited: code => {
            root.gitChecking = false;
            root.gitOk = code === 0;
            if (code !== 0)
                return;
            const text = gitOut.text.trim();
            root.gitDirtyCount = text === "" ? 0 : text.split("\n").length;
        }
    }

    // Opens a terminal in flakeDir with the flake-lock update command for every outdated input
    // pre-filled on the prompt line (scripts/prompt-run.sh) rather than run outright, so the user
    // reviews/edits it before pressing enter. The command text travels as a plain positional argv
    // entry -- never spliced into a script string, and with no "-c"/dash-led token for kitty's own
    // arg parser to trip over -- so nothing in an input's name can break out of the intended command
    // (same convention as DiskService's scan script). Runs under the user's actual login shell
    // (whatever $SHELL is -- prompt-run.sh itself picks the right pre-fill mechanism for it), not a
    // hardcoded bash, so the user lands in their normal shell when they're done.
    function openUpdateTerminal() {
        if (outdatedNames.length === 0)
            return;
        // Not outdatedNames.flatMap(...): this QML/JS engine doesn't implement Array.prototype.flatMap,
        // and it fails silently (Quickshell's stdout/stderr aren't visible anywhere) -- the whole function
        // was throwing right here and never reaching execDetached below.
        const updateArgs = [];
        for (const name of outdatedNames)
            updateArgs.push("--update-input", name);
        // sudo: updating the flake lock itself doesn't need it, but switching the system afterwards
        // does, and the user wants it pre-applied here rather than typed in again at that point.
        const cmd = ["sudo", "nix", "flake", "lock"].concat(updateArgs).join(" ");
        const script = Quickshell.shellPath("scripts/prompt-run.sh");
        const shell = Quickshell.env("SHELL") || "bash";
        // --hold: if the script errors out immediately (e.g. bad path), the window stays open
        // showing why instead of flashing and vanishing before it can be read.
        Quickshell.execDetached(["kitty", "--hold", "--directory", flakeDir, shell, script, cmd]);
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

    // Checked every minute rather than waited out as a single 1h interval: QML timers run on
    // a monotonic clock that doesn't advance during suspend, so a bare 1h repeat can go long
    // stretches of wall-clock time without firing on a machine that's mostly asleep. Polling
    // wall-clock elapsed time instead makes refreshes self-correct right after resume.
    Timer {
        interval: 60000 // 1m
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (isNaN(root.lastUpdated.getTime()) || Date.now() - root.lastUpdated.getTime() >= 3600000)
                root.refresh();
        }
    }
}
