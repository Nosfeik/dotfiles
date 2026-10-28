import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.modules.services
import qs.modules.components
import qs.modules.theme
import qs.config
import "BatteryState.js" as State

Item {
    id: root
    required property var bar
    property bool vertical: bar.orientation === "vertical"
    property bool isHovered: hover.hovered
    property bool layerEnabled: true
    property real radius: 0
    property real startRadius: radius
    property real endRadius: radius
    readonly property bool popupOpen: false

    readonly property var device: Battery.primaryDevice
    readonly property bool available: Battery.available && device.ready && device.isPresent
    readonly property var percentage: State.percentage(Battery.percentage, available && device.state !== UPowerDeviceState.Unknown)
    readonly property bool acConnected: available && !UPower.onBattery
    readonly property bool charging: available && Battery.isCharging
    readonly property string state: {
        if (!available) return "unknown";
        switch (device.state) {
        case UPowerDeviceState.Charging: return "charging";
        case UPowerDeviceState.Discharging: return "discharging";
        case UPowerDeviceState.FullyCharged: return "full";
        case UPowerDeviceState.PendingCharge: return "pending-charge";
        case UPowerDeviceState.PendingDischarge: return "pending-discharge";
        case UPowerDeviceState.Empty: return "empty";
        default: return "unknown";
        }
    }
    readonly property var chargeLimit: BatteryChargeLimit.batteries.length === 1 ? BatteryChargeLimit.threshold : null
    readonly property bool limitReached: State.limitReached(percentage, chargeLimit, acConnected, state, available ? device.changeRate : NaN)
    readonly property string description: State.status(percentage, state, acConnected, limitReached, chargeLimit)
    readonly property string tooltipText: State.tooltip(percentage, description)

    Layout.preferredWidth: 36
    Layout.preferredHeight: 36
    Layout.fillWidth: vertical
    Layout.fillHeight: !vertical
    HoverHandler { id: hover }
    // No MouseArea, TapHandler, popup, profile action or notification producer.
    StyledRect {
        id: buttonBg
        anchors.fill: parent
        variant: "bg"
        enableShadow: root.layerEnabled
        topLeftRadius: root.startRadius
        topRightRadius: root.vertical ? root.startRadius : root.endRadius
        bottomLeftRadius: root.vertical ? root.endRadius : root.startRadius
        bottomRightRadius: root.endRadius
        Rectangle {
            anchors.fill: parent
            color: Styling.srItem("overprimary")
            opacity: root.isHovered ? 0.25 : 0
            radius: buttonBg.radius
            Behavior on opacity {
                enabled: Config.animDuration > 0
                NumberAnimation { duration: Config.animDuration / 2 }
            }
        }
        BatteryGraphic {
            anchors.centerIn: parent
            percentage: root.percentage
            charging: root.charging
            limitReached: root.limitReached
        }
        StyledToolTip { show: root.isHovered; tooltipText: root.tooltipText }
    }
}
