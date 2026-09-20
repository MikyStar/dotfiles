hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto"
})

hl.config({
  input = {
    kb_layout  = "fr",
    kb_variant = "",
    kb_model   = "",
    kb_options = "",
    kb_rules   = "",
    numlock_by_default = true,
    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.8,
    };
  },
  misc = {
    font_family = "JetBrains Mono",
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})
