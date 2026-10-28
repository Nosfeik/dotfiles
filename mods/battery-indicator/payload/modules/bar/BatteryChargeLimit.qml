pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "BatteryState.js" as State

Singleton {
    id: root
    property var dbusThreshold: null
    property var sysfsThreshold: null
    readonly property var threshold: dbusThreshold !== null ? dbusThreshold : sysfsThreshold
    readonly property string source: dbusThreshold !== null ? "asusd-dbus" : sysfsThreshold !== null ? "sysfs" : "unavailable"
    // Never associate an aggregate percentage with one arbitrary battery.
    readonly property var batteries: UPower.devices.values.filter(device => device.ready && device.isLaptopBattery && device.isPresent)
    readonly property string batteryName: {
        if (batteries.length !== 1) return "";
        const name = batteries[0].nativePath.split("/").pop();
        return /^[A-Za-z0-9_-]+$/.test(name) ? name : "";
    }
    function refreshFallback() {
        sysfsThreshold = null;
        if (batteryName !== "" && dbusThreshold === null) fallback.reload();
    }
    onDbusThresholdChanged: if (dbusThreshold === null) refreshFallback()
    FileView {
        id: fallback
        path: root.dbusThreshold === null && root.batteryName ? "/sys/class/power_supply/" + root.batteryName + "/charge_control_end_threshold" : ""
        onPathChanged: root.refreshFallback()
        onLoaded: root.sysfsThreshold = State.threshold(Number(text().trim()))
        onLoadFailed: root.sysfsThreshold = null
    }
    Process {
        id: bridge
        command: ["gjs", "-m", decodeURIComponent(Qt.resolvedUrl("../../scripts/battery-indicator/charge-limit.js").toString().replace("file://", ""))]
        running: true
        stdinEnabled: true
        stdout: SplitParser {
            onRead: data => {
                try { root.dbusThreshold = State.threshold(JSON.parse(data).threshold); }
                catch (_) { root.dbusThreshold = null; }
            }
        }
        onExited: { root.dbusThreshold = null; restart.start(); }
    }
    Timer { id: restart; interval: 60000; onTriggered: bridge.running = true }
    Timer {
        interval: 60000
        repeat: true
        running: root.dbusThreshold === null && root.batteryName !== ""
        onTriggered: root.refreshFallback()
    }
    Connections {
        target: UPower
        function onOnBatteryChanged() { root.refreshFallback(); }
    }
}
