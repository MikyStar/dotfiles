import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.services
import qs.widgets.components
import qs.widgets.weather

Card {
    id: root

    CardHeader {
        title: "Weather"
        trailing: Format.timeAgo(WeatherService.lastUpdated)
        showRefresh: true
        refreshing: WeatherService.loading
        onRefreshClicked: WeatherService.refresh()
    }

    WeatherCurrent {}

    WeatherHourly {}

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

    WeatherDaily {}

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

    // City name.
    Text {
        Layout.fillWidth: true
        text: WeatherService.city
        color: Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
    }
}
