import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.components
import qs.bar.modules

// Status modules in a horizontally scrollable strip, with the battery and power button pinned to the right.
RowLayout {
    id: root

    // Width the section may not exceed; the strip scrolls when the modules need more.
    property real maxWidth: Infinity
    // Width needed to show every module plus the power button.
    readonly property real desiredWidth: modules.implicitWidth + spacing + pinned.implicitWidth

    spacing: Theme.sectionSpacing

    Flickable {
        id: strip

        Layout.preferredWidth: Math.max(0, Math.min(modules.implicitWidth, root.maxWidth - pinned.implicitWidth - root.spacing))
        Layout.preferredHeight: modules.implicitHeight
        contentWidth: modules.implicitWidth
        contentHeight: height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.HorizontalFlick

        // Pills that don't use the wheel themselves let it scroll the strip.
        WheelHandler {
            onWheel: event => {
                const delta = event.angleDelta.x !== 0 ? event.angleDelta.x : event.angleDelta.y;
                strip.contentX = Math.max(0, Math.min(strip.contentWidth - strip.width, strip.contentX - delta));
            }
        }

        RowLayout {
            id: modules
            height: parent.height
            spacing: Theme.sectionSpacing

            Wifi {}
            BluetoothStatus {}
            Volume {}
            Brightness {}
            Cpu {}
            Ram {}
            Temperature {}
        }
    }

    // Always visible, never scrolled away.
    RowLayout {
        id: pinned
        spacing: Theme.sectionSpacing

        Battery {}
        Power {}
    }
}
