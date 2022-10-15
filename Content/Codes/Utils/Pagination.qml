import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "./../../font/Icon.js" as MdiFont

//-- pagination --//
Item{
    id: itm_pagination

    property int currentPage: 1   //-- current page --//
    property int totalItem: 1    //-- total item --//
    property int pageSize: 1      //-- page size --//

    signal firstPage()                  //-- go to first page --//
    signal nextPage()                   //-- go to next page --//
    signal previousPage()               //-- go to previous page --//
    signal lastPage()                   //-- go to last page --//
    signal customPage(int customPage)   //-- go to custom page --//

    property bool isCenter: false       //-- alighn to center --//
    property alias txtColor: txf_currentPage.color  //-- text color --//


    height: 50 //parent.height
    width: height*4  + txf_currentPage.implicitWidth + 10
    anchors.right: parent.right
    anchors.margins: 2

    //-- size porpose --//
    Label{
        id: lbl_sizePopoz
        visible: false
        text: currentPage
    }

    RowLayout{
        anchors.fill: parent
        spacing: 0

        //-- filler --//
        Item{Layout.fillWidth: true}

        //-- first page --//
        MButton{
            id: btn_firstPage

            Layout.preferredWidth: height * 0.5
            Layout.fillHeight: true
            icons: MdiFont.Icon.chevron_double_left
            tooltip: "صفحه اول"
            flat: true
            enabled: currentPage > 1
            Material.background:"transparent"


            onClicked: {
                firstPage()
            }

        }

        //-- previous page --//
        MButton{
            id: btn_prevPage

            Layout.preferredWidth: height * 0.5
            Layout.fillHeight: true
            icons: MdiFont.Icon.chevron_left
            tooltip: "صفحه قبل"
            flat: true
            enabled: currentPage > 1
            Material.background:"transparent"


            onClicked: {
                previousPage()
            }

        }

        //-- current page --//

        TextInput{
            id: txf_currentPage

            Layout.preferredWidth: lbl_sizePopoz.implicitWidth + 3
            font.pixelSize: Qt.application.font.pixelSize
            selectByMouse: true
            text: currentPage

            onAccepted: {

                var num = parseInt(text)
                customPage(num)
            }

        }

        //-- next page --//
        MButton{
            id: btn_nextPage

            Layout.preferredWidth: height * 0.5
            Layout.fillHeight: true
            icons: MdiFont.Icon.chevron_right
            tooltip: "صفحه بعد"
            flat: true
            enabled: currentPage < totalItem/pageSize
            Material.background:"transparent"

            onClicked: {
                nextPage()
            }

        }

        //-- last page --//
        MButton{
            id: btn_lastPage

            Layout.preferredWidth: height * 0.5
            Layout.fillHeight: true
            icons: MdiFont.Icon.chevron_double_right
            tooltip: "صفحه آخر"
            flat: true
            enabled: currentPage < totalItem/pageSize
            Material.background:"transparent"

            onClicked: {
                lastPage()
            }

        }

        //-- filler --//
        Item{Layout.fillWidth: true; visible: isCenter}
    }

}
