import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "./../../font/Icon.js" as MdiFont


//-- message handler --//
Popup{
    id: root

    property variant mainPage

    signal show()
    onShow: {

        root.open()

    }

    //-- confirmed signal to delete --//
    signal confirm()

    parent: mainPage

    property string msg: ""

    modal: true
    focus: true
    //        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    width: lblAlarm.implicitWidth + lblDeltxt2.implicitWidth + 100 //lblMsg.implicitWidth * 1 + 30
    height: lblAlarm.implicitHeight + itmBtns.implicitHeight + 100//200//lblMsg.contentHeight * 3
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    Material.theme: Material.Light  //-- Light, Dark, System

    //-- back --//
    Rectangle{
        id:itmBackColor;
        color: "#e9e9e9"
        width: parent.width + 40
        height: parent.height + 40
        radius: 5
        anchors.centerIn: parent
    }

    //-- body --//
    GridLayout{
        anchors.fill: parent
        anchors.margins: 10

        rows: 4
        columns: 2

        //-- alarm icon --//
        Label{
            id: lblAlarm
            font.family: font_material.name
            font.pixelSize: Qt.application.font.pixelSize * 4
            Layout.row: 1
            Layout.column: 2
            Layout.rowSpan: 2
            text: MdiFont.Icon.alert_decagram
            color: Material.color(Material.Red)
        }

        Label{
            id: lblDeltxt
            font.family: font_irans.name
            font.pixelSize: Qt.application.font.pixelSize * 1.5
            Layout.row: 1
            Layout.column: 1
            Layout.alignment: Qt.AlignRight
            text: "عملیات حذف"

        }

        Label{
            id: lblDeltxt2
            font.family: font_irans.name
            font.pixelSize: Qt.application.font.pixelSize * 1
            Layout.row: 2
            Layout.column: 1
            Layout.alignment: Qt.AlignRight
            text: "این عملیات غیرقابل بازگشت خواهد بود"

        }

        //-- seperator --//
        Rectangle{
            Layout.row: 3
            Layout.column: 1
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#e1e1e1"

        }

        //-- buttons --//
        Item{
            id: itmBtns

            Layout.row: 4
            Layout.column: 1
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.preferredHeight: btnCencel.implicitHeight * 1.2

            RowLayout{
                anchors.fill: parent
                anchors.margins: 10

                Button{
                    id: btnCencel
//                    text: "انصراف"
                    text:  "\u2717" + " انصراف "
                    Layout.fillWidth: true
                    font.family: font_irans.name
                    font.bold: true

                    onClicked: root.close()
                }
                Button{
                    id: btnConfirm
                    text:  "\u2714" + " تایید "
                    Layout.fillWidth: true
                    Material.background: Material.Cyan
                    Material.foreground: "#FFFFFF"
                    font.family: font_irans.name
                    font.bold: true

                    onClicked: {
                        confirm()
                        root.close()
                    }
                }
            }
        }

    }

    FontLoader{
        id: font_material
        source: "qrc:/Content/font/materialdesignicons-webfont.ttf"
    }

    FontLoader{
        id: font_irans
        source: "qrc:/Content/font/IRANSans.ttf"
    }

}
