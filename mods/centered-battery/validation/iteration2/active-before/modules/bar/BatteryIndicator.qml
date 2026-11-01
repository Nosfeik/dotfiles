pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.services
import qs.modules.components
import qs.modules.theme
import qs.modules.globals
import qs.config

Item {
    id: root

    required property var bar

    property bool vertical: bar.orientation === "vertical"
    property bool isHovered: false
    property bool layerEnabled: true

    property real radius: 0
    property real startRadius: radius
    property real endRadius: radius

    // Popup visibility state
    property bool popupOpen: batteryPopup.isOpen

    // Function to interpolate color between green and red based on battery percentage
    function getBatteryColor() {
        if (!Battery.available)
            return Colors.overBackground;

        const pct = Battery.percentage;
        if (pct <= 15)
            return Colors.red;
        if (pct >= 85)
            return Colors.green;

        // Linear interpolation between red (15%) and green (85%)
        const ratio = (pct - 15) / (85 - 15);
        return Qt.rgba(Colors.red.r + (Colors.green.r - Colors.red.r) * ratio, Colors.red.g + (Colors.green.g - Colors.red.g) * ratio, Colors.red.b + (Colors.green.b - Colors.red.b) * ratio, 1);
    }

    Layout.preferredWidth: 36
    Layout.preferredHeight: 36
    Layout.fillWidth: vertical
    Layout.fillHeight: !vertical

    HoverHandler {
        onHoveredChanged: root.isHovered = hovered
    }

    // Transparent hit target; only the battery silhouette has a background.
    Item {
        id: buttonBg
        anchors.fill: parent

        CenteredBatteryGraphic {
            anchors.centerIn: parent
            width: Math.max(0, Math.min(30, parent.width - 6, (parent.height - 6) * 30 / 14))
            height: width * 14 / 30
            visible: Battery.available
            percentage: Battery.percentage
            charging: Battery.isCharging
            warningColor: Colors.red
            animationDuration: Config.animDuration
            emphasized: root.isHovered || root.popupOpen
        }

        // Preserve access to power profiles on machines without a battery.
        Text {
            anchors.centerIn: parent
            visible: !Battery.available
            text: PowerProfileClient.getProfileIcon(PowerProfileClient.currentProfile)
            font.family: Icons.font
            font.pixelSize: 18
            color: Colors.overBackground
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: batteryPopup.toggle()
        }

        StyledToolTip {
            visible: root.isHovered && !root.popupOpen
            tooltipText: Battery.available ? (Battery.isCharging ? I18n.t("battery.status_charging", Math.round(Battery.percentage), I18n.t("battery.charging")) : I18n.t("battery.status", Math.round(Battery.percentage))) : I18n.t("battery.power_profile", PowerProfileClient.getProfileDisplayName(PowerProfileClient.currentProfile))
        }
    }

    // Battery and power profiles popout — a floating pill next to the bar, or
    // grown out of the frame when the bar is contained by it. See BarPopout.
    BarPopout {
        id: batteryPopup
        anchorItem: buttonBg
        bar: root.bar

        Item {
            // The pill has always been 280 wide, which is this plus its own
            // padding either side — unless the profile row needs more.
            implicitWidth: Math.max(280 - batteryPopup.popupPadding * 2, mainColumn.implicitWidth)
            // Battery details (60px) + spacing (4px) + profiles (36px). Fixed
            // rather than derived so the panel doesn't expand into place on
            // first open.
            implicitHeight: (Battery.available ? 64 : 0) + 36

            ColumnLayout {
                id: mainColumn
                anchors.fill: parent
                spacing: 4

                StyledRect {
                    id: batteryDetailsContainer
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    visible: Battery.available
                    variant: "common"
                    enableShadow: false

                    radius: Styling.radius(0)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 12

                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: Battery.getBatteryIcon()
                            font.family: Icons.font
                            font.pixelSize: 24
                            color: root.getBatteryColor()
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: Battery.isPluggedIn ? (Battery.isCharging ? I18n.t("battery.charging") : I18n.t("battery.full")) : I18n.t("battery.on_battery")
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(0)
                                font.bold: true
                                color: Colors.overBackground
                            }

                            Text {
                                text: Battery.isPluggedIn ? (Battery.timeToFull !== "" ? I18n.t("battery.full_in", Battery.timeToFull) : I18n.t("battery.fully_charged")) : (Battery.timeToEmpty !== "" ? I18n.t("battery.remaining", Battery.timeToEmpty) : "")
                                font.family: Styling.defaultFont
                                font.pixelSize: Styling.fontSize(-1)
                                color: Colors.overBackground
                                opacity: 0.8
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        // Battery percentage display
                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: Math.round(Battery.percentage) + "%"
                            font.family: Styling.defaultFont
                            font.pixelSize: Styling.fontSize(2)
                            font.bold: true
                            color: root.getBatteryColor()
                            opacity: 0.8
                        }
                    }
                }

                RowLayout {
                    id: profilesRow
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4

                    Repeater {
                        model: PowerProfileClient.availableProfiles

                        delegate: StyledRect {
                            id: profileButton
                            required property string modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.preferredWidth: 80
                            height: 36

                            readonly property bool isSelected: PowerProfileClient.currentProfile === modelData
                            readonly property bool isFirst: index === 0
                            readonly property bool isLast: index === PowerProfileClient.availableProfiles.length - 1
                            property bool buttonHovered: false

                            readonly property real defaultRadius: Styling.radius(0)
                            readonly property real selectedRadius: Styling.radius(0) / 2

                            variant: isSelected ? "primary" : (buttonHovered ? "focus" : "common")
                            enableShadow: false

                            topLeftRadius: isSelected ? (isFirst ? defaultRadius : selectedRadius) : defaultRadius
                            bottomLeftRadius: isSelected ? (isFirst ? defaultRadius : selectedRadius) : defaultRadius
                            topRightRadius: isSelected ? (isLast ? defaultRadius : selectedRadius) : defaultRadius
                            bottomRightRadius: isSelected ? (isLast ? defaultRadius : selectedRadius) : defaultRadius

                            Text {
                                anchors.centerIn: parent
                                text: PowerProfileClient.getProfileIcon(profileButton.modelData)
                                font.family: Icons.font
                                font.pixelSize: 18
                                color: profileButton.item
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onEntered: profileButton.buttonHovered = true
                                onExited: profileButton.buttonHovered = false

                                onClicked: {
                                    PowerProfileClient.setProfile(profileButton.modelData);
                                }
                            }

                            StyledToolTip {
                                show: profileButton.buttonHovered
                                tooltipText: PowerProfileClient.getProfileDisplayName(profileButton.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
