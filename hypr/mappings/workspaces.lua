local C = require("constants")

-- Cycle to the next/previous workspace (handy alongside the number binds below)
hl.bind(C.mainMod .. " + bracketright", hl.dsp.focus({ workspace = "+1" }))
hl.bind(C.mainMod .. " + bracketleft",  hl.dsp.focus({ workspace = "-1" }))

hl.bind("CTRL + ALT + right", hl.dsp.focus({ workspace = "+1" }))
hl.bind("CTRL + ALT + left",   hl.dsp.focus({ workspace = "-1" }))

-- Numpad digits have a long-standing Hyprland quirk: depending on driver/
-- keyboard, the "2" key on the numpad can report as either KP_2 (numlock
-- semantics) or KP_Down (the non-numlock navigation-cluster name),
-- sometimes regardless of the actual Num Lock state. Binding both names
-- for each digit below means workspace switching works either way.
local numpadNavNames = {
  [1] = "KP_End",    [2] = "KP_Down",  [3] = "KP_Next",
  [4] = "KP_Left",   [5] = "KP_Begin", [6] = "KP_Right",
  [7] = "KP_Home",   [8] = "KP_Up",    [9] = "KP_Prior",
}

-- Workspaces 1-9: top-row numbers AND numpad (both digit and nav-cluster names)
for i = 1, 9 do
  hl.bind(C.mainMod .. " + " .. i,                      hl.dsp.focus({ workspace = i }))
  hl.bind(C.mainMod .. " + KP_" .. i,                    hl.dsp.focus({ workspace = i }))
  hl.bind(C.mainMod .. " + " .. numpadNavNames[i],       hl.dsp.focus({ workspace = i }))

  hl.bind(C.mainMod .. " + SHIFT + " .. i,               hl.dsp.window.move({ workspace = i }))
  hl.bind(C.mainMod .. " + SHIFT + KP_" .. i,            hl.dsp.window.move({ workspace = i }))
  hl.bind(C.mainMod .. " + SHIFT + " .. numpadNavNames[i], hl.dsp.window.move({ workspace = i }))
end

-- Workspace 10, conventionally bound to 0 / KP_0 / KP_Insert
hl.bind(C.mainMod .. " + 0",              hl.dsp.focus({ workspace = 10 }))
hl.bind(C.mainMod .. " + KP_0",           hl.dsp.focus({ workspace = 10 }))
hl.bind(C.mainMod .. " + KP_Insert",      hl.dsp.focus({ workspace = 10 }))
hl.bind(C.mainMod .. " + SHIFT + 0",         hl.dsp.window.move({ workspace = 10 }))
hl.bind(C.mainMod .. " + SHIFT + KP_0",      hl.dsp.window.move({ workspace = 10 }))
hl.bind(C.mainMod .. " + SHIFT + KP_Insert", hl.dsp.window.move({ workspace = 10 }))

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- TODO ability to insert workspace ?
