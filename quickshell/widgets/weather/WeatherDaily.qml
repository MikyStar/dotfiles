import QtQuick
import QtQuick.Layouts
import qs.style
import qs.widgets.weather

// 7-day forecast: a frozen AM/PM label column, then one scrolling column per day (day name above,
// morning row, afternoon row below), row heights kept in sync between the two so the labels line
// up with the day columns.
RowLayout {
    id: root

    // Kept close to the actual content height: Layout.alignment on a ColumnLayout only positions
    // it within its parent's cell, it does NOT center that layout's own children when given a
    // taller Layout.preferredHeight -- they'd just sit at the top with dead space below. So each
    // row is sized to fit its content (plus a small cushion), and the few rows that need real
    // centering (AM/PM, the slot block) use anchors.centerIn instead.
    readonly property int dayNameRowH: 24
    readonly property int slotRowH: 74

    Layout.fillWidth: true
    spacing: 6

    ColumnLayout {
        Layout.alignment: Qt.AlignTop
        spacing: 3

        Item { Layout.preferredWidth: 1; Layout.preferredHeight: root.dayNameRowH }
        Text {
            text: "AM"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: root.slotRowH
            verticalAlignment: Text.AlignVCenter
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
        }
        Text {
            text: "PM"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: root.slotRowH
            verticalAlignment: Text.AlignVCenter
            color: Colors.textDim
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
        }
    }

    ListView {
        Layout.fillWidth: true
        implicitHeight: root.dayNameRowH + root.slotRowH * 2 + 6
        orientation: ListView.Horizontal
        spacing: 12
        clip: true
        model: WeatherService.daily

        // Wrapped the same way as the hourly delegate: an Item the full height of the view, with
        // the actual day content centered in it instead of pinned to the top.
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
                    Layout.preferredHeight: root.dayNameRowH
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
                        Layout.preferredHeight: root.slotRowH
                        visible: modelData.slot !== null
                        // Safety net: if slotRowH is ever tuned too tight for the content again,
                        // clip it instead of letting it spill into the neighboring row.
                        clip: true

                        WeatherReading {
                            anchors.centerIn: parent
                            iconSize: 15
                            spacing: 1
                            valid: modelData.slot !== null
                            code: modelData.slot ? modelData.slot.code : 0
                            isDay: modelData.isDay
                            temp: modelData.slot ? modelData.slot.temp : 0
                            precip: modelData.slot ? modelData.slot.precip : 0
                        }
                    }
                }
            }
        }
    }
}
