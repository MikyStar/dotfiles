import QtQuick
import QtQuick.Layouts
import qs.style
import qs.bar.services
import qs.bar.components
import qs.widgets.components
import qs.widgets.infos

Card {
    id: root

    CardHeader {
        title: "Infos"
        showRefresh: true
        refreshing: InfosService.loading || InfosService.checkingUpdates
        onRefreshClicked: InfosService.refresh()
    }

    InfoRow {
        label: "Last switch"
        value: Format.timeAgo(InfosService.lastGenerationDate)
    }
    InfoRow {
        label: "Generations stored"
        value: String(InfosService.generationCount)
    }
    InfoRow {
        label: "Updates available"
        value: InfosService.checkingUpdates
            ? "checking…"
            : (InfosService.outdatedInputs === 0
                ? "up to date"
                : `${InfosService.outdatedInputs} of ${InfosService.totalInputs} inputs`)
    }

    Text {
        Layout.fillWidth: true
        // Text.Wrap alone isn't enough: a wrapping Text's default Layout.minimumWidth still equals
        // its unwrapped implicit width, so a long input list would refuse to shrink below that and
        // overflow past the card's right inset instead of wrapping -- Card's clip then cropped it
        // flush with the edge, leaving no visible right padding while the left stayed padded.
        Layout.minimumWidth: 0
        visible: !InfosService.checkingUpdates && InfosService.outdatedInputs > 0
        text: InfosService.outdatedNames.join(", ")
        color: Colors.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        wrapMode: Text.Wrap
    }
}
