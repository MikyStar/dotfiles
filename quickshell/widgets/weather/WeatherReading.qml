import QtQuick
import QtQuick.Layouts
import qs.style
import qs.widgets.weather

// Icon + temperature + precipitation-chance stack, shared by the hourly strip (WeatherHourly) and
// the daily morning/afternoon slots (WeatherDaily), with an optional label (e.g. an hour) above it.
ColumnLayout {
    id: root

    property string label: ""
    property int code: 0
    property bool isDay: true
    property real temp: 0
    property int precip: 0
    // False for a daily slot with no data (e.g. a day missing its afternoon reading): renders
    // nothing rather than a misleading "0°"/"0%".
    property bool valid: true
    // Hourly renders slightly bigger icons than the daily slots -- kept as a knob instead of two
    // near-duplicate components.
    property int iconSize: 16

    spacing: 2

    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: root.label !== ""
        text: root.label
        color: Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
    }
    Image {
        Layout.alignment: Qt.AlignHCenter
        visible: root.valid
        source: root.valid ? WeatherIcons.forCode(root.code, root.isDay) : ""
        sourceSize: Qt.size(root.iconSize * 2, root.iconSize * 2)
        fillMode: Image.PreserveAspectFit
        width: root.iconSize
        height: root.iconSize
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.valid ? Math.round(root.temp) + "°" : ""
        color: Colors.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
    }
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 1
        // Same vertical-alignment gotcha as the current-conditions row: the drop icon and the "%"
        // text are different heights, so both need Qt.AlignVCenter or the shorter one sits
        // top-aligned instead of centered on the other.
        Image {
            Layout.alignment: Qt.AlignVCenter
            visible: root.valid
            source: WeatherIcons.drop
            sourceSize: Qt.size(20, 20)
            fillMode: Image.PreserveAspectFit
            width: 10
            height: 10
        }
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.valid ? root.precip + "%" : ""
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
        }
    }
}
