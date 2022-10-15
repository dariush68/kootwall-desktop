import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Popup{
    id: msgHandler

    signal show(string message, string alarmType)
    onShow: {
        msg = message

        if(alarmType == "RED"){
            itmBackColor.color = "red"
            msgHandler.open()
        }
        else if(alarmType == "BLUE"){
            itmBackColor.color = "blue"
            msgHandler.open()
        }
        else if(alarmType == "LOG"){
            itmBackColor.color = "white"
            //                    msgHandler.open()
        }

    }

    property string msg: "value"

//    modal: true
    focus: true
    //        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    width: lblMsg.implicitWidth * 1 + 30
    height: lblMsg.contentHeight + 40
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    Material.theme: Material.Dark  //-- Light, Dark, System
    background: Rectangle{id:itmBackColor; color: "red"}

    GroupBox{
        anchors.fill: parent

        Label{
            id: lblMsg
            text: msgHandler.msg
            anchors.centerIn: parent
            font.family: "B Yekan"
        }
    }

    onOpened: timerPopup.restart()

    Timer {
        id: timerPopup; interval: 2000; running: true; repeat: false
        onTriggered: msgHandler.close()
    }

}
