import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.services
import qs.widgets.components
import qs.widgets.endpoints

Card {
    id: root

    CardHeader {
        title: "Endpoints"
        trailing: Format.timeAgo(EndpointsService.lastUpdated)
        showRefresh: true
        refreshing: EndpointsService.loading
        onRefreshClicked: EndpointsService.refresh()
    }

    Repeater {
        model: EndpointsService.statuses

        RowLayout {
            id: row
            required property var modelData
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                implicitWidth: 8
                implicitHeight: 8
                radius: 4
                color: row.modelData.ok ? Colors.good : Colors.critical
            }
            Text {
                Layout.fillWidth: true
                text: row.modelData.url
                color: Colors.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideMiddle
                font.underline: urlArea.containsMouse

                MouseArea {
                    id: urlArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: EndpointsService.open(row.modelData.url)
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        visible: EndpointsService.statuses.length === 0 && !EndpointsService.loading
        text: "No endpoints configured"
        color: Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
