import QtQuick
import QtQuick.Window
import "fixtures"

Window {
    id: preview
    width: 720
    height: 280
    visible: true
    title: "Centered Battery — validación visual"

    Rectangle {
        id: sheet
        anchors.fill: parent
        color: "#17201e"

        Repeater {
            model: ["#17201e", "#fafafa"]
            delegate: Rectangle {
                required property string modelData
                required property int index
                y: index * 140
                width: 720
                height: 140
                color: modelData

                Row {
                    x: 20
                    y: 20
                    spacing: 12
                    Repeater {
                        model: [0, 10, 25, 50, 75, 100, 37.25, 50]
                        delegate: Column {
                            required property real modelData
                            required property int index
                            width: 73
                            spacing: 10
                            Iteration2BatteryGraphic {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 67.2
                                height: 32
                                percentage: parent.modelData
                                charging: parent.index === 7
                                warningColor: "#ffb4ab"
                            }
                            Iteration2BatteryGraphic {
                                anchors.horizontalCenter: parent.horizontalCenter
                                percentage: parent.modelData
                                charging: parent.index === 7
                                warningColor: "#ffb4ab"
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: parent.index === 7 ? "Carga" : parent.modelData + "%"
                                color: "#7b8984"
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        onTriggered: sheet.grabToImage(result => {
            result.saveToFile(Qt.resolvedUrl("../validation/states.png").toString().replace("file://", ""));
            Qt.quit();
        })
    }
}
