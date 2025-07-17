import qs.widgets
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Toggle this if you have a global dark/light signal you can bind to.
    // Replace with whatever your environment exposes (e.g., Appearance.dark).
    property bool nordDark: true

    // --- Nord palette -------------------------------------------------
    readonly property color nord0:  "#2e3440"
    readonly property color nord1:  "#3b4252"
    readonly property color nord2:  "#434c5e"
    readonly property color nord3:  "#4c566a"
    readonly property color nord4:  "#d8dee9"
    readonly property color nord5:  "#e5e9f0"
    readonly property color nord6:  "#eceff4"
    readonly property color nord7:  "#8fbcbb"
    readonly property color nord8:  "#88c0d0"   // primary accent
    readonly property color nord9:  "#81a1c1"
    readonly property color nord10: "#5e81ac"
    readonly property color nord11: "#bf616a"
    readonly property color nord12: "#d08770"
    readonly property color nord13: "#ebcb8b"
    readonly property color nord14: "#a3be8c"
    readonly property color nord15: "#b48ead"

    // Derived role colors
    readonly property color baseBg:       nordDark ? nord1  : nord6
    readonly property color baseBgAlt:    nordDark ? nord2  : nord5
    readonly property color surfaceBg:    nordDark ? nord0  : nord4
    readonly property color textPrimary:  nordDark ? nord6  : nord1
    readonly property color textSecondary:nordDark ? nord5  : nord2

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    implicitWidth: 200
    implicitHeight: 120

    // Background container
    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.large
        color: root.surfaceBg

        RowLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.normal

            // Pipes demo
            UtilityButton {
                iconText: "󰟦"              // Nerd Font 'pipe' glyph; fallback text below
                fallbackText: "|>"
                tooltip: "Run Pipes"
                command: ["kitty", "--title", "󰘲 Pipes.sh", "pipes.sh"]
                accent: root.nord12       // warm aurora accent for contrast
            }

            // ASCIIQuarium
            UtilityButton {
                iconText: "󰈺"             // emoji fish; change if font lacks emoji
                fallbackText: "<><"
                tooltip: "ASCIIQuarium"
                // kitty will exec program passed after options
                command: ["kitty", "--title", "🐟 ASCIIQuarium", "asciiquarium"]
                accent: root.nord8        // cool frost/cyan accent -> water
            }
        }
    }

    // Reusable button component
    component UtilityButton: StyledRect {
        id: button

        // iconText may not render in all fonts; fallbackText shown if width 0
        required property string iconText
        required property string fallbackText
        required property string tooltip
        property var command
        property color accent: root.nord8

        Layout.preferredWidth: 60
        Layout.preferredHeight: 60

        radius: Appearance.rounding.large
        color: stateLayer.containsMouse ? button.accent : root.baseBgAlt
        border.color: root.baseBg
        border.width: 1

        StateLayer {
            id: stateLayer
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(button.accent.r, button.accent.g, button.accent.b, 0.20)

            Accessible.name: button.tooltip

            onClicked: {
                console.log("Button clicked!", button.tooltip, button.command);
                var ok = Quickshell.execDetached(button.command);
                if (!ok)
                    console.error("execDetached failed:", button.command);
            }
        }

        // Glyph display. Use a Text node for broad glyph/emoji support.
        Text {
            id: glyph
            anchors.centerIn: parent
            text: button.iconText
            color: stateLayer.containsMouse ? root.textPrimary : root.textSecondary
            font.pointSize: Appearance.font.size.extraLarge
            font.weight: stateLayer.containsMouse ? Font.DemiBold : Font.Normal
            onPaintedWidthChanged: {
                // crude fallback: if glyph cannot render (0 width), swap
                if (paintedWidth === 0) text = button.fallbackText;
            }
        }

        Behavior on color {
            NumberAnimation {
                duration: Appearance.anim.durations.normal
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.anim.curves.standard
            }
        }
    }

    Behavior on implicitHeight { Anim {} }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.expressiveDefaultSpatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.expressiveDefaultSpatial
    }
}
