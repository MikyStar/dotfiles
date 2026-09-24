import QtQuick
import QtQuick.Layouts
import qs.style
import qs.widgets.weather

// Current conditions: icon, temperature, and an error message (if any) pinned to the right.
RowLayout {
    id: root

    Layout.fillWidth: true
    spacing: 10

    // Layout.alignment is required here: the icon (fixed 28px) and the temperature text (a much
    // taller font) are very different heights, and QtQuick.Layouts top-aligns items by default
    // when no alignment is given -- without this the icon sits noticeably higher than the number
    // instead of centered on it.
    Image {
        Layout.alignment: Qt.AlignVCenter
        source: WeatherIcons.forCode(WeatherService.currentCode, WeatherService.currentIsDay)
        sourceSize: Qt.size(56, 56)
        fillMode: Image.PreserveAspectFit
        width: 28
        height: 28
    }
    Text {
        Layout.alignment: Qt.AlignVCenter
        text: Math.round(WeatherService.currentTemp) + "°"
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 10
    }
    Item { Layout.fillWidth: true }
    Text {
        Layout.alignment: Qt.AlignVCenter
        visible: WeatherService.error !== ""
        text: WeatherService.error
        color: Colors.critical
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        wrapMode: Text.Wrap
        Layout.maximumWidth: 140
    }
}
