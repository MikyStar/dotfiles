local C = require("constants")

-- Move focus between windows: arrows or vim-style hjkl, your pick (both are bound here)
hl.bind(C.mainMod .. " + h",    hl.dsp.focus({ direction = "l" }))
hl.bind(C.mainMod .. " + l",    hl.dsp.focus({ direction = "r" }))
hl.bind(C.mainMod .. " + k",    hl.dsp.focus({ direction = "u" }))
hl.bind(C.mainMod .. " + j",    hl.dsp.focus({ direction = "d" }))
hl.bind(C.mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(C.mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(C.mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(C.mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move (swap) the focused window itself: mainMod + SHIFT + direction
hl.bind(C.mainMod .. " + SHIFT + h",    hl.dsp.window.move({ direction = "l" }))
hl.bind(C.mainMod .. " + SHIFT + l",    hl.dsp.window.move({ direction = "r" }))
hl.bind(C.mainMod .. " + SHIFT + k",    hl.dsp.window.move({ direction = "u" }))
hl.bind(C.mainMod .. " + SHIFT + j",    hl.dsp.window.move({ direction = "d" }))
hl.bind(C.mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(C.mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(C.mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(C.mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize the focused window: mainMod + CTRL + direction, 30px steps
-- (x and y are both required together — pass 0 for the axis you're not resizing)
hl.bind(C.mainMod .. " + CTRL + h", hl.dsp.window.resize({ x = -30, y = 0, relative = true }))
hl.bind(C.mainMod .. " + CTRL + l", hl.dsp.window.resize({ x = 30, y = 0, relative = true }))
hl.bind(C.mainMod .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = -30, relative = true }))
hl.bind(C.mainMod .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = 30, relative = true }))

