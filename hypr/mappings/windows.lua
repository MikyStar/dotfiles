local C = require("constants")

-- Cycle focus between windows: Alt+Tab forward, Alt+Shift+Tab backward.
-- Replaces the old SUPER+hjkl focus binds.
hl.bind("ALT + Tab", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

hl.bind("ALT + SHIFT + Tab", function()
  hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Send the focused window to the workspace to the left/right (relative to current)
hl.bind(C.mainMod .. " + CTRL + right", hl.dsp.window.move({ workspace = "+1" }))
hl.bind(C.mainMod .. " + CTRL + left",  hl.dsp.window.move({ workspace = "-1" }))

-- Move (swap) the focused window itself in the current workspace
hl.bind(C.mainMod .. " + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(C.mainMod .. " + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(C.mainMod .. " + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(C.mainMod .. " + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize the focused window: 30px steps
hl.bind(C.mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind(C.mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind(C.mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind(C.mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 30, relative = true }))
