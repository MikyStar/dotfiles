import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.services
import qs.widgets.components
import qs.widgets.weather

Card {
    id: root

    CardHeader { title: "Weather" }

    // Current conditions.
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            text: WeatherIcons.forCode(WeatherService.currentCode, WeatherService.currentIsDay)
            color: Colors.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize + 12
        }
        Text {
            text: Math.round(WeatherService.currentTemp) + "°"
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 10
        }
        Item { Layout.fillWidth: true }
        Text {
            visible: WeatherService.error !== ""
            text: WeatherService.error
            color: Colors.critical
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            wrapMode: Text.Wrap
            Layout.maximumWidth: 140
        }
    }

    // Next 24h, one column per hour.
    ListView {
        Layout.fillWidth: true
        implicitHeight: 76
        orientation: ListView.Horizontal
        spacing: 10
        clip: true
        model: WeatherService.hourly

        delegate: ColumnLayout {
            id: hourCol
            required property var modelData
            width: 34
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: WeatherIcons.forCode(hourCol.modelData.code, hourCol.modelData.isDay)
                color: Colors.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.iconSize - 2
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Math.round(hourCol.modelData.temp) + "°"
                color: Colors.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 1
                Text {
                    text: WeatherIcons.drop
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 4
                }
                Text {
                    text: hourCol.modelData.precip + "%"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(hourCol.modelData.time, "HH") + "h"
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

    // Next 7 days, one column per day: morning row above afternoon row.
    ListView {
        Layout.fillWidth: true
        implicitHeight: 92
        orientation: ListView.Horizontal
        spacing: 12
        clip: true
        model: WeatherService.daily

        delegate: ColumnLayout {
            id: dayCol
            required property var modelData
            width: 44
            spacing: 3

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(dayCol.modelData.date, "ddd")
                color: Colors.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.bold: true
            }

            Repeater {
                model: [
                    { slot: dayCol.modelData.morning, isDay: true },
                    { slot: dayCol.modelData.afternoon, isDay: false },
                ]

                ColumnLayout {
                    required property var modelData
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 1
                    visible: modelData.slot !== null

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.slot ? WeatherIcons.forCode(modelData.slot.code, modelData.isDay) : ""
                        color: Colors.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.iconSize - 3
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.slot ? Math.round(modelData.slot.temp) + "°" : ""
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.slot ? modelData.slot.precip + "%" : ""
                        color: Colors.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                    }
                }
            }
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

    // City + last refreshed + manual refresh button.
    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: WeatherService.city
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
        }
        Item { Layout.fillWidth: true }
        Text {
            text: Format.timeAgo(WeatherService.lastUpdated)
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
        }
        Text {
            text: Icons.refresh
            color: refreshArea.containsMouse ? Colors.text : Colors.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize - 1

            RotationAnimation on rotation {
                running: WeatherService.loading
                loops: Animation.Infinite
                from: 0
                to: 360
                duration: 900
            }

            MouseArea {
                id: refreshArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: WeatherService.refresh()
            }
        }
    }
}
