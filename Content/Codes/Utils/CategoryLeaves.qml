import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import "./../../font/Icon.js" as MdiFont
import "./../../Codes/REST/apiservice.js" as Service
//import "./Content/Codes"
//import "./Content/Codes/ModelClass"
//import "./Content/Codes/Utils"
import "./../../Codes/Utils/Util.js" as Util

Rectangle {
    id: popupLeavs

    property variant mainPage

    signal show(string searchedText, string catType)
    onShow: {
//                msg = searchedText

        listmodelSearch.clear()
        listmodel_companies.clear()

//        popupLeavs.open()

        popupLeavs.searchCategoryLeaves(searchedText, catType, function() {

            log("search Categor leaves done")
        })

        //-- load all companies to company ListView --//
        loadCompaniesFromDB()
    }

    //-- signal for load companies list from DB --//
    signal loadCompaniesFromDB()
    onLoadCompaniesFromDB: {

        //-- load companies list from DataBase --//
        btnCategoriesGet.clicked()
    }

    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)
    onTriggerMsg: {
        msgHandler.show(msg, alarmType)
    }

//    parent: mainPage

    property bool   isLogEnabled:   true       //-- global log permission --//
    objectName: "Category Leaves"
    property int    companyCurrentPage   :   1      //-- current page of ListView elements --//
    property int    companyPageSize      :  50      //-- current page of ListView elements --//
    property int    totalCompany         :   0      //-- total element of company elements --//

    //-- selected company info --//
    property string  _companyTitle: ""
    property int     _companyID   : -1

//    modal: true
    focus: true
    //        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    width: parent.width/2 //lblMsg.implicitWidth * 1 + 30
    height: parent.height * 0.8 //lblMsg.contentHeight * 3
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    Material.theme: Material.Light  //-- Light, Dark, System

    //-- width size porpos --//
    property real slot: (lv_search.width -20) / 2 //-- (-20) for margins --/
    property int _widthTitle    : slot * 1.5
    property int _widthApprove  : slot * 0.5

    property bool    _localLogPermission:   true   //-- local log permission --//
    property variant _resp_product
    property bool    _isUpdate          :   false
//    property bool    _isNewBranchAdded  :   false
    property int     _selectedParentCPid: -1

    property variant _selectedCompanies: [] //-- the selected companies JSON file --//


    ListModel{
        id: listmodelSearch
    }

    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name
        font.pixelSize: Qt.application.font.pixelSize

        RowLayout{
            anchors.fill: parent
            anchors.margins: 5

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
                    radius: txf_categories_search.height/2
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

                                currentPage: companyCurrentPage
                                totalItem: totalCompany
                                pageSize: companyPageSize

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
//                                        message.text = resp.error
//                                        triggerMsg(resp.error, "RED")
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

//                                    message.text = "searched data recived"
//                                    triggerMsg("جست و جو انجام شد", "LOG")
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
//                                    visible: isTitleShow
                                    Layout.fillWidth: true
                                    Label{
                                        id: lbl_title
                                        text: "شرکت"
                                        anchors.centerIn: parent
                                    }
                                }

                                //-- categoryID --//
                                Item{
//                                    visible: isIdShow
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
//                                            visible: isTitleShow
                                            Layout.fillWidth: true
                                            txt: model.title
                                        }

                                        //-- categoryID --//
                                        Item{
                                            visible: false//isIdShow
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
//                                        message.text = resp.error
//                                        triggerMsg(resp.error, "RED")
                                        return

                                    }

                                    var result = resp.results
                                    totalCompany = resp.count

                                    listmodel.clear()

                                    for(var i=0; i<result.length; i++) {
                                        listmodel.append(result[i])
//                                        listmodel.setProperty(i, 'isSelected', false)
                                    }

//                                    message.text = "all data recived"
//                                    triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
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
//                                openCompanyWin()
                            }
                        }

                    }
                }
            }

            //-- leaves item listview and selected company and start button --//
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout{
                    anchors.fill: parent

                    //-- list view --//
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        ColumnLayout{
                            anchors.fill: parent
                            anchors.bottomMargin: 5

                            //-- size porpose --//
                            Label{
                                id: lblSize
                                font.pixelSize: Qt.application.font.pixelSize
                                text: "test"
                                visible: false
                            }

                            //-- list view header --//
                            ItemDelegate{
                                Layout.fillWidth: true
                                Layout.preferredHeight: lblSize.implicitHeight * 2

                                font.pixelSize: Qt.application.font.pixelSize

                                //- back color --//
                                Rectangle{anchors.fill: parent; color: "#05000000"; border{width: 1; color: "#22000000"}}


                                RowLayout{
                                    anchors.fill: parent
                                    spacing: 0

                                    Item { Layout.fillWidth: true } //-- filler --//

                                    //-- approve --//
                                    Item{
                                        Layout.preferredWidth: Math.max(lbl_approve.implicitWidth * 2, _widthApprove)
                                        Layout.fillHeight: true

                                        RowLayout{
                                            anchors.fill: parent

                                            CheckBox{
                                                id: chbx_allItem
                                                Layout.fillHeight: true
                                                Layout.margins: 3
                                                Material.accent : Util.color_kootwall_light //Material.BlueGrey
                                                checked: true

                                                onCheckedChanged: {


                                                    for(var i=0; i< listmodelSearch.count; i++){

                                                        listmodelSearch.setProperty(i,"isSelected", checked)
                                                    }

                                                    lv_search.isCheckBoxDirty = true
                                                }

                                            }


                                            Label{
                                                id: lbl_approve
                                                text: "انتخاب"
                                                //                                                anchors.centerIn: parent
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                        }

                                    }


                                    //-- title --//
                                    Item{
                                        Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthTitle)
                                        Label{
                                            id: lbl_description
                                            text: "موارد یافت شده"
                                            anchors.centerIn: parent
                                            color: "black"
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

                                ListView{
                                    id: lv_search

                                    property bool isCheckBoxDirty: false

                                    anchors.fill: parent
                                    highlightMoveDuration: (contentHeight*4)/1 //pixels/second

                                    ScrollBar.vertical: ScrollBar {
                                        id: control2
                                        size: 0.1
                                        position: 0.2
                                        active: true
                                        orientation: Qt.Vertical
                                        policy: listmodelSearch.count>(lv_search.height/40) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                        contentItem: Rectangle {
                                            implicitWidth: 6
                                            implicitHeight: 100
                                            radius: width / 2
                                            color: control2.pressed ? "#aa32aaba" : "#5532aaba"
                                        }
                                    }

                                    model: listmodelSearch

                                    section.property: "cat"
                                    section.delegate: Pane {
                                        width: lv_search.width
                                        height: sectionLabel.implicitHeight + 20
                                        Material.theme: Material.Dark
                                        Material.background: Util.color_kootwall_dark


                                        RowLayout{
                                            anchors.fill: parent
                                            spacing: 0

                                            Item { Layout.fillWidth: true } //-- filler --//

                                            //-- approve --//
                                            Item{
                                                Layout.preferredWidth: Math.max(lbl_approveSec.implicitWidth * 2, _widthApprove)
                                                Layout.fillHeight: true

                                                RowLayout{
                                                    anchors.fill: parent
                                                    visible: false

                                                    CheckBox{
                                                        id: chbx_allItemSec
                                                        Layout.fillHeight: true
                                                        Layout.margins: 3
                                                        Material.accent : Util.color_kootwall_light //Material.BlueGrey
                                                        checked: true

                                                        onCheckedChanged: {

                                                            /*

                                                for(var i=0; i< listmodelSearch.count; i++){

                                                    listmodelSearch.setProperty(i,"isSelected", checked)
                                                }

                                                lv_search.isCheckBoxDirty = true*/
                                                        }

                                                    }


                                                    Label{
                                                        id: lbl_approveSec
                                                        text: "تایید"
                                                        //                                                anchors.centerIn: parent
                                                        Layout.alignment: Qt.AlignVCenter
                                                    }
                                                }

                                            }


                                            //-- title --//
                                            Item{
                                                Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthTitle)
                                                Label{
                                                    id: sectionLabel
                                                    text: section
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            Item { Layout.fillWidth: true } //-- filler --//
                                        }

                                    }

                                    delegate: ItemDelegate{
                                        width: parent.width
                                        height: 40

                                        font.pixelSize: Qt.application.font.pixelSize
                                        Material.foreground: "#5e5e5e"

                                        Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                        RowLayout{
                                            anchors.fill: parent
                                            anchors.margins: 3

                                            Item { Layout.fillWidth: true } //-- filler --//


                                            //-- approve --//
                                            Item{
                                                Layout.preferredWidth: Math.max(lbl_approve.implicitWidth * 2, _widthApprove)
                                                Layout.fillHeight: true


                                                RowLayout{
                                                    anchors.fill: parent

                                                    CheckBox{
                                                        Layout.fillHeight: true
                                                        Layout.margins: 3
                                                        Material.accent : Util.color_kootwall_light //Material.BlueGrey
                                                        checked: model.isSelected

                                                        onCheckedChanged: {

                                                            lv_search.isCheckBoxDirty = true
                                                            listmodelSearch.setProperty(index,"isSelected", checked)
                                                        }

                                                    }
                                                    Label{
                                                        text: model.approve ? MdiFont.Icon.check : ""
                                                        Layout.alignment: Qt.AlignVCenter
                                                        font.family: font_material.name
                                                        font.pixelSize: Qt.application.font.pixelSize * 2
                                                        color: Material.color(Material.Green)
                                                    }
                                                }
                                            }

                                            //-- title --//
                                            TxtItmOfListView{
                                                Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthTitle)
                                                Layout.fillHeight: true
                                                txt: model.title
                                            }

                                            Item { Layout.fillWidth: true } //-- filler --//
                                        }

                                        //-- spliter --//
                                        Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                        onClicked: {
                                            lv_search.currentIndex = index

                                        }

                                        onDoubleClicked: {

                                            /*var tag     = listmodelSearch.get(index).tag
                                var catId   = listmodelSearch.get(index).id

                                var data = {
                                    'category'           : listmodelSearch.get(index).category,
                                    'baseCategory'       : listmodelSearch.get(index).baseCategory,
                                    'materialCategory'   : listmodelSearch.get(index).materialCategory,
                                    'material'           : listmodelSearch.get(index).material,
                                    'subMaterial'        : listmodelSearch.get(index).subMaterial,
                                    'subSubMaterial'     : listmodelSearch.get(index).subSubMaterial,
                                    'tag'                : listmodelSearch.get(index).tag
                                }

                                log("trigger moveToSelectedCategory")
                                popupSearch.moveToSelectedCategory(data)

                                popupSearch.close()*/
                                        }

                                    }

                                    onCurrentIndexChanged:{}

                                    highlight: Rectangle { color: "lightsteelblue"; radius: 2 }
                                    focus: true

                                    // some fun with transitions :-)
                                    add: Transition {
                                        // applied when entry is added
                                        NumberAnimation {
                                            properties: "x"; from: -lv_search.width;
                                            duration: 250;
                                        }
                                    }
                                    remove: Transition {
                                        // applied when entry is removed
                                        NumberAnimation {
                                            properties: "x"; to: lv_search.width;
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

                        }

                    }


                    //-- companies and start --//
                    Item {
                        id: itmCompButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: lblSelectedCompany.implicitHeight * 2

                        //-- company item background --//
                        Rectangle{
                            id: companyBack
                            height: parent.height
                            width: parent.width + 23
                            radius: height/2
//                            y: colEdit.y + paneTxts.y + flickEdit.y + txf_categories_companyFrame.y
                            x: -23

                            color: Util.color_kootwall_dark //Material.BlueGrey) //"#33FF0000"
                        }

                        RowLayout{
                            anchors.fill: parent
                            anchors.rightMargin: 5

                            Rectangle{
                                id: txf_categories_companyFrame
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "#11000000"

                                ListModel{
                                    id: listmodel_companies
                                }

                                ListView{
                                    id: lv_companies

                                    anchors.fill: parent
                                    layoutDirection: Qt.RightToLeft
                                    orientation: ListView.Horizontal
                                    spacing: 2
                                    Material.theme: Material.Dark
                                    clip: true

                                    model: listmodel_companies //listmodel

                                    delegate: ItemDelegate{

                                        width: lblCmp.implicitWidth+20
                                        height: lblCmp.implicitHeight+10
                                        y: 5

                                        //-- border --//
                                        Rectangle{
                                            anchors.fill: parent
                                            color: "#00FFFFFF"
                                            radius: 5
                                            border{width: 1; color: "#55FFFFFF"}
                                        }

                                        //-- title --//
                                        Label{
                                            id: lblCmp
                                            text: model.title
                                            anchors.centerIn: parent
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
                                }
                            }

                            Item {

                                Layout.fillHeight: true
                                Layout.preferredWidth: lblSelectedCompany.implicitWidth

                                //-- compan listy --//
                                Label{
                                    id: lblSelectedCompany
                                    text: "شرکت ها:"
                                    Material.theme: Material.Dark
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }


                    //-- add group --//
                    MButton{
                        id: btnCategoriesAdd2
                        Layout.fillWidth: true
                        icons: MdiFont.Icon.plus //"Add"
                        tooltip: "افزودن گروهی"

                        onClicked: {

                            popupProcess.open()
//                            return

                            //-- save selected companies of listmodel_companies to global varible (_selectedCompanies) --//
                            _selectedCompanies = []
                            for(var i=0; i< listmodel_companies.count; i++){

                                //-- filter selected companies from deselected ones --//
                                if(listmodel_companies.get(i).isSelected){

                                    _selectedCompanies.push(listmodel_companies.get(i))
                                }
                            }

                            //-- clear processPrecent field of listmodelSearch --//
                            for(var i=0; i< listmodelSearch.count; i++){
                                listmodelSearch.setProperty(i, "processPrecent", 0)
                            }

                            //-- process on product index --//
                            timer_ProductProcessIterate.productCurrentInesx = 0
                            timer_ProductProcessIterate.cntr = 0
                            timer_ProductProcessIterate.selectedCompanies = _selectedCompanies
                            timer_ProductProcessIterate.restart()
                            btnCencel.isStoped = false //-- init stop/resume button state --//

                        }


                    }
                }
            }

        }

    }


    //-- prosecc tracer --//
    Popup{
        id: popupProcess

        //-- confirmed signal to delete --//
        signal confirm()

        property string msg: ""

        modal: true
        focus: true
        closePolicy: Popup.CloseOnPressOutsideParent
        width: parent.width * 0.7 //lblAlarm.implicitWidth + lblDeltxt2.implicitWidth + 100 //lblMsg.implicitWidth * 1 + 30
        height: parent.height * 0.8 //lblAlarm.implicitHeight + itmBtns.implicitHeight + 100//200//lblMsg.contentHeight * 3
        x: parent.width/2 - width/2
        y: parent.height/2 - height/2
        Material.theme: Material.Light  //-- Light, Dark, System
        font.family: font_irans.name
        font.pixelSize: Qt.application.font.pixelSize

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
        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 10

            //-- ListView of selected product --//
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout{
                    anchors.fill: parent
                    spacing: 5

                    //-- header --//
                    ItemDelegate{
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40

                        RowLayout{
                            anchors.fill: parent
                            anchors.margins: 2

                            //-- ProgressBar of total item --//
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                ProgressBar{
                                    id: progBarTotal

                                    anchors.centerIn: parent
                                    width: parent.width
                                    value: (timer_ProductProcessIterate.productCurrentInesx / listmodelSearch.count )
                                    Material.accent: Util.color_kootwall_dark
                                }
                            }

                            //-- counter lable --//
                            Item {
                                Layout.fillHeight: true
                                Layout.preferredWidth: lblProg.implicitWidth * 1.2

                                Label{
                                    id: lblProg
                                    anchors.centerIn: parent

                                    text: ""
                                }

                            }
                        }

                    }

                    //-- list view --//
                    ListView{
                        id: lv_listProcess

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 1
                        highlightMoveDuration: (contentHeight*4)/1 //pixels/second
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            id: controlLvProc
                            size: 0.1
                            position: 0.2
                            active: true
                            orientation: Qt.Vertical
                            policy: listmodelSearch.count>(lv_listProcess.height/40) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                            contentItem: Rectangle {
                                implicitWidth: 6
                                implicitHeight: 100
                                radius: width / 2
                                color: controlLvProc.pressed ? "#aa32aaba" : "#5532aaba"
                            }
                        }

                        model: listmodelSearch

                        delegate: ItemDelegate{
                            width: parent.width
                            height: model.isSelected ? 30 : 0
                            visible: model.isSelected ? true : false

                            Rectangle{
                                anchors.fill: parent
                                color: "#333e3e3e"
                            }

                            RowLayout{
                                anchors.fill: parent
                                anchors.margins: 3

                                //-- process --//
                                Item {
                                    Layout.preferredWidth: procBar.implicitWidth * 1.2
                                    Layout.fillHeight: true

                                    ProgressBar{
                                        id: procBar
                                        anchors.centerIn: parent
                                        value: model.processPrecent
                                    }
                                }

                                //-- title --//
                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Label{
                                        text: model.title
                                        anchors.centerIn: parent
                                    }
                                }

                            }

                        }
                    }

                }
            }

            //-- seperator --//
            Rectangle{
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#e1e1e1"

            }

            //-- buttons --//
            Item{
                id: itmBtns

                Layout.fillWidth: true
                Layout.preferredHeight:btnCencel.implicitHeight * ( btnCencel.isStoped ? 2.2 : 1.2)

                ColumnLayout{
                    anchors.fill: parent
                    anchors.margins: 10

                    //-- cancel buttom --//
                    Button{
                        id: btnCencel

                        property bool isStoped: false

    //                    text: "انصراف"
                        text: isStoped ? ("ادامه") :  ("\u2717" + " توقف ")
                        Layout.fillWidth: true
                        font.family: font_irans.name
                        font.bold: true

                        onClicked:{

                            if(isStoped){

                                isStoped = false
                                timer_ProductProcessIterate.restart()
                            }
                            else{

                                isStoped = true
                            }

                        }
                    }

                    Button{
                        id: btnConfirm
                        visible: btnCencel.isStoped
                        text: /* "\u2714" +*/ " خروج "
                        Layout.fillWidth: true
                        Material.background: Material.Cyan
                        Material.foreground: "#FFFFFF"
                        font.family: font_irans.name
                        font.bold: true

                        onClicked: {
                            popupProcess.close()
                        }
                    }
                }
            }

        }

    }


    //-- process steps --//
    /**
    group product creation steps:
        1- btnCategoriesAdd2: click start button to begin process
        2- timer_ProductProcessIterate: start timer to iterate all product
        3- processOnProduct(): process on one item of product based on current index
        4- fetchCompanyProduct(): fetch already company of current product
        5- timer_updateProduct: delay timer for update current product
           timer_newProduct   : delay timer for create new product
        6- updateExistProduct(): update product
           createNewProduct()  : create new product
        7- go to step 2
      **/


    //-- product create/update terator with delay operation --//
    Timer {
        id: timer_ProductProcessIterate

        property variant selectedCompanies
        property int productCurrentInesx: 0
        property int cntr: 0

        interval: 100; running: false; repeat: true
        onTriggered: {

            cntr++

            listmodelSearch.setProperty(productCurrentInesx, "processPrecent", cntr*0.015)  //-- 45% --//
            lv_listProcess.currentIndex = productCurrentInesx

            //-- check stop  button condition --//
            if(btnCencel.isStoped){

                timer_ProductProcessIterate.stop()
                return
            }

            //-- check index of product --//
            if(productCurrentInesx >= listmodelSearch.count){

                log("all products processed")
                timer_ProductProcessIterate.stop()
                cntr = 0

                btnCencel.isStoped = true
                btnCencel.enabled = false
                btnCencel.text = "پایان"

                return
            }

            if(cntr > 30){
                cntr = 0
                timer_ProductProcessIterate.stop()

                log("\n\n\n")
                log("-------------------------------")
                log(" --- start process  [" + productCurrentInesx + "] " + listmodelSearch.get(productCurrentInesx).title + "---")
                log("-------------------------------")

                //-- filter selected product to process --//
                if(listmodelSearch.get(productCurrentInesx).isSelected){

                    //-- process on product index --//
                    processOnProduct(productCurrentInesx, selectedCompanies)
                    productCurrentInesx++
                }
                else{

                    listmodelSearch.setProperty(productCurrentInesx, "processPrecent", 1) //-- 100% --//
                    productCurrentInesx++
                    timer_ProductProcessIterate.cntr = 35
                    timer_ProductProcessIterate.restart()
                }

            }
        }
    }


    //-- new product delay timer --//
    Timer {
        id: timer_newProduct

        property variant selectedCompanies
        property variant selectedProductBranchIds
        property int cntr: 0

        interval: 100; running: false; repeat: true
        onTriggered: {

            cntr++

            listmodelSearch.setProperty(timer_ProductProcessIterate.productCurrentInesx-1, "processPrecent", (0.45 + cntr*0.03))  //-- 63% --//

            if(cntr > 5){
                cntr = 0
                timer_newProduct.stop()

                //-- call function to create new product --//
                createNewProduct(selectedCompanies
                                 , selectedProductBranchIds
                                 , function(){

                    log("--- create oeration is done ---")

                    listmodelSearch.setProperty(timer_ProductProcessIterate.productCurrentInesx-1, "processPrecent", 1)  //-- 100% --//

                    //-- going to next product processing --//
                    timer_ProductProcessIterate.restart()
                })
            }
        }
    }

    //-- update product delay timer --//
    Timer {
        id: timer_updateProduct

        property variant selectedCompanies
        property variant selectedProductBranchIds
        property int selectedParentCPid
        property int cntr: 0

        interval: 100; running: false; repeat: true
        onTriggered: {

            cntr++

            listmodelSearch.setProperty(timer_ProductProcessIterate.productCurrentInesx-1, "processPrecent", (0.45 + cntr*0.03))  //-- 63% --//

            if(cntr > 5){
                cntr = 0
                timer_updateProduct.stop()


                //-- call function to update product --//
                updateExistProduct(selectedParentCPid
                                   , selectedCompanies
                                   , selectedProductBranchIds
                                   , function(){

                    log("--- update oeration is done ---")

                    listmodelSearch.setProperty(timer_ProductProcessIterate.productCurrentInesx-1, "processPrecent", 1)  //-- 100% --//

                    //-- going to next product processing --//
                    timer_ProductProcessIterate.restart()
                })
            }
        }
    }

    //-- message handler --//
    MsgPopup{
        id: msgHandler

    }

    //-- status bar --//
    Label{
        id: message
        visible:  false //isShowStatus

        Layout.fillWidth: true
        Layout.preferredHeight: implicitHeight * 1.2

        background: Rectangle{color: "#99000000"}

        text: "status"
        color: "#ffffff"

    }


    //-- product create/update operation with iterate on product list --//
    function processOnProduct(productIndex, selCompanies){


        //-- select first Item --//
        var indx = productIndex
        var catIds = {
            'title'              : listmodelSearch.get(indx).title,
            'category'           : listmodelSearch.get(indx).category,
            'baseCategory'       : listmodelSearch.get(indx).baseCategory,
            'materialCategory'   : listmodelSearch.get(indx).materialCategory,
            'material'           : listmodelSearch.get(indx).material,
            'subMaterial'        : listmodelSearch.get(indx).subMaterial,
            'subSubMaterial'     : listmodelSearch.get(indx).subSubMaterial
        }

//        log(JSON.stringify(catIds))

        log("--- check companies of processing product... ---")


        //-- check selected product, if finded -> add companies of product to selected ones --//
        fetchCompanyProduct(catIds, selCompanies, function(isUpdate, selectedParentCPid, selectedCompanies){

            log("isUpdate = " + isUpdate)
            log("selectedParentCPid = " + selectedParentCPid)
            log("selectedCompanies = " + JSON.stringify(selectedCompanies))

            //-- trigger delay timer for next step --//
            if(isUpdate){ //-- update --//

                log("--- start update operation... ---")
                timer_updateProduct.selectedParentCPid        = selectedParentCPid
                timer_updateProduct.selectedCompanies         = selectedCompanies
                timer_updateProduct.selectedProductBranchIds  = catIds
                timer_updateProduct.restart()
            }
            else{       //-- create --//

                log("--- start create operation... ---")
                timer_newProduct.selectedCompanies          = selectedCompanies
                timer_newProduct.selectedProductBranchIds   = catIds
                timer_newProduct.restart()
            }
        })
    }


    //-- fetch all branch and filter leaves --//
    function searchCategoryLeaves(searchedtext, catType, cb){

        //-- search based on title --//
        var endpoint = ""

        if(catType === _CATEGORY){

            endpoint = "api/kootwall/LeavesSearch?category=" + searchedtext
        }
        else if(catType === _BASECATEGORY){

            endpoint = "api/kootwall/LeavesSearch?baseCategory=" + searchedtext
        }
        else if(catType === _CATEGORYMATERIAL){

            endpoint = "api/kootwall/LeavesSearch?materialCategory=" + searchedtext
        }
        else if(catType === _MATERIAL){

            endpoint = "api/kootwall/LeavesSearch?material=" + searchedtext
        }
        else if(catType === _SUBMATERIAL){

            endpoint = "api/kootwall/LeavesSearch?subMaterial=" + searchedtext
        }
        else {
            return
        }


        Service.get_all( endpoint, function(resp, http) {
            log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

//            log("count: " + resp.BaseCategory.length)

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
//                        message.text = resp.error
//                        triggerMsg(resp.error, "RED")

                cb()

                return

            }


            //-- check BaseCategory --//
            if(resp.hasOwnProperty('BaseCategory'))
            {

                for(var i=0; i<resp.BaseCategory.length; i++) {

                    //-- check node. is branch or leavs --//
                    var currentNodeId = resp.BaseCategory[i].id.toString()
                    var isFind = false
                    for(var j=0; (j<resp.MaterialCategory.length && !isFind); j++) {

                        var parentNodeId = resp.MaterialCategory[j].baseCategory.toString()
                        //                        log(currentNodeId + "===" + parentNodeId)
                        if(parentNodeId.indexOf(currentNodeId) >= 0){
                            isFind = true
                        }
                    }

                    //-- add if have not child --//
                    if(!isFind){
                        listmodelSearch.append({
                                                   'title'                  : resp.BaseCategory[i].title,
                                                   'category'               : resp.BaseCategory[i].category.toString(),
                                                   'baseCategory'           : resp.BaseCategory[i].id.toString(),
                                                   'materialCategory'       : "",
                                                   'material'               : "",
                                                   'subMaterial'            : "",
                                                   'subSubMaterial'         : "",
                                                   'cat'                    : "فصول اصلی",
                                                   'tag'                    : _BASECATEGORY,
                                                   'processPrecent'         : 0,
                                                   'isSelected'             : true
                                               })
                    }

                }
            }

            //-- check MaterialCategory --//
            if(resp.hasOwnProperty('MaterialCategory'))
            {

                for(var i=0; i<resp.MaterialCategory.length; i++) {

                    //-- check node. is branch or leavs --//
                    var currentNodeId = resp.MaterialCategory[i].id.toString()
                    var isFind = false
                    for(var j=0; (j<resp.Material.length && !isFind); j++) {

                        var parentNodeId = resp.Material[j].materialCategory.toString()
                        //                        log(currentNodeId + "===" + parentNodeId)
                        if(parentNodeId.indexOf(currentNodeId) >= 0){
                            isFind = true
                        }
                    }

                    //-- add if have not child --//
                    if(!isFind){
                        listmodelSearch.append({
                                                   'title'                  : resp.MaterialCategory[i].title,
                                                   'category'               : resp.MaterialCategory[i].category.toString(),
                                                   'baseCategory'           : resp.MaterialCategory[i].baseCategory.toString(),
                                                   'materialCategory'       : resp.MaterialCategory[i].id.toString(),
                                                   'material'               : "",
                                                   'subMaterial'            : "",
                                                   'subSubMaterial'         : "",
                                                   'cat'                    : "بخش 1",
                                                   'tag'                    : _CATEGORYMATERIAL,
                                                   'processPrecent'         : 0,
                                                   'isSelected'             : true
                                               })
                    }

                }
            }

            //-- check Material --//
            if(resp.hasOwnProperty('Material'))
            {

                for(var i=0; i<resp.Material.length; i++) {


                    //-- check node. is branch or leavs --//
                    var currentNodeId = resp.Material[i].id.toString()
                    var isFind = false
                    for(var j=0; (j<resp.SubMaterial.length && !isFind); j++) {

                        var parentNodeId = resp.SubMaterial[j].material.toString()
                        //                        log(currentNodeId + "===" + parentNodeId)
                        if(parentNodeId.indexOf(currentNodeId) >= 0){
                            isFind = true
                        }
                    }

                    //-- add if have not child --//
                    if(!isFind){
                        listmodelSearch.append({
                                                   'title'                  : resp.Material[i].title,
                                                   'category'               : resp.Material[i].category.toString(),
                                                   'baseCategory'           : resp.Material[i].baseCategory.toString(),
                                                   'materialCategory'       : resp.Material[i].materialCategory.toString(),
                                                   'material'               : resp.Material[i].id.toString(),
                                                   'subMaterial'            : "",
                                                   'subSubMaterial'         : "",
                                                   'cat'                    : "بخش 2",
                                                   'tag'                    : _MATERIAL,
                                                   'processPrecent'         : 0,
                                                   'isSelected'             : true
                                               })
                    }

                }
            }

            //-- check SubMaterial --//
            if(resp.hasOwnProperty('SubMaterial'))
            {

                for(var i=0; i<resp.SubMaterial.length; i++) {


                    //-- check node. is branch or leavs --//
                    var currentNodeId = resp.SubMaterial[i].id.toString()
                    var isFind = false
                    for(var j=0; (j<resp.SubSubMaterial.length && !isFind); j++) {

                        var parentNodeId = resp.SubSubMaterial[j].subMaterial.toString()
                        //                        log(currentNodeId + "===" + parentNodeId)
                        if(parentNodeId.indexOf(currentNodeId) >= 0){
                            isFind = true
                        }
                    }

                    //-- add if have not child --//
                    if(!isFind){
                        listmodelSearch.append({
                                                   'title'                  : resp.SubMaterial[i].title,
                                                   'category'               : resp.SubMaterial[i].category.toString(),
                                                   'baseCategory'           : resp.SubMaterial[i].baseCategory.toString(),
                                                   'materialCategory'       : resp.SubMaterial[i].materialCategory.toString(),
                                                   'material'               : resp.SubMaterial[i].material.toString(),
                                                   'subMaterial'            : resp.SubMaterial[i].id.toString(),
                                                   'subSubMaterial'         : "",
                                                   'cat'                    : "بخش 3",
                                                   'tag'                    : _SUBMATERIAL,
                                                   'processPrecent'         : 0,
                                                   'isSelected'             : true
                                               })
                    }



                }
            }

            //-- check SubSubMaterial --//
            if(resp.hasOwnProperty('SubSubMaterial'))
            {

                for(var i=0; i<resp.SubSubMaterial.length; i++) {

                    listmodelSearch.append({
                                               'title'                  : resp.SubSubMaterial[i].title,
                                               'category'               : resp.SubSubMaterial[i].category.toString(),
                                               'baseCategory'           : resp.SubSubMaterial[i].baseCategory.toString(),
                                               'materialCategory'       : resp.SubSubMaterial[i].materialCategory.toString(),
                                               'material'               : resp.SubSubMaterial[i].material.toString(),
                                               'subMaterial'            : resp.SubSubMaterial[i].subMaterial.toString(),
                                               'subSubMaterial'         : resp.SubSubMaterial[i].id.toString(),
                                               'cat'                    : "بخش 4",
                                               'tag'                    : _SUBSUBMATERIAL,
                                               'processPrecent'         : 0,
                                               'isSelected'             : true
                                           })

                }
            }



            //--trigger job done --//
            cb()
        })

    }


    //-- fetch Products on Title from DB --//
    function fetchCompanyProduct(categoriesId, selectedCompanies, callBack){

        //-- search based on categoriesID --//
        var endpoint = "api/kootwall/orders2-list-generic-view?"

        if(categoriesId.subSubMaterial   != "") endpoint += "&subSubMaterialId="    + categoriesId.subSubMaterial
        if(categoriesId.subMaterial      != "") endpoint += "&subMaterialId="       + categoriesId.subMaterial
        if(categoriesId.material         != "") endpoint += "&materialId="          + categoriesId.material
        if(categoriesId.materialCategory != "") endpoint += "&materialCategoryId="  + categoriesId.materialCategory
        if(categoriesId.baseCategory     != "") endpoint += "&baseCategoryId="      + categoriesId.baseCategory
        if(categoriesId.category         != "") endpoint += "&categoryId="          + categoriesId.category

        log("endpoint = " + endpoint)

        Service.get_all( endpoint, function(resp, http) {
            log( endpoint + ", state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
//                message.text = resp.error
                triggerMsg(resp.error, "RED")
                return

            }

            var tempCompaniesList = selectedCompanies

            var isUpdate = false            //-- status of product (finded: TRUE, new product: FALSE)
            var selectedParentCPid = -1     //-- id of finded product (-1 when new product)

            //-- triger selected item when new models fetched --//
            if(resp.length > 0){

                isUpdate = true
                selectedParentCPid = resp[0].id


                //-- iterate on existence companies for selected product --//
                for(var i=0; i<resp[0].ordered_meals.length; i++) {

                    //-- filter existed company --//
                    var isCompanyFind = false
                    for(var j=0; j< tempCompaniesList.length; j++){

                        if(tempCompaniesList[j].id === resp[0].ordered_meals[i].company.id){

                            isCompanyFind = true
                            break
                        }
                    }

                    //-- added company --//
                    if(!isCompanyFind){
                        selectedCompanies.push({
                                                    "id": resp[0].ordered_meals[i].company.id,
                                                    "title": resp[0].ordered_meals[i].company.title,
                                                    "isSelected": true
                                                })
                    }

                }

            }

//            message.text = "searched data recived"
            triggerMsg("جست و جو انجام شد", "LOG")

            //-- callBack function to return resualt when process done --//
            callBack(isUpdate, selectedParentCPid, selectedCompanies)
        })

    }


    //-- create new product --//
    function createNewProduct(selectecCompanies, selectedProductBranchIds, callBack){

        log("create new product")

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
            for(var i=0; i< selectecCompanies.length; i++){

                //-- send data --//
                var data4 = {
//                  "title"             : txf_categories_title.text          ,
//                    "pic1"              : txf_categories_pic.text           ,
//                    "description"       : txf_categories_description.text  ,
                    "quantity"          : 1,
                    "company"           : selectecCompanies[i].id
                }

                if(selectedProductBranchIds.category > -1)            data4.category           = selectedProductBranchIds.category
                if(selectedProductBranchIds.baseCategory > -1)        data4.baseCategory       = selectedProductBranchIds.baseCategory
                if(selectedProductBranchIds.materialCategory > -1)    data4.materialCategory   = selectedProductBranchIds.materialCategory
                if(selectedProductBranchIds.material > -1)            data4.material           = selectedProductBranchIds.material
                if(selectedProductBranchIds.subMaterial > -1)         data4.subMaterial        = selectedProductBranchIds.subMaterial
                if(selectedProductBranchIds.subSubMaterial > -1)      data4.subSubMaterial     = selectedProductBranchIds.subSubMaterial


                d1.push(data4)
            }

            //-- add product of existed company --//
            var d4 = {

                //"table_number"      : 4,
                "ordered_meals"     : d1,
//               "title"             : (rdBtn_currentTitle.checked ? txf_categories_title.text : txf_categories_titleNew.text) ,
//                "pic1"              : txf_categories_pic.text           ,
//                "description"       : txf_categories_description.text  ,
//                                            "branchTitles"      : (
//                                                                      (title_category         === "" ? "" : (title_category           +">"))
//                                                                      + (title_baseCategory     === "" ? "" : (title_baseCategory       +">"))
//                                                                      + (title_materialCategory === "" ? "" : (title_materialCategory   +">"))
//                                                                      + (title_material         === "" ? "" : (title_material           +">"))
//                                                                      + (title_subMaterial      === "" ? "" : (title_subMaterial        +">"))
//                                                                      + (title_subSubMaterial   === "" ? "" : (title_subSubMaterial     ))
//                                                                      ),
            }

            if(selectedProductBranchIds.category > -1)            d4.category           = selectedProductBranchIds.category
            if(selectedProductBranchIds.baseCategory > -1)        d4.baseCategory       = selectedProductBranchIds.baseCategory
            if(selectedProductBranchIds.materialCategory > -1)    d4.materialCategory   = selectedProductBranchIds.materialCategory
            if(selectedProductBranchIds.material > -1)            d4.material           = selectedProductBranchIds.material
            if(selectedProductBranchIds.subMaterial > -1)         d4.subMaterial        = selectedProductBranchIds.subMaterial
            if(selectedProductBranchIds.subSubMaterial > -1)      d4.subSubMaterial     = selectedProductBranchIds.subSubMaterial


            log("jd4 = " + JSON.stringify(d4))

            var endpoint = ""

            //-- operate requests --//
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
//                triggerMsg("عنوان جدید ایجاد شد", "BLUE")

                //-- log activity --//
                logActivity(_ACTIVITY_CREATE
                            , _COMPANYPRODUCT
                            , ("محصولی جدید در مدیریت محصول ها ایجاد شد: " + selectedProductBranchIds.title)
                            ,function(){

                                callBack()
                            })


            })

        })
    }


    //-- update finded product --//
    function updateExistProduct(selectedParentCPid, selectecCompanies, selectedProductBranchIds, callBack){

        log("update finded product")

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
            for(var i=0; i< selectecCompanies.length; i++){

                //-- send data --//
                var data4 = {
//                  "title"             : txf_categories_title.text          ,
//                    "pic1"              : txf_categories_pic.text           ,
//                    "description"       : txf_categories_description.text  ,
                    "quantity"          : 1,
                    "company"           : selectecCompanies[i].id
                }

                if(selectedProductBranchIds.category > -1)            data4.category           = selectedProductBranchIds.category
                if(selectedProductBranchIds.baseCategory > -1)        data4.baseCategory       = selectedProductBranchIds.baseCategory
                if(selectedProductBranchIds.materialCategory > -1)    data4.materialCategory   = selectedProductBranchIds.materialCategory
                if(selectedProductBranchIds.material > -1)            data4.material           = selectedProductBranchIds.material
                if(selectedProductBranchIds.subMaterial > -1)         data4.subMaterial        = selectedProductBranchIds.subMaterial
                if(selectedProductBranchIds.subSubMaterial > -1)      data4.subSubMaterial     = selectedProductBranchIds.subSubMaterial


                d1.push(data4)
            }

            //-- add product of existed company --//
            var d4 = {

                //"table_number"      : 4,
                "ordered_meals"     : d1,
//               "title"             : (rdBtn_currentTitle.checked ? txf_categories_title.text : txf_categories_titleNew.text) ,
//                "pic1"              : txf_categories_pic.text           ,
//                "description"       : txf_categories_description.text  ,
//                                            "branchTitles"      : (
//                                                                      (title_category         === "" ? "" : (title_category           +">"))
//                                                                      + (title_baseCategory     === "" ? "" : (title_baseCategory       +">"))
//                                                                      + (title_materialCategory === "" ? "" : (title_materialCategory   +">"))
//                                                                      + (title_material         === "" ? "" : (title_material           +">"))
//                                                                      + (title_subMaterial      === "" ? "" : (title_subMaterial        +">"))
//                                                                      + (title_subSubMaterial   === "" ? "" : (title_subSubMaterial     ))
//                                                                      ),
            }

            if(selectedProductBranchIds.category > -1)            d4.category           = selectedProductBranchIds.category
            if(selectedProductBranchIds.baseCategory > -1)        d4.baseCategory       = selectedProductBranchIds.baseCategory
            if(selectedProductBranchIds.materialCategory > -1)    d4.materialCategory   = selectedProductBranchIds.materialCategory
            if(selectedProductBranchIds.material > -1)            d4.material           = selectedProductBranchIds.material
            if(selectedProductBranchIds.subMaterial > -1)         d4.subMaterial        = selectedProductBranchIds.subMaterial
            if(selectedProductBranchIds.subSubMaterial > -1)      d4.subSubMaterial     = selectedProductBranchIds.subSubMaterial


            log("jd4 = " + JSON.stringify(d4))

            var endpoint = ""

            log("_selectedParentCPid = " + selectedParentCPid)
//            log("state, _isUpdate: " + _isUpdate + ", rdBtn_newTitle.checked: " + rdBtn_newTitle.checked
//                + ", rdBtn_currentTitle.checked = " + rdBtn_currentTitle.checked)

            var requestType = "UPDATE"

            //-- operate requests --//
            endpoint = "api/kootwall/orders2-update-mixin/"+ selectedParentCPid

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
//                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "BLUE")

                //-- log activity --//
                logActivity(_ACTIVITY_UPDATE
                            , _COMPANYPRODUCT
                            , ("به روز رسانی محصول در مدیریت محصول ها: " + selectedProductBranchIds.title)
                            ,function(){

                                callBack()
                            })


            })

        })
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
