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
    readonly property color outlineColor: emphasized ? "#f0f4f3" : "#cbd5d3"
    readonly property color interiorColor: "#172421"

    implicitWidth: 30
    implicitHeight: 14

    // Scale the drawing as one unit, keeping the terminal and stroke proportional.
    Item {
        id: drawing
        width: 30
        height: 14
        anchors.centerIn: parent
        scale: Math.min(root.width / width, root.height / height)

        Rectangle {
            x: 27
            y: 4
            width: 3
            height: 6
            radius: 1
            color: root.outlineColor
            border.width: 0.5
            border.color: root.interiorColor
        }

        // The dark keyline belongs to the silhouette and stays legible on white.
        Rectangle {
            width: 28
            height: 14
            radius: 7
            color: root.interiorColor

            Rectangle {
                anchors.fill: parent
                anchors.margins: 0.5
                radius: 6.5
                color: root.interiorColor
                border.width: 1.25
                border.color: root.outlineColor
            }
        }

        // Rounded at both ends, with exact continuous width and no minimum segment.
        Rectangle {
            id: core
            objectName: "centeredBatteryFill"
            x: 4
            y: 3
            width: 20 * root.level
            height: 8
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
                startX: 15
                startY: 2.5
                PathLine { x: 11; y: 7.5 }
                PathLine { x: 13.5; y: 7.5 }
                PathLine { x: 13; y: 11.5 }
                PathLine { x: 17; y: 6 }
                PathLine { x: 14.5; y: 6 }
                PathLine { x: 15; y: 2.5 }
            }
        }
    }
}
