import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as QCC1_4
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import Qt.labs.settings 1.0
import "./Content/font/Icon.js" as MdiFont
import "./Content/Codes/REST/apiservice.js" as Service
import "./Content/Codes"
import "./Content/Codes/ModelClass"
import "./Content/Codes/Utils"
import "./Content/Codes/Utils/Util.js" as Util


QtObject {

    property string _token_access: ""
    property string _token_refresh: ""
    property bool   isLogined: false
    property string _userName: ""
    property string _password: ""
    property bool   isAdminPermission: false

    property bool logPermission         : true //true   //-- print log permission --//
    property bool _localLogPermission   : true //true   //-- local log permission --//

    property alias font_irans: font_irans
    property alias font_material: font_material

    //-- enums --//
    property string _CATEGORY        : "CATEGORY"
    property string _BASECATEGORY    : "BASECATEGORY"
    property string _CATEGORYMATERIAL: "CATEGORYMATERIAL"
    property string _MATERIAL        : "MATERIAL"
    property string _SUBMATERIAL     : "SUBMATERIAL"
    property string _SUBSUBMATERIAL  : "SUBSUBMATERIAL"
    property string _COMPANY         : "COMPANY"
    property string _COMPANYPRODUCT  : "COMPANYPRODUCT"

    //-- global categories listmodels --//
    property ListModel lm_category

    //-- save app setting --//
    property var setting: Settings{
        id: setting

        property string username: ""
        property string password: ""
        property string token_access: ""
        property string token_refresh: ""
        property bool   isRemember

        property alias companyProductWidth: companyProductsWin.width
        property alias companyProductHeight: companyProductsWin.height

        property alias mainWinWidth:  mainWin.width
        property alias mainWinHeight: mainWin.height

        property alias addProductWinWidth:  win_addProduction.width
        property alias addProductWinHeight: win_addProduction.height

        property alias companyWinWidth:  companyWin.width
        property alias companyWinHeight: companyWin.height

        property alias activeLoggerWinWidth:  activityLogger.width
        property alias activeLoggerWinHeight: activityLogger.height


        //-- SplitView parameter --//
        property alias split_categoryWidth1         : splt_c.savedWidth
        property alias split_baseCategoryWidth1     : splt_bc.savedWidth
        property alias split_materialCategoryWidth1 : splt_mc.savedWidth
        property alias split_materialWidth1         : splt_m.savedWidth
        property alias split_subMaterialWidth1      : splt_sm.savedWidth
        property alias split_subSubMaterialWidth1   : splt_ssm.savedWidth
        property alias flickXpos                    : flick.contentX

        //-- expand status --//
        property alias expand_categoryWidth1         : itm_categories.isExpand
        property alias expand_baseCategoryWidth1     : itm_baseCategory.isExpand
        property alias expand_materialCategoryWidth1 : itm_materialCategory.isExpand
        property alias expand_materialWidth1         : itm_materialItem.isExpand
        property alias expand_subMaterialWidth1      : itm_subMaterial.isExpand
        property alias expand_subSubMaterialWidth1   : itm_subSubMaterial.isExpand

    }


    //-- main window --//
    property var mainWin: ApplicationWindow {
        id: mainWin
        visible: false //true
        onVisibleChanged: {

            //-- load category data if window visible --//
            if(visible){
                itm_categories.fetchCatsFromDB()
            }
        }

        width: 1200
        height: 640
        minimumWidth: 800
        minimumHeight: 500
        title: qsTr("کوتوال")
        font.family: font_irans.name
        objectName: "main"

        Material.theme: Material.Light

        FontLoader{
            id: font_irans
            source: "qrc:/Content/font/IRANSans.ttf"
        }

        FontLoader{
            id: font_material
            source: "qrc:/Content/font/materialdesignicons-webfont.ttf"
        }
        font.pixelSize: Qt.application.font.pixelSize

        //-- header --//
        header: ToolBar{

            Material.background : Util.color_kootwall_dark //Material.BlueGrey

            RowLayout{
                anchors.fill: parent
                anchors.margins: 5


                //-- setting item --//
                ItemDelegate {
                    visible: false
                    Layout.fillHeight: true
                    Layout.preferredWidth: lbl_setting_icon.implicitWidth + 20

                    RowLayout{
                        anchors.fill: parent
                        anchors.margins: 5

                        Label{
                            id: lbl_setting_icon
                            font.family: font_material.name
                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                            text: MdiFont.Icon.settings_outline
                        }
                    }

                    onClicked: {

                        //-- LogOut proccess --//
                        if(isLogined){

                            //-- remove signIn saved setting property --//
                            setting.username = ""
                            setting.password = ""
                            setting.token_access  = ""
                            setting.token_refresh = ""

                            _token_access = ""
                            _token_refresh = ""

                            //-- save user and pass --//
                            _userName = ""
                            _password = ""

                            isLogined = false
                            isAdminPermission = false
                        }
                        //-- LogIn proccess --//
                        else{
                            authWin.visible = true
                        }
                    }

                }


                //-- logout/logIn item --//
                ItemDelegate {
                    Layout.fillHeight: true
                    Layout.preferredWidth: lbl_logout_icon.implicitWidth + lbl_logout_txt.implicitWidth + 20

                    RowLayout{
                        anchors.fill: parent
                        anchors.margins: 5

                        Label{
                            id: lbl_logout_icon
                            font.family: font_material.name
                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                            text: isLogined ? MdiFont.Icon.logout : MdiFont.Icon.login
                        }

                        Label{
                            id: lbl_logout_txt
                            text: isLogined ? "خروج" : "ورود"
                        }
                    }

                    onClicked: {

                        //-- LogOut proccess --//
                        if(isLogined){

                            //-- remove signIn saved setting property --//
                            setting.username = ""
                            setting.password = ""
                            setting.token_access  = ""
                            setting.token_refresh = ""

                            _token_access = ""
                            _token_refresh = ""

                            //-- save user and pass --//
                            _userName = ""
                            _password = ""

                            isLogined = false
                            isAdminPermission = false
                        }
                        //-- LogIn proccess --//
                        else{
                            authWin.visible = true
                        }
                    }

                }

                //-- Company item --//
                ItemDelegate {
                    Layout.fillHeight: true
                    Layout.preferredWidth: lbl_company_icon.implicitWidth + lbl_company_txt.implicitWidth + 20

                    RowLayout{
                        anchors.fill: parent
                        anchors.margins: 5

                        Label{
                            id: lbl_company_icon
                            font.family: font_material.name
                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                            text: MdiFont.Icon.city
                        }

                        Label{
                            id: lbl_company_txt
                            text: "مدیریت شرکت ها"
                        }
                    }

                    onClicked: {

                        itm_company.openWin()
                    }

                }

                //-- Company Products item --//
                ItemDelegate {
                    Layout.fillHeight: true
                    Layout.preferredWidth: lbl_companyProduct_icon.implicitWidth + lbl_companyProduct_txt.implicitWidth + 20

                    RowLayout{
                        anchors.fill: parent
                        anchors.margins: 5

                        Label{
                            id: lbl_companyProduct_icon
                            font.family: font_material.name
                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                            text: MdiFont.Icon.cube_outline
                        }

                        Label{
                            id: lbl_companyProduct_txt
                            text: "مدیریت محصول ها"
                        }
                    }

                    onClicked: {

                        itm_companyProducts.openWin()
                    }

                }

                //-- Activity Logger item --//
                ItemDelegate {
                    visible: isAdminPermission
                    Layout.fillHeight: true
                    Layout.preferredWidth: lbl_activityLogger_icon.implicitWidth + lbl_activityLogger_txt.implicitWidth + 20

                    RowLayout{
                        anchors.fill: parent
                        anchors.margins: 5

                        Label{
                            id: lbl_activityLogger_icon
                            font.family: font_material.name
                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                            text: MdiFont.Icon.laptop_mac
                        }

                        Label{
                            id: lbl_activityLogger_txt
                            text: "مدیریت فعالیت ها"
                        }
                    }

                    onClicked: {

                        itm_activityLogger.openWin()
                    }

                }

                //-- filler --//
                Item { Layout.fillWidth: true }

                SearchField{
                    id: totalSearch
                    width: 200

                    //-- string text --//
                    onEnteredText:{
                        console.log("text = " + text)
                        globalSearch.show(text)
                    }
                }

                //-- login user --//
                ItemDelegate {
                    visible: isLogined
                    Layout.fillHeight: true
                    Layout.preferredWidth: lbl_user_icon.implicitWidth + lbl_user_txt.implicitWidth + 20

                    RowLayout{
                        anchors.fill: parent
                        anchors.margins: 5

                        Label{
                            id: lbl_user_icon
                            font.family: font_material.name
                            font.pixelSize: Qt.application.font.pixelSize * 1.5
                            text: MdiFont.Icon.account
                            Layout.alignment: Qt.AlignCenter
                        }

                        Label{
                            id: lbl_user_txt
                            text: _userName
                            font.family: font_irans.name
                            Layout.alignment: Qt.AlignCenter
                        }
                    }

                }
            }


        }

        //-- size propose --//
        Label{
            id: lblHeaderSize
            text: "زیردسته بندی"
            visible: false
        }

        //-- main --//
        RowLayout{
            anchors.fill: parent
            anchors.margins: 5

            Flickable{
                id: flick
                Layout.fillWidth: true
                Layout.fillHeight: true
                /*contentWidth: itm_subSubMaterial.implicitWidth
                              + itm_subMaterial.implicitWidth
                              + itm_materialItem.implicitWidth
                              + itm_materialCategory.implicitWidth
                              + itm_baseCategory.implicitWidth
                              + itm_categories.implicitWidth
                              + rlCats.spacing*6*/
                contentWidth: (itm_categories.isExpand ? (maxWidth) : (minWidth))
                              + (itm_baseCategory.isExpand ? (maxWidth) : (minWidth))
                              + (itm_materialCategory.isExpand ? (maxWidth) : (minWidth))
                              + (itm_materialItem.isExpand ? (maxWidth) : (minWidth))
                              + (itm_subMaterial.isExpand ? (maxWidth) : (minWidth))
                              + (itm_subSubMaterial.isExpand ? (maxWidth) : (minWidth))
                              + 10


                ScrollBar.horizontal: ScrollBar {
                    id: control
                    size: 0.1
                    position: 0.2
                    active: true
                    orientation: Qt.Horizontal
//                    policy: listmodel.count>(lv.height/40) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                    contentItem: Rectangle {
                        implicitWidth: 6
                        implicitHeight: 6
                        radius: width / 2
                        color: control.pressed ? "#aa32aaba" : "#5532aaba"
                    }

                }

                property int minWidth: 200
                property int maxWidth: 320

                QCC1_4.SplitView {
                    id: splt
//                    visible: false
                     anchors.fill: parent
                     orientation: Qt.Horizontal

                     onResizingChanged: {
//                         console.log(resizing)
                         if(!resizing){
                             splt_c.savedWidth  = splt_c.width
                             splt_bc.savedWidth = splt_bc.width
                             splt_mc.savedWidth = splt_mc.width
                             splt_m.savedWidth  = splt_m.width
                             splt_sm.savedWidth = splt_sm.width
                             splt_ssm.savedWidth= splt_ssm.width
                         }
                     }

                     //-- sixth group --//
                     Rectangle {
                         id: splt_ssm

                         property int lastExpandWidth   //-- save width for expand mode --//
                         property int savedWidth        //-- save width restor porpose --//
                         property int minWidth: flick.minWidth

                         width: itm_subSubMaterial.isExpand ? savedWidth : 60
                         Layout.maximumWidth: itm_subSubMaterial.isExpand ? flick.maxWidth : 60
                         Layout.minimumWidth: itm_subSubMaterial.isExpand ? minWidth : 60

                         SubSubMaterial{
                             id: itm_subSubMaterial

                             anchors.fill: parent
                             anchors.margins: 5
                             headerUnExpandHeight: lblHeaderSize.implicitWidth * 1.7
                             isLogEnabled: logPermission

                             //-- handle message --//
                             //-- string msg, , String alarmType --//
                             onTriggerMsg: msgHandler.show(msg, alarmType)

                             //-- signal to AddProduct --//
                             onOpenAddProduct: {
                                 itm_navigationGuid.addProduct(_SUBSUBMATERIAL)
                             }

                             //-- string subSubMaterialID --//
                             onReturnSelectedSubSubMaterial: {
                                 log("trigger: " + subSubMaterialID)

                                 //-- loade data is done, chech flag of searchrd resualts --//
                                 if(globalSearch.searchData.isSubSubMaterialValid){

                                     selectNewItemBasedonID(globalSearch.searchData.idSubSubMaterial, function(isFinded){

                                         if(isFinded) globalSearch.searchData.isSubSubMaterialValid = false
                                     })
                                 }
                             }

                             onIsExpandChanged: {
                                 if(isExpand){
                                     splt_ssm.minWidth    = splt_ssm.lastExpandWidth
                                     splt_ssm.width       = splt_ssm.lastExpandWidth
                                     timer_subSubMaterial.restart()
                                 }
                                 else{
                                     splt_ssm.lastExpandWidth = splt_ssm.width
                                 }
                             }

                             Timer {
                                 id: timer_subSubMaterial
                                 interval: 10; running: false; repeat: false
                                 onTriggered: {
                                     splt_ssm.minWidth = flick.minWidth
                                     timer_subSubMaterial.stop()
                                 }
                             }

                         }

                     }

                     //-- fifth group --//
                     Rectangle {
                         id: splt_sm

                         property int lastExpandWidth   //-- save width for expand mode --//
                         property int savedWidth        //-- save width restor porpose --//
                         property int minWidth: flick.minWidth

                         width: itm_subMaterial.isExpand ? savedWidth : 60
                         Layout.maximumWidth: itm_subMaterial.isExpand ? flick.maxWidth : 60
                         Layout.minimumWidth: itm_subMaterial.isExpand ? minWidth : 60

                         SubMaterial{
                             id: itm_subMaterial

                             anchors.fill: parent
                             anchors.margins: 5
                             headerUnExpandHeight: lblHeaderSize.implicitWidth * 1.7
                             isLogEnabled: logPermission

                             //-- string subMaterialID --//
                             onReturnSelectedSubMaterial:{

                                 itm_subSubMaterial.setedIndex(subMaterialID)


                                 //-- loade data is done, chech flag of searchrd resualts --//
                                 if(globalSearch.searchData.isSubMaterialValid){

                                     selectNewItemBasedonID(globalSearch.searchData.idSubMaterial, function(isFinded){

                                         if(isFinded) globalSearch.searchData.isSubMaterialValid = false
                                     })
                                 }
                             }

                             //-- handle message --//
                             //-- string msg, , String alarmType --//
                             onTriggerMsg: msgHandler.show(msg, alarmType)

                             //-- signal to AddProduct --//
                             onOpenAddProduct: {
                                 itm_navigationGuid.addProduct(_SUBMATERIAL)
                             }

                             onIsExpandChanged: {
                                 if(isExpand){
                                     splt_sm.minWidth    = splt_sm.lastExpandWidth
                                     splt_sm.width       = splt_sm.lastExpandWidth
                                     timer_subMaterial.restart()
                                 }
                                 else{
                                     splt_sm.lastExpandWidth = splt_sm.width
                                 }
                             }

                             Timer {
                                 id: timer_subMaterial
                                 interval: 10; running: false; repeat: false
                                 onTriggered: {
                                     splt_sm.minWidth = flick.minWidth
                                     timer_subMaterial.stop()
                                 }
                             }

                         }

                     }

                     //-- fourth group --//
                     Rectangle {
                         id: splt_m

                         property int lastExpandWidth   //-- save width for expand mode --//
                         property int savedWidth        //-- save width restor porpose --//
                         property int minWidth: flick.minWidth

                         width: itm_materialItem.isExpand ? savedWidth : 60
                         Layout.maximumWidth: itm_materialItem.isExpand ? flick.maxWidth : 60
                         Layout.minimumWidth: itm_materialItem.isExpand ? minWidth : 60

                         MaterialItem{
                             id: itm_materialItem

                             anchors.fill: parent
                             anchors.margins: 5
                             headerUnExpandHeight: lblHeaderSize.implicitWidth * 1.7
                             isLogEnabled: logPermission

                             //-- string materialID --//
                             onReturnSelectedMaterial:{

                                 itm_subMaterial.setedIndex(materialID)


                                 //-- loade data is done, chech flag of searchrd resualts --//
                                 if(globalSearch.searchData.isMaterialValid){

                                     selectNewItemBasedonID(globalSearch.searchData.idMaterial, function(isFinded){

                                         if(isFinded) globalSearch.searchData.isMaterialValid = false
                                     })
                                 }
                             }

                             //-- handle message --//
                             //-- string msg, , String alarmType --//
                             onTriggerMsg: msgHandler.show(msg, alarmType)

                             //-- signal to AddProduct --//
                             onOpenAddProduct: {
                                 itm_navigationGuid.addProduct(_MATERIAL)
                             }

                             onIsExpandChanged: {
                                 if(isExpand){
                                     splt_m.minWidth    = splt_m.lastExpandWidth
                                     splt_m.width       = splt_m.lastExpandWidth
                                     timer_material.restart()
                                 }
                                 else{
                                     splt_m.lastExpandWidth = splt_m.width
                                 }
                             }

                             Timer {
                                 id: timer_material
                                 interval: 10; running: false; repeat: false
                                 onTriggered: {
                                     splt_m.minWidth = flick.minWidth
                                     timer_material.stop()
                                 }
                             }

                         }

                     }

                     //-- third group --//
                     Rectangle {
                         id: splt_mc

                         property int lastExpandWidth   //-- save width for expand mode --//
                         property int savedWidth        //-- save width restor porpose --//
                         property int minWidth: flick.minWidth

                         width: itm_materialCategory.isExpand ? savedWidth : 60
                         Layout.maximumWidth: itm_materialCategory.isExpand ? flick.maxWidth : 60
                         Layout.minimumWidth: itm_materialCategory.isExpand ? minWidth : 60

                         MaterialCategory{
                             id: itm_materialCategory

                             anchors.fill: parent
                             anchors.margins: 5
                             headerUnExpandHeight: lblHeaderSize.implicitWidth * 1.7
                             isLogEnabled: logPermission

                             //-- string materialCategoryID --//
                             onReturnSelectedMaterialCategory:{

                                 itm_materialItem.setedIndex(materialCategoryID)

                                 //-- loade data is done, chech flag of searchrd resualts --//
                                 if(globalSearch.searchData.isMaterialCategoryValid){

                                     selectNewItemBasedonID(globalSearch.searchData.idMaterialCategory, function(isFinded){

                                         if(isFinded) globalSearch.searchData.isMaterialCategoryValid = false
                                     })
                                 }
                             }

                             //-- handle message --//
                             //-- string msg, , String alarmType --//
                             onTriggerMsg: msgHandler.show(msg, alarmType)

                             //-- signal to AddProduct --//
                             onOpenAddProduct: {
                                 itm_navigationGuid.addProduct(_CATEGORYMATERIAL)
                             }

                             onIsExpandChanged: {
                                 if(isExpand){
                                     splt_mc.minWidth = splt_mc.lastExpandWidth
                                     splt_mc.width = splt_mc.lastExpandWidth
                                     timer_materialCategory.restart()
                                 }
                                 else{
                                     splt_mc.lastExpandWidth = splt_mc.width
                                 }
                             }

                             Timer {
                                 id: timer_materialCategory
                                 interval: 10; running: false; repeat: false
                                 onTriggered: {
                                     splt_mc.minWidth = flick.minWidth
                                     timer_materialCategory.stop()
                                 }
                             }

                         }

                     }

                     //-- second group --//
                     Rectangle {
                         id: splt_bc

                         property int lastExpandWidth   //-- save width for expand mode --//
                         property int savedWidth        //-- save width restor porpose --//
                         property int minWidth: flick.minWidth

                         width: itm_baseCategory.isExpand ? savedWidth : 60
                         Layout.maximumWidth: itm_baseCategory.isExpand ? flick.maxWidth : 60
                         Layout.minimumWidth: itm_baseCategory.isExpand ? minWidth : 60

                         BaseCategory{
                             id: itm_baseCategory

                             anchors.fill: parent
                             anchors.margins: 5
                             headerUnExpandHeight: lblHeaderSize.implicitWidth * 1.7
                             isLogEnabled: logPermission

                             //-- string baseCategoryID --//
                             onReturnSelectedBaseCategory:{

                                 itm_materialCategory.setedIndex(baseCategoryID)

                                 log("--- load data of basecategory is completed")

                                 //-- loade data is done, chech flag of searchrd resualts --//
                                 if(globalSearch.searchData.isBaseCategoryValid){

                                     selectNewItemBasedonID(globalSearch.searchData.idBaseCategory, function(isFinded){

                                         if(isFinded) globalSearch.searchData.isBaseCategoryValid = false
                                         log("globalSearch.searchData.isBaseCategoryValid = " + globalSearch.searchData.isBaseCategoryValid)
                                     })
                                 }
                             }

                             //-- signal to AddProduct --//
                             onOpenAddProduct: {
                                 itm_navigationGuid.addProduct(_BASECATEGORY)
                             }

                             //-- handle message --//
                             //-- string msg, , String alarmType --//
                             onTriggerMsg: msgHandler.show(msg, alarmType)

                             onIsExpandChanged: {
                                 if(isExpand){
                                     splt_bc.minWidth = splt_bc.lastExpandWidth
                                     splt_bc.width = splt_bc.lastExpandWidth
                                     timer_baseCategory.restart()
                                 }
                                 else{
                                     splt_bc.lastExpandWidth = splt_bc.width
                                 }
                             }

                             Timer {
                                 id: timer_baseCategory
                                 interval: 10; running: false; repeat: false
                                 onTriggered: {
                                     splt_bc.minWidth = flick.minWidth
                                     timer_baseCategory.stop()
                                 }
                             }

                         }

                     }

                     //-- first group --//
                     Rectangle {
                         id: splt_c

                         property int lastExpandWidth //-- save width for expand mode --//
                         property int savedWidth //-- save width restor porpose --//
                         property int minWidth: flick.minWidth
                         onSavedWidthChanged: {
                             console.log("savedWidth = " + savedWidth)
                         }

                         width: itm_categories.isExpand ? savedWidth : 60
                         Layout.maximumWidth: itm_categories.isExpand ? flick.maxWidth : 60
                         Layout.minimumWidth: itm_categories.isExpand ? minWidth : 60

                         Component.onDestruction: {
//                             setting.splt_catSavedWidth = width
                             console.log("destroy, l = " + setting.split_categoryWidth1)
                         }
                         Component.onCompleted:{
//                             width = setting.splt_catSavedWidth
                             console.log(" start, setting.splt_catSavedWidth = " + setting.split_categoryWidth1)
                         }

                         Category{
                             id: itm_categories

                             anchors.fill: parent
                             anchors.margins: 5
                             headerUnExpandHeight: lblHeaderSize.implicitWidth * 1.7
                             isLogEnabled: logPermission

                             //-- string categoryID --//
                             onReturnSelectedCategory: itm_baseCategory.setedIndex(categoryID)

                             //-- handle message --//
                             //-- string msg, , String alarmType --//
                             onTriggerMsg: msgHandler.show(msg, alarmType)

                             //-- signal to AddProduct --//
                             onOpenAddProduct: {
                                 itm_navigationGuid.addProduct(_CATEGORY)
                             }

                             onIsExpandChanged: {
                                 if(isExpand){
                                     splt_c.minWidth = splt_c.lastExpandWidth
                                     splt_c.width = splt_c.lastExpandWidth
                                     timer_category.restart()
                                 }
                                 else{
                                     splt_c.lastExpandWidth = splt_c.width
                                 }
                             }

                             Timer {
                                 id: timer_category
                                 interval: 10; running: false; repeat: false
                                 onTriggered: {
                                     splt_c.minWidth = flick.minWidth
                                     timer_category.stop()
                                     console.log("timer done")
                                 }
                             }
                         }
                     }

                     //-- last dummy --//
                     Rectangle {
                         id: splt_r
                         property int _width: width
                         onWidthChanged:{_width=width}
                         width: 6
                         Layout.maximumWidth: 6
                         Layout.minimumWidth: 6
                         color: "transparent"

                     }
                }

            }

            //-- Navigation Guid --//
            NavigationGuid{
                id: itm_navigationGuid

                Layout.fillHeight: true
                Layout.preferredWidth: 120
                isLogEnabled: logPermission

                //-- handle categories win expand signall --//
                //-- string catName --//
                onExpandWin:{

                    if(catName === "Category"){
                        itm_categories.isExpand = true
                    }
                    else if(catName === "BaseCategory"){
                        itm_baseCategory.isExpand = true
                    }
                    else if(catName === "MaterialCategory"){
                        itm_materialCategory.isExpand = true
                    }
                    else if(catName === "Material"){
                        itm_materialItem.isExpand = true
                    }
                    else if(catName === "SubMaterial"){
                        itm_subMaterial.isExpand = true
                    }
                    else if(catName === "SubSubMaterial"){
                        itm_subSubMaterial.isExpand = true
                    }
                }

                titleCategory: {
                    //-- validate selected item --//
                    if(itm_categories.selModelIndx > -1 && itm_categories.modelItm.count > 0){

                        return itm_categories.modelItm.get(itm_categories.selModelIndx).title
                    }
                    return ""
                }

                titleBaseCategory: {

                    //-- validate selected item --//
                    if(itm_baseCategory.selModelIndx > -1 && itm_baseCategory.modelItm.count > 0){

                        return itm_baseCategory.modelItm.get(itm_baseCategory.selModelIndx).title
                    }
                    return ""
                }

                titleMaterialCategory: {

                    //-- validate selected item --//
                    if(itm_materialCategory.selModelIndx > -1 && itm_materialCategory.modelItm.count > 0){

                        return itm_materialCategory.modelItm.get(itm_materialCategory.selModelIndx).title
                    }
                    return ""
                }

                titleMaterial: {

                    //-- validate selected item --//
                    if(itm_materialItem.selModelIndx > -1 && itm_materialItem.modelItm.count > 0){

                        return itm_materialItem.modelItm.get(itm_materialItem.selModelIndx).title
                    }
                    return ""
                }

                titleSubMaterial: {

                    //-- validate selected item --//
                    if(itm_subMaterial.selModelIndx > -1 && itm_subMaterial.modelItm.count > 0){

                        return itm_subMaterial.modelItm.get(itm_subMaterial.selModelIndx).title
                    }
                    return ""
                }

                titleSubSubMaterial: {

                    //-- validate selected item --//
                    if(itm_subSubMaterial.selModelIndx > -1 && itm_subSubMaterial.modelItm.count > 0){

                        return itm_subSubMaterial.modelItm.get(itm_subSubMaterial.selModelIndx).title
                    }
                    return ""
                }

                //-- var navs; category title --//
                onAddProduct: {

                    var isGroupProductCreation = false  //-- flag to detect parent vs leaves --//
                    var selectedbranchItemId = -1       //-- save selected parent kind branch id --//

                    //-- check recived signal to open AddProduct win (only open product not parent branch) --//
                    if(navs      === _CATEGORY          && itm_baseCategory.modelItm.count      > 0) isGroupProductCreation = true
                    else if(navs === _BASECATEGORY      && itm_materialCategory.modelItm.count  > 0) isGroupProductCreation = true
                    else if(navs === _CATEGORYMATERIAL  && itm_materialItem.modelItm.count      > 0) isGroupProductCreation = true
                    else if(navs === _MATERIAL          && itm_subMaterial.modelItm.count       > 0) isGroupProductCreation = true
                    else if(navs === _SUBMATERIAL       && itm_subSubMaterial.modelItm.count    > 0) isGroupProductCreation = true


                    addProduct.title_category = ""
                    addProduct.id_category    = -1
                    //-- validate selected item --//
                    if(itm_categories.selModelIndx > -1 && itm_categories.modelItm.count > 0){

                        addProduct.title_category = itm_categories.modelItm.get(itm_categories.selModelIndx).title
                        addProduct.id_category    = itm_categories.modelItm.get(itm_categories.selModelIndx).id

                    }

                    addProduct.title_baseCategory = ""
                    addProduct.id_baseCategory    = -1
                    //-- validate selected item --//
                    if(itm_baseCategory.selModelIndx > -1 && itm_baseCategory.modelItm.count > 0){

                        addProduct.title_baseCategory = itm_baseCategory.modelItm.get(itm_baseCategory.selModelIndx).title
                        addProduct.id_baseCategory    = itm_baseCategory.modelItm.get(itm_baseCategory.selModelIndx).id

                    }

                    addProduct.title_materialCategory = ""
                    addProduct.id_materialCategory    = -1
                    //-- validate selected item --//
                    if(itm_materialCategory.selModelIndx > -1 && itm_materialCategory.modelItm.count > 0){

                        addProduct.title_materialCategory = itm_materialCategory.modelItm.get(itm_materialCategory.selModelIndx).title
                        addProduct.id_materialCategory    = itm_materialCategory.modelItm.get(itm_materialCategory.selModelIndx).id

                    }

                    addProduct.title_material = ""
                    addProduct.id_material    = -1
                    //-- validate selected item --//
                    if(itm_materialItem.selModelIndx > -1 && itm_materialItem.modelItm.count > 0){

                        addProduct.title_material = itm_materialItem.modelItm.get(itm_materialItem.selModelIndx).title
                        addProduct.id_material    = itm_materialItem.modelItm.get(itm_materialItem.selModelIndx).id

                    }

                    addProduct.title_subMaterial = ""
                    addProduct.id_subMaterial    = -1
                    //-- validate selected item --//
                    if(itm_subMaterial.selModelIndx > -1 && itm_subMaterial.modelItm.count > 0){

                        addProduct.title_subMaterial = itm_subMaterial.modelItm.get(itm_subMaterial.selModelIndx).title
                        addProduct.id_subMaterial    = itm_subMaterial.modelItm.get(itm_subMaterial.selModelIndx).id

                    }

                    addProduct.title_subSubMaterial = ""
                    addProduct.id_subSubMaterial    = -1
                    //-- validate selected item --//
                    if(itm_subSubMaterial.selModelIndx > -1 && itm_subSubMaterial.modelItm.count > 0){

                        addProduct.title_subSubMaterial = itm_subSubMaterial.modelItm.get(itm_subSubMaterial.selModelIndx).title
                        addProduct.id_subSubMaterial    = itm_subSubMaterial.modelItm.get(itm_subSubMaterial.selModelIndx).id

                    }

                    if(isGroupProductCreation){


                        if(navs      === _CATEGORY         ) selectedbranchItemId = addProduct.id_category
                        else if(navs === _BASECATEGORY     ) selectedbranchItemId = addProduct.id_baseCategory
                        else if(navs === _CATEGORYMATERIAL ) selectedbranchItemId = addProduct.id_materialCategory
                        else if(navs === _MATERIAL         ) selectedbranchItemId = addProduct.id_material
                        else if(navs === _SUBMATERIAL      ) selectedbranchItemId = addProduct.id_subMaterial
                        else if(navs === _SUBSUBMATERIAL   ) selectedbranchItemId = addProduct.id_subSubMaterial

                        //-- open add group product win --//
                        categoryLeaves.show(selectedbranchItemId, navs)
                    }
                    else{
                        //-- open add windows --//
                        addProduct.openWin()
                    }
                }
            }


        }


        //-- serach in all categories --//
        GlobalSearch{
            id: globalSearch

            mainPage: parent //-- alighment porpos --//
            isLogEnabled: logPermission

            property variant searchData: {
                'isCategoryValid'           : false,
                'isBaseCategoryValid'       : false,
                'isMaterialCategoryValid'   : false,
                'isMaterialValid'           : false,
                'isSubMaterialValid'        : false,
                'isSubSubMaterialValid'     : false,
                'idCategory'                : "",
                'idBaseCategory'            : "",
                'idMaterialCategory'        : "",
                'idMaterial'                : "",
                'idSubMaterial'             : "",
                'idSubSubMaterial'          : "",
            }

            //-- move to selected category --//
            //-- variant data --//
            onMoveToSelectedCategory: {

                console.log("tag: " + data.tag + ", catId: " + data.category)

                var tag = data.tag

                var isCategoryValid         = false
                var isBaseCategoryValid     = false
                var isCategoryMaterialValid = false
                var isMaterialValid         = false
                var isSubMaterialValid      = false
                var isSubSubMaterialValid   = false

                var idCategory         = ""
                var idBaseCategory     = ""
                var idCategoryMaterial = ""
                var idMaterial         = ""
                var idSubMaterial      = ""
                var idSubSubMaterial   = ""

                if(tag === _CATEGORY){

                    itm_categories.selectNewItemBasedonID(data.category, function(){

                        console.log("category load is done")
                    })

                }
                else if(tag === _BASECATEGORY){

                    //-- set flag to applay selected serach resualt after load from DB --//
                    searchData.isBaseCategoryValid       = true
                    searchData.idBaseCategory            = data.baseCategory

                    itm_categories.selectNewItemBasedonID(data.category)
                    //-- if list fiil --//
                    itm_baseCategory.selectNewItemBasedonID(data.baseCategory, function(isFinded){

                        console.log("base cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isBaseCategoryValid = false
                        }
                    })


                }
                else if(tag === _CATEGORYMATERIAL){

                    //-- set flag to applay selected serach resualt after load from DB --//
                    searchData.isBaseCategoryValid       = true
                    searchData.idBaseCategory            = data.baseCategory
                    searchData.isMaterialCategoryValid   = true
                    searchData.idMaterialCategory        = data.materialCategory

                    itm_categories.selectNewItemBasedonID(data.category)
                    //-- if list fiil --//
                    itm_baseCategory.selectNewItemBasedonID(data.baseCategory, function(isFinded){

                        console.log("base cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isBaseCategoryValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_materialCategory.selectNewItemBasedonID(data.materialCategory, function(isFinded){

                        console.log("material cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isMaterialCategoryValid = false
                        }
                    })

                }
                else if(tag === _MATERIAL){

                    //-- set flag to applay selected serach resualt after load from DB --//
                    searchData.isBaseCategoryValid      = true
                    searchData.idBaseCategory           = data.baseCategory
                    searchData.isMaterialCategoryValid  = true
                    searchData.idMaterialCategory       = data.materialCategory
                    searchData.isMaterialValid          = true
                    searchData.idMaterial               = data.material

                    itm_categories.selectNewItemBasedonID(data.category)
                    //-- if list fiil --//
                    itm_baseCategory.selectNewItemBasedonID(data.baseCategory, function(isFinded){

                        console.log("base cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isBaseCategoryValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_materialCategory.selectNewItemBasedonID(data.materialCategory, function(isFinded){

                        console.log("material cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isMaterialCategoryValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_materialItem.selectNewItemBasedonID(data.material, function(isFinded){

                        console.log("material isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isMaterialValid = false
                        }
                    })

                }
                else if(tag === _SUBMATERIAL){

                    //-- set flag to applay selected serach resualt after load from DB --//
                    searchData.isBaseCategoryValid      = true
                    searchData.idBaseCategory           = data.baseCategory
                    searchData.isMaterialCategoryValid  = true
                    searchData.idMaterialCategory       = data.materialCategory
                    searchData.isMaterialValid          = true
                    searchData.idMaterial               = data.material
                    searchData.isSubMaterialValid       = true
                    searchData.idSubMaterial            = data.subMaterial

                    itm_categories.selectNewItemBasedonID(data.category)
                    //-- if list fiil --//
                    itm_baseCategory.selectNewItemBasedonID(data.baseCategory, function(isFinded){

                        console.log("base cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isBaseCategoryValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_materialCategory.selectNewItemBasedonID(data.materialCategory, function(isFinded){

                        console.log("material cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isMaterialCategoryValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_materialItem.selectNewItemBasedonID(data.material, function(isFinded){

                        console.log("material isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isMaterialValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_subMaterial.selectNewItemBasedonID(data.subMaterial, function(isFinded){

                        console.log("sub material isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isSubMaterialValid = false
                        }
                    })

                }
                else if(tag === _SUBSUBMATERIAL){

                    //-- set flag to applay selected serach resualt after load from DB --//
                    searchData.isBaseCategoryValid      = true
                    searchData.idBaseCategory           = data.baseCategory
                    searchData.isMaterialCategoryValid  = true
                    searchData.idMaterialCategory       = data.materialCategory
                    searchData.isMaterialValid          = true
                    searchData.idMaterial               = data.material
                    searchData.isSubMaterialValid       = true
                    searchData.idSubMaterial            = data.subMaterial
                    searchData.isSubSubMaterialValid    = true
                    searchData.idSubSubMaterial         = data.subSubMaterial

                    itm_categories.selectNewItemBasedonID(data.category)
                    //-- if list fiil --//
                    itm_baseCategory.selectNewItemBasedonID(data.baseCategory, function(isFinded){

                        console.log("base cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isBaseCategoryValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_materialCategory.selectNewItemBasedonID(data.materialCategory, function(isFinded){

                        console.log("material cat isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isMaterialCategoryValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_materialItem.selectNewItemBasedonID(data.material, function(isFinded){

                        console.log("material isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isMaterialValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_subMaterial.selectNewItemBasedonID(data.subMaterial, function(isFinded){

                        console.log("sub material isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isSubMaterialValid = false
                        }
                    })
                    //-- if list fiil --//
                    itm_subSubMaterial.selectNewItemBasedonID(data.subSubMaterial, function(isFinded){

                        console.log("sub sub material isFinded: " + isFinded )
                        if(isFinded){

                            searchData.isSubSubMaterialValid = false
                        }
                    })
                }

                /*searchData.isCategoryValid         = isCategoryValid
                searchData.isBaseCategoryValid       = isBaseCategoryValid
                searchData.isMaterialCategoryValid   = isCategoryMaterialValid
                searchData.isMaterialValid           = isMaterialValid
                searchData.isSubMaterialValid        = isSubMaterialValid
                searchData.isSubSubMaterialValid     = isSubSubMaterialValid
                searchData.idCategory                = idCategory
                searchData.idBaseCategory            = idBaseCategory
                searchData.idMaterialCategory        = idCategoryMaterial
                searchData.idMaterial                = idMaterial
                searchData.idSubMaterial             = idSubMaterial
                searchData.idSubSubMateria          = idSubSubMaterial*/

                console.log(
                            "searchData = " +
                            searchData.isCategoryValid           + "," +
                            searchData.isBaseCategoryValid       + "," +
                            searchData.isMaterialCategoryValid   + "," +
                            searchData.isMaterialValid           + "," +
                            searchData.isSubMaterialValid        + "," +
                            searchData.isSubSubMaterialValid     + "," +
                            searchData.idCategory                + "," +
                            searchData.idBaseCategory            + "," +
                            searchData.idMaterialCategory        + "," +
                            searchData.idMaterial                + "," +
                            searchData.idSubMaterial             + "," +
                            searchData.idSubSubMaterial
                            )

            }

        }

        //-- message handler --//
        MsgPopup{
            id: msgHandler

        }

        //-- key handler --..
        Item {
            anchors.fill: parent
            focus: true
            Keys.onPressed: {
                if (event.key == Qt.Key_F5) {
                    console.log("refferesh");
                    event.accepted = true;
                }
            }
        }

        //-- log system --//
        function log(str){

            //-- check global permission --//
            if(!logPermission) return

            //-- check local permission --//
            if(!_localLogPermission) return

            //-- print logs --//
            console.log(objectName + "; " + str)
        }
    }

    //-- Add production --//
    property var win_addGroupProduction: ApplicationWindow{
        id: win_addGroupProduction

        visible: false
        width: 800 //addProduct.width
        height: 500 //addProduct.height
        minimumWidth: 800
        minimumHeight: 500
        title: "افزودن گروهی محصول ها"


        CategoryLeaves{
            id: categoryLeaves

            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            isLogEnabled: logPermission

            onShow: win_addGroupProduction.visible = true
        }
    }

    //-- Add production --//
    property var win_addProduction: ApplicationWindow{
        id: win_addProduction

        visible: false
        width: 800 //addProduct.width
        height: 500 //addProduct.height
        minimumWidth: 800
        minimumHeight: 500
        title: "افزودن محصول ها"

        AddProduct{
            id: addProduct

            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            isLogEnabled: logPermission

            onOpenWin: win_addProduction.visible = true
            onOpenCompanyWin: itm_company.openWin()

            //-- update category list that new item added to it --//
            //-- string catName, variant itm --//
            onUpdateCatList: {

                if(catName === _BASECATEGORY){
                    itm_baseCategory.addNewItem(itm)
                }
                else if(catName === _CATEGORYMATERIAL){
                    itm_materialCategory.addNewItem(itm)
                }
                else if(catName === _MATERIAL){
                    itm_materialItem.addNewItem(itm)
                }
                else if(catName === _SUBMATERIAL){
                    itm_subMaterial.addNewItem(itm)
                }
                else if(catName === _SUBSUBMATERIAL){
                    itm_subSubMaterial.addNewItem(itm)
                }
            }
        }
    }


    //-- Company Window --//
    property var companyWin: ApplicationWindow{
        id: companyWin

        visible: false
        width: 900 //Math.max(lblAlarm.implicitWidth*1.3 , 300)
        height: 650
        minimumWidth: 800
        minimumHeight: 500
        title: "مدیریت شرکت ها"



        //-- Company item --//
        Company{
            id: itm_company

            anchors.fill: parent
            isLogEnabled: logPermission
            categoryListmodel: itm_categories.modelItm

            onOpenWin: companyWin.visible = true
        }
    }


    //-- Company Products Window --//
    property var companyProductsWin: ApplicationWindow{
        id: companyProductsWin

        visible: false
//        width: 900 //Math.max(lblAlarm.implicitWidth*1.3 , 300)
//        height: 650
        title: "مدیریت محصول ها"

        minimumWidth: 800
        minimumHeight: 500

        //-- CompanyProduct item --//
        CompanyProduct{
            id: itm_companyProducts

            anchors.fill: parent
            isLogEnabled: logPermission

            onOpenWin: companyProductsWin.visible = true

        }
    }


    //-- Activity logger Window --//
    property var activityLoggerWin: ApplicationWindow{
        id: activityLogger

        visible: false
        title: "مدیریت فعالیت ها"

        minimumWidth: 1000
        minimumHeight: 500

        //-- CompanyProduct item --//
        ActivityLogger{
            id: itm_activityLogger

            anchors.fill: parent
            isLogEnabled: logPermission

            onOpenWin: activityLogger.visible = true

        }
    }

    //-- export JSON fron DB Window --//
    property var jsonWin: ApplicationWindow{
        id: jsonWin

        visible: false
        width: 900 //Math.max(lblAlarm.implicitWidth*1.3 , 300)
        height: 650
        title: "export JSON fron DB"

        ColumnLayout{
            anchors.fill: parent

            Item {
                id: itmGet
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                RowLayout{
                    anchors.fill: parent

                    //-- category --//
                    Button{
                        text: "get category"
                        onClicked: {

                            itmGet.getCategory()
                        }
                    }

                    //-- BaseCategory --//
                    Button{
                        text: "BaseCategory"
                        onClicked: {

                            console.log("/n/n/n/lennnn = " + Util.structJSON.length)

                            for(var i=0; i<Util.structJSON.length; i++){

                                console.log("send request = " + i)

                                var selID = Util.structJSON[i].id

                                itmGet.getBaseCategory(selID, i, function(d, indx){

                                    console.log("index = " + indx + ", d=" + d)
                                    Util.structJSON[indx].Category = d

                                    txtJson.text = JSON.stringify(Util.structJSON)

                                })
                            }


                        }
                    }

                    //-- MaterialCategory --//
                    Button{
                        text: "MaterialCategory"
                        onClicked: {

                            console.log("/n/n/n/lennnn = " + Util.structJSON.length)

                            for(var i=0; i<Util.structJSON.length; i++){

                                console.log("len["+i+"] = " + Util.structJSON[i].Category.length)

                                for(var j=0; i<Util.structJSON[i].Category.length; j++){

                                    console.log("send request = " + i + "->" + j)

                                    var selID = Util.structJSON[i].Category[j].id

                                    itmGet.getMaterialCategory(selID, i, j, function(d, indx, indx2){

                                        console.log("index = " + indx + ", d=" + d)
                                        Util.structJSON[indx].Category[indx2].MaterialCategory = d

                                        txtJson.text = JSON.stringify(Util.structJSON)

                                    })
                                }

                            }

                        }
                    }

                    //-- Material --//
                    Button{
                        text: "Material"
                        onClicked: {

                            console.log("/n/n/n/lennnn = " + Util.structJSON.length)

                            for(var i=0; i<Util.structJSON.length; i++){

                                console.log("len["+i+"] = " + Util.structJSON[i].Category.length)

                                for(var j=0; j<Util.structJSON[i].Category.length; j++){

                                    console.log("send request = " + i + "->" + j)

                                    for(var k=0; k<Util.structJSON[i].Category[j].MaterialCategory.length; k++){


                                        var selID = Util.structJSON[i].Category[j].MaterialCategory[k].id

                                        itmGet.getMaterial(selID, i, j, k, function(d, indx, indx2, indx3){

                                            Util.structJSON[indx].Category[indx2].MaterialCategory[indx3].Material = d

                                            txtJson.text = JSON.stringify(Util.structJSON)

                                        })
                                    }
                                }

                            }

                        }
                    }

                    //-- SubMaterial --//
                    Button{
                        text: "SubMaterial"
                        onClicked: {

                            console.log("/n/n/n/lennnn = " + Util.structJSON.length)

                            for(var i=0; i<Util.structJSON.length; i++){

                                console.log("len["+i+"] = " + Util.structJSON[i].Category.length)

                                for(var j=0; j<Util.structJSON[i].Category.length; j++){

                                    console.log("send request = " + i + "->" + j)

                                    for(var k=0; k<Util.structJSON[i].Category[j].MaterialCategory.length; k++){

                                        for(var h=0; h<Util.structJSON[i].Category[j].MaterialCategory[k].Material.length; h++){


                                            var selID = Util.structJSON[i].Category[j].MaterialCategory[k].Material[h].id

                                            itmGet.getSubMaterial(selID, i, j, k, h, function(d, indx, indx2, indx3, indx4){

                                                Util.structJSON[indx].Category[indx2].MaterialCategory[indx3].Material[indx4].SubMaterial = d

                                                txtJson.text = JSON.stringify(Util.structJSON)

                                            })
                                        }
                                    }
                                }

                            }

                        }
                    }

                }

                function getCategory(){

                    var endpoint = "api/kootwall/Category"

                    Service.get_all( endpoint, function(resp, http) {
                        console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                        //-- check ERROR --//
                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                        {
                            console.log("error detected; " + resp.error)
                            return

                        }

                        console.log("\n\n\n\n")
                        console.log("len = " + resp.length)
                        console.log("resp = " + resp[0].title)

                        //                                var data = []

                        for(var i=0; i<resp.length; i++) {
                            //                                    listmodel.append(resp[i])
                            var t = {}
                            t.title = resp[i].title
                            t.id = resp[i].id
                            Util.structJSON.push(t)
                        }

                        txtJson.text = JSON.stringify(Util.structJSON)

                    })
                }

                function getBaseCategory(catID, indx, cb){

                    //                            var endpoint = "api/kootwall/BaseCategory"
                    var endpoint = "api/kootwall/BaseCategory?c=" + catID

                    Service.get_all( endpoint, function(resp, http) {
                        console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                        //-- check ERROR --//
                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                        {
                            console.log("error detected; " + resp.error)
                            return

                        }

                        var data = []

                        for(var i=0; i<resp.length; i++) {
                            //                                    listmodel.append(resp[i])
                            var t = {}
                            t.title = resp[i].title
                            t.id = resp[i].id
                            data.push(t)
                        }

                        cb(data, indx)
                    })
                }

                function getMaterialCategory(catID, indx, indx2, cb){

                    var endpoint = "api/kootwall/MaterialCategory?c=" + catID

                    Service.get_all( endpoint, function(resp, http) {
                        console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                        //-- check ERROR --//
                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                        {
                            console.log("error detected; " + resp.error)
                            return

                        }

                        var data = []

                        for(var i=0; i<resp.length; i++) {
                            //                                    listmodel.append(resp[i])
                            var t = {}
                            t.title = resp[i].title
                            t.id = resp[i].id
                            data.push(t)
                        }

                        cb(data, indx, indx2)
                    })
                }

                function getMaterial(catID, indx, indx2, indx3, cb){

                    var endpoint = "api/kootwall/Material?c=" + catID

                    Service.get_all( endpoint, function(resp, http) {
                        console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                        //-- check ERROR --//
                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                        {
                            console.log("error detected; " + resp.error)
                            return

                        }

                        var data = []

                        for(var i=0; i<resp.length; i++) {
                            //                                    listmodel.append(resp[i])
                            var t = {}
                            t.title = resp[i].title
                            t.id = resp[i].id
                            data.push(t)
                        }

                        cb(data, indx, indx2, indx3)
                    })
                }

                function getSubMaterial(catID, indx, indx2, indx3, indx4, cb){

                    var endpoint = "api/kootwall/SubMaterial?c=" + catID

                    Service.get_all( endpoint, function(resp, http) {
                        console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                        //-- check ERROR --//
                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                        {
                            console.log("error detected; " + resp.error)
                            return

                        }

                        var data = []

                        for(var i=0; i<resp.length; i++) {
                            //                                    listmodel.append(resp[i])
                            var t = {}
                            t.title = resp[i].title
                            t.id = resp[i].id
                            data.push(t)
                        }

                        cb(data, indx, indx2, indx3, indx4)
                    })
                }

            }

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true

                color: "#e0e0e0"
                clip: true

                TextArea{
                    id: txtJson
                    anchors.centerIn: parent
                    text: "TextArea\n...\n...\n...\n...\n...\n...\n"
                    selectByMouse: true
                    wrapMode: Text.Wrap
                    width: parent.width

                }

            }
        }

    }


    //-- import JSON to DB Window --//
    property var jsonImportWin: ApplicationWindow{
        id: jsonImportWin

        visible: false //true
        width: 900 //Math.max(lblAlarm.implicitWidth*1.3 , 300)
        height: 650
        title: "import JSON to DB"

        ColumnLayout{
            anchors.fill: parent

            Item {
                id: itmAddCat
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                RowLayout{
                    anchors.fill: parent

                    Button{
                        text:"import JSON"

                        onClicked: {

                            itmAddCat.request("file:///C:/Users/DA/Desktop/kootwall/json/ابنیه.json", function(resp, http) {
                                //                                console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                //-- check ERROR --//
                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                {
                                    console.log("error detected; " + resp.error)
                                    return

                                }


                                console.log("\n\n\n lennnn = " + resp.length)

                                //-- loop for Category --//
                                for(var i=0; i<resp.length; i++){

                                    console.log("["+i+"] " + resp[i].title + ", len["+i+"] = " + resp[i].Category.length)

                                    txtImportJson.text += "\n["+i+"] "
                                            + resp[i].title + ", len = " + resp[i].Category.length

                                    //-- add category item --//
                                    itmAddCat.add_categoryItm(resp[i].title, i, function(indx, itmID){

                                        console.log("\n\nadd_categoryItm -> index " + indx + " added: " + resp[indx].title + " id: " + itmID + "\n\n")

                                        btnNext.permit = false
                                        while(!btnNext.permit);

                                        //-- loop for BaseCategory --//
                                        for(var j=0; j<resp[indx].Category.length; j++){

                                            txtImportJson.text += "\n\t["+j+"] "
                                                    + resp[indx].Category[j].title + ", len = " + resp[indx].Category[j].MaterialCategory.length


                                            //-- add base category item --//
                                            itmAddCat.add_baseCategoryItm(resp[indx].Category[j].title, itmID, j, function(indxBC, itmBcID){

                                                console.log("\n\tadd_baseCategoryItm -> index " + indxBC
                                                            + " added: " + resp[indx].Category[indxBC].title
                                                            + " id: " + itmBcID
                                                            + ", parentCat = " + itmID + "\n")


                                                //-- loop for MaterialCategory --//
                                                for(var k=0; k<resp[indx].Category[indxBC].MaterialCategory.length; k++){

                                                    txtImportJson.text += "\n\t\t["+k+"] "
                                                            + "["+ indx + "," + indxBC +"]"
                                                            + resp[indx].Category[indxBC].MaterialCategory[k].title
                                                            + ", len = " + resp[indx].Category[indxBC].MaterialCategory[k].Material.length

                                                    //-- add categoryMaterial item --//
                                                    itmAddCat.add_categoryMaterialItm(resp[indx].Category[indxBC].MaterialCategory[k].title
                                                                                      , itmBcID, k, function(indxCM, itmCmID){

                                                                                          console.log("\n\t categoryMateria index " + indxBC
                                                                                                      + " added: " + resp[indx].Category[indxBC].MaterialCategory[indxCM].title
                                                                                                      + " id: " + itmCmID
                                                                                                      + ", parentCat = " + itmBcID + "\n")

                                                                                          //-- loop for material item --//
                                                                                          for(var h=0; h<resp[indx].Category[indxBC].MaterialCategory[indxCM].Material.length; h++){

                                                                                              txtImportJson.text += "\n\t\t\t["+h+"] "
                                                                                                      + resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[h].title
                                                                                                      + ", len = " + resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[h].SubMaterial.length

                                                                                              //-- add Material item --//
                                                                                              itmAddCat.add_MaterialItm(resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[h].title
                                                                                                                                , itmCmID, h, function(indxM, itmMID){

                                                                                                                                    console.log("\n\t Materia index " + indxM
                                                                                                                                                + " added: " + resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[indxM].title
                                                                                                                                                + " id: " + itmMID
                                                                                                                                                + ", parentCat = " + itmCmID + "\n")



                                                                                                                                    //-- loop for sub material item --//
                                                                                                                                    for(var m=0; m<resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[indxM].SubMaterial.length; m++){

                                                                                                                                        txtImportJson.text += "\n\t\t\t\t["+m+"] "
                                                                                                                                                + resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[indxM].SubMaterial[m].title


                                                                                                                                        //-- add Material item --//
                                                                                                                                        itmAddCat.add_SubMaterialItm(resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[indxM].SubMaterial[m].title
                                                                                                                                                                          , itmMID, m, function(indxSM, itmSmID){

                                                                                                                                                                              console.log("\n\t SubMateria index " + indxSM
                                                                                                                                                                                          + " added: " + resp[indx].Category[indxBC].MaterialCategory[indxCM].Material[indxM].SubMaterial[indxSM].title
                                                                                                                                                                                          + " id: " + itmSmID
                                                                                                                                                                                          + ", parentCat = " + itmMID + "\n")

                                                                                                                                                                          })
                                                                                                                                    }
                                                                                                                                })

                                                                                          }
                                                                                      })


                                                }
                                            })
                                        }

                                    })


                                }


                            })
                        }
                    }
                }

                function request(address, cb) {
                    //                    log('request: ' + verb + ' ' + BASE + (endpoint?'/' + endpoint:''))
                    var xhr = new XMLHttpRequest();
                    xhr.onreadystatechange = function() {
                        console.log('xhr: on ready state change: ' + xhr.readyState + " == " + xhr.HEADERS_RECEIVED)

                        var headerType = ""

                        //-- check to recived header --//
                        if(xhr.readyState == xhr.HEADERS_RECEIVED) {

                            console.log(xhr.status + "-" + xhr.statusText + ", " + xhr.readyState + "," + xhr.getResponseHeader("Content-Type"))
                            headerType = xhr.getResponseHeader("Content-Type") // application/json
                        }


                        //-- check to recived content --//
                        if(xhr.readyState === XMLHttpRequest.DONE) {
                            if(cb) {

                                //-- check server connection --//
                                if(xhr.status == 0){

                                    var obj = JSON.parse('{ "error":"server not conected"}');
                                    cb(obj, xhr)
                                    return
                                }

                                //-- check sdelete operation --//
                                if(xhr.statusText == "No Content"){

                                    //-- operation is successfull --//
                                    if(xhr.status == 204){

                                        var obj = JSON.parse('{ "del":"successfull delete operation"}');
                                        cb(obj, xhr)
                                        return
                                    }
                                    //-- operation is not successfull --//
                                    else{

                                        var obj = JSON.parse('{ "del":"delete operation was not successfull"}');
                                        cb(obj, xhr)
                                        return

                                    }

                                }


                                console.log(xhr.status + "-" + xhr.statusText + ", " + xhr.responseText.toString() + ",")

                                if (typeof xhr.responseText.toString() === "undefined") {
                                    cb("{'title':'not JSON data'}", xhr);
                                }
                                else{
                                    var res = JSON.parse(xhr.responseText.toString())
                                    cb(res, xhr);
                                }

                            }
                        }
                    }
                    xhr.open("GET", address);
                    xhr.send()
                }

                function add_categoryItm(itm, index, cb){

                    //-- verify token --//
                    checkToken(function(resp){

                        //-- token expire, un logined user --//
                        if(!resp){
                            console.log("access denied")
                            return
                        }


                        //-- send data --//
                        var data = {
                            "title": itm,
//                            "pic": ""
                        }

                        var endpoint = "api/kootwall/Category"

                        Service.create_item(_token_access, endpoint, data, function(resp, http) {

                            console.log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                            //-- check ERROR --//
                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                            {
                                console.log("error detected; " + resp.error)
                                return

                            }

                            //-- Authentication --//
                            if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                            {
                                //-- invalid Authentication --//
                                if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                    console.log("Authentication credentials were not provided")
                                    return
                                }

                                //-- handle token expire --//
                                if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                    console.log("Given token not valid for any token type")
                                    return
                                }

                                //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                message.text = resp.detail
                                return
                            }

                            var txt = resp.title
                            if(txt.indexOf("This title has already been used") > -1){

                                console.log("This title has already been used")
                                //                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                return
                            }

                            console.log("Item created")

                            cb(index, resp.id)


                        })
                    })

                }

                function add_baseCategoryItm(itm, parentCat, index, cb){

                    //-- verify token --//
                    checkToken(function(resp){

                        //-- token expire, un logined user --//
                        if(!resp){
                            console.log("access denied")
                            return
                        }


                        //-- send data --//
                        //-- send data --//
                        var data = {
                            "title"     : itm,
                            "category"  : parentCat,
//                            "pic"       : ""
                        }

                        var endpoint = "api/kootwall/BaseCategory"

                        Service.create_item(_token_access, endpoint, data, function(resp, http) {

                            console.log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                            //-- check ERROR --//
                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                            {
                                console.log("error detected; " + resp.error)
                                return

                            }

                            //-- Authentication --//
                            if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                            {
                                //-- invalid Authentication --//
                                if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                    console.log("Authentication credentials were not provided")
                                    return
                                }

                                //-- handle token expire --//
                                if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                    console.log("Given token not valid for any token type")
                                    return
                                }

                                //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                message.text = resp.detail
                                return
                            }

                            var txt = resp.title
                            if(txt.indexOf("This title has already been used") > -1){

                                console.log("This title has already been used")
                                //                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                return
                            }

                            console.log("Item created")

                            cb(index, resp.id)


                        })
                    })

                }

                function add_categoryMaterialItm(itm, parentCat, index, cb){

                    //-- verify token --//
                    checkToken(function(resp){

                        //-- token expire, un logined user --//
                        if(!resp){
                            console.log("access denied")
                            return
                        }


                        //-- send data --//
                        //-- send data --//
                        var data = {
                            "title"         : itm,
                            "baseCategory"  : parentCat,
//                            "pic"           : ""
                        }

                        var endpoint = "api/kootwall/MaterialCategory"

                        Service.create_item(_token_access, endpoint, data, function(resp, http) {

                            console.log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                            //-- check ERROR --//
                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                            {
                                console.log("error detected; " + resp.error)
                                return

                            }

                            //-- Authentication --//
                            if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                            {
                                //-- invalid Authentication --//
                                if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                    console.log("Authentication credentials were not provided")
                                    return
                                }

                                //-- handle token expire --//
                                if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                    console.log("Given token not valid for any token type")
                                    return
                                }

                                //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                message.text = resp.detail
                                return
                            }

                            var txt = resp.title
                            if(txt.indexOf("This title has already been used") > -1){

                                console.log("This title has already been used")
                                //                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                return
                            }

                            console.log("Item created")

                            cb(index, resp.id)


                        })
                    })

                }

                function add_MaterialItm(itm, parentCat, index, cb){

                    //-- verify token --//
                    checkToken(function(resp){

                        //-- token expire, un logined user --//
                        if(!resp){
                            console.log("access denied")
                            return
                        }


                        //-- send data --//
                        //-- send data --//
                        var data = {
                            "title"         : itm,
                            "materialCategory"  : parentCat,
//                            "pic"           : ""
                        }

                        var endpoint = "api/kootwall/Material"

                        Service.create_item(_token_access, endpoint, data, function(resp, http) {

                            console.log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                            //-- check ERROR --//
                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                            {
                                console.log("error detected; " + resp.error)
                                return

                            }

                            //-- Authentication --//
                            if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                            {
                                //-- invalid Authentication --//
                                if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                    console.log("Authentication credentials were not provided")
                                    return
                                }

                                //-- handle token expire --//
                                if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                    console.log("Given token not valid for any token type")
                                    return
                                }

                                //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                message.text = resp.detail
                                return
                            }

                            var txt = resp.title
                            if(txt.indexOf("This title has already been used") > -1){

                                console.log("This title has already been used")
                                //                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                return
                            }

                            console.log("Item created")

                            cb(index, resp.id)


                        })
                    })

                }

                function add_SubMaterialItm(itm, parentCat, index, cb){

                    //-- verify token --//
                    checkToken(function(resp){

                        //-- token expire, un logined user --//
                        if(!resp){
                            console.log("access denied")
                            return
                        }


                        //-- send data --//
                        //-- send data --//
                        var data = {
                            "title"     : itm,
                            "material"  : parentCat,
//                            "pic"       : ""
                        }

                        var endpoint = "api/kootwall/SubMaterial"

                        Service.create_item(_token_access, endpoint, data, function(resp, http) {

                            console.log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                            //-- check ERROR --//
                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                            {
                                console.log("error detected; " + resp.error)
                                return

                            }

                            //-- Authentication --//
                            if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                            {
                                //-- invalid Authentication --//
                                if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                    console.log("Authentication credentials were not provided")
                                    return
                                }

                                //-- handle token expire --//
                                if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                    console.log("Given token not valid for any token type")
                                    return
                                }

                                //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                message.text = resp.detail
                                return
                            }

                            var txt = resp.title
                            if(txt.indexOf("This title has already been used") > -1){

                                console.log("This title has already been used")
                                //                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                return
                            }

                            console.log("Item created")

                            cb(index, resp.id)


                        })
                    })

                }

                //-- delay --//
                function delay(delayTime, cb) {
                    var timer = new Timer();
                    timer.interval = delayTime;
                    timer.repeat = false;
                    timer.triggered.connect(cb);
                    timer.start();
                }

            }

            Rectangle{
                Layout.fillHeight: true
                Layout.fillWidth: true

                color: "#e0e0e0"
                clip: true

                Flickable{
                    anchors.fill: parent

                    contentHeight: txtImportJson.implicitHeight

                    ScrollBar.vertical: ScrollBar{}

                    TextArea{
                        id: txtImportJson
                        anchors.centerIn: parent
                        text: ""
                        selectByMouse: true
                        wrapMode: Text.Wrap
                        width: parent.width

                    }
                }

            }


        }
    }


    //-- auth --//
    property var authWin:  ApplicationWindow{
        id: authWin
        visible: true//false//
        width: 700 //Math.max(lblAlarm.implicitWidth*1.3 , 300)
        height: 500 //username.implicitHeight * 5
        title: "صفحه ورود"
        objectName: "Auth"
        flags: Qt.Dialog //SplashScreen //Dialog

        Material.theme: Material.Light

        onVisibleChanged: {

            if(visible){

                //-- hide pass textbox --//
                lblShowPass.isPassShow = false

                if(!cbx_remeber.checked) return

                username.text   = setting.username
                password.text   = setting.password
            }
        }

        font {
            family: font_irans.name
            pixelSize: Qt.application.font.pixelSize
        }

        Component.onCompleted: {

//            log("start up init")

            cbx_remeber.checked = setting.isRemember

            if(!cbx_remeber.checked) return

            _token_access       = setting.token_access
            _token_refresh      = setting.token_refresh
            _userName           = setting.username
            _password           = setting.password
            username.text       = setting.username
            password.text       = setting.password

//            log(setting.username + "," + setting.password)
        }

        //-- back --//
        Rectangle{
            anchors.fill: parent
            anchors.margins: 5
            radius: 5


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
        }

        //-- body --//
        RowLayout{
            anchors.fill: parent
            anchors.margins: 10

            //- logo section --//
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Rectangle{
                    id: itmLogo
                    width: parent.width * 0.6
                    height: width
                    radius: width/2
                    color: "white" //"#5a5a5a"
                    anchors.centerIn: parent
                    border{width: 1; color: "#5a5a5a"}

                    Behavior on scale{NumberAnimation{duration: 200}}

                    Image {
                        id: imgLogo
                        source: "qrc:/Content/Images/logo.png"
                        sourceSize: Qt.size(parent.width*0.6, parent.height*0.6)
                        anchors.centerIn: parent
                    }

                }
            }

            //-- login section --//
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout{
                    anchors.fill: parent
                    anchors.margins: 20

                    Item{Layout.fillHeight: true} //-- filler --//

                    Label{
                        text: "ورود کاربران"
                        font.family: font_irans.name
                        font.pixelSize: Qt.application.font.pixelSize * 2
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item{Layout.preferredHeight: itmUser.height} //-- spacer --//

                    //-- username item --//
                    Rectangle{
                        id: itmUser
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: height/2
                        color: "#e6e6e6"

                        RowLayout{
                            anchors.fill: parent
                            anchors.leftMargin: height/2
                            anchors.rightMargin: height/2

                            //-- username --//
                            TextInput{
                                id: username
                                Layout.fillWidth: true
                                selectByMouse: true
                                color : "#666666"

                                //-- placeholder --//
                                Label{
                                    text: parent.text == "" ? "نام کاربری" : ""
                                    anchors.right: parent.right
                                    color : "#666666"
                                }

                                Keys.onPressed: {
                                    if (event.key == Qt.Key_Tab) {
                                        password.focus = true
                                        event.accepted = true;
                                    }
                                }
                            }
                            Label{
                                id: lblUser
                                Layout.alignment: Qt.AlignRight

                                font.family: font_material.name
                                font.pixelSize: Qt.application.font.pixelSize * (username.focus ? 1.5 : 1.3)
                                text: MdiFont.Icon.account
                                color: username.focus ? "#03A9F4" : "#666666"
                                Behavior on font.pixelSize {NumberAnimation{duration: 100}}
                            }
                        }
                    }

                    //-- password item --//
                    Rectangle{
                        id: itmPass
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: height/2
                        color: "#e6e6e6"

                        RowLayout{
                            anchors.fill: parent
                            anchors.leftMargin: height/2
                            anchors.rightMargin: height/2

                            //-- show pass --//
                            Label{
                                id: lblShowPass

                                property bool isPassShow: false

                                Layout.alignment: Qt.AlignRight

                                font.family: font_material.name
                                font.pixelSize: Qt.application.font.pixelSize * (password.focus ? 1.5 : 1.3)
                                text: isPassShow ? MdiFont.Icon.eye_off_outline : MdiFont.Icon.eye_outline
                                color: password.focus ? "#03A9F4" : "#666666"
                                Behavior on font.pixelSize {NumberAnimation{duration: 100}}
                                MouseArea{
                                    anchors.fill: parent
                                    onClicked: {
                                        lblShowPass.isPassShow  = !lblShowPass.isPassShow
                                    }
                                }
                            }

                            //-- password --//
                            TextInput{
                                id: password
                                Layout.fillWidth: true
                                selectByMouse: true
                                color : "#666666"
                                echoMode: lblShowPass.isPassShow ? TextInput.Normal : TextInput.Password

                                //-- placeholder --//
                                Label{
                                    text: parent.text == "" ? "رمز عبور" : ""
                                    anchors.right: parent.right
                                    color : "#666666"
                                }

                                onAccepted: {
                                    btnLogin.clicked()
                                }

                                Keys.onPressed: {
                                    if (event.key == Qt.Key_Tab) {
                                        btnLogin.focus = true
                                        event.accepted = true;
                                    }
                                }
                            }
                            Label{
                                id: lblPass
                                Layout.alignment: Qt.AlignRight

                                font.family: font_material.name
                                font.pixelSize: Qt.application.font.pixelSize * (password.focus ? 1.5 : 1.3)
                                text: MdiFont.Icon.lock
                                color: password.focus ? "#03A9F4" : "#666666"
                                Behavior on font.pixelSize {NumberAnimation{duration: 100}}
                            }
                        }
                    }

                    Item{Layout.preferredHeight: itmUser.height*0.6} //-- spacer --//

                    //-- login button --//
                    Button{
                        id: btnLogin
                        text: "ورود"
                        Layout.fillWidth: true
                        Material.foreground : "white"
                        Material.background: Util.color_kootwall_light //Material.BlueGrey

                        onClicked: {

                            //-- check user empty --//
                            if(username.text === ""){

                                alarmLogin.msg = "لطفا نام کاربری را وارد کنید"
                                return
                            }

                            //-- check pass empty --//
                            if(password.text === ""){

                                alarmLogin.msg = "لطفا رمز عبور را وارد کنید"
                                return
                            }

                            var data = {
                                'username': username.text,
                                'password': password.text
                            }

                            var endpoint = "api/token/"

                            Service.logIn( endpoint, data, function(resp, http) {

                                /*authWin*/console.log( "state of " + authWin.objectName + " = " + http.status + " " + http.statusText + ', /n handle log in resp: ' + JSON.stringify(resp))

                                //-- check ERROR --//
                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                {
                                    authWin.log("error detected; " + resp.error)
                                    //                                    alarmLogin.msg = resp.error
                                    alarmLogin.msg = "مشکلی در ارتباط با اینترنت وجود دارد"
                                    return
                                }

                                //-- 400-Bad Request --//
                                //-- No active account found with the given credentials --//
                                if(http.status === 400 || resp.hasOwnProperty('non_field_errors')){

                                    authWin.log("error detected; " + resp.non_field_errors.toString())
                                    //                                    alarmLogin.msg = resp.non_field_errors.toString()
                                    alarmLogin.msg = "کاربری با مشخصات وارد شده یافت نشد"
                                    return
                                }

                                _token_access = resp.access
                                _token_refresh = resp.refresh

                                //-- save user and pass --//
                                _userName = username.text
                                _password = password.text

                                isLogined = true

                                //-- save in Setting --//
                                setting.username        = _userName
                                setting.password        = _password
                                setting.token_access    = _token_access
                                setting.token_refresh   = _token_refresh

//                                /*authWin*/console.log("save: " + setting.username + "," + setting.password)

                                authWin.visible = false
                                mainWin.visible = true

                                authWin.checkPermissionLevel(_userName)

                            })

                        }

                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: lblRemember.implicitHeight

                        RowLayout{
                            anchors.fill: parent

                            Item{Layout.fillWidth: true}

                            Label{
                                id: lblRemember
                                text: "مرا به خاطر بسپار"
                            }

                            CheckBox{
                                id: cbx_remeber
                                text: ""
                                Material.accent : Util.color_kootwall_light //Material.BlueGrey

                                onCheckStateChanged: {
                                    setting.isRemember = checked
                                }
                            }
                        }
                    }

                    Item{Layout.fillHeight: true} //-- filler --//
                }
            }
        }


        //-- check user permission level --//
        function checkPermissionLevel(user){


            //-- verify token --//
            checkToken(function(resp){

                //-- search based on title --//
                var endpoint = "api/kootwall/Users"

                Service.get_all_users(_token_access, endpoint, function(resp, http) {
                    log( "state in auth = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

                    //-- check ERROR --//
                    if(resp.hasOwnProperty('error')) // chack exist error in resp
                    {
                        log("error detected; " + resp.error)
                        message.text = resp.error
                        triggerMsg(resp.error, "RED")
                        return

                    }

                    for(var i=0; i<resp.length; i++) {

                        if(resp[i].username === user){

                            isAdminPermission = resp[i].is_superuser
//                            log("user["+ i +"] = " + resp[i].username + ", is_superuser = " + isAdminPermission)
                            break
                        }
                    }

//                    message.text = "searched data recived"
//                    triggerMsg("جست و جو انجام شد", "LOG")
                })
            })
        }


        //-- Alarm --//
        Rectangle{
            id: alarmLogin

            property string msg: ""

            width: parent.width
            height: lblAlarm.implicitHeight * 2.5
            anchors.bottom: parent.bottom

            color: msg === "" ? "transparent" : "#E91E63"

            Label{
                id: lblAlarm
                text: alarmLogin.msg
                anchors.centerIn: parent
                color: "white"
                font.family: font_irans.name
            }
        }

        //-- log system --//
        function log(str){

            //-- check global permission --//
            if(!logPermission) return

            //-- check local permission --//
            if(!_localLogPermission) return

            //-- print logs --//
            console.log(objectName + "; " + str)
        }

    }


    //-- referesh token --//
    function refereshToken(cb){

        var data = {
            'refresh': _token_refresh
        }

        var endpoint = "api/token/refresh/"

        Service.verify( endpoint, data, function(resp, http) {

            mainWin.log( "state = " + http.status + " " + http.statusText + ', /n handle refersh resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                mainWin.log("error detected; " + resp.error)
                alarmLogin.msg = resp.error
                if(cb) cb(false)
                return false
            }

            //-- 200- OK --//
            if(http.status === 200 || resp.hasOwnProperty('access')){

                //                log("Unauthorized; " + resp.detail.toString())
                //                alarmLogin.msg = resp.detail.toString()

                //-- refresh token --//
                _token_access = resp.access
                mainWin.log("new access toke refreshed")
                if(cb) cb(true)
                return true
            }

            mainWin.log("new access token was not refreshed")
            if(cb) cb(false)
            return false

        })

    }


    //-- verify token (referesh/access) --//
    function verifyToken(token, cb){


        var data = {
            'token': token //_token_refresh //_token_access
        }

        var endpoint = "api/token/verify/"

        Service.verify( endpoint, data, function(resp, http) {

            mainWin.log( "state = " + http.status + " " + http.statusText + ', /n handle verify_token resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                mainWin.log("error detected; " + resp.error)
                alarmLogin.msg = resp.error
                if(cb) cb(false)
                return
            }

            //-- 401- Unauthorized --//
            if(http.status === 401 || resp.hasOwnProperty('detail')){

                //                log("Unauthorized; " + resp.detail.toString())
                //                alarmLogin.msg = resp.detail.toString()
                if(cb) cb(false)
                return

                //-- refresh token --//
            }

            if(cb) cb(true)
            return

        })

    }


    //-- check token --//
    function checkToken(cb){

        //-- check user logIn status --//
        /*if(!isLogined){
            mainWin.log("LogIned Please")
            if(cb) cb(false)
            return false
        }*/

        //-- verify access token --//
        mainWin.log("check access token ...")
        verifyToken(_token_access, function(resp) {
            mainWin.log("resp _token_access = " + resp)

            //-- access token is valid --//
            if(resp){
                if(cb) cb(true)
                return true
            }
            else{

                //-- verify referesh token --//
                mainWin.log("check referesh token ...")
                verifyToken(_token_refresh, function(resp) {
                    mainWin.log("resp _token_referesh = " + resp)

                    if(!resp){

                        mainWin.log("refresh token expired; user loged out")
                        isLogined = false
                        if(cb) cb(false)
                        return false
                    }
                    else{

                        mainWin.log("try to refresh access token")
                        //-- referesh token --//
                        refereshToken(function(resp) {

                            mainWin.log("resp referesh access Token status: = " + resp)

                            //-- access token refereshed --//
                            if(resp){
                                if(cb) cb(true)
                                return true
                            }
                            else{

                                mainWin.log("new access token was not refreshed")
                                if(cb) cb(false)

                                return false
                            }

                        })
                    }
                })
            }
        })


    }

    //-- activity ENUM --//
    property string _ACTIVITY_CREATE: "CREATE"
    property string _ACTIVITY_UPDATE: "UPDATE"
    property string _ACTIVITY_DELETE: "DELETE"

    //-- log user activity --//
    function logActivity(action, section, description, callBack){

        itm_activityLogger.addActivityLog(action, section, description, "False", _userName, function(){

            callBack()
        })
    }


}
