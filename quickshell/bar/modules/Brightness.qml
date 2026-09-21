import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.services

// Left click: slider. Scroll: +/- 5%. Hidden on machines without a backlight.
Pill {
    id: root

    visible: Backlight.available
    icon: Icons.brightness(Backlight.level)
    text: Math.round(Backlight.level * 100) + "%"
    contentSpacing: Theme.iconTextSpacing
    reserveText: "100%"
    active: menu.open
    onClicked: menu.toggle()
    wheelEnabled: true
    onScrolled: delta => Backlight.set(Backlight.level + (delta > 0 ? 0.05 : -0.05))

    PopupMenu {
        id: menu
        anchorItem: root

        MenuHeader { text: "Brightness" }
        SliderBar {
            Layout.fillWidth: true
            value: Backlight.level
            onMoved: value => Backlight.set(value)
        }
    }
}
