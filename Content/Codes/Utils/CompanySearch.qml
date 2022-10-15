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


//-- message handler --//
Popup{
    id: popupSearch

    property variant mainPage


    property string pageTitle:      "جست و جو شرکت ها"  //-- modul header title --//
    property bool   isLogEnabled:   true            //-- global log permission --//
    property bool   _localLogPermission:    true    //-- local log permission --//
    property int    companyCurrentPage   :   1      //-- current page of company elements --//
    property int    companyPageSize      :  50      //-- current page of company elements --//
    property int    totalCompany         :   0      //-- total element of company elements --//

    signal show()
    onShow: {
//                msg = searchedText

//        listmodelSearch.clear()

        //-- clear selected companies --//
        listmodel_selectedCompanies.clear()

        //-- load first page --//
        companyCurrentPage = 1

        popupSearch.open()
        btnCategoriesGet.clicked()

    }

    //-- return selected companies --//
    signal returnSelectedCompanies(ListModel companies)

    parent: mainPage
    objectName: "SearchCompany"

    modal: true
    focus: true
    //        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    width: parent.width/2 //lblMsg.implicitWidth * 1 + 30
    height: parent.height * 0.8 //lblMsg.contentHeight * 3
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    Material.theme: Material.Light  //-- Light, Dark, System


    //-- company product --//
    Pane{
        anchors.fill: parent
//        background: Rectangle{color: "#00FFFFFF"}

        Material.theme: Material.Light

        font.pixelSize: Qt.application.font.pixelSize
        font.family: font_irans.name

        //-- body --//
        Rectangle{
            anchors.fill: parent
            anchors.margins: 10
            radius: 5
            color: "transparent" //Util.color_kootwall_dark

            //-- ListView & selected items --//
            RowLayout{
                anchors.fill: parent

                //-- companies ListView --//
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

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
//                                txtColor: "white"

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

                            //-- page indicator --//
                            RowLayout{
                                visible: false
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                //-- total company count --//
                                Label{
                                    Layout.alignment: Qt.AlignVCenter
                                    text: "تعداد: " + totalCompany
                                    font.pixelSize: Qt.application.font.pixelSize * 0.7
                                }

                                //-- previous button --//
                                MButton{
                                    id: btn_previous

                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    icons: MdiFont.Icon.chevron_double_left
                                    tooltip: "صفحه قبل"
                                    flat: true
                                    enabled: companyCurrentPage > 1
                                    Material.background:"transparent"

                                    onClicked: {

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

                                }

                                Label{
                                    id: lbl_currentPages

//                                    text: companyCurrentPage
                                    text: ((companyPageSize*(companyCurrentPage-1)) + 1) + "-" + Math.min((companyPageSize*companyCurrentPage), totalCompany)
                                    font.family: font_irans.name
                                    font.pixelSize: Qt.application.font.pixelSize
                                    Layout.alignment: Qt.AlignCenter
                                }

                                //-- next button --//
                                MButton{
                                    id: btn_next

                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    icons: MdiFont.Icon.chevron_double_right
                                    tooltip: "صفحه بعد"
                                    flat: true
    //                                enabled: (lvPageSizeOffset+1) < (listmodel_category.get(lv_category.currentIndex).product_count / lvPageSize)
                                    enabled: companyCurrentPage < totalCompany/companyPageSize
                                    Material.background:"transparent"

                                    onClicked: {

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

                                    Rectangle { anchors.fill: parent; opacity: (isSelected ? 0.5 : 0.0); color: Util.color_kootwall_light; radius: 2 }

                                    RowLayout{
                                        anchors.fill: parent
                                        anchors.margins: 3

                                        //-- title --//
                                        TxtItmOfListView{
        //                                    visible: isTitleShow
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

                                        if(isExist(listmodel.get(index)) === -1)
                                            listmodel_selectedCompanies.append(listmodel.get(index))

                                    }


                                }


                                onCurrentIndexChanged:{

                                    log("lv.currentIndex = " + lv.currentIndex)

                                    //-- controll count of listview --//
                                    if(lv.count < 1) return

                                    //-- controll currentIndex of listview --//
                                    if(lv.currentIndex < 0) return

        //                            _companyID      = listmodel.get(lv.currentIndex).id
        //                            _companyTitle   = listmodel.get(lv.currentIndex).title
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

//                                var endpoint = "api/kootwall/Company"
                                var endpoint = "api/kootwall/Company?page=" + companyCurrentPage + "&page_size=" + companyPageSize

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
        //                                message.text = resp.error
        //                                triggerMsg(resp.error, "RED")
                                        return

                                    }

                                    var result = resp.results
                                    totalCompany = resp.count

                                    listmodel.clear()

                                    for(var i=0; i<result.length; i++) {
                                        listmodel.append(result[i])
                                        listmodel.setProperty(i, 'isSelected', false)
                                    }

        //                            message.text = "all data recived"
        //                            triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                })
                            }

                        }

                        //-- buttons --//
                        Item{
                            Layout.fillWidth: true
                            Layout.preferredHeight: btnAddCompany.implicitHeight

                            RowLayout{
                                anchors.fill: parent

                                Button{
                                    id: btnAddCompany

                                    text: "افزودن شرکت"
        //                            Layout.fillWidth: true
                                    font.pixelSize: Qt.application.font.pixelSize * 1.0
                                    Material.background: Util.color_kootwall_light //Material.Teal
                                    Material.foreground: "#f0f0f0"

                                    onClicked: {
                //                        openCompanyWin()
                                    }
                                }


                                Button{
                                    id: btnSelect

                                    text: "انتخاب شرکت ها"
                                    Layout.fillWidth: true
                                    font.pixelSize: Qt.application.font.pixelSize * 1.0
                                    Material.background: Util.color_kootwall_light //Material.Teal
                                    Material.foreground: "#f0f0f0"

                                    onClicked: {

                                        returnSelectedCompanies(listmodel_selectedCompanies)
                                        popupSearch.close()
                                    }
                                }
                            }
                        }

                    }

                }

                //-- selected companies --//
                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    ColumnLayout{
                        anchors.fill: parent

                        //-- selected company header --//
                        Button{
                            Layout.fillWidth: true
                            text: ""
                            flat: true
                            down: true
                            Text {
                                id: txt_title
                                text: "شرکت های انتخاب شده"
                                anchors.centerIn: parent
                            }
                        }

                        ListModel{
                            id: listmodel_selectedCompanies
                        }

                        //-- ListView --//
                        Rectangle{
                            Layout.row: 10
                            Layout.column: 1
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#11000000"

                            ListView{
                                id: lv_companies

                                anchors.fill: parent
                                layoutDirection: Qt.RightToLeft
//                                orientation: ListView.Horizontal
                                spacing: 0

                                model: listmodel_selectedCompanies

                                delegate: ItemDelegate{

//                                    visible: model.isSelected
                                    width: parent.width //model.isSelected ? (lblCmp.implicitWidth+20) : 0
                                    height: (lblDel.implicitHeight+10)

                                    //-- border --//
                                    Rectangle{
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        color: "#00FFFFFF"
                                        radius: 5
                                        border{width: 1; color: "#55000000"}
                                    }

                                    //-- title --//
                                    TxtItmOfListView{
                                        visible: isTitleShow
                                        width: parent.width - 4
                                        anchors.centerIn: parent
                                        txt: model.title
                                    }

                                    //-- dlete lable --//
                                    Label{
                                        id: lblDel
                                        visible: false
                                        font.family: font_material.name
                                        font.pixelSize: Qt.application.font.pixelSize * 2
                                        color: Material.color(Material.Red)
                                        anchors.centerIn: parent
                                        text: MdiFont.Icon.window_close
                                    }

                                    MouseArea{
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: lblDel.visible = true
                                        onExited:  lblDel.visible = false
                                        onClicked: {
//                                            listmodel.setProperty(index, 'isSelected', false)
                                            listmodel_selectedCompanies.remove(index)
                                            mouse.accepted = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }

    //-- check item exist in listmodel of selected companies --//
    //-- return index or -1 --//
    function isExist(itm){

        for(var i=0; i< listmodel_selectedCompanies.count; i++){

            log("check, " + itm.id + " == " + listmodel_selectedCompanies.get(i).id)
            log("check ["+i+"], " + itm.title + " == " + listmodel_selectedCompanies.get(i).title)
            if(itm.id === listmodel_selectedCompanies.get(i).id) return i
        }

        return -1
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
