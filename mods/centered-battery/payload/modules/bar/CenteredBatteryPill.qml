pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

// Batería compacta + porcentaje. Solo dibujo: el estado y los colores llegan desde fuera.
Item {
    id: root

    required property real percentage
    property bool charging: false
    property bool showText: true
    property bool hovered: false
    property bool inverted: false          // popup abierto: cápsula en color primario
    property int animationDuration: 0

    // Colores del tema (se pasan desde Colors.* en la barra)
    property color accent: "#00e69a"
    property color warning: "#f9e4b4"
    property color critical: "#f497b1"
    property color textColor: "#a8d5bf"
    property color hoverText: "#d6f5e6"
    property color background: "#101010"

    property string fontFamily: "Roboto Condensed"

    readonly property real level: isFinite(percentage) ? Math.max(0, Math.min(1, percentage / 100)) : 0
    readonly property int pct: Math.round(level * 100)
    readonly property bool isCritical: !charging && pct < 10
    readonly property bool isLow: !charging && pct < 20
    readonly property color stateColor: inverted ? background : (isCritical ? critical : (isLow ? warning : accent))
    readonly property color labelColor: inverted ? background : (isCritical ? critical : (hovered ? hoverText : textColor))

    implicitWidth: row.implicitWidth
    implicitHeight: 16

    // Ancho del caso más largo ("100%"): la cápsula se dimensiona con esto y no salta al cambiar de cifra
    TextMetrics { id: widestNum; font: number.font; text: "100" }
    TextMetrics { id: pctSign; font: sign.font; text: "%" }
    readonly property real reservedWidth: showText ? 25 + row.spacing + widestNum.advanceWidth + 1 + pctSign.advanceWidth : 25

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        // ---- Glifo de batería: 25 × 13 ----
        Item {
            id: glyph
            width: 25
            height: 13
            anchors.verticalCenter: parent.verticalCenter

            // Pulso suave en nivel crítico
            SequentialAnimation on opacity {
                running: root.isCritical && root.animationDuration > 0
                loops: Animation.Infinite
                alwaysRunToEnd: true
                NumberAnimation { to: 0.45; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
            }

            // Cuerpo
            Rectangle {
                id: body
                width: 22
                height: 13
                radius: 4
                color: "transparent"
                border.width: 1.5
                border.color: root.stateColor
                Behavior on border.color { ColorAnimation { duration: root.animationDuration } }

                // Pista vacía (tenue) para que se lea el nivel restante
                Rectangle {
                    id: track
                    x: 3; y: 3
                    width: body.width - 6
                    height: body.height - 6
                    radius: 1.5
                    color: root.stateColor
                    opacity: 0.16
                }

                // Relleno continuo
                Rectangle {
                    id: fill
                    x: 3; y: 3
                    height: track.height
                    width: track.width * root.level
                    radius: 1.5
                    color: root.stateColor
                    Behavior on width {
                        enabled: root.animationDuration > 0
                        NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                    }
                    Behavior on color { ColorAnimation { duration: root.animationDuration } }

                    // Cargando: brillo que recorre el relleno
                    Rectangle {
                        visible: root.charging && root.animationDuration > 0 && fill.width > 4
                        width: 6; height: parent.height
                        radius: parent.radius
                        opacity: 0.55
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.5; color: "#ffffff" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                        NumberAnimation on x {
                            running: root.charging && root.animationDuration > 0
                            from: -6; to: Math.max(0, fill.width)
                            duration: 1400
                            loops: Animation.Infinite
                        }
                    }
                }
            }

            // Borne
            Rectangle {
                x: 23
                y: 4
                width: 2
                height: 5
                radius: 1
                color: root.stateColor
            }

            // Rayo: relleno claro con contorno fino del fondo, se lee igual sobre el relleno y sobre la pista vacía.
            // Va dentro del área interior (y 2..11 con contorno) para no cortar el borde del cuerpo.
            Shape {
                id: bolt
                objectName: "bolt"
                visible: root.charging
                x: body.width / 2 - 4
                y: 2
                width: 8; height: 9
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeWidth: 0.8
                    strokeColor: root.inverted ? root.accent : root.background
                    fillColor: root.inverted ? root.background : root.hoverText
                    joinStyle: ShapePath.RoundJoin
                    startX: 5.2; startY: 0.5
                    PathLine { x: 1.0; y: 5.2 }
                    PathLine { x: 3.8; y: 5.2 }
                    PathLine { x: 2.8; y: 8.5 }
                    PathLine { x: 7.0; y: 3.8 }
                    PathLine { x: 4.2; y: 3.8 }
                    PathLine { x: 5.2; y: 0.5 }
                }
            }
        }

        // ---- Porcentaje: número + "%" pequeño ----
        Row {
            visible: root.showText
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                id: number
                text: root.pct
                font.family: root.fontFamily
                font.pixelSize: 14
                font.weight: 600
                font.features: { "tnum": 1 }
                color: root.labelColor
                Behavior on color { ColorAnimation { duration: root.animationDuration } }
            }
            Text {
                id: sign
                anchors.baseline: number.baseline
                text: "%"
                font.family: root.fontFamily
                font.pixelSize: 11
                font.weight: 600
                color: root.labelColor
                opacity: 0.6
            }
        }
    }
}
