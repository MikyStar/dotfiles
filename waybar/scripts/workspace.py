#!/usr/bin/env python3
"""Waybar module showing the content of a single Hyprland workspace.

Usage: waybar-workspace <workspace-id>

The script stays alive, listens to Hyprland's event socket and prints one
JSON line for Waybar whenever the rendered state changes:

* empty workspace  -> hollow dot if focused, hidden otherwise
* one window       -> icon of the application
* several windows  -> one dot per window (capped at MAX_DOTS)
"""

import json
import os
import socket
import subprocess
import sys

DOT = "\u25cf"  # ●
EMPTY_DOT = "\u25cb"  # ○
MAX_DOTS = 4
FALLBACK_ICON = "\uf2d0"

# Hyprland window class (lowercase) -> Nerd Font glyph.
APP_ICONS = {
    "firefox": "\uf269",
    "librewolf": "\uf269",
    "chromium": "\uf268",
    "google-chrome": "\uf268",
    "brave-browser": "\uf268",
    "kitty": "\uf120",
    "alacritty": "\uf120",
    "foot": "\uf120",
    "wezterm": "\uf120",
    "com.mitchellh.ghostty": "\uf120",
    "code": "\ue70c",
    "codium": "\ue70c",
    "discord": "\uf392",
    "spotify": "\uf1bc",
    "org.telegram.desktop": "\uf2c6",
    "steam": "\uf1b6",
    "thunar": "\uf07b",
    "org.gnome.nautilus": "\uf07b",
    "dolphin": "\uf07b",
    "mpv": "\uf008",
    "vlc": "\uf008",
    "thunderbird": "\uf0e0",
    "org.pwmt.zathura": "\uf1c1",
    "obsidian": "\uf15c",
}

# Events after which the content of a workspace may have changed.
REFRESH_EVENTS = {
    "workspace",
    "workspacev2",
    "focusedmon",
    "openwindow",
    "closewindow",
    "movewindow",
    "movewindowv2",
    "activewindow",  # window classes can be set slightly after opening
}


def hyprctl_json(command):
    """Run `hyprctl -j <command>` and return the parsed output."""
    return json.loads(subprocess.check_output(["hyprctl", "-j", command]))


def focused_workspace_id():
    monitors = hyprctl_json("monitors")
    focused = next((m for m in monitors if m["focused"]), monitors[0])
    return focused["activeWorkspace"]["id"]


def windows_on(workspace_id):
    return [
        client
        for client in hyprctl_json("clients")
        if client["mapped"] and client["workspace"]["id"] == workspace_id
    ]


def render(workspace_id):
    """Return the Waybar JSON payload (as a dict) for one workspace."""
    windows = windows_on(workspace_id)
    is_focused = focused_workspace_id() == workspace_id

    if not windows:
        text = EMPTY_DOT if is_focused else ""
    elif len(windows) == 1:
        text = APP_ICONS.get(windows[0]["class"].lower(), FALLBACK_ICON)
    else:
        text = " ".join([DOT] * min(len(windows), MAX_DOTS))

    return {
        "text": text,
        "class": "active" if is_focused else "",
        "tooltip": "\n".join(w["class"] for w in windows),
    }


def hypr_events():
    """Yield the name of every event emitted by Hyprland."""
    runtime_dir = os.environ["XDG_RUNTIME_DIR"]
    signature = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
    path = f"{runtime_dir}/hypr/{signature}/.socket2.sock"

    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as sock:
        sock.connect(path)
        for line in sock.makefile("r", encoding="utf-8"):
            yield line.split(">>", 1)[0]  # format: "name>>data"


def states(workspace_id):
    """Yield the module state now, then again each time it changes."""
    last = render(workspace_id)
    yield last

    for event in hypr_events():
        if event not in REFRESH_EVENTS:
            continue
        state = render(workspace_id)
        if state != last:
            last = state
            yield state


def main():
    workspace_id = int(sys.argv[1])
    for state in states(workspace_id):
        print(json.dumps(state), flush=True)


if __name__ == "__main__":
    main()
