pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import "../payload/modules/bar"

Window {
    width: 700
    height: 220
    visible: true
    Rectangle {
        id: sheet
        anchors.fill: parent
        Repeater {
            model: ["#17201e", "#fafafa"]
            delegate: Rectangle {
                id: row
                required property string modelData
                required property int index
                width: 700
                height: 110
                y: index * height
                color: modelData
                Repeater {
                    model: [0, 10, 25, 50, 75, 100, 50]
                    delegate: Item {
                        id: cell
                        required property real modelData
                        required property int index
                        x: 10 + index * 98
                        width: 92
                        height: 110
                        // Preview backdrop only; the bar uses its native StyledRect bg.
                        Rectangle {
                            width: 74
                            height: 36
                            radius: height / 2
                            color: "#111111"
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 24
                            CenteredBatteryGraphic {
                                anchors.centerIn: parent
                                percentage: cell.modelData
                                charging: cell.index === 6
                                warningColor: "#ffb4ab"
                            }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 76
                            text: cell.index === 6 ? "Cargando" : cell.modelData + "%"
                            color: row.index === 0 ? "#dce5e2" : "#34443e"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
    Timer {
        interval: 600
        running: true
        onTriggered: sheet.grabToImage(result => {
            result.saveToFile(Qt.resolvedUrl("../validation/iteration3/states.png").toString().replace("file://", ""));
            Qt.quit();
        })
    }
}
