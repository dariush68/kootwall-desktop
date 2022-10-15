import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import "./../../font/Icon.js" as MdiFont
import "./../REST/apiservice.js" as Service
import "./../Utils"


//-- Categories --//
Rectangle{
    id: root

    signal setedIndex(string categoryID)
    onSetedIndex:{

        log("signal recived: " + categoryID)

        if(categoryID === "empty"){

            root.state = "EMPTY"
            listmodel.clear()

            //-- trigger empty list of sub cat --//
            returnSelectedMaterial("empty")

            //-- clear collapse mode label --//
            lbl1.text = ""

            //-- clear cat Id history --//
            parentCatId = ""

            //-- clear parent Id text fields --//
            txf_categories_materialCategory.text    = ""
        }
        else{

            //-- ignore unchange request --//
            if(categoryID === parentCatId) return

            parentCatId = categoryID

            log("proccess id " + categoryID)

            txf_categories_materialCategory.text = parentCatId
            fetchBasedonMaterialCategory(categoryID)

        }

        //-- clear text fields --//
        clearCategoriesTextfields()
    }

    //-- send selected Item to sub category --//
    signal returnSelectedMaterial(string materialID)


    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)

    //-- double click for open add production win --//
    signal openAddProduct()

    //-- add new item without DB operation --//
    signal addNewItem(variant itm)
    onAddNewItem: {
        listmodel.append(itm)
    }

    //-- select new index in listview externaly --//
    function selectNewItemBasedonID(catID, cb){

        //        log("--- start to search materialCategories; " + catID + ", count: " + listmodel.count)
        var flagFound = false
        for(var i=0; i< listmodel.count && !flagFound; i++){

            //            log(catID + "==" + listmodel.get(i).id)
            if(catID === listmodel.get(i).id.toString()){

                lv.currentIndex = i
                flagFound = true
                //                log("founded, index = " + i)
            }
        }

        if(cb) cb(flagFound)
    }


    property string pageTitle:              "بخش 2"  //-- modul header title --//
    property bool   isExpand:               true            //-- keep Expand mode status --//
    property bool   isShowStatus:           false           //-- show/hide status bar --//
    property int    headerUnExpandHeight:   100             //-- header height in unExpanded mode --//
    property int    maxItmWidth:            200             //-- maximum width of module --//
    property bool   isLogEnabled:           true            //-- global log permission --//
    property alias  modelItm:               listmodel       //-- scategory ListModel --//
    property alias  selModelIndx:           lv.currentIndex //-- listview current index --//

    //-- handle Expand mode status --//
    onIsExpandChanged: {

        log("lv.currentIndex = " + lv.currentIndex)
        log("lv.count = " + lv.count)
        //-- check current index of list view --//
        if(lv.count > 0 /*&& lv.currentIndex < 0*/){

            var temp = lv.currentIndex
            lv.currentIndex = -1
            lv.currentIndex = temp

        }
    }

    property bool   _isEditable:            false  //-- allow user to edit text Item --//
    property bool   _localLogPermission:    true   //-- local log permission --//
    property int    _zeroFillLenght:        5      //-- lenght of number in ordering for filled with zero --//

    //-- show permission for database items --//
    property bool isIdShow              : false
    property bool isMaterialCategoryShow: false
    property bool isTitleShow           : true
    property bool isPicShow             : false
    property bool isDateShow            : false
    property int  visibleItmCount       : 1     //-- hold visible item count for size porpose (in edit win height) --//

    //-- hold parent cat ID for insert in new item --//
    property string parentCatId: ""

    objectName: "MaterialItem"
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

    Component.onCompleted: {
        log("start to fecth data: ")
        //        dataSource.categories_getAll()
    }

    /*
      FILL  : show Module becuase listmodel has component
      EMPTY : Hide Module becuase listmodel lack of any component
      */
    states: [
        State {
            name: "FILL"
            PropertyChanges {
                target: root
                opacity: 1.0
                maxItmWidth: 200
            }
        },
        State {
            name: "EMPTY"
            PropertyChanges {
                target: root
                opacity: 1.0 //0.0
                maxItmWidth: 200 //0
            }
        }
    ]

    //-- transition animation --//
    transitions: [
        Transition {
            from: "FILL"
            to: "EMPTY"
            NumberAnimation {
                target: root
                properties: "maxItmWidth,opacity"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "EMPTY"
            to: "FILL"
            NumberAnimation {
                target: root
                properties: "maxItmWidth,opacity"
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    ]

    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name

        ColumnLayout{
            anchors.fill: parent
            anchors.margins: 5

            //-- table header --//
            Button{
                Layout.fillWidth: true
                Layout.preferredHeight: isExpand ? implicitHeight : headerUnExpandHeight
                text: isExpand ? pageTitle : ""
                flat: true
                down: true
                onClicked: {isExpand = !isExpand}
                Text {
                    id: txt_title
                    text: pageTitle
                    anchors.centerIn: parent
                    rotation: 90
                    visible: !isExpand
                }
            }

            //-- list view header --//
            ItemDelegate{
                Layout.fillWidth: true
                Layout.preferredHeight: lblSize.implicitHeight * 2
                visible: isExpand

                font.pixelSize: Qt.application.font.pixelSize

                //- back color --//
                Rectangle{anchors.fill: parent; color: "#05000000"; border{width: 1; color: "#22000000"}}

                RowLayout{
                    anchors.fill: parent

                    Item{ Layout.fillWidth: true } //-- filler --//

                    //-- categoryID --//
                    Label{
                        visible: isIdShow
                        text: "شماره"
                    }

                    //-- materialCategory --//
                    Label{
                        visible: isMaterialCategoryShow
                        text: "دسنه والد"
                    }

                    //-- title --//
                    Label{
                        id: lblTitle
                        visible: isTitleShow
                        text: "عنوان"
                    }

                    //-- pic --//
                    Label{
                        visible: isPicShow
                        text: "تصویر"
                    }

                    //-- date --//
                    Label{
                        visible: isDateShow
                        text: "تاریخ"
                    }

                    Item{ Layout.fillWidth: true } //-- filler --//
                }

                onClicked: {
                    if(btnReorder.state === "SELECT"){
                        btnReorder.state = "MOVE"
                        btnReorder.isDirty = true
                    }
                    else if(btnReorder.state === "MOVE"){

                        btnReorder.state = "SELECT"
                    }
                }
            }

            //-- ListView --//
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: isExpand

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
                        Material.foreground: "#5e5e5e"

                        //-- odd/even grey backgroung --//
                        Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                        //-- selected backgroung --//
                        Rectangle{visible: isSelected ;anchors.fill: parent; color: "#4400ff00"; }

                        RowLayout{
                            anchors.fill: parent
                            anchors.margins: 3

                            //-- categoryID --//
                            Label{
                                visible: isIdShow
                                text: model.id //+ ","
                            }

                            //-- Category --//
                            Label{
                                visible: isMaterialCategoryShow
                                text: model.materialCategory //+ ","
                            }

                            //-- title --//
                            TxtItmOfListView{
                                visible: isTitleShow
                                Layout.fillWidth: true
                                txt: model.title
                            }

                            //-- pic --//
                            Label{
                                visible: isPicShow
                                text: ""//model.pic //+ ","
                            }

                            //-- date --//
                            Label{
                                visible: isDateShow
                                text: model.date
                            }
                        }

                        //-- orderNum fields --//
                        Label{
                            visible: false
                            text: model.orderNum
                        }

                        //-- spliter --//
                        Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                        onClicked: {
                            //-- check reordering flag --//
                            //-- first step reordering (select reordering items) --//
                            if(btnReorder.state === "SELECT"){

                                listmodel.setProperty(index, "isSelected", !isSelected)
                                listmodel.setProperty(index, "orderSelected", btnReorder.orderCntr++)
                            }
                            //-- second step reordering (move selected item to target position) --//
                            else if(btnReorder.state === "MOVE"){

                                log("moving")

                                var targetItem = index

                                //-- iterate based on order numbers of selected  items --//
                                for(var k=0; k<btnReorder.orderCntr; k++){

                                    //-- serach between all items to find orderNumber --//
                                    for(var i=0; i<listmodel.count; i++){

                                        //-- check selected and order number --//
                                        if(listmodel.get(i).isSelected && listmodel.get(i).orderSelected == k){

                                            //-- move from top to down --//
                                            if(i < targetItem){
                                                listmodel.move(i,targetItem-1,1)
                                                listmodel.setProperty(targetItem-1, "isSelected", false)
                                                i--
                                            }
                                            //-- move from down to top --//
                                            else{
                                                listmodel.move(i,targetItem,1)
                                                listmodel.setProperty(targetItem, "isSelected", false)
                                                targetItem++
                                            }

                                            break
                                        }
                                    }

                                }

                                //-- deselect all items --//
                                for(var i=0; i<listmodel.count; i++){
                                    listmodel.setProperty(i, "isSelected", false)
                                    listmodel.setProperty(i, "orderSelected", -1)
                                }

                                btnReorder.state = "SELECT"
                                btnReorder.orderCntr = 0 //-- init to 0 --//
                            }
                            //-- normal mode --//
                            else{

                                lv.currentIndex = index

                                txf_categories_categoryID.text      = listmodel.get(lv.currentIndex).id
                                txf_categories_materialCategory.text    = listmodel.get(lv.currentIndex).materialCategory
                                txf_categories_title.text           = listmodel.get(lv.currentIndex).title
                                txf_categories_pic.text             = ""//listmodel.get(lv.currentIndex).pic
                                txf_categories_date.text            = listmodel.get(lv.currentIndex).date
                            }
                        }

                        onDoubleClicked: {
                            //-- open addProduct window --//
                            openAddProduct()
                        }

                    }


                    onCurrentIndexChanged:{

                        //-- initial collapse label text --//
                        lbl1.text = ""

                        log("lv.currentIndex = " + lv.currentIndex)

                        //-- controll count of listview --//
                        if(lv.count < 1) return

                        //-- controll currentIndex of listview --//
                        if(lv.currentIndex < 0) return

                        txf_categories_categoryID.text      = listmodel.get(lv.currentIndex).id
                        txf_categories_materialCategory.text    = listmodel.get(lv.currentIndex).materialCategory
                        txf_categories_title.text           = listmodel.get(lv.currentIndex).title
                        txf_categories_pic.text             = ""//listmodel.get(lv.currentIndex).pic
                        txf_categories_date.text            = listmodel.get(lv.currentIndex).date

                        //-- trigger sub category list --//
                        returnSelectedMaterial(txf_categories_categoryID.text)

                        //-- set collapse label text to current Item --//
                        lbl1.text = ""
                                + (isIdShow           ? txf_categories_categoryID.text            : "")
                                + (isMaterialCategoryShow ? "  " + txf_categories_materialCategory.text   : "")
                                + (isTitleShow        ? "  " + txf_categories_title.text          : "")
                                + (isPicShow          ? "  " + txf_categories_pic.text            : "")
                                + (isDateShow         ? "  " + txf_categories_date.text           : "")
                    }

                    highlight: Rectangle { color: "lightsteelblue"; radius: 2 }
                    focus: true

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

            //-- spliter --//
            Rectangle{Layout.fillWidth:  true; Layout.preferredHeight: 1; color: "#e5e5e5"; visible: isExpand}

            //-- TextFields --//
            Item{
                Layout.fillWidth:  true
                Layout.preferredHeight: _isEditable ?
                                            txf_categories_categoryID.implicitHeight * (visibleItmCount+2.2)
                                          : lblSize.implicitHeight * 2
                visible: isExpand

                //-- size porpose --//
                Label{
                    id: lblSize
                    font.pixelSize: Qt.application.font.pixelSize
                    text: "test"
                    visible: false
                }

                ColumnLayout{
                    anchors.fill: parent

                    //-- expander button --//
                    Button{
                        text: _isEditable ? MdiFont.Icon.menu_down : MdiFont.Icon.menu_up
                        font.pixelSize: Qt.application.font.pixelSize * 2
                        font.family: font_material.name
                        Layout.fillWidth: true
                        Layout.preferredHeight: lblSize.implicitHeight * 2
                        flat: true
                        down: true
                        onClicked: {
                            _isEditable = !_isEditable
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: _isEditable

                        GridLayout{
                            anchors.fill: parent

                            rows: 7
                            columns: 2

                            //-- Serach --//
                            SearchField{
                                id: txf_categories_search

                                Layout.row: 0
                                Layout.column: 1
                                Layout.columnSpan: 2
                                Layout.fillWidth: true

                                onAcceptedText: {

                                    //-- search based on title --//

                                    var endpoint = "api/kootwall/Material?q=" + text

                                    Service.get_all( endpoint, function(resp, http) {
                                        log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

                                        //-- check ERROR --//
                                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                                        {
                                            log("error detected; " + resp.error)
                                            message.text = resp.error
                                            triggerMsg(resp.error, "RED")
                                            return

                                        }

                                        listmodel.clear()

                                        for(var i=0; i<resp.length; i++) {
                                            listmodel.append(resp[i])
                                            listmodel.setProperty(i, "isSelected", false)
                                            listmodel.setProperty(i, "orderSelected", -1)
                                        }

                                        //-- triger subcategory list --//
                                        returnSelectedMaterial(listmodel.get(lv.currentIndex).id)

                                        message.text = "searched data recived"
                                        triggerMsg("جست و جو انجام شد", "LOG")
                                    })
                                }
                            }


                            //-- MaterialCategoryID --//
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

                                placeholderText: "شماره شناسایی"
                                enabled: false
                            }

                            //-- Category --//
                            Label{
                                visible: isMaterialCategoryShow
                                Layout.row: 2
                                Layout.column: 2
                                Layout.alignment: Qt.AlignRight

                                text: "دسته والد:"
                            }
                            TextField{
                                id: txf_categories_materialCategory
                                visible: isMaterialCategoryShow
                                Layout.row: 2
                                Layout.column: 1

                                placeholderText: "عنوان دسته والد"
                                selectByMouse: true
                                enabled: false
                            }

                            //-- title --//
                            Label{
                                visible: isTitleShow
                                Layout.row: 3
                                Layout.column: 2
                                Layout.alignment: Qt.AlignRight

                                text: "عنوان:"
                            }
                            TextField{
                                id: txf_categories_title
                                visible: isTitleShow
                                Layout.row: 3
                                Layout.column: 1

                                placeholderText: "عنوان"
                                selectByMouse: true
                                onAccepted: btnCategoriesAdd.clicked()
                            }

                            //-- pic --//
                            Label{
                                visible: isPicShow
                                Layout.row: 4
                                Layout.column: 2
                                Layout.alignment: Qt.AlignRight

                                text: "تصویر:"
                            }
                            TextField{
                                id: txf_categories_pic
                                visible: isPicShow
                                Layout.row: 4
                                Layout.column: 1

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

                                placeholderText: "تاریخ"
                                selectByMouse: true
                            }

                            //-- filler --//
                            Item {
                                Layout.row: 6
                                Layout.column: 1
                                Layout.fillHeight: true

                            }
                        }

                    }

                }

            }

            //-- spliter --//
            Rectangle{Layout.fillWidth:  true; Layout.preferredHeight: 1; color: "#e5e5e5"; visible: isExpand}

            //-- buttons --//
            Item{
                Layout.fillWidth:  true
                Layout.preferredHeight: btnCategoriesAdd.implicitHeight * 1
                visible: isExpand && _isEditable

                RowLayout{
                    anchors.fill: parent

                    //-- reorder --//
                    MButton{
                        id: btnReorder

                        property bool isDirty: false
                        property int orderCntr: 0

                        visible: isAdminPermission
                        Layout.fillWidth: true
                        icons: MdiFont.Icon.sort
                        tooltip: "مرتب سازی"

                        state: "WAIT"

                        states: [
                            State {
                                name: "WAIT"
                                PropertyChanges {
                                    target: btnReorder
                                    isDown: false
                                }
                                PropertyChanges {
                                    target: lblTitle
                                    text: "عنوان"
                                    Material.foreground: "Black"
                                }
                            },
                            State {
                                name: "SELECT"
                                PropertyChanges {
                                    target: btnReorder
                                    isDown: true
                                }
                                PropertyChanges {
                                    target: lblTitle
                                    text: "پس از انتخاب کلیک کنید"
                                    Material.foreground: Material.Green
                                }
                            },
                            State {
                                name: "MOVE"
                                PropertyChanges {
                                    target: btnReorder
                                    isDown: true
                                }
                                PropertyChanges {
                                    target: lblTitle
                                    text: "مقصد را انتخاب کنید"
                                    Material.foreground: Material.Red
                                }
                            }

                        ]

                        onClicked: {
                            if(btnReorder.state === "WAIT"){
                                btnReorder.state = "SELECT"
                            }
                            else{
                                btnReorder.state = "WAIT"

                                //--  check MOVE state passed --//
                                if(btnReorder.isDirty){

                                    //-- init dirty flag --//
                                    btnReorder.isDirty = false

                                    var list = ""
                                    for(var i=0; i<listmodel.count; i++){

                                        list += listmodel.get(i).id + ":" + fillZero(i, _zeroFillLenght) + "_"
                                    }

                                    //--clear last underline --//
                                    if(i>0) list = list.substring(0,list.length-1)

                                    //-- validate inpute --//
                                    if(isNaN(parentCatId)){
                                        log("invalid categoryID")
                                        return
                                    }

                                    //-- search based on categoryID --//
                                    var endpoint = "api/kootwall/Material?c=" + parentCatId + "&list=" + list

                                    Service.get_all( endpoint, function(resp, http) {
                                        log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

                                        //-- check ERROR --//
                                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                                        {
                                            log("error detected; " + resp.error)
                                            message.text = resp.error
                                            triggerMsg(resp.error, "RED")
                                            return

                                        }

                                        listmodel.clear()

                                        for(var i=0; i<resp.length; i++) {
                                            listmodel.append(resp[i])
                                            listmodel.setProperty(i, "isSelected", false)
                                            listmodel.setProperty(i, "orderSelected", -1)
                                        }

                                        //-- triger selected item when new models fetched --//
                                        if(listmodel.count > 0){

                                            root.state = "FILL"

                                            lv.currentIndex = -1 //-- trigger current index --//
                                            lv.currentIndex = 0
                                            log("--- FILL ----")

                                            //-- trigger sub category list --//
                                            returnSelectedMaterial(listmodel.get(lv.currentIndex).id)
                                        }
                                        else{

                                            root.state = "EMPTY"
                                            log("--- EMPTY ----")

                                            //-- trigger sub category list --//
                                            returnSelectedMaterial("empty")
                                        }

                                        message.text = "searched data recived"
                                        triggerMsg("جست و جو انجام شد", "LOG")
                                    })

                                }
                            }
                        }

                        //-- fill zero --//
                        //--num: im=nteger, len: filled num len with zero; 0012: len=4 --//
                        function fillZero(num, len){

                            var ss=""
                            ss = num.toString()
                            var l = ss.length

                            var res = ""

                            for(var i=0; i<len-l; i++) res = res + "0"

                            res = res + ss

//                            log("num = " + num + ", len = " + len + " => res = " + res)
                            return res
                        }
                    }

                    //-- get --//
                    MButton{
                        id: btnCategoriesGet
                        visible: false
                        Layout.fillWidth: true
                        icons: MdiFont.Icon.arrow_down_bold_circle_outline //"Get"
                        tooltip: "بارگذاری"

                        onClicked: {

                            var endpoint = "api/kootwall/Material"

                            Service.get_all( endpoint, function(resp, http) {
                                log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                //-- check ERROR --//
                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                {
                                    log("error detected; " + resp.error)
                                    message.text = resp.error
                                    triggerMsg(resp.error, "RED")
                                    return

                                }

                                listmodel.clear()

                                for(var i=0; i<resp.length; i++) {
                                    listmodel.append(resp[i])
                                    listmodel.setProperty(i, "isSelected", false)
                                    listmodel.setProperty(i, "orderSelected", -1)
                                }

                                message.text = "all data recived"
                                triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                            })
                        }

                    }

                    //-- add --//
                    MButton{
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

                            //-- check parent ID field --//
                            if(txf_categories_materialCategory.text === ""){
                                log("parent ID is empty")
                                message.text = "parent ID is empty"
                                triggerMsg("در شاخه فصول اصلی آیتمی انتخاب نشده است", "RED")
                                return
                            }

                            //-- send data --//
                            var data = {
                                "title"             : txf_categories_title.text,
                                "materialCategory"  : txf_categories_materialCategory.text,
//                                "pic"               : txf_categories_pic.text,
                                "orderNum"          : listmodel.count
                            }

                            //-- verify token --//
                            checkToken(function(resp){

                                //-- token expire, un logined user --//
                                if(!resp){
                                    message.text = "access denied"
                                    triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                    return
                                }


                                var endpoint = "api/kootwall/Material"

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


                                    listmodel.append(resp)
                                    listmodel.setProperty(lv.count-1, "isSelected", false)
                                    lv.currentIndex = lv.count-1
                                    message.text = "Item created"
                                    triggerMsg("عنوان جدید ایجاد شد", "LOG")

                                    //-- log activity --//
                                    logActivity(_ACTIVITY_CREATE, _MATERIAL, ("عنوانی جدید در بخش 2 ایجاد شد: " + txf_categories_title.text))

                                    //-- clear text fields --//
                                    clearCategoriesTextfields()


                                })
                            })



                        }
                    }

                    //-- edit --//
                    MButton{
                        Layout.fillWidth: true
                        icons: MdiFont.Icon.pencil //"Edit"
                        tooltip: "ویرایش"

                        onClicked: {

                            if(listmodel.count == 0){
                                log("model is empty")
                                message.text = "model is empty"
                                triggerMsg("آیتمی برای تغیر وجود ندارد", "RED")
                                return
                            }

                            if(txf_categories_categoryID.text === ""){
                                log("select one item, pleaze")
                                message.text = "select one item, pleaze"
                                triggerMsg("لطفا ابتدا عنصر موردنظر را انتخاب کنید", "RED")
                                return
                            }

                            if(txf_categories_title.text === listmodel.get(lv.currentIndex).title){
                                log("cant detect any change")
                                message.text = "cant detect any change"
                                triggerMsg("تغییری در عنوان ایجاد نشده است", "BLUE")
                                return
                            }

                            editWin.show()

                        }

                        EditWin{
                            id: editWin

                            mainPage: root.parent

                            onConfirm: {

                                var data = {
                                    "title"             : txf_categories_title.text,
                                    "materialCategory"  : txf_categories_materialCategory.text,
//                                    "pic"               : txf_categories_pic.text
                                }

                                var clickedIndex = lv.currentIndex

                                //-- verify token --//
                                checkToken(function(resp){

                                    //-- token expire, un logined user --//
                                    if(!resp){
                                        message.text = "access denied"
                                        triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                        return
                                    }

                                    //-- can use gridModel.get(lview.currentIndex).url --//
                                    var endpoint = "api/kootwall/Material/" + listmodel.get(clickedIndex).id + "/"

                                    Service.update_item(_token_access, endpoint, data, function(resp, http) {

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

                                        var txt = resp.title
                                        if(txt.indexOf("This title has already been used") > -1){

                                            message.text = "This title has already been used"
                                            triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                            return
                                        }

                                        listmodel.setProperty(clickedIndex, 'title', resp.title)
                                        listmodel.setProperty(clickedIndex, 'pic',   resp.pic)

                                        message.text = "Item updated"
                                        triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")

                                        //-- log activity --//
                                        logActivity(_ACTIVITY_UPDATE, _MATERIAL, ("به روز رسانی عنوان در بخش 2: " + txf_categories_title.text))

                                    })
                                })
                            }
                        }
                    }

                    //-- json parse problem --//
                    //-- delete --//
                    MButton{
                        visible: isAdminPermission
                        Layout.fillWidth: true
                        icons: MdiFont.Icon.delete_ //"Delete"
                        tooltip: "حذف"

                        onClicked: {

                            if(listmodel.count == 0){
                                log("model is empty")
                                message.text = "model is empty"
                                triggerMsg("آیتمی برای حذف وجود ندارد", "RED")
                                return
                            }

                            if(txf_categories_categoryID.text === ""){
                                log("select one item, pleaze")
                                message.text = "select one item, pleaze"
                                triggerMsg("لطفا ابتدا عنصر موردنظر را انتخاب کنید", "RED")
                                return
                            }

                            delWin.show()

                        }

                        DeleteWin{
                            id: delWin

                            mainPage: root.parent

                            onConfirm: {

                                var clickedIndex = lv.currentIndex

                                //-- verify token --//
                                checkToken(function(resp){

                                    //-- token expire, un logined user --//
                                    if(!resp){
                                        message.text = "access denied"
                                        triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                        return
                                    }
                                    //-- can use gridModel.get(lview.currentIndex).url --//
                                    var endpoint = "api/kootwall/Material/" + listmodel.get(clickedIndex).id + "/"

                                    Service.delete_item(_token_access, endpoint, function(resp, http) {

                                        log( "state = " + http.status + " " + http.statusText + ', /n handle delete resp: ' + JSON.stringify(resp))

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

                                        //-- delete json parser --//
                                        if(resp.hasOwnProperty('del')) // chack exist detail in resp
                                        {
                                            if(resp.del.indexOf("successfull delete operation") > -1){

                                                //-- log activity --//
                                                logActivity(_ACTIVITY_DELETE, _MATERIAL, ("حذف عنوان در بخش 2: " + txf_categories_title.text))


                                                listmodel.remove(clickedIndex, 1)

                                                //-- triger subcategory list --//
                                                if(lv.count>0)
                                                    returnSelectedMaterial(listmodel.get(clickedIndex).id)
                                                else returnSelectedMaterial("empty")

                                                //-- clear TextField --//
                                                clearCategoriesTextfields()
                                            }

                                            //-- handle token expire --//
                                            //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                            message.text = resp.del
                                            triggerMsg(resp.del, "LOG")
                                        }



                                    })

                                })
                            }
                        }
                    }
                }

            }

            //-- collapse mode --//
            Item {
                visible: !isExpand
                Layout.fillHeight: true
                Layout.preferredWidth: 40

                ItemDelegate{

                    anchors.fill: parent

                    font.pixelSize: Qt.application.font.pixelSize

                    //- back color --//
                    Rectangle{anchors.fill: parent; color: "#33000000"}

                    ColumnLayout{
                        anchors.fill: parent


                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#00FF0000"
                            Label{
                                id: lbl1
                                anchors.centerIn: parent
                                text: ""
                                /*text: ""
                                      + (isIdShow           ? txf_categories_categoryID.text            : "")
                                      + (isMaterialCategoryShow ? "  " + txf_categories_materialCategory.text   : "")
                                      + (isTitleShow        ? "  " + txf_categories_title.text          : "")
                                      + (isPicShow          ? "  " + txf_categories_pic.text            : "")
                                      + (isDateShow         ? "  " + txf_categories_date.text           : "")*/
                                rotation: 90
                            }
                        }

                    }

                    onClicked: {
                        isExpand = true
                    }
                }

            }

            //-- status bar --//
            Label{
                id: message
                visible: isExpand && _isEditable && isShowStatus

                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight * 1.2

                background: Rectangle{color: "#99000000"}

                text: "status"
                color: "#ffffff"

            }
        }

    }

    //-- fetch data based on MaterialCategoryId --//
    function fetchBasedonMaterialCategory(categoryID){

        //-- validate inpute --//
        if(isNaN(categoryID)){
            log("invalid categoryID")
            return
        }


        //-- search based on categoryID --//
        var endpoint = "api/kootwall/Material?c=" + categoryID

        Service.get_all( endpoint, function(resp, http) {
            log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
                message.text = resp.error
                triggerMsg(resp.error, "RED")
                return

            }

            listmodel.clear()

            for(var i=0; i<resp.length; i++) {
                listmodel.append(resp[i])
                listmodel.setProperty(i, "isSelected", false)
                listmodel.setProperty(i, "orderSelected", -1)
            }

            //-- triger selected item when new models fetched --//
            if(listmodel.count > 0){

                root.state = "FILL"

                lv.currentIndex = -1 //-- trigger current index --//
                lv.currentIndex = 0
                log("--- FILL ----")

                //-- trigger sub category list --//
                returnSelectedMaterial(listmodel.get(lv.currentIndex).id)
            }
            else{

                root.state = "EMPTY"
                log("--- EMPTY ----")

                //-- trigger sub category list --//
                returnSelectedMaterial("empty")
            }

            message.text = "searched data recived"
            triggerMsg("جست و جو انجام شد", "LOG")
        })

    }

    //-- clear all text of esit section --//
    function clearCategoriesTextfields(){
        if(isIdShow             && txf_categories_categoryID.enabled)       txf_categories_categoryID.text  = ""
        if(isDateShow           && txf_categories_date.enabled)             txf_categories_date.text        = ""
        if(isPicShow            && txf_categories_pic.enabled)              txf_categories_pic.text         = ""
        if(isTitleShow          && txf_categories_title.enabled)            txf_categories_title.text       = ""
        if(isMaterialCategoryShow   && txf_categories_materialCategory.enabled)     txf_categories_materialCategory.text    = ""
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

