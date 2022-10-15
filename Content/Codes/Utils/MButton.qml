import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import "./../../font/Icon.js" as MdiFont
import "./Util.js" as Util

 Button{
    id: btn

    property alias icons: btn.text
    property real sizeRatio: 1.5
    property string tooltip: ""
    property bool isDown: false

    font.pixelSize: Qt.application.font.pixelSize * sizeRatio
    font.family: font_material.name
    text: MdiFont.Icon.arrow_down_bold_circle_outline
//    Material.foreground: tooltip == "" ? "red" : "white"
//    flat: true
//    down: true
    Material.background: isDown ? Util.color_kootwall_dark :  Util.color_kootwall_light
    highlighted: true

    ToolTip.visible: hovered
    ToolTip.text: tooltip
    ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
    ToolTip.timeout: 5000

    FontLoader{
        id: font_material
        source: "qrc:/Content/font/materialdesignicons-webfont.ttf"
    }

}
