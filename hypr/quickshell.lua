-- Quickshell bar: blur rules + autostart.
-- Namespaces come from the QML config: "qs-bar" (Bar.qml), "qs-popup" (PopupMenu.qml),
-- "qs-widgets" (Widgets.qml) and "qs-widgets-left" (LeftWidgets.qml).

-- Blur behind the bar pills and the submenus.
-- ignore_alpha skips the fully transparent areas, so only the translucent pills/panels blur.
hl.layer_rule({
  match = { namespace = "^qs-.*$" },
  blur = true,
  ignore_alpha = 0.7,
})
