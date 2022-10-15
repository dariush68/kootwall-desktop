import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import "./../../font/Icon.js" as MdiFont
import "./../REST/apiservice.js" as Service
import "./../Utils/Util.js" as Util
import "./../Utils"

Rectangle {
    id: root

    //-- add signal --//
    signal addProduct(var navs)

    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)

    //-- signal for expand categories windows --//
    signal expandWin(string catName)

    //-- branches titles --//
    property string titleCategory        : "دسته بندی"
    property string titleBaseCategory    : "زیر دسته بندی"
    property string titleMaterialCategory: "فصوا اصلی"
    property string titleMaterial        : "زیرمجموعه 1"
    property string titleSubMaterial     : "زیرمجموعه 2"
    property string titleSubSubMaterial  : "زیرمجموعه 3"


    property bool   isLogEnabled:           true   //-- global log permission --//
    property bool   _localLogPermission:    true   //-- local log permission --//

    objectName: "NavigationGuid"
    color: "#FFFFFF"
    radius: 3
    border{width: 1; color: "#999e9e9e"}


    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        horizontalOffset: 1//8
        verticalOffset: 1//8
        color: "#80000000"
        spread: 0.0
        samples: 17
        radius: 12
    }


    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name

        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 5


            //-- header --//
            Button{
                id: btnHeader
                Layout.fillWidth: true
                text: "شاخه انتخاب شده"
                flat: true
                down: true
            }

            //-- category --//
            ItemDelegate{
                id: nav_category
                opacity: titleCategory === "" ? 0.0 : 1.0
                Layout.fillWidth: true
                Behavior on opacity{ NumberAnimation{duration: 100}}

                Label{
                    id: lbl_titleCategory
                    text: titleCategory
                    anchors.centerIn: parent
                    width: Math.min(parent.width, implicitWidth)
                    elide: Text.ElideMiddle
                }

                ToolTip.visible: lbl_titleCategory.implicitWidth > width ? hovered : false
                ToolTip.text: titleCategory
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.timeout: 5000

                onClicked: {
                    expandWin("Category")
                }
            }

            //-- down icon--//
            Label{
                opacity: titleBaseCategory === "" ? 0.0 : 1.0
                font.family: font_material.name
                text: MdiFont.Icon.chevron_down //arrow_down_thick
                Layout.alignment: Qt.AlignHCenter
                Behavior on opacity{ NumberAnimation{duration: 100}}
            }

            //-- BaseCategory --//
            ItemDelegate{
                id: nav_baseCategory
                opacity: titleBaseCategory === "" ? 0.0 : 1.0
                Layout.fillWidth: true
                Behavior on opacity{ NumberAnimation{duration: 100}}

                Label{
                    id: lbl_titleBaseCategory
                    text: titleBaseCategory
                    anchors.centerIn: parent
                    width: Math.min(parent.width, implicitWidth)
                    elide: Text.ElideMiddle
                }

                ToolTip.visible: lbl_titleBaseCategory.implicitWidth > width ? hovered : false
                ToolTip.text: titleCategory
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.timeout: 5000

                onClicked: {
                    expandWin("BaseCategory")
                }
            }

            //-- down icon--//
            Label{
                opacity: titleMaterialCategory === "" ? 0.0 : 1.0
                font.family: font_material.name
                text: MdiFont.Icon.chevron_down //arrow_down_thick
                Layout.alignment: Qt.AlignHCenter
                Behavior on opacity{ NumberAnimation{duration: 100}}
            }

            //-- MaterialCategory --//
            ItemDelegate{
                id: nav_materialCategory
                opacity: titleMaterialCategory === "" ? 0.0 : 1.0
                Layout.fillWidth: true
                Behavior on opacity{ NumberAnimation{duration: 100}}

                Label{
                    id: lbl_titleMaterialCategory
                    text: titleMaterialCategory
                    anchors.centerIn: parent
                    width: Math.min(parent.width, implicitWidth)
                    elide: Text.ElideMiddle
                }

                ToolTip.visible: lbl_titleMaterialCategory.implicitWidth > width ? hovered : false
                ToolTip.text: titleCategory
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.timeout: 5000

                onClicked: {
                    expandWin("MaterialCategory")
                }
            }

            //-- down icon--//
            Label{
                opacity: titleMaterial === "" ? 0.0 : 1.0
                font.family: font_material.name
                text: MdiFont.Icon.chevron_down //arrow_down_thick
                Layout.alignment: Qt.AlignHCenter
                Behavior on opacity{ NumberAnimation{duration: 100}}
            }

            //-- Material --//
            ItemDelegate{
                id: nav_material
                opacity: titleMaterial === "" ? 0.0 : 1.0
                Layout.fillWidth: true
                Behavior on opacity{ NumberAnimation{duration: 100}}

                Label{
                    id: lbl_titleMaterial
                    text: titleMaterial
                    anchors.centerIn: parent
                    width: Math.min(parent.width, implicitWidth)
                    elide: Text.ElideMiddle
                }

                ToolTip.visible: lbl_titleMaterial.implicitWidth > width ? hovered : false
                ToolTip.text: titleCategory
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.timeout: 5000

                onClicked: {
                    expandWin("Material")
                }
            }

            //-- down icon--//
            Label{
                opacity: titleSubMaterial === "" ? 0.0 : 1.0
                font.family: font_material.name
                text: MdiFont.Icon.chevron_down //arrow_down_thick
                Layout.alignment: Qt.AlignHCenter
                Behavior on opacity{ NumberAnimation{duration: 100}}
            }

            //-- SubMaterial --//
            ItemDelegate{
                id: nav_subMaterial
                opacity: titleSubMaterial === "" ? 0.0 : 1.0
                Layout.fillWidth: true
                Behavior on opacity{ NumberAnimation{duration: 100}}

                Label{
                    id: lbl_titleSubMaterial
                    text: titleSubMaterial
                    anchors.centerIn: parent
                    width: Math.min(parent.width, implicitWidth)
                    elide: Text.ElideMiddle
                }

                ToolTip.visible: lbl_titleSubMaterial.implicitWidth > width ? hovered : false
                ToolTip.text: titleCategory
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.timeout: 5000

                onClicked: {
                    expandWin("SubMaterial")
                }
            }

            //-- down icon--//
            Label{
                opacity: titleSubSubMaterial === "" ? 0.0 : 1.0
                font.family: font_material.name
                text: MdiFont.Icon.chevron_down //arrow_down_thick
                Layout.alignment: Qt.AlignHCenter
                Behavior on opacity{ NumberAnimation{duration: 100}}
            }

            //-- SubSubMaterial --//
            ItemDelegate{
                id: nav_subSubMaterial
                opacity: titleSubSubMaterial === "" ? 0.0 : 1.0
                Layout.fillWidth: true
                Behavior on opacity{ NumberAnimation{duration: 100}}

                Label{
                    id: lbl_titleSubSubMaterial
                    text: titleSubSubMaterial
                    anchors.centerIn: parent
                    width: Math.min(parent.width, implicitWidth)
                    elide: Text.ElideMiddle
                }

                ToolTip.visible: lbl_titleSubSubMaterial.implicitWidth > width ? hovered : false
                ToolTip.text: titleCategory
                ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                ToolTip.timeout: 5000

                onClicked: {
                    expandWin("SubSubMaterial")
                }
            }

            //-- filler --//
            Item { Layout.fillHeight: true }

            Button{
                id: btnAddProduct
                text: "افزودن محصول"
                Layout.fillWidth: true
//                Layout.preferredHeight: implicitHeight * 2
                Material.background: Util.color_kootwall_light //Material.BlueGrey
                Material.foreground: "#FFFFFF"

                onClicked: {
                    addProduct("")
                }
            }
        }

    }




    //-- log system --//
    function log(str, ignorMsg){

        //-- check global permission --//
        if(!isLogEnabled) return

        //-- check local permission --//
        if(!_localLogPermission) return

        //-- check msg permission --//
        if(!isNaN(ignorMsg) && ignorMsg) return

        //-- print logs --//
        console.log(objectName + "; " + str)
    }

}
