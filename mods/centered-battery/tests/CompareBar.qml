import QtQuick
import QtQuick.Window

Window {
    width: 360
    height: 250
    visible: true
    Rectangle {
        id: sheet
        anchors.fill: parent
        color: "#17201e"
        Repeater {
            model: ["before", "after"]
            delegate: Item {
                required property string modelData
                required property int index
                y: index * 125
                width: 360
                height: 125
                Text {
                    x: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: parent.index === 0 ? "Antes\n30 × 14" : "Después\n33,6 × 16"
                    color: "#dce5e2"
                    font.pixelSize: 13
                }
                Image {
                    x: 112
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../validation/iteration2/bar-" + parent.modelData + ".png"
                }
            }
        }
    }
    Timer {
        interval: 500
        running: true
        onTriggered: sheet.grabToImage(result => {
            result.saveToFile(Qt.resolvedUrl("../validation/iteration2/bar-comparison.png").toString().replace("file://", ""));
            Qt.quit();
        })
    }
}
