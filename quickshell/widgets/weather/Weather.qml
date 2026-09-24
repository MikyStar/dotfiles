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

    // Current conditions.
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        // Layout.alignment is required here: the icon (fixed 28px) and the temperature text
        // (a much taller font) are very different heights, and QtQuick.Layouts top-aligns
        // items by default when no alignment is given -- without this the icon sits noticeably
        // higher than the number instead of centered on it.
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

    // Next 24h, one column per hour.
    ListView {
        Layout.fillWidth: true
        implicitHeight: 90
        orientation: ListView.Horizontal
        spacing: 10
        clip: true
        model: WeatherService.hourly

        // Wrapped in an Item the full height of the view so the actual content can be centered
        // in it, rather than a bare ColumnLayout which would just sit at the top.
        delegate: Item {
            id: hourCell
            required property var modelData
            width: 34
            height: ListView.view.height

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(hourCell.modelData.time, "HH") + "h"
                    color: Colors.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
                Image {
                    Layout.alignment: Qt.AlignHCenter
                    source: WeatherIcons.forCode(hourCell.modelData.code, hourCell.modelData.isDay)
                    sourceSize: Qt.size(32, 32)
                    fillMode: Image.PreserveAspectFit
                    width: 16
                    height: 16
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(hourCell.modelData.temp) + "°"
                    color: Colors.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 1
                    // Same vertical-alignment gotcha as the current-conditions row: the drop
                    // icon and the "%" text are different heights, so both need Qt.AlignVCenter
                    // or the shorter one sits top-aligned instead of centered on the other.
                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        source: WeatherIcons.drop
                        sourceSize: Qt.size(20, 20)
                        fillMode: Image.PreserveAspectFit
                        width: 10
                        height: 10
                    }
                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: hourCell.modelData.precip + "%"
                        color: Colors.textDim
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                    }
                }
            }
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Colors.pillBorder }

    // Next 7 days: a frozen AM/PM label column, then one scrolling column per day
    // (day name above, morning row, afternoon row below), row heights kept in sync
    // between the two so the labels line up with the day columns.
    RowLayout {
        id: dailyRow
        Layout.fillWidth: true
        spacing: 6

        // Kept close to the actual content height: Layout.alignment on a ColumnLayout only
        // positions it within its parent's cell, it does NOT center that layout's own children
        // when given a taller Layout.preferredHeight -- they'd just sit at the top with dead
        // space below. So each row is sized to fit its content (plus a small cushion), and the
        // few rows that need real centering (AM/PM, the slot block) use anchors.centerIn instead.
        readonly property int dayNameRowH: 24
        readonly property int slotRowH: 74

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: 3

            Item { Layout.preferredWidth: 1; Layout.preferredHeight: dailyRow.dayNameRowH }
            Text {
                text: "AM"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: dailyRow.slotRowH
                verticalAlignment: Text.AlignVCenter
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
            }
            Text {
                text: "PM"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: dailyRow.slotRowH
                verticalAlignment: Text.AlignVCenter
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
            }
        }

        ListView {
            Layout.fillWidth: true
            implicitHeight: dailyRow.dayNameRowH + dailyRow.slotRowH * 2 + 6
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            model: WeatherService.daily

            // Wrapped the same way as the hourly delegate: an Item the full height of the view,
            // with the actual day content centered in it instead of pinned to the top.
            delegate: Item {
                id: dayCell
                required property var modelData
                width: 44
                height: ListView.view.height

                ColumnLayout {
                    anchors.centerIn: parent
                    width: dayCell.width
                    spacing: 3

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredHeight: dailyRow.dayNameRowH
                        text: Qt.formatDateTime(dayCell.modelData.date, "ddd")
                        color: Colors.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        font.bold: true
                    }

                    Repeater {
                        model: [
                            { slot: dayCell.modelData.morning, isDay: true },
                            { slot: dayCell.modelData.afternoon, isDay: false },
                        ]

                        Item {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: dailyRow.slotRowH
                            visible: modelData.slot !== null
                            // Safety net: if slotRowH is ever tuned too tight for the content
                            // again, clip it instead of letting it spill into the neighboring row.
                            clip: true

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 1

                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    visible: modelData.slot !== null
                                    source: modelData.slot ? WeatherIcons.forCode(modelData.slot.code, modelData.isDay) : ""
                                    sourceSize: Qt.size(30, 30)
                                    fillMode: Image.PreserveAspectFit
                                    width: 15
                                    height: 15
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.slot ? Math.round(modelData.slot.temp) + "°" : ""
                                    color: Colors.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                }
                                RowLayout {
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: 1
                                    // Same vertical-alignment gotcha as the current-conditions
                                    // row: without Qt.AlignVCenter the shorter icon top-aligns
                                    // instead of centering on the "%" text next to it.
                                    Image {
                                        Layout.alignment: Qt.AlignVCenter
                                        visible: modelData.slot !== null
                                        source: WeatherIcons.drop
                                        sourceSize: Qt.size(20, 20)
                                        fillMode: Image.PreserveAspectFit
                                        width: 10
                                        height: 10
                                    }
                                    Text {
                                        Layout.alignment: Qt.AlignVCenter
                                        text: modelData.slot ? modelData.slot.precip + "%" : ""
                                        color: Colors.textDim
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 3
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

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
