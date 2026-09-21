import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.services

// Month grid (weeks start on Monday) with previous/next navigation.
ColumnLayout {
    id: root

    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()

    readonly property var dayNames: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    // 42 cells: 0 for blanks, otherwise the day of month.
    readonly property var cells: {
        const offset = (new Date(year, month, 1).getDay() + 6) % 7;
        const days = new Date(year, month + 1, 0).getDate();
        return Array.from({ length: 42 }, (_, i) => i - offset + 1 > 0 && i - offset + 1 <= days ? i - offset + 1 : 0);
    }

    function shift(delta: int) {
        const d = new Date(year, month + delta, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    spacing: Theme.popupSpacing

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: Icons.chevronLeft
            color: Colors.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: root.shift(-1) }
        }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM yyyy")
            color: Colors.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 1
            font.bold: true
        }
        Text {
            text: Icons.chevronRight
            color: Colors.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.iconSize
            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: root.shift(1) }
        }
    }

    Grid {
        columns: 7
        Layout.alignment: Qt.AlignHCenter

        Repeater {
            model: root.dayNames
            Text {
                required property string modelData
                width: 32
                height: 26
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
                color: Colors.textDim
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
            }
        }

        Repeater {
            model: root.cells
            Rectangle {
                required property int modelData
                readonly property bool isToday: modelData > 0 && modelData === root.today.getDate()
                    && root.month === root.today.getMonth() && root.year === root.today.getFullYear()
                width: 32
                height: 32
                radius: 16
                color: isToday ? Colors.accent : "transparent"

                Text {
                    anchors.centerIn: parent
                    visible: parent.modelData > 0
                    text: parent.modelData
                    color: parent.isToday ? "#101018" : Colors.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }
        }
    }
}
