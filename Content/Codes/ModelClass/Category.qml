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

    //    signal setedIndex(int categoryID)

    //-- send selected Item to sub category --//
    signal returnSelectedCategory(string categoryID)

    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)

    //-- double click for open add production win --//
    signal openAddProduct()

    signal fetchCatsFromDB()
    onFetchCatsFromDB: {

        log("start to fecth data: ")
        //        dataSource.categories_getAll()
        btnCategoriesGet.clicked()
    }

    //-- select new index in listview externaly --//
    function selectNewItemBasedonID(catID, cb){

        log("--- start to search categories; " + catID)
        var flagFound = false
        for(var i=0; i< listmodel.count && !flagFound; i++){

            log(catID + "==" + listmodel.get(i).id)
            if(catID === listmodel.get(i).id.toString()){

                lv_categories.currentIndex = i
                flagFound = true
                log("founded, index = " + i)
            }
        }

        if(cb) cb()
    }


    property string pageTitle:              "فهرست بها" //-- modul header title --//
    property bool   isExpand:               true        //-- keep Expand mode status --//
    property bool   isShowStatus:           false       //-- show/hide status bar --//
    property int    headerUnExpandHeight:   100         //-- header height in unExpanded mode --//
    property int    maxItmWidth:            200         //-- maximum width of module --//
    property bool   isLogEnabled:           true        //-- global log permission --//
    property alias  modelItm:               listmodel   //-- scategory ListModel --//
    property alias  selModelIndx:           lv_categories.currentIndex //-- listview current index --//

    //-- handle Expand mode status --//
    onIsExpandChanged: {

        log("lv_categories.currentIndex = " + lv_categories.currentIndex)
        log("lv_categories.count = " + lv_categories.count)
        //-- check current index of list view --//
        if(lv_categories.count > 0 /*&& lv_categories.currentIndex < 0*/){

            var temp = lv_categories.currentIndex
            lv_categories.currentIndex = -1
            lv_categories.currentIndex = temp

        }
    }

    property bool   _isEditable:            false  //-- allow user to edit text Item --//
    property bool   _localLogPermission:    true   //-- local log permission --//
    property int    _zeroFillLenght:        5      //-- lenght of number in ordering for filled with zero --//

    //-- show permission for database items --//
    property bool isIdShow       : false
    property bool isTitleShow    : true
    property bool isPicShow      : false
    property bool isDateShow     : false
    property int  visibleItmCount: 1        //-- hold visible item count for size porpose (in edit win height) --//

    objectName: "Category"
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
                    id: lv_categories

                    anchors.fill: parent

                    ScrollBar.vertical: ScrollBar {
                        id: control
                        size: 0.1
                        position: 0.2
                        active: true
                        orientation: Qt.Vertical
                        policy: listmodel.count>(lv_categories.height/40) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                        contentItem: Rectangle {
                            implicitWidth: 6
                            implicitHeight: 100
                            radius: width / 2
                            color: control.pressed ? "#aa32aaba" : "#5532aaba"
                        }
                    }

                    highlightMoveDuration: contentHeight/1

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
                            text: model.orderNum //!= "undefined" ? model.orderNum : "-1"
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

                                log("moving to " + index )

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

                                lv_categories.currentIndex = index
                            }
                        }

                        onDoubleClicked: {
                            //-- open addProduct window --//
                            openAddProduct()
                        }


                    }


                    onCurrentIndexChanged:{
                        //                    log("lv_categories.currentIndex = " + lv_categories.currentIndex)

                        txf_categories_categoryID.text  = listmodel.get(currentIndex).id
                        txf_categories_title.text       = listmodel.get(currentIndex).title
                        txf_categories_pic.text         = ""//listmodel.get(currentIndex).pic
                        txf_categories_date.text        = listmodel.get(currentIndex).date

                        //                            setedIndex(parseInt(txf_categories_categoryID.text))
                        returnSelectedCategory(listmodel.get(lv_categories.currentIndex).id)
                    }

                    highlight: Rectangle { color: "lightsteelblue"; radius: 2 }
                    focus: true

                    // some fun with transitions :-)
                    add: Transition {
                        // applied when entry is added
                        NumberAnimation {
                            properties: "x"; from: -lv_categories.width;
                            duration: 250;
                        }
                    }
                    remove: Transition {
                        // applied when entry is removed
                        NumberAnimation {
                            properties: "x"; to: lv_categories.width;
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
//                        text: _isEditable ? MdiFont.Icon.arrow_down_drop_circle_outline : MdiFont.Icon.arrow_up_drop_circle_outline
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

                            rows: 6
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

                                    var endpoint = "api/kootwall/Category?q=" + text

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
                                        returnSelectedCategory(listmodel.get(lv_categories.currentIndex).id)

                                        message.text = "searched data recived"
                                        triggerMsg("جست و جو انجام شد", "LOG")
                                    })
                                }

                            }

                            //-- CategoryID --//
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

                            //-- title --//
                            Label{
                                visible: isTitleShow
                                Layout.row: 2
                                Layout.column: 2
                                Layout.alignment: Qt.AlignRight

                                text: "عنوان:"
                            }
                            TextField{
                                id: txf_categories_title
                                visible: isTitleShow
                                Layout.row: 2
                                Layout.column: 1

                                placeholderText: "عنوان دسته بندی"
                                selectByMouse: true
                                onAccepted: btnCategoriesAdd.clicked()
                            }

                            //-- pic --//
                            Label{
                                visible: isPicShow
                                Layout.row: 3
                                Layout.column: 2
                                Layout.alignment: Qt.AlignRight

                                text: "تصویر:"
                            }
                            TextField{
                                id: txf_categories_pic
                                visible: isPicShow
                                Layout.row: 3
                                Layout.column: 1

                                placeholderText: "آدرس تصویر"
                                selectByMouse: true
                            }

                            //-- date --//
                            Label{
                                visible: isDateShow
                                Layout.row: 4
                                Layout.column: 2
                                Layout.alignment: Qt.AlignRight

                                text: "تاریخ:"
                            }
                            TextField{
                                id: txf_categories_date
                                visible: isDateShow
                                Layout.row: 4
                                Layout.column: 1

                                placeholderText: "تاریخ"
                                selectByMouse: true
                            }

                            //-- filler --//
                            Item {
                                Layout.row: 5
                                Layout.column: 2
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

                                    log("list = "+ list)

                                    //-- send request to server --//
                                    var endpoint = "api/kootwall/Category?list=" + list

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
//                        visible: false
                        Layout.fillWidth: true
                        icons: MdiFont.Icon.refresh //"Get"
                        tooltip: "بارگذاری"

                        onClicked: {

                            var endpoint = "api/kootwall/Category"

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

                                //-- save fetched data to global category listmodel --//
                                lm_category = listmodel

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

                            //-- send data --//
                            var data = {
                                "title": txf_categories_title.text,
//                                "pic": txf_categories_pic.text,
                                "orderNum": listmodel.count
                            }

                            var clickedIndex = lv_categories.currentIndex

                            //-- verify token --//
                            checkToken(function(resp){

                                //-- token expire, un logined user --//
                                if(!resp){
                                    message.text = "access denied"
                                    triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                    return
                                }


                                var endpoint = "api/kootwall/Category"

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
                                        triggerMsg(resp.detail, "LOG")
                                        return
                                    }

                                    var txt = resp.title
                                    if(txt.indexOf("This title has already been used") > -1){

                                        message.text = "This title has already been used"
                                        triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                        return
                                    }

                                    //-- add item to global category listmodel --//
                                    lm_category.append(resp)


                                    listmodel.append(resp)
                                    listmodel.setProperty(lv_categories.count-1, "isSelected", false)
                                    lv_categories.currentIndex = lv_categories.count-1
                                    message.text = "Item created"
                                    triggerMsg("عنوان جدید ایجاد شد", "LOG")

                                    //-- log activity --//
                                    logActivity(_ACTIVITY_CREATE, _CATEGORY, ("عنوانی جدید در فهرست بها ایجاد شد: " + txf_categories_title.text))

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

                            if(txf_categories_title.text === listmodel.get(lv_categories.currentIndex).title){
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
                                    "title": txf_categories_title.text,
//                                    "pic": txf_categories_pic.text
                                }

                                var clickedIndex = lv_categories.currentIndex

                                //-- verify token --//
                                checkToken(function(resp){

                                    //-- token expire, un logined user --//
                                    if(!resp){
                                        message.text = "access denied"
                                        triggerMsg("لطفا ابتدا ورود کنید", "RED")
                                        return
                                    }

                                    //-- can use gridModel.get(lview.currentIndex).url --//
                                    var endpoint = "api/kootwall/Category/" + listmodel.get(clickedIndex).id + "/"

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
                                            triggerMsg(resp.detail, "LOG")
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

                                        //-- edit global category listmodel --//
                                        lm_category.setProperty(clickedIndex, 'title', resp.title)
                                        lm_category.setProperty(clickedIndex, 'pic',   resp.pic)



                                        message.text = "Item updated"
                                        triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")

                                        //-- log activity --//
                                        logActivity(_ACTIVITY_UPDATE, _CATEGORY, ("به روز رسانی عنوان در فهرست بها: " + txf_categories_title.text))

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

//                            if(txf_categories_categoryID.text === ""){
                            if(lv_categories.currentIndex < 0){
                                log("select one item, pleaze")
                                message.text = "select one item, pleaze"
                                triggerMsg("ابتدا عنصر موردنظر را انتخاب کنید", "RED")
                                return
                            }

                            delWin.show()

                        }
                    }

                    DeleteWin{
                        id: delWin

                        mainPage: root.parent

                        onConfirm: {


                            var clickedIndex = lv_categories.currentIndex

                            //-- verify token --//
                            checkToken(function(resp){

                                //-- token expire, un logined user --//
                                if(!resp){
                                    message.text = "access denied"
                                    triggerMsg("لطفا ابتدا ورود کنید", "RED")
                                    return
                                }
                                //-- can use gridModel.get(lview.currentIndex).url --//
                                var endpoint = "api/kootwall/Category/" + listmodel.get(clickedIndex).id + "/"

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
                                            logActivity(_ACTIVITY_DELETE, _CATEGORY, ("حذف عنوان در فهرست بها: " + txf_categories_title.text))

                                            listmodel.remove(clickedIndex, 1)

                                            //-- remove item from global category listmodel --//
                                            lm_category.remove(clickedIndex, 1)

                                            //-- triger subcategory list --//
                                            if(lv_categories.count>0)
                                                returnSelectedCategory(listmodel.get(clickedIndex).id)
                                            else returnSelectedCategory("empty")

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
                                      + (isIdShow    ? txf_categories_categoryID.text      : "")
                                      + (isTitleShow ? "  " + txf_categories_title.text    : "")
                                      + (isPicShow   ? "  " + txf_categories_pic.text      : "")
                                      + (isDateShow  ? "  " + txf_categories_date.text     : "")
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

    //-- clear all text of esit section --//
    function clearCategoriesTextfields(){
        txf_categories_categoryID.text  = ""
        txf_categories_date.text        = ""
        txf_categories_pic.text         = ""
        txf_categories_title.text       = ""
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

    // REST code in js
    //https://gist.github.com/EtienneR/2f3ab345df502bd3d13e

    //-- django rest auth
    //https://simpleisbetterthancomplex.com/tutorial/2018/12/19/how-to-use-jwt-authentication-with-django-rest-framework.html


    //-- TEST for tocken check --//
    Rectangle{
        visible: false
        width: parent.width
        height: 200

        ColumnLayout{
            anchors.fill: parent

            Button{
                text: "checked access token"
                onClicked: {

                    //-- verify token --//
                    verifyToken(_token_access, function(resp) {

                        log("checked done; " + resp)
                    })
                }
            }

            Button{
                text: "checked refferesh token"
                onClicked: {

                    //-- verify token --//
                    verifyToken(_token_refresh, function(resp) {

                        log("checked done; " + resp)
                    })
                }
            }

            Button{
                text: "refferesh"
                onClicked: {

                    //-- verify token --//
                    checkToken(function(resp){

                        log("checked done")
                    })
                }
            }
        }
    }
}

