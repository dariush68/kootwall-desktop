import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import "../font/Icon.js" as MdiFont
import "./REST/apiservice.js" as Service
import "./Utils/Util.js" as Util
import "./Utils"

Rectangle{
    id: root

    //-- visible window --//
    signal openWin()
    onOpenWin:{

        //-- clear all text fields --//
        clearTextFields()
        _isUpdate           = false
        if(id_subSubMaterial == -1) _isNewBranchAdded   = false //-- in subsubmaterial cat user can not add new branch --//
        rdBtn_currentTitle.checked = true

        log("_isNewBranchAdded = " + _isNewBranchAdded)

        //-- check this product is Exist in ParentPC DB --//
        fetchCompanyProduct(txf_categories_title.text)
//        fetchCompanyProductNew(txf_categories_title.text)

        //-- load all companies to company ListView --//
        loadCompaniesFromDB()
    }

    //-- signal for load companies list from DB --//
    signal loadCompaniesFromDB()
    onLoadCompaniesFromDB: {

        //-- load companies list from DataBase --//
        btnCategoriesGet.clicked()
    }

    //-- signal to open acompanyManager window --//
    signal openCompanyWin()


    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)
    onTriggerMsg: {
        msgHandler.show(msg, alarmType)
    }

    //-- update category list that new item added to it --//
    signal updateCatList(string catName, variant itm)

    property string pageTitle:      "افزودن محصول ها"  //-- modul header title --//
    property bool   isLogEnabled:   true        //-- global log permission --//
    property bool   isShowStatus:   false       //-- show/hide status bar --//
    property int    companyCurrentPage   :   1      //-- current page of ListView elements --//
    property int    companyPageSize      :  50      //-- current page of ListView elements --//
    property int    totalCompany         :   0      //-- total element of company elements --//


    //-- selected navigations titles --//
    property string title_category           : ""
    property string title_baseCategory       : ""
    property string title_materialCategory   : ""
    property string title_material           : ""
    property string title_subMaterial        : ""
    property string title_subSubMaterial     : ""

    //-- ids of selected cats. --//
    property int id_category           : -1
    property int id_baseCategory       : -1
    property int id_materialCategory   : -1
    property int id_material           : -1
    property int id_subMaterial        : -1
    property int id_subSubMaterial     : -1


    property bool    _localLogPermission:   true   //-- local log permission --//
    property variant _resp_product
    property bool    _isUpdate          :   false
    property bool    _isNewBranchAdded  :   false
    property int     _selectedParentCPid: -1

    //-- show permission for database items --//
    property bool isIdShow          : false
    property bool isTitleShow       : true
    property bool isPic1Show        : false
    property bool isDateShow        : false
    property bool isCatNavigateShow : true
    property bool isBranchIdShow    : false
    property bool isCompanyShow     : true
    property bool isDescriptionShow : true
    property int  visibleItmCount   : 4     //-- hold visible item count for size porpose (in edit win height) --//

    //-- selected company info --//
    property string  _companyTitle: ""
    property int     _companyID   : -1

    objectName: "AddProduct"
    color: "#FFFFFF"
    radius: 3
    border{width: 1; color: "#999e9e9e"}


    Component.onCompleted: {

        //-- load companies list from DataBase --//
//        btnCategoriesGet.clicked()
    }

    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name
        font.pixelSize: Qt.application.font.pixelSize

        RowLayout{
            anchors.fill: parent

            //-- company product --//
            Pane{
                Layout.fillHeight: true
                Layout.preferredWidth: 200
                background: Rectangle{color: "#00FFFFFF"}

                Material.theme: Material.Dark

                Rectangle{
                    //                    anchors.fill: parent
                    width: 200 - 10
                    height: parent.height
                    anchors.centerIn: parent
                    anchors.margins: 10
                    radius: companyBack.radius
                    color: Util.color_kootwall_dark


                    //-- body --//
                    ColumnLayout{
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 1

                        //-- table header --//
                        Button{
                            Layout.fillWidth: true
                            text: "لیست شرکت ها"
                            flat: true
                            down: true


                            //-- load BusyIndicator --//
                            BusyIndicator {
                                id: busyLoader

                                height: parent.height - 8
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 4
                                running: false
                            }
                        }

                        //-- pagination --//
                        Button{
                            Layout.fillWidth: true
                            text: ""
                            flat: true
                            down: true

                            //-- pagination --//
                            Pagination{
                                id: itm_pagination
                                height: parent.height
                                width: parent.width
                                anchors.right: parent.right
                                anchors.margins: 2
                                isCenter: true
                                txtColor: "white"

                                currentPage: root.companyCurrentPage
                                totalItem: root.totalCompany
                                pageSize: root.companyPageSize

                                onFirstPage: {

                                    companyCurrentPage = 1

                                    if(txf_categories_search.searchedTxt === ""){
                                        btnCategoriesGet.clicked()
                                    }
                                    else{
                                        txf_categories_search.searchCompanies()
                                    }
                                }

                                onNextPage: {

                                    if(companyCurrentPage >= 0){
                                        companyCurrentPage++

                                        if(txf_categories_search.searchedTxt === ""){
                                            btnCategoriesGet.clicked()
                                        }
                                        else{
                                            txf_categories_search.searchCompanies()
                                        }
                                    }
                                }

                                onPreviousPage: {

                                    if(companyCurrentPage > 1){
                                        companyCurrentPage--

                                        if(txf_categories_search.searchedTxt === ""){
                                            btnCategoriesGet.clicked()
                                        }
                                        else{
                                            txf_categories_search.searchCompanies()
                                        }
                                    }
                                }

                                onLastPage: {

                                    companyCurrentPage = totalCompany/companyPageSize + 1

                                    if(txf_categories_search.searchedTxt === ""){
                                        btnCategoriesGet.clicked()
                                    }
                                    else{
                                        txf_categories_search.searchCompanies()
                                    }
                                }

                                //-- int customPage --//
                                onCustomPage: {

                                    if(customPage >= 1 && customPage <= (totalCompany/companyPageSize)){
                                        companyCurrentPage = customPage

                                        if(txf_categories_search.searchedTxt === ""){
                                            btnCategoriesGet.clicked()
                                        }
                                        else{
                                            txf_categories_search.searchCompanies()
                                        }
                                    }
                                    else{
                                        if(customPage < 1) firstPage()
                                        else lastPage()
                                    }
                                }
                            }
                        }

                        //-- search field --//
                        SearchField{
                            id: txf_categories_search

                            Layout.row: 0
                            Layout.column: 1
                            Layout.columnSpan: 2
                            Layout.fillWidth: true

                            onEnteredText: {

                                companyCurrentPage = 1 //-- load first page --//
                                txf_categories_search.searchCompanies()
                            }

                            function searchCompanies(){

                                //-- search based on title --//

//                                var endpoint = "api/kootwall/Company?q=" + text
                                var endpoint = "api/kootwall/Company?page=" + companyCurrentPage + "&page_size=" + companyPageSize + "&q=" + txf_categories_search.searchedTxt

                                //-- start busy animation --//
                                busyLoader.running = true

                                Service.get_all( endpoint, function(resp, http) {
                                    log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

                                    //-- stop busy animation --//
                                    busyLoader.running = false

                                    //-- check ERROR --//
                                    if(resp.hasOwnProperty('error')) // chack exist error in resp
                                    {
                                        log("error detected; " + resp.error)
                                        message.text = resp.error
                                        triggerMsg(resp.error, "RED")
                                        return

                                    }

                                    var result = resp.results
                                    totalCompany = resp.count

                                    listmodel.clear()

                                    for(var i=0; i<result.length; i++) {
                                        listmodel.append(result[i])
                                        listmodel.setProperty(i, 'isSelected', false)
                                    }

                                    //-- fixed bug; unable select last on item of search resualt --//
                                    lv.currentIndex = -1

                                    message.text = "searched data recived"
                                    triggerMsg("جست و جو انجام شد", "LOG")
                                })
                            }
                        }

                        //-- list view header --//
                        ItemDelegate{
                            visible: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: lblSize.implicitHeight * 2

                            font.pixelSize: Qt.application.font.pixelSize

                            //- back color --//
                            Rectangle{anchors.fill: parent; color: "#05000000"; border{width: 1; color: "#22000000"}}

                            RowLayout{
                                anchors.fill: parent

                                Item { Layout.fillWidth: true } //-- filler --//

                                //-- title --//
                                Item{
                                    visible: isTitleShow
                                    Layout.fillWidth: true
                                    Label{
                                        id: lbl_title
                                        text: "شرکت"
                                        anchors.centerIn: parent
                                    }
                                }

                                //-- categoryID --//
                                Item{
                                    visible: isIdShow
                                    Layout.preferredWidth: Math.max(lbl_ccategoryID.implicitWidth * 2, 50)
                                    Label{
                                        id: lbl_ccategoryID
                                        text: "categoryID"
                                        anchors.centerIn: parent
                                    }
                                }

                                Item { Layout.fillWidth: true } //-- filler --//
                            }
                        }

                        //-- ListView --//
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            ListModel{
                                id: listmodel
                            }

                            ListView{
                                id: lv

                                anchors.fill: parent

                                ScrollBar.vertical: ScrollBar {
                                    id: control
                                    size: 0.1
                                    position: 0.2
                                    active: true
                                    orientation: Qt.Vertical
                                    policy: listmodel.count>(lv.height/40) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                    contentItem: Rectangle {
                                        implicitWidth: 6
                                        implicitHeight: 100
                                        radius: width / 2
                                        color: control.pressed ? "#aa32aaba" : "#5532aaba"
                                    }

                                }

                                model: listmodel

                                delegate: ItemDelegate{
                                    width: parent.width
                                    height: 40

                                    font.pixelSize: Qt.application.font.pixelSize

//                                    Rectangle { anchors.fill: parent; opacity: (isSelected ? 0.5 : 0.0); color: Util.color_kootwall_light; radius: 2 }

                                    RowLayout{
                                        anchors.fill: parent
                                        anchors.margins: 3

                                        //-- title --//
                                        TxtItmOfListView{
                                            visible: isTitleShow
                                            Layout.fillWidth: true
                                            txt: model.title
                                        }

                                        //-- categoryID --//
                                        Item{
                                            visible: isIdShow
                                            Layout.preferredWidth: Math.max(lbl_ccategoryID.implicitWidth * 2, 50)
                                            Label{
                                                text: model.id
                                                anchors.centerIn: parent
                                                width: Math.min(parent.width, implicitWidth)
                                                elide: Text.ElideMiddle
                                            }
                                        }

                                    }

                                    //-- spliter --//
                                    Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                    onClicked: {
                                        lv.currentIndex = index

                                        var isFind = false
                                        for(var i=0; i< listmodel_companies.count && !isFind; i++){

                                            if(listmodel.get(index).id === listmodel_companies.get(i).id) isFind = true
                                        }

                                        //-- selected company is exist in list --//
                                        if(isFind) return

                                        listmodel_companies.append({
                                                                       "id": listmodel.get(index).id,
                                                                       "productId": -1,
                                                                       "title": listmodel.get(index).title,
                                                                       "isSelected": true
                                                                   })

//                                        if(listmodel.get(index).isSelected){
                                            
//                                            listmodel.setProperty(index, 'isSelected', false)
//                                        }
//                                        else{
                                            
//                                            listmodel.setProperty(index, 'isSelected', true)
//                                        }
                                        

                                        //                                        _companyID      = listmodel.get(lv.currentIndex).id
                                        //                                        _companyTitle   = listmodel.get(lv.currentIndex).title
                                    }


                                }


                                onCurrentIndexChanged:{

                                    log("lv.currentIndex = " + lv.currentIndex)

                                    //-- controll count of listview --//
                                    if(lv.count < 1) return

                                    //-- controll currentIndex of listview --//
                                    if(lv.currentIndex < 0) return

                                    _companyID      = listmodel.get(lv.currentIndex).id
                                    _companyTitle   = listmodel.get(lv.currentIndex).title
                                }

                                //                                highlight: Rectangle { color: Util.color_kootwall_light; radius: 2 }
                                //                                focus: true

                                // some fun with transitions :-)
                                add: Transition {
                                    // applied when entry is added
                                    NumberAnimation {
                                        properties: "x"; from: -lv.width;
                                        duration: 250;
                                    }
                                }
                                remove: Transition {
                                    // applied when entry is removed
                                    NumberAnimation {
                                        properties: "x"; to: lv.width;
                                        duration: 250;
                                    }
                                }
                                displaced: Transition {
                                    // applied when entry is moved
                                    // (e.g because another element was removed)
                                    SequentialAnimation {
                                        // wait until remove has finished
                                        PauseAnimation { duration: 250 }
                                        NumberAnimation { properties: "y"; duration: 75
                                        }
                                    }
                                }
                            }

                        }

                        //-- get (used for auto load) --//
                        MButton{
                            visible: false
                            id: btnCategoriesGet
                            Layout.fillWidth: true
                            icons: MdiFont.Icon.arrow_down_bold_circle_outline //"Get"
                            tooltip: "بارگذاری"

                            onClicked: {

                                var endpoint = "api/kootwall/Company?page=" + companyCurrentPage+ "&page_size=" + companyPageSize

                                //-- start busy animation --//
                                busyLoader.running = true

                                Service.get_all( endpoint, function(resp, http) {
                                    log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                    //-- stop busy animation --//
                                    busyLoader.running = false

                                    //-- check ERROR --//
                                    if(resp.hasOwnProperty('error')) // chack exist error in resp
                                    {
                                        log("error detected; " + resp.error)
                                        message.text = resp.error
                                        triggerMsg(resp.error, "RED")
                                        return

                                    }

                                    var result = resp.results
                                    totalCompany = resp.count

                                    listmodel.clear()

                                    for(var i=0; i<result.length; i++) {
                                        listmodel.append(result[i])
//                                        listmodel.setProperty(i, 'isSelected', false)
                                    }

                                    message.text = "all data recived"
                                    triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                })
                            }

                        }

                        Button{
                            id: btnAddCompany

                            text: "افزودن شرکت"
                            Layout.fillWidth: true
                            font.pixelSize: Qt.application.font.pixelSize * 1.0
                            Material.background: Util.color_kootwall_light //Material.Teal
                            Material.foreground: "#0f0f0f"
                            //                            highlighted: true

                            onClicked: {
                                openCompanyWin()
                            }
                        }

                    }
                }
            }

            //-- product fields --//
            Item{
                id: itmProd
                Layout.fillHeight: true
                Layout.fillWidth: true
                z: -10

                //-- company item background (unused) --//
                Rectangle{
                    id: companyBack
                    visible: false
                    height: txf_categories_companyFrame.height
                    width: itmProd.width + height*2
                    radius: 10//height/2
                    y: colEdit.y + paneTxts.y + flickEdit.y + txf_categories_companyFrame.y
                    x: -height*2 -colEdit.spacing

                    color: Util.color_kootwall_dark //Material.BlueGrey) //"#33FF0000"
                }

                //-- body --//
                ColumnLayout{
                    id: colEdit
                    anchors.fill: parent
                    anchors.margins: 10

                    //-- TextFields --//
                    Item{
                        id: paneTxts

                        Layout.fillWidth:  true
                        Layout.fillHeight: true

                        //-- size porpose --//
                        Label{
                            id: lblSize
                            font.pixelSize: Qt.application.font.pixelSize
                            text: "test"
                            visible: false
                        }

                        Flickable{
                            id: flickEdit

                            contentHeight:
                                txf_categories_categoryID.implicitHeight * (visibleItmCount+0.2)
                                + itm_catNavigate.implicitHeight //nav_category.implicitHeight * 9
                                + txf_categories_description.implicitHeight
                                + txf_categories_companyFrame.height + 50

                            ScrollBar.vertical: ScrollBar { } //-- vertical Scroll --//

                            anchors.fill: parent
                            clip: true

                            GridLayout{
                                anchors.fill: parent

                                rows: 9
                                columns: 2
                                clip: true

                                //-- ID --//
                                Label{
                                    id: lbl_catId
                                    visible: isIdShow
                                    Layout.row: 1
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "شماره:"
                                }
                                TextField{
                                    id: txf_categories_categoryID
                                    visible: isIdShow
                                    Layout.row: 1
                                    Layout.column: 1
                                    Layout.fillWidth: true

                                    placeholderText: "شماره شناسایی"
                                    enabled: false
                                }

                                //-- title --//
                                Label{
                                    visible: isTitleShow
                                    Layout.row: 3
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "نام محصول:"
                                }

                                //-- title body --//
                                Frame{
                                    visible: isTitleShow
                                    Layout.row: 3
                                    Layout.column: 1
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: txf_categories_title.implicitHeight * 2 + 50 + glRbtn.columnSpacing*2

                                    ButtonGroup {
                                        buttons: [rdBtn_currentTitle, rdBtn_newTitle]
                                    }

                                    GridLayout{
                                        id: glRbtn
                                        anchors.fill: parent
                                        anchors.margins: 10

                                        rows: 3
                                        columns: 4

                                        //-- current branch --//
                                        RadioButton{
                                            id: rdBtn_currentTitle
                                            text: ""
                                            Layout.row: 1
                                            Layout.column: 3
                                            checked: true
                                        }
                                        Label{
                                            Layout.row: 1
                                            Layout.column: 2
                                            Layout.alignment: Qt.AlignRight

                                            text: "عنوان:"
                                            enabled: rdBtn_currentTitle.checked
                                        }
                                        TextField{
                                            id: txf_categories_title
                                            Layout.row: 1
                                            Layout.column: 1
                                            Layout.fillWidth: true
                                            enabled: rdBtn_currentTitle.checked
                                            readOnly: true
                                            text:{
                                                if(title_subSubMaterial != "")      return title_subSubMaterial
                                                if(title_subMaterial != "")         return title_subMaterial
                                                if(title_material != "")            return title_material
                                                if(title_materialCategory != "")    return title_materialCategory
                                                if(title_baseCategory != "")        return title_baseCategory
                                                if(title_category != "")            return title_category
                                                return ""
                                            }

                                            placeholderText: "عنوان محصول"
                                            selectByMouse: true
                                            //                                            onAccepted: btnCategoriesAdd.clicked()
                                        }


                                        //-- new branch --//
                                        RadioButton{
                                            id: rdBtn_newTitle
                                            text: ""
                                            Layout.row: 2
                                            Layout.column: 3
                                        }
                                        Label{
                                            Layout.row: 2
                                            Layout.column: 2
                                            Layout.alignment: Qt.AlignRight

                                            text: "افزودن محصول جدید:"
                                            enabled: rdBtn_newTitle.checked
                                        }
                                        TextField{
                                            id: txf_categories_titleNew
                                            Layout.row: 2
                                            Layout.column: 1
                                            Layout.fillWidth: true
                                            enabled: rdBtn_newTitle.checked

                                            placeholderText: "عنوان محصول جدید"
                                            selectByMouse: true
                                            //                                            onAccepted: btnCategoriesAdd.clicked()
                                        }
                                        MButton{
                                            id: btnAddCat
                                            Layout.row: 2
                                            Layout.column: 0
                                            icons: MdiFont.Icon.plus
                                            tooltip: "افزودن شاخه جدید"
                                            enabled: rdBtn_newTitle.checked && !_isNewBranchAdded
                                            onClicked: {

                                                //-- check new product --//
                                                if(rdBtn_newTitle.checked){

                                                    addNewCatBranch(txf_categories_titleNew.text, "")

                                                }
                                            }
                                        }

                                        //-- filler --//
                                        Item{
                                            Layout.row: 3
                                            Layout.column: 1
                                            Layout.fillHeight: true
                                        }

                                    }
                                }

                                //-- pic --//
                                Label{
                                    visible: isPic1Show
                                    Layout.row: 4
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "تصویر:"
                                }
                                TextField{
                                    id: txf_categories_pic
                                    visible: isPic1Show
                                    Layout.row: 4
                                    Layout.column: 1
                                    Layout.fillWidth: true

                                    placeholderText: "تصویر"
                                    selectByMouse: true
                                }

                                //-- date --//
                                Label{
                                    visible: isDateShow
                                    Layout.row: 5
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "تاریخ:"
                                }
                                TextField{
                                    id: txf_categories_date
                                    visible: isDateShow
                                    Layout.row: 5
                                    Layout.column: 1
                                    Layout.fillWidth: true

                                    placeholderText: "تاریخ"
                                    selectByMouse: true
                                }

                                //-- Branch --//
                                Label{
                                    visible: isCatNavigateShow
                                    Layout.row: 6
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "دسته بندی:"
                                }
                                ItemDelegate {
                                    id: itm_catNavigate
                                    visible: isCatNavigateShow
                                    Layout.row: 6
                                    Layout.column: 1
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: nav_category.implicitHeight * 3
                                    clip: true

                                    Flickable{
                                        anchors.fill: parent

                                        contentWidth: nav_subSubMaterial.implicitWidth
                                                      + nav_subMaterial.implicitWidth
                                                      + nav_material.implicitWidth
                                                      + nav_materialCategory.implicitWidth
                                                      + nav_baseCategory.implicitWidth
                                                      + nav_category.implicitWidth
                                                      + lbl_divider.implicitWidth *4
                                                      + rowItm.spacing*4

                                        ScrollBar.horizontal: ScrollBar { }

                                        RowLayout{
                                            id: rowItm
                                            anchors.fill: parent


                                            //-- SubSubMaterial --//
                                            ItemDelegate{
                                                opacity: nav_subSubMaterial.text === "" ? 0.0 : 1.0
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: nav_subSubMaterial.implicitWidth
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_subSubMaterial
                                                    text: title_subSubMaterial
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                id: lbl_divider
                                                opacity: nav_subSubMaterial.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_left //arrow_down_thick
                                                Layout.alignment: Qt.AlignVCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }


                                            //-- SubMaterial --//
                                            ItemDelegate{
                                                opacity: nav_subMaterial.text === "" ? 0.0 : 1.0
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: nav_subMaterial.implicitWidth
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_subMaterial
                                                    text: title_subMaterial
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_subMaterial.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_left //arrow_down_thick
                                                Layout.alignment: Qt.AlignVCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- Material --//
                                            ItemDelegate{
                                                opacity: nav_material.text === "" ? 0.0 : 1.0
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: nav_material.implicitWidth
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_material
                                                    text: title_material
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_material.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_left //arrow_down_thick
                                                Layout.alignment: Qt.AlignVCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- MaterialCategory --//
                                            ItemDelegate{
                                                opacity: nav_materialCategory.text === "" ? 0.0 : 1.0
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: nav_materialCategory.implicitWidth
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_materialCategory
                                                    text: title_materialCategory
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_materialCategory.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_left //arrow_down_thick
                                                Layout.alignment: Qt.AlignVCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- BaseCategory --//
                                            ItemDelegate{
                                                opacity: nav_baseCategory.text === "" ? 0.0 : 1.0
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: nav_baseCategory.implicitWidth
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_baseCategory
                                                    text: title_baseCategory
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_baseCategory.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_left //arrow_down_thick
                                                Layout.alignment: Qt.AlignVCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- category --//
                                            ItemDelegate{
                                                opacity: nav_category.text === "" ? 0.0 : 1.0
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: nav_category.implicitWidth
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_category
                                                    text: title_category
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- filler --//
                                            Item{Layout.fillWidth: true}

                                        }

                                    }
                                }

                                //-- company --//
                                Label{
                                    visible: isCompanyShow && false
                                    Layout.row: 7
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "شرکت:"
                                    //                                    Material.theme: Material.Dark
                                }
                                TextField{
                                    id: txf_categories_company
                                    visible: isCompanyShow && false
                                    Layout.row: 7
                                    Layout.column: 1
                                    Layout.fillWidth: true
                                    readOnly: true

                                    placeholderText: "شرکت"
                                    text: _companyTitle
                                    selectByMouse: true
                                    //                                    Material.theme: Material.Dark


                                }

                                //-- description --//
                                Label{
                                    visible: isDescriptionShow
                                    Layout.row: 8
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "شرح کالا:"
                                }
//                                TextField{
                                TextArea{
                                    id: txf_categories_description
                                    visible: isDescriptionShow
                                    Layout.row: 8
                                    Layout.column: 1
                                    Layout.fillWidth: true

                                    placeholderText: "شرح کالا"
                                    selectByMouse: true
                                    wrapMode: Text.Wrap
                                }

                                //-- Branch ID --//
                                Label{
                                    visible: isBranchIdShow
                                    Layout.row: 9
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "شاخه:"
                                }
                                ItemDelegate {
                                    id: itm_catNavigate_id
                                    visible: isBranchIdShow
                                    Layout.row: 9
                                    Layout.column: 1
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: lbl_navID.implicitHeight * 3
                                    clip: true


                                    Label{
                                        id: lbl_navID
                                        text: ((id_subSubMaterial != -1)     ? (id_subSubMaterial     + " < ") : "")
                                              + ((id_subMaterial != -1)      ? (id_subMaterial        + " < ") : "")
                                              + ((id_material != -1)         ? (id_material           + " < ") : "")
                                              + ((id_materialCategory != -1) ? (id_materialCategory   + " < ") : "")
                                              + ((id_baseCategory != -1)     ? (id_baseCategory       + " < " ): "")
                                              + ((id_category != -1)         ? (id_category)                   : "")
                                        anchors.centerIn: parent
                                    }

                                }


                                //-- compan listy --//
                                Label{
                                    visible: isCompanyShow
                                    Layout.row: 10
                                    Layout.column: 2
                                    Layout.alignment: Qt.AlignRight

                                    text: "شرکت ها:"
                                    Material.theme: Material.Dark
                                }
                                Rectangle{
                                    id: txf_categories_companyFrame
                                    Layout.row: 10
                                    Layout.column: 1
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.max(lbl_navID.implicitHeight * 4 , flowItem.implicitHeight + 5)
//                                    Layout.fillHeight: true
                                    color: Util.color_kootwall_dark
                                    radius: 10

                                    ListModel{
                                        id: listmodel_companies
                                    }

                                    Flow{
                                        id: flowItem
                                        anchors.fill: parent
                                        anchors.margins: 2

                                        spacing: 2
                                        layoutDirection: Qt.RightToLeft

                                        Repeater{

                                            model: listmodel_companies


                                            ItemDelegate{

                                                width: lblCmp.implicitWidth + lblPicIcon.implicitWidth + 20
                                                height: lblCmp.implicitHeight+10
                                                y: 5

                                                //-- border --//
                                                Rectangle{
                                                    anchors.fill: parent
                                                    color: "#00FFFFFF"
                                                    radius: 5
                                                    border{width: 1; color: "#55FFFFFF"}
                                                }

                                                RowLayout{
                                                    anchors.fill: parent
                                                    anchors.margins: 3

                                                    //-- title --//
                                                    Label{
                                                        id: lblCmp
                                                        text: model.title
                                                        color: "white"

                                                        MouseArea{
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            //                                                onEntered: lblDel.visible = true
                                                            //                                                onExited:  lblDel.visible = false
                                                            onClicked: {

                                                                listmodel_companies.setProperty(index, 'isSelected', !listmodel_companies.get(index).isSelected)
                                                                mouse.accepted = false
                                                            }
                                                        }
                                                    }

                                                    //-- gallery icon --//
                                                    Label{
                                                        id: lblPicIcon
                                                        text: MdiFont.Icon.image_filter
                                                        font.family: font_material.name
                                                        color: "white"

                                                        MouseArea{
                                                            anchors.fill: parent
                                                            anchors.margins: -5
                                                            hoverEnabled: true
                                                            onEntered: lblPicIcon.color = "#00BCD4"
                                                            onExited:  lblPicIcon.color = "#FFFFFF"
                                                            onClicked: {
//                                                                console.log("product id " + model.productId)

                                                                uploadImage.openWin(model.productId, txf_categories_title.text, model.title)
                                                            }
                                                        }
                                                    }

                                                }

                                                //-- dlete lable --//
                                                Label{
                                                    id: lblDel
                                                    visible: !model.isSelected
                                                    font.family: font_material.name
                                                    font.pixelSize: Qt.application.font.pixelSize * 2
                                                    color: Material.color(Material.Red)
                                                    anchors.centerIn: parent
                                                    text: MdiFont.Icon.window_close
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                    //-- spliter --//
                    Rectangle{Layout.fillWidth:  true; Layout.preferredHeight: 1; color: "#e5e5e5";}

                    //-- buttons --//
                    Item{
                        Layout.fillWidth:  true
                        Layout.preferredHeight: btnCategoriesAdd.implicitHeight * 1

                        RowLayout{
                            anchors.fill: parent


                            //-- add single item (unused) --//
                            MButton{
                                visible: false
                                id: btnCategoriesAdd
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.plus //"Add"
                                tooltip: "افزودن"

                                onClicked: {

                                    //-- check title field --//
                                    if(txf_categories_title.text === ""){
                                        log("item is empty")
                                        message.text = "item is empty"
                                        triggerMsg("لطفا عنوان عنصر جدید را وارد کنید", "RED")
                                        return
                                    }

                                    //-- verify token --//
                                    checkToken(function(resp){

                                        //-- token expire, un logined user --//
                                        if(!resp){
                                            message.text = "access denied"
                                            triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                            return
                                        }

                                        //-- send data --//
                                        var data = {
                                            "title"             : txf_categories_title.text         ,
//                                            "pic1"              : txf_categories_pic.text           ,
                                            "description"       : txf_categories_description.text   ,
                                            "company"           : _companyID                        ,
                                            "branchTitles"      : (
                                                                      (title_category         === "" ? "" : (title_category           +">"))
                                                                      + (title_baseCategory     === "" ? "" : (title_baseCategory       +">"))
                                                                      + (title_materialCategory === "" ? "" : (title_materialCategory   +">"))
                                                                      + (title_material         === "" ? "" : (title_material           +">"))
                                                                      + (title_subMaterial      === "" ? "" : (title_subMaterial        +">"))
                                                                      + (title_subSubMaterial   === "" ? "" : (title_subSubMaterial     ))
                                                                      )
                                        }

                                        //-- added existed branch --//
                                        if(id_category > -1)            data.category           = id_category
                                        if(id_baseCategory > -1)        data.baseCategory       = id_baseCategory
                                        if(id_materialCategory > -1)    data.materialCategory   = id_materialCategory
                                        if(id_material > -1)            data.material           = id_material
                                        if(id_subMaterial > -1)         data.subMaterial        = id_subMaterial
                                        if(id_subSubMaterial > -1)      data.subSubMaterial     = id_subSubMaterial

                                        log("aded date = "
                                            + "\n title: "             + data.title
                                            + "\n description: "       + data.description
                                            + "\n category: "          + data.category
                                            + "\n baseCategory: "      + data.baseCategory
                                            + "\n materialCategory: "  + data.materialCategory
                                            + "\n material: "          + data.material
                                            + "\n subMaterial: "       + data.subMaterial
                                            + "\n subSubMaterial: "    + data.subSubMaterial
                                            + "\n company: "           + data.company
                                            + "\n branchTitles: "      + data.branchTitles
                                            )


                                        var endpoint = "api/kootwall/CompanyProduct"

                                        Service.create_item(_token_access, endpoint, data, function(resp, http) {

                                            log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                                            //-- check ERROR --//
                                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                                            {
                                                log("error detected; " + resp.error)
                                                message.text = resp.error
                                                triggerMsg(resp.error, "RED")
                                                return

                                            }

                                            //-- Authentication --//
                                            if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                                            {
                                                //-- invalid Authentication --//
                                                if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                    message.text = "Authentication credentials were not provided"
                                                    triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                    return
                                                }

                                                //-- handle token expire --//
                                                if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                                    message.text = "Given token not valid for any token type"
                                                    triggerMsg("لطفا با نام کاربرید و رمز عبور وارد شوید", "RED")
                                                    return
                                                }

                                                //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                message.text = resp.detail
                                                triggerMsg(resp.detail, "RED")
                                                return
                                            }

                                            if(resp.hasOwnProperty('non_field_errors')) // chack exist non_field_errors in resp
                                            {
                                                var txt = resp.non_field_errors
                                                if(txt.indexOf("This title has already been used") > -1){

                                                    message.text = "This title has already been used"
                                                    triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                    return
                                                }
                                            }

                                            message.text = "Item created"
                                            triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")
                                            triggerMsg("عنوان جدید ایجاد شد", "BLUE")

                                            //-- clear text fields --//
                                            clearTextFields()


                                        })
                                    })



                                }
                            }

                            //-- add group --//
                            MButton{
                                id: btnCategoriesAdd2
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.plus //"Add"
                                tooltip: "افزودن گروهی"

                                onClicked: {

                                    //-- check title field --//
                                    if(txf_categories_title.text === ""){
                                        log("item is empty")
                                        message.text = "item is empty"
                                        triggerMsg("لطفا عنوان عنصر جدید را وارد کنید", "RED")
                                        return
                                    }

                                    //-- verify token --//
                                    checkToken(function(resp){

                                        //-- token expire, un logined user --//
                                        if(!resp){
                                            message.text = "access denied"
                                            triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                            return
                                        }

                                        var d1 = []

                                        //-- add product of selected company --//
                                        for(var i=0; i< listmodel_companies.count; i++){

                                            //-- ignore unselected companies --//
                                            if(!listmodel_companies.get(i).isSelected) continue

                                            //-- send data --//
                                            var data4 = {
//                                                "title"             : txf_categories_title.text          ,
//                                                "pic1"              : txf_categories_pic.text           ,
                                                "description"       : txf_categories_description.text  ,
//                                                "branchTitles"      : (
//                                                                          (title_category         === "" ? "" : (title_category           +">"))
//                                                                          + (title_baseCategory     === "" ? "" : (title_baseCategory       +">"))
//                                                                          + (title_materialCategory === "" ? "" : (title_materialCategory   +">"))
//                                                                          + (title_material         === "" ? "" : (title_material           +">"))
//                                                                          + (title_subMaterial      === "" ? "" : (title_subMaterial        +">"))
//                                                                          + (title_subSubMaterial   === "" ? "" : (title_subSubMaterial     ))
//                                                                          ),
                                                "quantity"          : 1,
                                                "company"           : listmodel_companies.get(i).id
                                            }

                                            if(id_category > -1)            data4.category           = id_category
                                            if(id_baseCategory > -1)        data4.baseCategory       = id_baseCategory
                                            if(id_materialCategory > -1)    data4.materialCategory   = id_materialCategory
                                            if(id_material > -1)            data4.material           = id_material
                                            if(id_subMaterial > -1)         data4.subMaterial        = id_subMaterial
                                            if(id_subSubMaterial > -1)      data4.subSubMaterial     = id_subSubMaterial


                                            d1.push(data4)
                                        }

                                        //-- add product of existed company --//

                                        log("txf_categories_title.text = " + txf_categories_title.text )
                                        log("txf_categories_pic.text         ="+txf_categories_pic.text)
                                        log("txf_categories_description.text ="+txf_categories_description.text)

                                        var d4 = {

                                            //                                            "table_number"      : 4,
                                            "ordered_meals"     : d1,
//                                            "title"             : (rdBtn_currentTitle.checked ? txf_categories_title.text : txf_categories_titleNew.text) ,
//                                            "pic1"              : txf_categories_pic.text           ,
                                            "description"       : txf_categories_description.text  ,
//                                            "branchTitles"      : (
//                                                                      (title_category         === "" ? "" : (title_category           +">"))
//                                                                      + (title_baseCategory     === "" ? "" : (title_baseCategory       +">"))
//                                                                      + (title_materialCategory === "" ? "" : (title_materialCategory   +">"))
//                                                                      + (title_material         === "" ? "" : (title_material           +">"))
//                                                                      + (title_subMaterial      === "" ? "" : (title_subMaterial        +">"))
//                                                                      + (title_subSubMaterial   === "" ? "" : (title_subSubMaterial     ))
//                                                                      ),
                                        }

                                        if(id_category > -1)            d4.category           = id_category
                                        if(id_baseCategory > -1)        d4.baseCategory       = id_baseCategory
                                        if(id_materialCategory > -1)    d4.materialCategory   = id_materialCategory
                                        if(id_material > -1)            d4.material           = id_material
                                        if(id_subMaterial > -1)         d4.subMaterial        = id_subMaterial
                                        if(id_subSubMaterial > -1)      d4.subSubMaterial     = id_subSubMaterial

                                        log("jd4 = " + JSON.stringify(d4))
                                        //                                        return

                                        var endpoint = ""


                                        log("_selectedParentCPid = " + _selectedParentCPid)
                                        log("state, _isUpdate: " + _isUpdate + ", rdBtn_newTitle.checked: " + rdBtn_newTitle.checked
                                            + ", rdBtn_currentTitle.checked = " + rdBtn_currentTitle.checked)

                                        var requestType = "null"

                                        if((rdBtn_currentTitle.checked && _isUpdate)){ //-- update selected product --//
                                            requestType = "UPDATE"
                                            log("status = " + requestType + ", update selected product")
                                        }
                                        else if(rdBtn_currentTitle.checked && !_isUpdate){ //-- craete new product --//
                                            requestType = "CREATE"
                                            log("status = " + requestType + ", craete new product")
                                        }
                                        else if(rdBtn_newTitle.checked && !_isNewBranchAdded){ //-- error, user should click on new branch button --//

                                            triggerMsg("ابتدا شاخه جدید ایجاد کنید", "RED")
                                            return
                                        }
                                        else if(rdBtn_newTitle.checked && _isNewBranchAdded && !_isUpdate){ //-- create new branch and then add new product --//
                                            requestType = "CREATE"
                                            log("status = " + requestType + ", create new branch and then add new product")
                                        }
                                        else if(rdBtn_newTitle.checked && _isNewBranchAdded && _isUpdate){ //-- create new branch and then update selected product --//
                                            requestType = "UPDATE"
                                            log("status = " + requestType + ", create new branch and then update selected product")
                                        }


                                        //-- operate requests --//

                                        if(requestType === "null"){
                                            return
                                        }
                                        else if(requestType === "UPDATE"){
                                            endpoint = "api/kootwall/orders2-update-mixin/"+ _selectedParentCPid

                                            log("endpoint = " + endpoint)

                                            Service.update_item(_token_access, endpoint, d4, function(resp, http) {

                                                log( "state = " + http.status + " " + http.statusText + ', /n handle update resp: ' + JSON.stringify(resp))

                                                //-- check ERROR --//
                                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                {
                                                    log("error detected; " + resp.error)
                                                    message.text = resp.error
                                                    triggerMsg(resp.error, "RED")
                                                    return

                                                }

                                                //-- Authentication --//
                                                if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                                                {
                                                    if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                        message.text = "Authentication credentials were not provided"
                                                        triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                        return
                                                    }

                                                    //-- handle token expire --//
                                                    //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                    message.text = resp.detail
                                                    triggerMsg(resp.detail, "RED")
                                                    return
                                                }

                                                if(resp.hasOwnProperty('title')) // chack exist detail in resp
                                                {
                                                    var txt = resp.title
                                                    if(txt.indexOf("This title has already been used") > -1){

                                                        message.text = "This title has already been used"
                                                        triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                        return
                                                    }
                                                }

                                                message.text = "Item updated"
                                                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "BLUE")

                                                //-- log activity --//
                                                logActivity(_ACTIVITY_UPDATE, _COMPANYPRODUCT, ("به روز رسانی محصول در مدیریت محصول ها: " + txf_categories_title.text))


                                            })
                                        }
                                        else if(requestType === "CREATE"){
                                            endpoint = "api/kootwall/orders2-create-generic-view/"

                                            log("endpoint = " + endpoint)

                                            Service.create_item(_token_access, endpoint, d4, function(resp, http) {

                                                log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                                                //-- check ERROR --//
                                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                {
                                                    log("error detected; " + resp.error)
                                                    message.text = resp.error
                                                    triggerMsg(resp.error, "RED")
                                                    return

                                                }

                                                //-- Authentication --//
                                                if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                                                {
                                                    //-- invalid Authentication --//
                                                    if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                        message.text = "Authentication credentials were not provided"
                                                        triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                        return
                                                    }

                                                    //-- handle token expire --//
                                                    if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                                        message.text = "Given token not valid for any token type"
                                                        triggerMsg("لطفا با نام کاربری و رمز عبور وارد شوید", "RED")
                                                        return
                                                    }

                                                    //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                    message.text = resp.detail
                                                    triggerMsg(resp.detail, "RED")
                                                    return
                                                }

                                                if(resp.hasOwnProperty('non_field_errors')) // chack exist non_field_errors in resp
                                                {
                                                    var txt = resp.non_field_errors
                                                    if(txt.indexOf("This title has already been used") > -1){

                                                        message.text = "This title has already been used"
                                                        triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                        return
                                                    }
                                                }

                                                message.text = "Item created"
                                                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")
                                                triggerMsg("عنوان جدید ایجاد شد", "BLUE")

                                                //-- log activity --//
                                                logActivity(_ACTIVITY_CREATE, _COMPANYPRODUCT, ("محصولی جدید در مدیریت محصول ها ایجاد شد: " + txf_categories_title.text))

                                                _isUpdate = true
                                                _selectedParentCPid = resp.id

                                                //-- clear text fields --//
                                                clearTextFields()


                                            })
                                        }

                                    })



                                }

                            }



                            //-- add group old --//
                            /*MButton{
                                id: btnCategoriesAdd2
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.plus //"Add"
                                tooltip: "افزودن گروهی"

                                onClicked: {

                                    //-- check title field --//
                                    if(txf_categories_title.text === ""){
                                        log("item is empty")
                                        message.text = "item is empty"
                                        triggerMsg("لطفا عنوان عنصر جدید را وارد کنید", "RED")
                                        return
                                    }

                                    //-- verify token --//
                                    checkToken(function(resp){

                                        //-- token expire, un logined user --//
                                        if(!resp){
                                            message.text = "access denied"
                                            triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                            return
                                        }

                                        var d1 = []

                                        //-- add product of selected company --//
                                        for(var i=0; i< listmodel_companies.count; i++){

                                            //-- ignore unselected companies --//
                                            if(!listmodel_companies.get(i).isSelected) continue

                                            //-- send data --//
                                            var data4 = {
//                                                "title"             : txf_categories_title.text          ,
//                                                "pic1"              : txf_categories_pic.text           ,
                                                "description"       : txf_categories_description.text  ,
//                                                "branchTitles"      : (
//                                                                          (title_category         === "" ? "" : (title_category           +">"))
//                                                                          + (title_baseCategory     === "" ? "" : (title_baseCategory       +">"))
//                                                                          + (title_materialCategory === "" ? "" : (title_materialCategory   +">"))
//                                                                          + (title_material         === "" ? "" : (title_material           +">"))
//                                                                          + (title_subMaterial      === "" ? "" : (title_subMaterial        +">"))
//                                                                          + (title_subSubMaterial   === "" ? "" : (title_subSubMaterial     ))
//                                                                          ),
                                                "quantity"          : 1,
                                                "company"           : listmodel_companies.get(i).id
                                            }

                                            if(id_category > -1)            data4.category           = id_category
                                            if(id_baseCategory > -1)        data4.baseCategory       = id_baseCategory
                                            if(id_materialCategory > -1)    data4.materialCategory   = id_materialCategory
                                            if(id_material > -1)            data4.material           = id_material
                                            if(id_subMaterial > -1)         data4.subMaterial        = id_subMaterial
                                            if(id_subSubMaterial > -1)      data4.subSubMaterial     = id_subSubMaterial


                                            d1.push(data4)
                                        }

                                        //-- add product of existed company --//

                                        log("txf_categories_title.text = " + txf_categories_title.text )
                                        log("txf_categories_pic.text         ="+txf_categories_pic.text)
                                        log("txf_categories_description.text ="+txf_categories_description.text)

                                        var d4 = {

                                            //                                            "table_number"      : 4,
                                            "ordered_meals"     : d1,
//                                            "title"             : (rdBtn_currentTitle.checked ? txf_categories_title.text : txf_categories_titleNew.text) ,
//                                            "pic1"              : txf_categories_pic.text           ,
                                            "description"       : txf_categories_description.text  ,
//                                            "branchTitles"      : (
//                                                                      (title_category         === "" ? "" : (title_category           +">"))
//                                                                      + (title_baseCategory     === "" ? "" : (title_baseCategory       +">"))
//                                                                      + (title_materialCategory === "" ? "" : (title_materialCategory   +">"))
//                                                                      + (title_material         === "" ? "" : (title_material           +">"))
//                                                                      + (title_subMaterial      === "" ? "" : (title_subMaterial        +">"))
//                                                                      + (title_subSubMaterial   === "" ? "" : (title_subSubMaterial     ))
//                                                                      ),
                                        }

                                        if(id_category > -1)            d4.category           = id_category
                                        if(id_baseCategory > -1)        d4.baseCategory       = id_baseCategory
                                        if(id_materialCategory > -1)    d4.materialCategory   = id_materialCategory
                                        if(id_material > -1)            d4.material           = id_material
                                        if(id_subMaterial > -1)         d4.subMaterial        = id_subMaterial
                                        if(id_subSubMaterial > -1)      d4.subSubMaterial     = id_subSubMaterial

                                        log("jd4 = " + JSON.stringify(d4))
                                        //                                        return

                                        var endpoint = ""


                                        log("_selectedParentCPid = " + _selectedParentCPid)
                                        log("state, _isUpdate: " + _isUpdate + ", rdBtn_newTitle.checked: " + rdBtn_newTitle.checked
                                            + ", rdBtn_currentTitle.checked = " + rdBtn_currentTitle.checked)

                                        var requestType = "null"

                                        if((rdBtn_currentTitle.checked && _isUpdate)){ //-- update selected product --//
                                            requestType = "UPDATE"
                                            log("status = " + requestType + ", update selected product")
                                        }
                                        else if(rdBtn_currentTitle.checked && !_isUpdate){ //-- craete new product --//
                                            requestType = "CREATE"
                                            log("status = " + requestType + ", craete new product")
                                        }
                                        else if(rdBtn_newTitle.checked && !_isNewBranchAdded){ //-- error, user should click on new branch button --//

                                            triggerMsg("ابتدا شاخه جدید ایجاد کنید", "RED")
                                            return
                                        }
                                        else if(rdBtn_newTitle.checked && _isNewBranchAdded && !_isUpdate){ //-- create new branch and then add new product --//
                                            requestType = "CREATE"
                                            log("status = " + requestType + ", create new branch and then add new product")
                                        }
                                        else if(rdBtn_newTitle.checked && _isNewBranchAdded && _isUpdate){ //-- create new branch and then update selected product --//
                                            requestType = "UPDATE"
                                            log("status = " + requestType + ", create new branch and then update selected product")
                                        }


                                        //-- operate requests --//

                                        if(requestType === "null"){
                                            return
                                        }
                                        else if(requestType === "UPDATE"){
                                            endpoint = "api/kootwall/orders2-update-mixin/"+ _selectedParentCPid

                                            log("endpoint = " + endpoint)

                                            Service.update_item(_token_access, endpoint, d4, function(resp, http) {

                                                log( "state = " + http.status + " " + http.statusText + ', /n handle update resp: ' + JSON.stringify(resp))

                                                //-- check ERROR --//
                                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                {
                                                    log("error detected; " + resp.error)
                                                    message.text = resp.error
                                                    triggerMsg(resp.error, "RED")
                                                    return

                                                }

                                                //-- Authentication --//
                                                if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                                                {
                                                    if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                        message.text = "Authentication credentials were not provided"
                                                        triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                        return
                                                    }

                                                    //-- handle token expire --//
                                                    //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                    message.text = resp.detail
                                                    triggerMsg(resp.detail, "RED")
                                                    return
                                                }

                                                if(resp.hasOwnProperty('title')) // chack exist detail in resp
                                                {
                                                    var txt = resp.title
                                                    if(txt.indexOf("This title has already been used") > -1){

                                                        message.text = "This title has already been used"
                                                        triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                        return
                                                    }
                                                }

                                                message.text = "Item updated"
                                                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "BLUE")

                                                //-- log activity --//
                                                logActivity(_ACTIVITY_UPDATE, _COMPANYPRODUCT, ("به روز رسانی محصول در مدیریت محصول ها: " + txf_categories_title.text))


                                            })
                                        }
                                        else if(requestType === "CREATE"){
                                            endpoint = "api/kootwall/orders2-create-generic-view/"

                                            log("endpoint = " + endpoint)

                                            Service.create_item(_token_access, endpoint, d4, function(resp, http) {

                                                log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                                                //-- check ERROR --//
                                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                {
                                                    log("error detected; " + resp.error)
                                                    message.text = resp.error
                                                    triggerMsg(resp.error, "RED")
                                                    return

                                                }

                                                //-- Authentication --//
                                                if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                                                {
                                                    //-- invalid Authentication --//
                                                    if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                        message.text = "Authentication credentials were not provided"
                                                        triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                        return
                                                    }

                                                    //-- handle token expire --//
                                                    if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                                                        message.text = "Given token not valid for any token type"
                                                        triggerMsg("لطفا با نام کاربری و رمز عبور وارد شوید", "RED")
                                                        return
                                                    }

                                                    //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                    message.text = resp.detail
                                                    triggerMsg(resp.detail, "RED")
                                                    return
                                                }

                                                if(resp.hasOwnProperty('non_field_errors')) // chack exist non_field_errors in resp
                                                {
                                                    var txt = resp.non_field_errors
                                                    if(txt.indexOf("This title has already been used") > -1){

                                                        message.text = "This title has already been used"
                                                        triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                        return
                                                    }
                                                }

                                                message.text = "Item created"
                                                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")
                                                triggerMsg("عنوان جدید ایجاد شد", "BLUE")

                                                //-- log activity --//
                                                logActivity(_ACTIVITY_CREATE, _COMPANYPRODUCT, ("محصولی جدید در مدیریت محصول ها ایجاد شد: " + txf_categories_title.text))

                                                _isUpdate = true
                                                _selectedParentCPid = resp.id

                                                //-- clear text fields --//
                                                clearTextFields()


                                            })
                                        }

                                    })



                                }

                            }*/


                        }

                    }

                    //-- status bar --//
                    Label{
                        id: message
                        visible:  isShowStatus

                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight * 1.2

                        background: Rectangle{color: "#99000000"}

                        text: "status"
                        color: "#ffffff"

                    }

                }

            }

        }

    }

    //-- product gallery manager --//
    UploadProductImg{
        id: uploadImage
    }

    //-- message handler --//
    MsgPopup{
        id: msgHandler

    }

    //-- fetch Products on Title from DB --//
    function fetchCompanyProductNew(cpTitle){

        log("cpTitle = " + cpTitle)
        //-- validate inpute --//
        if(cpTitle === ""){
            log("invalid cpTitle")
            return
        }


        //-- search based on categoryID --//
        //        var endpoint = "api/kootwall/CompanyProduct?n=" + categoryID
//        var endpoint = "api/kootwall/orders2-list-generic-view"//"?q=" + cpTitle
        var endpoint = "api/kootwall/get-group-product-to-companies"//"?q=" + cpTitle

        if(title_subSubMaterial != "")           endpoint += "?subSubMaterial=" + title_subSubMaterial
        else if(title_subMaterial != "")         endpoint += "?subMaterial=" + title_subMaterial
        else if(title_material != "")            endpoint += "?material=" + title_material
        else if(title_materialCategory != "")    endpoint += "?materialCategory=" + title_materialCategory
        else if(title_baseCategory != "")        endpoint += "?baseCategory=" + title_baseCategory
        else if(title_category != "")            endpoint += "?category=" + title_category

        log("endpoint = " + endpoint)

        Service.get_all( endpoint, function(resp, http) {
            console.log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
                message.text = resp.error
                triggerMsg(resp.error, "RED")
                return

            }

            //-- save json file to global var --//
            _resp_product = resp

            listmodel_companies.clear()

//            log(" resp[0].ordered_meals.length = " + resp[0].ordered_meals.length)
            for(var j=0; j<resp.length; j++) {


                    /*for(var j=0; j< listmodel.count; j++){

                        if(listmodel.get(j).title === resp[0].ordered_meals[i].company.title){

                            listmodel.setProperty(j, "isSelected", true)
                            break
                        }
                    }*/

                    listmodel_companies.append({
                                                   "id": resp[j].company, //resp[j].ordered_meals[i].company.id,
                                                   "productId": resp[j].id, // resp[j].ordered_meals[i].id,
                                                   "title": resp[j].companyTitle, // resp[j].ordered_meals[i].company.title,
                                                   "isSelected": true
                                               })

//                    log("added " + resp[j].ordered_meals[i].company.id + " - " + resp[j].ordered_meals[i].company.title)

            }

            /*for(var i=0; i< listmodel.count; i++){
                log("["+i+"] = " + listmodel.get(i).id + " - " + listmodel.get(i).title)
            }*/

            //-- triger selected item when new models fetched --//
            if(resp.length > 0){

                root.state = "FILL"

                _isUpdate = true
                _selectedParentCPid = resp[0].id

                //-- fill selected TextFields --//
                if(resp[0].description  !== null) txf_categories_description.text = resp[0].description
                if(resp[0].pic1         !== null) txf_categories_pic.text         = resp[0].pic1

                log("--- FILL ----")

            }
            else{

                _isUpdate = false
                _selectedParentCPid = -1
                root.state = "EMPTY"
                log("--- EMPTY ----")

            }

            message.text = "searched data recived"
            triggerMsg("جست و جو انجام شد", "LOG")
        })

    }


    //-- fetch Products on Title from DB --//
    function fetchCompanyProduct(cpTitle){

        log("cpTitle = " + cpTitle)
        //-- validate inpute --//
        if(cpTitle === ""){
            log("invalid cpTitle")
            return
        }


        //-- search based on categoryID --//
        //        var endpoint = "api/kootwall/CompanyProduct?n=" + categoryID
        var endpoint = "api/kootwall/orders2-list-generic-view"//"?q=" + cpTitle

        if(title_subSubMaterial != "")           endpoint += "?subSubMaterial=" + title_subSubMaterial
        else if(title_subMaterial != "")         endpoint += "?subMaterial=" + title_subMaterial
        else if(title_material != "")            endpoint += "?material=" + title_material
        else if(title_materialCategory != "")    endpoint += "?materialCategory=" + title_materialCategory
        else if(title_baseCategory != "")        endpoint += "?baseCategory=" + title_baseCategory
        else if(title_category != "")            endpoint += "?category=" + title_category

        log("endpoint = " + endpoint)

        Service.get_all( endpoint, function(resp, http) {
            console.log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
                message.text = resp.error
                triggerMsg(resp.error, "RED")
                return

            }

            //-- save json file to global var --//
            _resp_product = resp

            listmodel_companies.clear()

            var description = ""

//            log(" resp[0].ordered_meals.length = " + resp[0].ordered_meals.length)
            for(var j=0; j<resp.length; j++) {
                for(var i=0; i<resp[j].ordered_meals.length; i++) {


                    /*for(var j=0; j< listmodel.count; j++){

                        if(listmodel.get(j).title === resp[0].ordered_meals[i].company.title){

                            listmodel.setProperty(j, "isSelected", true)
                            break
                        }
                    }*/

                    var _data_company_id = ""
                    var _data_productId = ""
                    var _data_company_title = ""


                    //-- validate data existance --//
                    if(resp[j].ordered_meals[i].company != null){
                        _data_company_title = resp[j].ordered_meals[i].company.title
                        _data_company_id = resp[j].ordered_meals[i].company.id
                    }
                    if(resp[j].ordered_meals[i].id != null) _data_productId = resp[j].ordered_meals[i].id


                    //-- check data id and appended to models --//
                    if(_data_company_id !== "" && _data_productId !== "")
                    {
                        listmodel_companies.append({
                                                       "id": _data_company_id,
                                                       "productId": _data_productId,
                                                       "title": _data_company_title,
                                                       "isSelected": true
                                                   })

//                        log("added " + resp[j].ordered_meals[i].company.id + " - " + resp[j].ordered_meals[i].company.title)
                    }

                    if(resp[j].description != "") description = resp[j].description
                }
            }

            /*for(var i=0; i< listmodel.count; i++){
                log("["+i+"] = " + listmodel.get(i).id + " - " + listmodel.get(i).title)
            }*/

            //-- triger selected item when new models fetched --//
            if(resp.length > 0){

                root.state = "FILL"

                _isUpdate = true
                _selectedParentCPid = resp[0].id

                //-- fill selected TextFields --//
//                if(resp[0].description  !== null) txf_categories_description.text = resp[0].description
                txf_categories_description.text = description;
                if(resp[0].pic1         !== null) txf_categories_pic.text         = resp[0].pic1

                log("--- FILL ----")

            }
            else{

                _isUpdate = false
                _selectedParentCPid = -1
                root.state = "EMPTY"
                log("--- EMPTY ----")

            }

            message.text = "searched data recived"
            triggerMsg("جست و جو انجام شد", "LOG")
        })

    }

    //-- add new cat --//
    function addNewCatBranch(newTitle, newPic){


        //-- verify token --//
        checkToken(function(resp){

            //-- token expire, un logined user --//
            if(!resp){
                message.text = "access denied"
                triggerMsg("لطفا ابتدا وارد شوید", "RED")
                return
            }

            //-- send data --//
            var data = {
                "title"     : newTitle, //txf_categories_title.text,
//                "pic"       : newPic //txf_categories_pic.text
            }

            var endpoint = ""

            //-- check product branch and fill parent category id --//
            if(id_subMaterial != -1){

                data.subMaterial = id_subMaterial
                endpoint = "api/kootwall/SubSubMaterial"
            }
            else if(id_material != -1){

                data.material = id_material
                endpoint = "api/kootwall/SubMaterial"
            }
            else if(id_materialCategory != -1){

                data.materialCategory = id_materialCategory
                endpoint = "api/kootwall/Material"
            }
            else if(id_baseCategory != -1){

                data.baseCategory = id_baseCategory
                endpoint = "api/kootwall/MaterialCategory"
            }
            else if(id_category != -1){

                data.category = id_category
                endpoint = "api/kootwall/BaseCategory"
            }
            else{

                log("filled deep af branche")
                message.text = "filled deep af branche"
                triggerMsg("به آخرین انشعاب نمی توانید محصولی اضافه کنید", "RED")
                return
            }



            Service.create_item(_token_access, endpoint, data, function(resp, http) {

                log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp: ' + JSON.stringify(resp))

                //-- check ERROR --//
                if(resp.hasOwnProperty('error')) // chack exist error in resp
                {
                    log("error detected; " + resp.error)
                    message.text = resp.error
                    triggerMsg(resp.error, "RED")
                    return

                }

                //-- Authentication --//
                if(resp.hasOwnProperty('detail')) // chack exist detail in resp
                {
                    //-- invalid Authentication --//
                    if(resp.detail.indexOf("Authentication credentials were not provided.") > -1){

                        message.text = "Authentication credentials were not provided"
                        triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                        return
                    }

                    //-- handle token expire --//
                    if(resp.detail.indexOf("Given token not valid for any token type") > -1){

                        message.text = "Given token not valid for any token type"
                        triggerMsg("لطفا با نام کاربرید و رمز عبور وارد شوید", "RED")
                        return
                    }

                    //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                    message.text = resp.detail
                    triggerMsg(resp.detail, "RED")
                    return
                }


                if(resp.hasOwnProperty('non_field_errors')) // chack exist non_field_errors in resp
                {
                    var txt = resp.non_field_errors
                    if(txt.indexOf("This title has already been used") > -1){

                        message.text = "This title has already been used"
                        triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                        return
                    }
                }

                //-- sucesfull operations --//
                _isNewBranchAdded   = true
                _isUpdate           = false

                //-- check product branch and fill parent category id --//
                if(id_subMaterial != -1){

                    id_subSubMaterial       = resp.id
                    title_subSubMaterial    = resp.title
                    updateCatList(_SUBSUBMATERIAL, resp)

                    //-- log activity --//
                    logActivity(_ACTIVITY_CREATE, _SUBSUBMATERIAL, ("عنوانی جدید در بخش 4 ایجاد شد: " + newTitle))
                }
                else if(id_material != -1){

                    id_subMaterial       = resp.id
                    title_subMaterial    = resp.title
                    updateCatList(_SUBMATERIAL, resp)

                    //-- log activity --//
                    logActivity(_ACTIVITY_CREATE, _SUBMATERIAL, ("عنوانی جدید در بخش 3 ایجاد شد: " + newTitle))
                }
                else if(id_materialCategory != -1){

                    id_material       = resp.id
                    title_material    = resp.title
                    updateCatList(_MATERIAL, resp)

                    //-- log activity --//
                    logActivity(_ACTIVITY_CREATE, _MATERIAL, ("عنوانی جدید در بخش 2 ایجاد شد: " + newTitle))
                }
                else if(id_baseCategory != -1){

                    id_materialCategory       = resp.id
                    title_materialCategory    = resp.title
                    updateCatList(_CATEGORYMATERIAL, resp)

                    //-- log activity --//
                    logActivity(_ACTIVITY_CREATE, _CATEGORYMATERIAL, ("عنوانی جدید در فصول اصلی ایجاد شد: " + newTitle))
                }
                else if(id_category != -1){

                    id_baseCategory       = resp.id
                    title_baseCategory    = resp.title
                    updateCatList(_BASECATEGORY, resp)

                    //-- log activity --//
                    logActivity(_ACTIVITY_CREATE, _BASECATEGORY, ("عنوانی جدید درفهرست بها ایجاد شد: " + newTitle))
                }
                else{

                    log("can not find cat. id")
                }

//                listmodel.append(resp)
//                lv_categories.currentIndex = lv_categories.count-1
                message.text = "Item created"
                triggerMsg("عنوان جدید ایجاد شد", "LOG")


            })
        })
    }

    //-- clear text fileds --//
    function clearTextFields(){

        //        if(isTitleShow          && txf_categories_title.enabled)        txf_categories_title.text       = ""
        if(isDescriptionShow    && txf_categories_description.enabled)  txf_categories_description.text = ""
        txf_categories_titleNew.text = ""
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
