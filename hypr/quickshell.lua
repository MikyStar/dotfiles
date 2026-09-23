-- Quickshell bar: blur rules + autostart.
-- Namespaces come from the QML config: "qs-bar" (bar.qml) and "qs-popup" (PopupMenu.qml).

-- Blur behind the bar pills and the submenus.
-- ignore_alpha skips the fully transparent areas, so only the translucent pills/panels blur.
hl.layer_rule({
  match = { namespace = "^qs-.*$" },
  blur = true,
  ignore_alpha = 0.8,
})
