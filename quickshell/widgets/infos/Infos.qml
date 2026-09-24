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
        trailing: Format.timeAgo(InfosService.lastUpdated)
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
}
