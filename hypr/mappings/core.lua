local C = require("constants")

hl.bind(C.mainMod .. " + Return", hl.dsp.exec_cmd(C.terminal))
hl.bind(C.mainMod .. " + D", hl.dsp.exec_cmd(C.launcher))
hl.bind(C.mainMod .. " + Q", hl.dsp.window.close())
hl.bind(C.mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- withUWSM = true in configuration.nix, so quit via uwsm rather than the
-- raw exit dispatcher (calling hl.dsp.exit() directly can leave the
-- systemd session in a bad state)
hl.bind(C.mainMod .. " + M", hl.dsp.exec_cmd("uwsm stop"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region"))

hl.bind(C.mainMod .. "+ F", hl.dsp.window.fullscreen())
