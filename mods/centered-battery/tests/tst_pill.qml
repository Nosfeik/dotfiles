import QtQuick
import QtTest
import "../payload/modules/bar"

Rectangle {
    width: 200
    height: 60
    color: "#101010"

    CenteredBatteryPill {
        id: pill
        percentage: 50
    }

    TestCase {
        name: "CenteredBatteryPill"
        when: windowShown

        function init() {
            pill.animationDuration = 0;
            pill.percentage = 50;
            pill.charging = false;
            pill.showText = true;
            pill.hovered = false;
            pill.inverted = false;
        }


        function test_level_data() {
            return [
                {tag: "empty", value: 0, level: 0, pct: 0},
                {tag: "half", value: 50, level: 0.5, pct: 50},
                {tag: "full", value: 100, level: 1, pct: 100},
                {tag: "fractional", value: 37.6, level: 0.376, pct: 38},
                {tag: "negative", value: -10, level: 0, pct: 0},
                {tag: "overfull", value: 120, level: 1, pct: 100},
                {tag: "nan", value: NaN, level: 0, pct: 0},
                {tag: "infinity", value: Infinity, level: 0, pct: 0}
            ];
        }

        function test_level(data) {
            pill.percentage = data.value;
            fuzzyCompare(pill.level, data.level, 1e-9);
            compare(pill.pct, data.pct);
        }

        function test_stateColors_data() {
            return [
                {tag: "normal", value: 50, charging: false, color: "accent", critical: false, low: false},
                {tag: "low-boundary", value: 20, charging: false, color: "accent", critical: false, low: false},
                {tag: "low", value: 19, charging: false, color: "warning", critical: false, low: true},
                {tag: "critical-boundary", value: 10, charging: false, color: "warning", critical: false, low: true},
                {tag: "critical", value: 9, charging: false, color: "critical", critical: true, low: true},
                {tag: "rounds-up", value: 19.6, charging: false, color: "accent", critical: false, low: false},
                {tag: "low-charging", value: 15, charging: true, color: "accent", critical: false, low: false},
                {tag: "critical-charging", value: 5, charging: true, color: "accent", critical: false, low: false}
            ];
        }

        function test_stateColors(data) {
            pill.percentage = data.value;
            pill.charging = data.charging;
            compare(pill.isCritical, data.critical);
            compare(pill.isLow, data.low);
            compare(Qt.colorEqual(pill.stateColor, pill[data.color]), true);
        }

        function test_inverted() {
            pill.percentage = 5;
            pill.inverted = true;
            compare(Qt.colorEqual(pill.stateColor, pill.background), true);
            compare(Qt.colorEqual(pill.labelColor, pill.background), true);
        }

        function test_labelColor() {
            compare(Qt.colorEqual(pill.labelColor, pill.textColor), true);
            pill.hovered = true;
            compare(Qt.colorEqual(pill.labelColor, pill.hoverText), true);
            pill.percentage = 5;
            compare(Qt.colorEqual(pill.labelColor, pill.critical), true);
        }

        function test_reservedWidthStable() {
            const widths = [0, 5, 23, 99, 100].map(function (v) {
                pill.percentage = v;
                return pill.reservedWidth;
            });
            for (let i = 1; i < widths.length; i++)
                compare(widths[i], widths[0]);
            verify(pill.implicitWidth <= pill.reservedWidth + 0.5,
                   "implicitWidth " + pill.implicitWidth + " > reserved " + pill.reservedWidth);
        }

        function test_verticalNoText() {
            pill.showText = false;
            compare(pill.reservedWidth, 25);
            tryCompare(pill, "implicitWidth", 25, 500);
        }

        function test_chargingDoesNotChangeGeometry() {
            const w = pill.implicitWidth, h = pill.implicitHeight, r = pill.reservedWidth;
            pill.charging = true;
            compare(pill.implicitWidth, w);
            compare(pill.implicitHeight, h);
            compare(pill.reservedWidth, r);
        }

        function test_boltInsideBody() {
            pill.charging = true;
            const bolt = findChild(pill, "bolt");
            verify(bolt !== null, "bolt not found");
            verify(bolt.visible);
            // Contorno de 1 px: 0.5 fuera del path. El borde del cuerpo ocupa 0..1.5 y 11.5..13.
            verify(bolt.y + 0.5 - 0.5 >= 1.5, "bolt top overlaps body border");
            verify(bolt.y + 8.5 + 0.5 <= 11.5, "bolt bottom overlaps body border");
            pill.charging = false;
            verify(!bolt.visible);
        }

        function test_animationsOffWhenDisabled() {
            pill.percentage = 5;
            pill.charging = false;
            pill.animationDuration = 0;
            wait(50);
            const glyph = pill.children[0].children[0];
            compare(glyph.opacity, 1);
        }
    }
}
