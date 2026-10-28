import QtQuick
import QtQuick.Window
import QtQuick.Shapes
import qs.config
import qs.modules.theme
import "BatteryState.js" as State

Item {
    id: root
    implicitWidth: 28
    implicitHeight: 18
    property var percentage: null
    property bool charging: false
    property bool limitReached: false
    property bool animate: true
    readonly property var value: State.percentage(percentage, true)
    readonly property string level: State.level(value)
    readonly property color fillColor: level === "red" ? Colors.red : level === "yellow" ? Colors.yellow : Colors.green
    readonly property real pixelRatio: Screen.devicePixelRatio || 1
    readonly property real stroke: Math.max(1, Math.round(1.4 * pixelRatio)) / pixelRatio
    readonly property real fillWidth: fill.width
    property real fraction: value === null ? 0 : value / 100
    Behavior on fraction {
        enabled: root.animate && root.value !== null && Config.animDuration > 0
        NumberAnimation { duration: Config.animDuration / 2; easing.type: Easing.OutCubic }
    }
    Rectangle {
        id: outline
        x: 0
        y: 1
        width: 25
        height: 16
        radius: 4
        color: "transparent"
        border.width: root.stroke
        border.color: Colors.overBackground
        antialiasing: true
    }
    Rectangle {
        x: 26
        y: 6
        width: 2
        height: 6
        radius: 1
        color: Colors.overBackground
        antialiasing: true
    }
    Rectangle {
        id: fill
        x: 3
        y: 4
        width: 19 * root.fraction
        height: 10
        radius: Math.min(2, width / 2)
        color: root.fillColor
        visible: root.value !== null && root.value > 0
        antialiasing: true
        Behavior on color {
            enabled: root.animate && Config.animDuration > 0
            ColorAnimation { duration: Config.animDuration / 2 }
        }
    }
    Shape {
        anchors.centerIn: outline
        width: 12; height: 12
        visible: root.limitReached && root.value !== null && !root.charging
        ShapePath {
            strokeColor: Colors.background; strokeWidth: 3.5; fillColor: "transparent"
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: 2; startY: 6
            PathLine { x: 5; y: 9 }
            PathLine { x: 10; y: 3 }
        }
        ShapePath {
            strokeColor: Colors.overBackground; strokeWidth: 1.5; fillColor: "transparent"
            capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: 2; startY: 6
            PathLine { x: 5; y: 9 }
            PathLine { x: 10; y: 3 }
        }
    }
    Text {
        id: marker
        anchors.centerIn: outline
        text: root.value === null ? "?" : Icons.lightning
        visible: root.value === null || root.charging
        font.family: root.value === null ? Config.theme.font : Icons.font
        font.pixelSize: root.value === null ? 11 : 14
        font.weight: Font.Bold
        color: Colors.overBackground
        style: Text.Outline
        styleColor: Colors.background
        SequentialAnimation on opacity {
            running: root.animate && root.visible && root.charging && root.value !== null && Config.animDuration > 0
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0.82; duration: Math.max(1800, Config.animDuration * 6); easing.type: Easing.InOutSine }
            NumberAnimation { from: 0.82; to: 1; duration: Math.max(1800, Config.animDuration * 6); easing.type: Easing.InOutSine }
            onRunningChanged: if (!running) marker.opacity = 1
        }
    }
}
