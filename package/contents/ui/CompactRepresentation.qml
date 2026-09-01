import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../code/parser.js" as Parser

// Panel view: stacked session and weekly fuel-gauge-style meters per provider.
Item {
    id: compact

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    // Keep the panel footprint close to a tray icon while retaining a visible meter.
    readonly property int meterWidth: Kirigami.Units.gridUnit
    readonly property int barHeight: Kirigami.Units.smallSpacing
    readonly property int barSpacing: Kirigami.Units.smallSpacing
    readonly property int meterHeight: compact.barHeight * 2 + compact.barSpacing
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

            delegate: Item {
                required property var modelData
                readonly property var percents: Parser.gaugePercents(modelData)

                width: compact.meterWidth
                height: compact.meterHeight

                Column {
                    anchors.fill: parent
                    spacing: compact.barSpacing

                    HorizontalGauge {
                        width: parent.width
                        height: compact.barHeight
                        remainingPercent: percents.session >= 0 ? Parser.remainingPercent(percents.session) : -1
                        fillColor: root.sessionColor
                    }

                    HorizontalGauge {
                        width: parent.width
                        height: compact.barHeight
                        remainingPercent: percents.weekly >= 0 ? Parser.remainingPercent(percents.weekly) : -1
                        fillColor: root.weeklyColor
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
