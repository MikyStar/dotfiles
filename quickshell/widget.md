# Widgets

## Goal

Now I want to create some desktop widgets that will be displayed in the right hand side of the screen, vertically centered

They have to be dynamic and displayed over the wallpaper, but they have to be behind the applications.

There will be 3 distinct sections

They will be in the same theme as the current QuickShell bar: For the icons use the some color as the one of the pills and the text same color as the text. Also use Nerd Font icons

You will put the code for those widgets under a 'widgets' folder at the same level as 'bar', each widget will have it's own directory under there

## Sections

1. Weather

- Using weather.com
- First row, current weather
- Then, display in an horizontal list below the weather for the each next 24h (with each hour below, temperature and possibility of rain)
- Display on horizontal list for the previsions of the next 7 days (one icon for the morning, one the afernoon, temperature and possibility of rain for morning and afternoon too)
- Below display the city (use Nice France), the last refreshed (like '35 min ago') and a refresh icon button to refresh the data
- Auto refresh every 1h

2. Infos

- Date + hour of last NixOS snapshot + human readable distance from now (like '3 days ago' or '2 months ago')
- Number of snapshots stored
- Number of packages available for updates (*DISCUSS THE STRATEGY FIRST*)

3. Disk space

- Space used over space available for each device
- Displayed as a tree structure like the 'tree command'
- Underline on hover and display an icon of a terminal (on click open kitty at the location of the path) and of a folder (on click open nautilus at the location of the path)
- Add a config file with the list of hardcoded path to display
- By default display space used for:
    - /
    - /home/user
    - /home/user/.cache
    - /home/user/Desktop
    - /home/user/Documents
    - /home/user/Downloads
    - /home/user/Pictures
    - /home/user/Repos (and every folder within (1 depth like /home/user/Repos/dotfiles))
- In additions to the locations under $HOME already pointed above, display the other 5 most heavy folders

4. Endpoints

- A vertical list of URL endpoint status (*DISCUSS THE STRATEGY FIRST*)
- Url with a dot either green (HTTP code 2xx) or red (every other code)
- On hover underline the text and on click opens firefox to the URL
- Add a config file with the list of URLS

> If there's an system wide packages that has to be installed for this NixOS machine to fulfill the above requirements (I'm thinking about cURL for instance), tell them to me before acting on 


## Discussions

### 2. Infos — "NixOS snapshot" & package updates strategy

- **What counts as a "snapshot"?** This host has no btrfs/zfs/snapper/timeshift/restic installed — there's no real filesystem snapshotting configured. What likely exists instead are `nixos-rebuild` **system generations** (`/nix/var/nix/profiles/system-*-link`, 25 of them currently). My assumption: "last snapshot" = last `nixos-rebuild switch/boot`, read from the mtime of the current `system` symlink (or `nixos-rebuild list-generations`), and "number of snapshots" = number of generations kept. Please confirm that's what you meant, vs. wanting to set up actual btrfs/zfs snapshots first (bigger scope, would need a new module in `/etc/nixos`).

> Reponse:
> Exactly, I meant the last nixos-rebuild switch

- **Package updates count** — a few options, roughly cheap → expensive:
  - **A. Stale-lock proxy**: just show how old `/etc/nixos/flake.lock` is (days since last `nix flake update`). Free, no network/build, but not an actual count.
  - **B. Outdated inputs count**: compare locked revisions in `flake.lock` against latest upstream (`nix flake metadata`) — gives "N flake inputs behind", not a package count, and needs a network call per check.
  - **C. Real package diff**: dry-build against updated inputs and diff closures (ideally with `nvd diff`) to get an actual "N packages upgradable" number — most accurate but noticeably heavier (a full evaluation/dry build), so it shouldn't run on every auto-refresh.
  - My lean: **A or B on the hourly auto-refresh, C only on manual refresh click**, to keep the widget cheap by default. `nvd` isn't installed — needed only if we go with C's nicer per-package diff.

> Reponse:
> Go with option B


### 4. Endpoints — status check strategy

- **Polling shape**: rather than one `curl`/process per URL (many concurrent QML `Process` objects), batch all configured URLs into a single refresh cycle (loop over them with `curl -s -o /dev/null -w '%{http_code}' --max-time 3`), so one dead/slow endpoint can't stall the others or the whole widget.
- **Timeout & failure handling**: any timeout, DNS failure, or non-2xx should just render as the red dot — worth confirming that's the desired behavior for unreachable hosts too (vs. a distinct "unknown" state).

> Reponse:
> Yes batch

- **Refresh interval**: not specified in the Goal section — suggest something short like 30–60s given this is just a HEAD/GET, but wanted to confirm before hardcoding it.

> Reponse:
> Go with 5 minutes (But the refresh button triggers them all)

- `curl` is already present system-wide, so no extra package needed for this one.

### 1. Weather — data source

- `weather.com` has no free/official public API to hit directly. Options were: Open-Meteo (free, no key, has current/hourly/daily + precipitation probability), a key-based provider (OpenWeatherMap/WeatherAPI), or a user-supplied weather.com/IBM key.

> Reponse:
> Open-Meteo

### 3. Disk space — "5 most heavy folders" scope

- Ambiguous whether the extra 5 heaviest folders should be scanned across the whole filesystem or just under `$HOME`. Whole-filesystem would surface `/nix/store` (not actionable), so leaned towards `$HOME`-only.

> Reponse:
> Scan $HOME only

### Package check

- `kitty`, `nautilus`, `firefox`, `curl` all already installed system-wide — no NixOS config changes needed.
- `jq` turned out unnecessary for the package-updates check: QML can `JSON.parse()` `nix flake metadata --json` output directly in JS.
