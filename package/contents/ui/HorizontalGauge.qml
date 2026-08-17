import QtQuick
import org.kde.kirigami as Kirigami

// Fuel-gauge-style meter. The fill represents quota remaining, never quota used.
Item {
    id: gauge

    property real remainingPercent: -1
    property color fillColor: Kirigami.Theme.positiveTextColor

    readonly property real clampedRemaining: Math.max(0, Math.min(100, remainingPercent))
    readonly property color trackColor: Qt.alpha(Kirigami.Theme.textColor, 0.18)

    implicitWidth: Kirigami.Units.gridUnit * 5
    implicitHeight: Kirigami.Units.smallSpacing * 2

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: gauge.trackColor
    }

    Rectangle {
        width: parent.width * gauge.clampedRemaining / 100
        height: parent.height
        radius: height / 2
        color: gauge.fillColor
        visible: gauge.remainingPercent >= 0
    }
}
