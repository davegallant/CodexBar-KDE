import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../code/parser.js" as Parser

// Panel view: one horizontal fuel-gauge-style meter per provider.
Item {
    id: compact

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    // Keep the panel footprint close to a tray icon while retaining a visible meter.
    readonly property int meterWidth: Kirigami.Units.gridUnit
    readonly property int meterHeight: Kirigami.Units.smallSpacing
    readonly property int count: Math.max(1, root.models.length)
    readonly property int fallbackSize: Kirigami.Units.gridUnit * 2
    readonly property int panelHeight: root.models.length === 0 ? compact.fallbackSize : compact.meterHeight

    Layout.minimumWidth: compact.vertical ? compact.meterWidth : compact.count * (compact.meterWidth + gaugeGrid.spacing)
    Layout.minimumHeight: compact.vertical ? compact.count * (compact.panelHeight + gaugeGrid.spacing) : compact.panelHeight

    Grid {
        id: gaugeGrid
        anchors.centerIn: parent
        columns: compact.vertical ? 1 : compact.count
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            visible: root.models.length === 0
            source: Qt.resolvedUrl("../icons/codexbar.svg")
            width: compact.fallbackSize
            height: compact.fallbackSize
            opacity: root.loading ? 0.5 : 1
        }

        Repeater {
            model: root.models

            delegate: HorizontalGauge {
                required property var modelData
                readonly property int usedPercent: Parser.gaugeCenterPercent(modelData)

                width: compact.meterWidth
                height: compact.meterHeight
                remainingPercent: usedPercent >= 0 ? Parser.remainingPercent(usedPercent) : -1
                fillColor: root.sessionColor
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
