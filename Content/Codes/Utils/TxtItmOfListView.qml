import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item{
    id: txtItm

    property string txt: ""

    width: 200

    Label{
        id: lblTitle
        text: txt
        anchors.centerIn: parent
        width: Math.min(parent.width, implicitWidth)
        elide: Text.ElideMiddle
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true

        ToolTip.visible: lblTitle.implicitWidth > parent.width ? hovered : false
        ToolTip.text: txt
        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
        ToolTip.timeout: 5000
    }

}
