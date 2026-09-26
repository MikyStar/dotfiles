hl.on("hyprland.start", function()
  hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
  hl.exec_cmd("hyprctl setcursor Adwaita 18")
  -- hl.exec_cmd("waybar")
  -- hl.exec_cmd("mako")
  hl.exec_cmd("quickshell")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("hypridle")
  -- Feeds clipboard history into cliphist's db; the quickshell clipboard menu (SUPER+SHIFT+V) only
  -- reads from it.
  hl.exec_cmd("wl-paste --watch cliphist store")
end)
