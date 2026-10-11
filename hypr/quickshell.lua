-- Quickshell bar: blur rules + autostart.
-- Namespaces come from the QML config: "qs-bar" (Bar.qml), "qs-popup" (PopupMenu.qml),
-- "qs-widgets" (Widgets.qml), "qs-widgets-left" (LeftWidgets.qml), "qs-clipboard"
-- (Clipboard.qml) and "qs-notification-popup" (NotificationPopup.qml).

-- Blur behind the bar pills and the submenus.
-- ignore_alpha skips the fully transparent areas, so only the translucent pills/panels blur.
-- Deliberately excludes "qs-finder" (below), which needs the opposite: blur across its whole
-- dim backdrop, not just its opaque panels.
hl.layer_rule({
  match = { namespace = "^qs-(bar|popup|widgets|widgets-left|clipboard|notification-popup)$" },
  blur = true,
  ignore_alpha = 0.7,
})

-- Finder (Finder.qml): blurs everything behind it, including the dim full-screen backdrop
-- that the widgets slide onto. That backdrop is a uniform low-alpha (0.35) rectangle covering
-- the whole screen, not a mostly-transparent surface with a few opaque bits like the bar, so
-- unlike the rule above this one has no ignore_alpha cutoff -- there's nothing to exclude.
hl.layer_rule({
  match = { namespace = "^qs-finder$" },
  blur = true,
})
