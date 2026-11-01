pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import "fixtures" as Before
import "fixtures" as After

Window {
    width: 760
    height: 480
    visible: true
    title: "Centered Battery — iteración 2"

    Rectangle {
        id: sheet
        anchors.fill: parent
        Repeater {
            model: 4
            delegate: Rectangle {
                id: row
                required property int index
                readonly property bool updated: index % 2 === 1
                readonly property bool light: index >= 2
                y: index * 120
                width: 760
                height: 120
                color: light ? "#fafafa" : "#17201e"

                Text {
                    x: 16
                    y: 34
                    text: row.updated ? "Después\n33.6 × 16" : "Antes\n30 × 14"
                    color: row.light ? "#34443e" : "#dce5e2"
                    font.pixelSize: 13
                }

                Repeater {
                    model: [10, 25, 50, 75, 100, 50]
                    delegate: Item {
                        id: cell
                        required property real modelData
                        required property int index
                        x: 120 + index * 104
                        width: 100
                        height: 120

                        Repeater {
                            model: [1, 2]
                            delegate: Loader {
                                required property int modelData
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: modelData === 1 ? 16 : 48
                                width: (row.updated ? 33.6 : 30) * modelData
                                height: (row.updated ? 16 : 14) * modelData
                                sourceComponent: row.updated ? after : before
                            }
                        }

                        Component {
                            id: before
                            Before.CenteredBatteryGraphic {
                                percentage: cell.modelData
                                charging: cell.index === 5
                                warningColor: "#ffb4ab"
                            }
                        }
                        Component {
                            id: after
                            After.Iteration2BatteryGraphic {
                                percentage: cell.modelData
                                charging: cell.index === 5
                                warningColor: "#ffb4ab"
                            }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 92
                            text: cell.index === 5 ? "Cargando" : cell.modelData + "%"
                            color: row.light ? "#34443e" : "#dce5e2"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
    Timer {
        interval: 700
        running: true
        onTriggered: sheet.grabToImage(result => {
            result.saveToFile(Qt.resolvedUrl("../validation/iteration2/comparison.png").toString().replace("file://", ""));
            Qt.quit();
        })
    }
}
