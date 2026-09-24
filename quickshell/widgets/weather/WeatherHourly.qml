import QtQuick
import QtQuick.Layouts
import qs.widgets.weather

// Next 24h, one column per hour.
ListView {
    id: root

    Layout.fillWidth: true
    implicitHeight: 90
    orientation: ListView.Horizontal
    spacing: 10
    clip: true
    model: WeatherService.hourly

    // Wrapped in an Item the full height of the view so the actual content can be centered in it,
    // rather than a bare ColumnLayout which would just sit at the top.
    delegate: Item {
        id: hourCell
        required property var modelData
        width: 34
        height: ListView.view.height

        WeatherReading {
            anchors.centerIn: parent
            label: Qt.formatDateTime(hourCell.modelData.time, "HH") + "h"
            code: hourCell.modelData.code
            isDay: hourCell.modelData.isDay
            temp: hourCell.modelData.temp
            precip: hourCell.modelData.precip
        }
    }
}
