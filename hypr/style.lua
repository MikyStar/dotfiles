hl.config({
  decoration = {
    rounding       = 5,
    rounding_power = 2,
    inactive_opacity = 0.7,
  },
  general = {
    gaps_out = 10,
  },
})

-- hl.layer_rule({
--   match = { namespace = "waybar" },
--   blur = true,
--   blur_popups = true,   -- also blurs the power menu
--   ignore_alpha = 0.5,   -- skips the fully transparent bar, so only the zones blur
-- })

hl.env("QT_STYLE_OVERRIDE", "Adwaita-Dark")

-- GTK3 apps
hl.env("GTK_THEME", "Adwaita:dark")
