pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

// Pure visual: state comes from Ambxst's existing Battery singleton at the call site.
Item {
    id: root

    required property real percentage
    required property bool charging
    required property color warningColor
    property int animationDuration: 0
    property bool emphasized: false
    readonly property real level: isFinite(percentage) ? Math.max(0, Math.min(1, percentage / 100)) : 0
    readonly property bool critical: percentage < 10
    readonly property color coreColor: critical ? warningColor : "#35ecd0"
    readonly property color outlineColor: emphasized ? "#f0f4f3" : Qt.lighter("#cbd5d3", 1.06)
    readonly property color interiorColor: "#172421"

    implicitWidth: 56.6
    implicitHeight: 26

    // Scale the drawing as one unit, keeping the terminal and stroke proportional.
    Item {
        id: drawing
        width: 56.6
        height: 26
        anchors.centerIn: parent
        scale: Math.min(root.width / width, root.height / height)

        Rectangle {
            x: 53
            y: 9
            width: 3.6
            height: 8
            radius: 1
            color: root.outlineColor
            border.width: 0.5
            border.color: root.interiorColor
        }

        // The dark keyline belongs to the silhouette and stays legible on white.
        Rectangle {
            width: 54
            height: 26
            radius: 13
            color: root.interiorColor

            Rectangle {
                anchors.fill: parent
                anchors.margins: 0.5
                radius: 12.5
                color: root.interiorColor
                border.width: 1.5
                border.color: root.outlineColor
            }
        }

        // Rounded at both ends, with exact continuous width and no minimum segment.
        Rectangle {
            id: core
            objectName: "centeredBatteryFill"
            x: 4
            y: 4
            width: 46 * root.level
            height: 18
            radius: Math.min(width / 2, height / 2)
            color: root.coreColor

            Behavior on width {
                enabled: root.animationDuration > 0
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        // A small outlined bolt remains readable over both empty and filled areas.
        Shape {
            objectName: "centeredBatteryBolt"
            anchors.fill: parent
            visible: root.charging
            ShapePath {
                strokeWidth: 0.75
                strokeColor: root.interiorColor
                fillColor: root.outlineColor
                joinStyle: ShapePath.RoundJoin
                startX: 28.3
                startY: 7
                PathLine { x: 22.3; y: 14 }
                PathLine { x: 26.3; y: 14 }
                PathLine { x: 25.3; y: 19 }
                PathLine { x: 31.3; y: 11 }
                PathLine { x: 27.3; y: 11 }
                PathLine { x: 28.3; y: 7 }
            }
        }
    }
}
