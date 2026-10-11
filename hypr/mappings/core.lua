local C = require("constants")

hl.bind(C.mainMod .. " + Return", hl.dsp.exec_cmd(C.terminal))

-- Tap-SUPER-alone launcher: bound to the modifier key's own keysym with `release = true`, so it
-- only fires once SUPER_L is released -- any other key pressed while SUPER is held (workspace
-- switches, SUPER+Q, etc.) consumes that combo first and suppresses this release-bind, so the two
-- never conflict even though they share the same modifier.
hl.bind(C.mainMod .. " + SUPER_L", hl.dsp.exec_cmd(C.launcher), { release = true })
hl.bind(C.mainMod .. " + SUPER_R", hl.dsp.exec_cmd(C.launcher), { release = true })
hl.bind(C.mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(C.clipboardMenu))
hl.bind(C.mainMod .. " + Q", hl.dsp.window.close())
hl.bind(C.mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- withUWSM = true in configuration.nix, so quit via uwsm rather than the
-- raw exit dispatcher (calling hl.dsp.exit() directly can leave the
-- systemd session in a bad state)
hl.bind(C.mainMod .. " + M", hl.dsp.exec_cmd("uwsm stop"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind(C.mainMod .. "+ F", hl.dsp.window.fullscreen())

-- Routed through loginctl (not hyprlock directly) so hypridle's lock_cmd
-- guard (pidof hyprlock || hyprlock) is what actually spawns it, avoiding
-- a duplicate hyprlock instance.
hl.bind(C.mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))


