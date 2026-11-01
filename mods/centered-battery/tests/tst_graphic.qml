import QtQuick
import QtTest
import "../payload/modules/bar"

Rectangle {
    width: 200
    height: 100
    color: "#345678"

    CenteredBatteryGraphic {
        id: battery
        percentage: 50
        charging: false
        warningColor: "#ffb4ab"
    }

    TestCase {
        name: "CenteredBattery"
        when: windowShown

        function init() {
            battery.animationDuration = 0;
            battery.percentage = 50;
            battery.charging = false;
            battery.warningColor = "#ffb4ab";
            battery.width = 56.6;
            battery.height = 19;
        }

        function test_continuousFill_data() {
            return [
                {tag: "empty", value: 0, width: 0.0},
                {tag: "ten", value: 10, width: 4.6000000000000005},
                {tag: "quarter", value: 25, width: 11.5},
                {tag: "half", value: 50, width: 23.0},
                {tag: "three-quarters", value: 75, width: 34.5},
                {tag: "full", value: 100, width: 46},
                {tag: "fractional", value: 37.25, width: 17.135},
                {tag: "subpixel", value: 0.5, width: 0.23},
                {tag: "negative", value: -10, width: 0},
                {tag: "overfull", value: 120, width: 46},
                {tag: "invalid", value: NaN, width: 0}
            ];
        }

        function test_continuousFill(data) {
            battery.percentage = data.value;
            fuzzyCompare(findChild(battery, "centeredBatteryFill").width, data.width, 0.001);
        }

        function test_chargeDoesNotChangeGeometry() {
            const fill = findChild(battery, "centeredBatteryFill");
            const bolt = findChild(battery, "centeredBatteryBolt");
            compare(bolt.visible, false);
            battery.charging = true;
            compare(bolt.visible, true);
            compare(fill.width, 23);
            compare(battery.width, 56.6);
            compare(battery.height, 19);
        }

        function test_themeWarning() {
            battery.percentage = 9.9;
            compare(battery.coreColor, battery.warningColor);
            battery.warningColor = "#e61a44";
            compare(battery.coreColor, battery.warningColor);
            battery.percentage = 10;
            compare(battery.coreColor, Qt.color("#35ecd0"));
        }

        function test_animation() {
            battery.percentage = 0;
            battery.animationDuration = 200;
            battery.percentage = 100;
            const fill = findChild(battery, "centeredBatteryFill");
            wait(50);
            verify(fill.width > 0 && fill.width < 46);
            tryCompare(fill, "width", 46, 500);
            battery.animationDuration = 0;
            battery.percentage = 25;
            compare(fill.width, 11.5);
        }

        function test_transparentHitArea() {
            battery.width = 36;
            battery.height = 36;
            waitForRendering(battery);
            const snapshot = grabImage(battery);
            // QtTest captures the window backing store, including the parent.
            compare(snapshot.pixel(0, 0), Qt.color("#345678"));
            compare(snapshot.pixel(35, 35), Qt.color("#345678"));
        }
    }
}
