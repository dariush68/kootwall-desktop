import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import "./../../font/Icon.js" as MdiFont


//-- txtSearch item --//
Rectangle{
    id: itmSearch

    property alias searchedTxt: txtSearch.text

    //-- signal to return searched text --//
    signal acceptedText(string text)

    //-- signal to return searched text when entered --//
    signal enteredText(string text)

    radius: height/6
    color: "#e6e6e6"
    width: 100
    height: txtSearch.implicitHeight * 2

    RowLayout{
        anchors.fill: parent
        anchors.leftMargin: height/6
        anchors.rightMargin: height/6

        //-- clear icon --//
        RoundButton{
            text: "" // "\u2715"
            Layout.fillHeight: true
            Layout.preferredWidth: height
            Layout.margins: -5
            flat: true

            Label{
                id: lblClear
                anchors.centerIn: parent
                font.family: font_material.name
                font.pixelSize: Qt.application.font.pixelSize * 1.0
                text: MdiFont.Icon.window_close
                color: "#666666"
            }

            onClicked: {
                txtSearch.text = ""
                acceptedText("")
                enteredText("")
            }
        }

        //-- txtSearch --//
        TextInput{
            id: txtSearch
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            selectByMouse: true
            color : "#666666"
            font.pixelSize: Qt.application.font.pixelSize
            clip: true

            //-- placeholder --//
            Label{
                text: parent.text == "" ? "جست و جو" : ""
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color : "#666666"
                font.pixelSize: Qt.application.font.pixelSize
            }

            onTextChanged: {
                acceptedText(text)
            }

            onAccepted: {
                enteredText(text)
            }
        }
        Label{
            id: lblUser
            Layout.alignment: Qt.AlignRight

            font.family: font_material.name
            font.pixelSize: Qt.application.font.pixelSize * (txtSearch.focus ? 1.5 : 1.3)
            text: MdiFont.Icon.magnify
            color: txtSearch.focus ? "#03A9F4" : "#666666"
            Behavior on font.pixelSize {NumberAnimation{duration: 100}}
        }
    }
}

