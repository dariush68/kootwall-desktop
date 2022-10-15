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

    //-- visible window --//
    signal openWin()
    onOpenWin:{

        //-- load companies list from DataBase --//
//        btnCategoriesGet.clicked()
        btnCatGet.clicked()

        filter_user.searchUser("")
        btnCategoriesGet.clicked()
    }

    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)
    onTriggerMsg: {
        msgHandler.show(msg, alarmType)
    }

    property string pageTitle:      "مدیریت فعالیت ها"   //-- modul header title --//
    property bool   isLogEnabled:   true       //-- global log permission --//
    property bool   isShowStatus:   false      //-- show/hide status bar --//
    property variant _resp                     //-- global recieved JSON data --//
    property int lvPageSize      :   30        //--page size of ListView elements --//
    property int lvPageSizeOffset:   0          //-- offset for Switch to other pages --//


    property bool   _localLogPermission:    true   //-- local log permission --//
    property bool   _isEditable        :    true   //-- allow user to edit text Item --//
    property string _savedDate         :    ""     //-- save last searched date --//
    property variant lastSearchRessault            //-- save lase JSON file of search date resault --//


    //-- show permission for editable items --//
    property bool isIdShow          : false
    property bool isUserShow        : false
    property bool isDateShow        : false
    property bool isActionShow      : true
    property bool isSectionShow     : true
    property bool isDescriptionShow : true
    property bool isApproveShow     : true

    //-- show permission for listvie items --//
    property bool lv_isIdShow          : false
    property bool lv_isUserShow        : true
    property bool lv_isDateShow        : true
    property bool lv_isActionShow      : true
    property bool lv_isSectionShow     : true
    property bool lv_isDescriptionShow : true
    property bool lv_isApproveShow     : true
    property int  visibleItmCount      : 6     //-- hold visible item count for size porpose (in edit win height) --//

    //-- width size porpos --//
    property real slot: (lvSection.width -20) / visibleItmCount //-- (-20) for margins --/
    property int _widthID           : slot * 1
    property int _widthUser         : slot * 1
    property int _widthAction       : slot * 0.5
    property int _widthSection      : slot * 1
    property int _widthDate         : slot * 1
    property int _widthDescription  : slot * 2
    property int _widthApprove      : slot * 0.5


    objectName: "ActivityLogger"
    color: "#FFFFFF"
    radius: 3
    border{width: 1; color: "#999e9e9e"}


    /*Component.onCompleted: {

        filter_user.searchUser("")
        btnCategoriesGet.clicked()
    }*/

    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name

        RowLayout{
            anchors.fill: parent
            spacing: 0

            //-- edit item (invisible) --//
            Rectangle{
                visible: false
                Layout.fillHeight: true
                Layout.preferredWidth: 200
                Layout.margins: 5
                color: "#FFFFFF"

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
                ColumnLayout{
                    id: colEdit
                    anchors.fill: parent
                    anchors.margins: 10


                    //-- TextFields --//
                    Pane{
                        id: paneTxts

                        Layout.fillWidth:  true
                        Layout.fillHeight: true

                        font.pixelSize: Qt.application.font.pixelSize

                        //-- size porpose --//
                        Label{
                            id: lblSize
                            font.pixelSize: Qt.application.font.pixelSize
                            text: "test"
                            visible: false
                        }

                        ColumnLayout{
                            anchors.fill: parent

                            Flickable{
                                id: flickEdit

                                contentHeight: txf_activity_ID.implicitHeight * (7)

                                ScrollBar.vertical: ScrollBar {
                                    id: control
                                    size: 0.1
                                    position: 0.2
                                    active: true
                                    orientation: Qt.Vertical
//                                    policy: flickEdit.contentHeight > flickEdit.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                    contentItem: Rectangle {
                                        implicitWidth: 6
                                        implicitHeight: 100
                                        radius: width / 2
                                        color: control.pressed ? "#aa32aaba" : "#2232aaba"
                                    }
                                }

                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: _isEditable
                                clip: true

                                GridLayout{
                                    anchors.fill: parent

                                    rows: 16
                                    columns: 2

                                    //-- Serach --//
                                    SearchField{
                                        id: txf_activity_search

                                        Layout.row: 0
                                        Layout.column: 1
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true

                                        onAcceptedText: {


                                            //-- verify token --//
                                            checkToken(function(resp){

                                                //-- search based on title --//
                                                var endpoint = "api/kootwall/ActivityLog?q=" + text

                                                Service.get_all_users(_token_access, endpoint, function(resp, http) {
                                                    log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

                                                    //-- check ERROR --//
                                                    if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                    {
                                                        log("error detected; " + resp.error)
                                                        message.text = resp.error
                                                        triggerMsg(resp.error, "RED")
                                                        return

                                                    }

                                                    //-- sort based on date --//
                                                    var sortedData = sortBaseonDate(resp)

                                                    listmodel.clear()

                                                    for(var i=0; i<sortedData.length; i++) {
                                                        listmodel.append(sortedData[i])

                                                        var dd = sortedData[i].activityDate
                                                        var list = dd.split("T")
                                                        var date = list[0]
                                                        var temp = list[1].split(":")
                                                        var time = temp[0] + ":" + temp[1]

                                                        listmodel.setProperty(i, "activityDate", (date + " " + time))
                                                        listmodel.setProperty(i,"isSelected", false)
                                                    }

                                                    message.text = "searched data recived"
                                                    triggerMsg("جست و جو انجام شد", "LOG")
                                                })
                                            })
                                        }
                                    }

                                    //-- activity ID --//
                                    Label{
                                        id: lbl_activityId
                                        visible: isIdShow
                                        Layout.row: 1
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "شماره:"
                                    }
                                    TextField{
                                        id: txf_activity_ID
                                        visible: isIdShow
                                        Layout.row: 1
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "شماره شناسایی"
                                        enabled: false
                                    }

                                    //-- user --//
                                    Label{
                                        visible: isUserShow
                                        Layout.row: 3
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "کاربر:"
                                    }

                                    TextField{
                                        id: txf_activity_user
                                        visible: isUserShow
                                        Layout.row: 3
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "کاربر"
                                        selectByMouse: true
                                    }

                                    //-- action --//
                                    Label{
                                        visible: isActionShow
                                        Layout.row: 4
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "عملیات:"
                                    }
                                    TextField{
                                        id: txf_activity_action
                                        visible: isActionShow
                                        Layout.row: 4
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "عملیات"
                                        selectByMouse: true
                                    }

                                    //-- section --//
                                    Label{
                                        visible: isSectionShow
                                        Layout.row: 5
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "بخش:"
                                    }
                                    TextField{
                                        id: txf_activity_section
                                        visible: isSectionShow
                                        Layout.row: 5
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "بخش"
                                        selectByMouse: true
                                    }

                                    //-- date --//
                                    Label{
                                        visible: isDateShow
                                        Layout.row: 6
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "تاریخ:"
                                    }
                                    TextField{
                                        id: txf_activity_date
                                        visible: isDateShow
                                        Layout.row: 6
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "تاریخ"
                                        selectByMouse: true
                                    }

                                    //-- description --//
                                    Label{
                                        visible: isDescriptionShow
                                        Layout.row: 7
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "توضیحات:"
                                    }
                                    TextField{
                                        id: txf_activity_description
                                        visible: isDescriptionShow
                                        Layout.row: 7
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "توضیحات"
                                        selectByMouse: true
                                        wrapMode: Text.Wrap
                                    }

                                    //-- approvement --//
                                    Label{
                                        visible: isApproveShow
                                        Layout.row: 8
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "تایید:"
                                    }
                                    TextField{
                                        id: txf_activity_approve
                                        visible: isApproveShow
                                        Layout.row: 8
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "تایید"
                                        selectByMouse: true
                                    }

                                    //-- filler --//
                                    Item {
                                        Layout.row: 9
                                        Layout.column: 2
                                        Layout.fillHeight: true

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
                        visible: _isEditable

                        RowLayout{
                            anchors.fill: parent

                            //-- get --//
                            MButton{
                                id: btnCategoriesGet
//                                visible: false
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.arrow_down_bold_circle_outline //"Get"
                                tooltip: "بارگذاری"

                                onClicked: {

//                                    var d = new Date();
//                                    var dd = "2019-04-22T18:19:58.011615Z"
//                                    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];


                                    //-- verify token --//
                                    checkToken(function(resp){

                                        var endpoint = "api/kootwall/activity-list-generic-view/"

                                        Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                                            log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                            //-- check ERROR --//
                                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                                            {
                                                log("error detected; " + resp.error)
                                                message.text = resp.error
                                                triggerMsg(resp.error, "RED")
                                                return

                                            }

                                            _resp = resp

                                            listmodel_category.clear()

                                            for(var i=0; i<resp.length; i++) {
                                                listmodel_category.append(resp[i])

                                            }

                                            message.text = "all data recived"
                                            triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                        })

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
                                    if(txf_activity_action.text === ""){
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
                                        //-- send data --//
                                        var data = {
                                            "action"        : txf_activity_action.text      ,
                                            "description"   : txf_activity_description.text ,
                                            "approve"       : txf_activity_approve.text,
                                            "user"          : _userName
                                        }
                                        d1.push(data)

                                        var sendData = {
                                            "ordered_meals": d1,
                                            "title": currentDate()
                                        }

                                        log("sendData = " + JSON.stringify(sendData))

//                                        var endpoint = "api/kootwall/ActivityLog"
                                        var endpoint = "api/kootwall/activity-create-generic-view/"

                                        Service.create_item(_token_access, endpoint, sendData, function(resp, http) {

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

                                            if(resp.hasOwnProperty('title')) // chack exist detail in resp
                                            {
                                                var txt = resp.title
                                                if(txt.indexOf("This title has already been used") > -1){

                                                    message.text = "This title has already been used"
                                                    triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                    return
                                                }
                                            }


                                            listmodel_category.append(resp)
                                            lv_category.currentIndex = lv_category.count-1
                                            message.text = "Item created"
                                            triggerMsg("عنوان جدید ایجاد شد", "LOG")

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

                                    //-- chech existense of dirty chenge (check any CheckBox clicked) --//
                                    if(!lvSection.isCheckBoxDirty) return

                                    lvSection.isCheckBoxDirty = false

                                    var sendData

                                    //-- verify token --//
                                    checkToken(function(resp){

                                        var endpoint = "api/kootwall/activity-list-generic-view?n=" + listmodel_category.get(lv_category.currentIndex).title

                                        Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                                            log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                            //-- check ERROR --//
                                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                                            {
                                                log("error detected; " + resp.error)
                                                message.text = resp.error
                                                triggerMsg(resp.error, "RED")
                                                return

                                            }


                                            for(var i=0; i<resp[0].ordered_meals.length; i++) {

                                                for(var j=0; j< listmodel.count; j++){

                                                    if(resp[0].ordered_meals[i].id == listmodel.get(j).id){
                                                        resp[0].ordered_meals[i].approve = listmodel.get(j).approve

                                                        break
                                                    }
                                                }
                                            }

                                            sendData = resp[0]


                                            //-- update item --//

                                            log("sendData update = " + JSON.stringify(sendData), true)

                                            var endpoint = "api/kootwall/activity-update-mixin/" + resp[0].id

                                            Service.update_item(_token_access, endpoint, sendData, function(resp_update, http) {

                                                log( "state = " + http.status + " " + http.statusText + ', /n handle update resp_update: ' + JSON.stringify(resp_update))

                                                //-- check ERROR --//
                                                if(resp_update.hasOwnProperty('error')) // chack exist error in resp_update
                                                {
                                                    log("error detected; " + resp_update.error)
                                                    message.text = resp_update.error
                                                    triggerMsg(resp_update.error, "RED")
                                                    return

                                                }

                                                //-- Authentication --//
                                                if(resp_update.hasOwnProperty('detail')) // chack exist detail in resp_update
                                                {
                                                    if(resp_update.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                        message.text = "Authentication credentials were not provided"
                                                        triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                        return
                                                    }

                                                    //-- handle token expire --//
                                                    //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                    message.text = resp_update.detail
                                                    triggerMsg(resp_update.detail, "RED")
                                                    return
                                                }

                                                if(resp_update.hasOwnProperty('title')) // chack exist title in resp_update
                                                {
                                                    var txt = resp_update.title
                                                    if(txt.indexOf("This title has already been used") > -1){

                                                        message.text = "This title has already been used"
                                                        triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                        return
                                                    }
                                                }

                                                _resp[lv_category.currentIndex] = sendData

                                                message.text = "Item updated"
                                                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")
                                                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "BLUE")

                                            })


                                            message.text = "all data recived"
                                            triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                        })

                                    })


                                }

                            }

                            //-- json parse problem --//
                            //-- delete --//
                            MButton{
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.delete_ //"Delete"
                                tooltip: "حذف"

                                onClicked: {


                                    delWin.show()

                                }

                                DeleteWin{
                                    id: delWin

                                    mainPage: root.parent

                                    onConfirm: {


                                        //-- chech existense of dirty chenge (check any CheckBox clicked) --//
                                        if(!lvSection.isCheckBoxDirty) return

                                        lvSection.isCheckBoxDirty = false

                                        var sendData

                                        //-- verify token --//
                                        checkToken(function(resp){

                                            var endpoint = "api/kootwall/activity-list-generic-view?n=" + listmodel_category.get(lv_category.currentIndex).title

                                            Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                                                log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                                //-- check ERROR --//
                                                if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                {
                                                    log("error detected; " + resp.error)
                                                    message.text = resp.error
                                                    triggerMsg(resp.error, "RED")
                                                    return

                                                }


                                                var resTemp = []
                                                for(var i=0; i<resp[0].ordered_meals.length; i++) {

                                                    var isFind = false
                                                    for(var j=0; j< listmodel.count; j++){

//                                                        log(resp[0].ordered_meals[i].id + "==" + listmodel.get(j).id)
                                                        if(resp[0].ordered_meals[i].id == listmodel.get(j).id
                                                                && listmodel.get(j).approve == true){
//                                                            resp[0].ordered_meals[i].approve = listmodel.get(j).approve
                                                            isFind = true

                                                            break
                                                        }
                                                    }

                                                    if(!isFind) resTemp.push(resp[0].ordered_meals[i])

                                                }

//                                                log("resTemp = " + resTemp)

                                                resp[0].ordered_meals = resTemp
                                                sendData = resp[0]


                                                //-- update item --//

                                                log("sendData update = " + JSON.stringify(sendData))

                                                var endpoint = "api/kootwall/activity-update-mixin/" + resp[0].id

                                                Service.update_item(_token_access, endpoint, sendData, function(resp_update, http) {

                                                    log( "state = " + http.status + " " + http.statusText + ', /n handle update resp_update: ' + JSON.stringify(resp_update))

                                                    //-- check ERROR --//
                                                    if(resp_update.hasOwnProperty('error')) // chack exist error in resp_update
                                                    {
                                                        log("error detected; " + resp_update.error)
                                                        message.text = resp_update.error
                                                        triggerMsg(resp_update.error, "RED")
                                                        return

                                                    }

                                                    //-- Authentication --//
                                                    if(resp_update.hasOwnProperty('detail')) // chack exist detail in resp_update
                                                    {
                                                        if(resp_update.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                            message.text = "Authentication credentials were not provided"
                                                            triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                            return
                                                        }

                                                        //-- handle token expire --//
                                                        //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                        message.text = resp_update.detail
                                                        triggerMsg(resp_update.detail, "RED")
                                                        return
                                                    }

                                                    if(resp_update.hasOwnProperty('title')) // chack exist title in resp_update
                                                    {
                                                        var txt = resp_update.title
                                                        if(txt.indexOf("This title has already been used") > -1){

                                                            message.text = "This title has already been used"
                                                            triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                            return
                                                        }
                                                    }

                                                    _resp[lv_category.currentIndex] = sendData

                                                    //-- remove checked item from listmodel --//
                                                    for(var j=listmodel.count-1; j>= 0; j--){

                                                        if(listmodel.get(j).approve == true){
                                                            listmodel.remove(j)
                                                        }
                                                    }

                                                    message.text = "Item updated"
                                                    triggerMsg("عملیات حذف با موفقیت انجام شد", "LOG")
                                                    triggerMsg("عملیات حذف با موفقیت انجام شد", "BLUE")

                                                })


                                                message.text = "all data recived"
                                                triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                            })

                                        })

                                        return
                                        //-- delete cat filter item --//
                                        //-- verify token --//
                                        checkToken(function(resp){

                                            //-- token expire, un logined user --//
                                            if(!resp){
                                                message.text = "access denied"
                                                triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                                return
                                            }

//                                            log("id = " + listmodel_category.get(lv_category.currentIndex).id)

                                            //-- can use gridModel.get(lview.currentIndex).url --//
//                                            var endpoint = "api/kootwall/ActivityLog/" + listmodel.get(lv.currentIndex).id + "/"
                                            var endpoint = "api/kootwall/activity/" + listmodel_category.get(lv_category.currentIndex).id

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

                                                        listmodel_category.remove(lv_category.currentIndex, 1)
                                                    }

                                                    //-- handle token expire --//
                                                    //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                    message.text = resp.del
                                                    triggerMsg(resp.del, "LOG")

                                                    //-- clear all textfileds --//
                                                    clearCategoriesTextfields()
                                                }



                                            })

                                        })
                                    }
                                }
                            }
                        }

                    }

                    //-- status bar --//
                    Label{
                        id: message
                        visible: _isEditable && isShowStatus

                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight * 1.2

                        background: Rectangle{color: "#99000000"}

                        text: "status"
                        color: "#ffffff"

                    }


                }
            }


            //-- filters and ListView --//
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.leftMargin: 5

                ColumnLayout{
                    anchors.fill: parent

                    //-- filter item --//
                    Rectangle{
                        id: filters

                        Layout.preferredHeight: 250
                        Layout.fillWidth: true
                        Layout.margins: 5
                        Layout.leftMargin: 0
                        Layout.bottomMargin: 0
                        color: "#FFFFFF"

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

                        RowLayout{
                            anchors.fill: parent

                            //-- filler --//
                            Item{Layout.fillWidth: true}

                            //-- user filter --//
                            GroupBox{
                                id: filter_user

                                Layout.fillHeight: true
                                Layout.minimumWidth: 150
                                Layout.fillWidth: true
                                Layout.margins: 5
                                title: "فیلتر کاربر"


                                //-- body --//
                                ColumnLayout{
                                    anchors.fill: parent

                                    //-- Serach --//
                                    SearchField{
                                        id: txf_user_search

                                        Layout.fillWidth: true

                                        onAcceptedText: {
                                            filter_user.searchUser(text)
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
                                            spacing: 0

                                            //-- user --//
                                            Item{
                                                visible: lv_isUserShow
                                                Layout.fillWidth: true
                                                Label{
                                                    id: lbl_user2
                                                    text: "کاربر"
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                    }

                                    //-- ListView --//
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true


                                        ListModel{
                                            id: listmodel_users
                                        }

                                        ListView{
                                            id: lv_users

                                            anchors.fill: parent

                                            ScrollBar.vertical: ScrollBar {
                                                id: control4
                                                size: 0.1
                                                position: 0.2
                                                active: true
                                                orientation: Qt.Vertical
                                                policy: listmodel_users.count>(lv_users.height/30) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                                contentItem: Rectangle {
                                                    implicitWidth: 6
                                                    implicitHeight: 100
                                                    radius: width / 2
                                                    color: control4.pressed ? "#aa32aaba" : "#5532aaba"
                                                }

                                            }

                                            model: listmodel_users

                                            delegate: ItemDelegate{

                                                width: parent.width
                                                height: 30

                                                font.pixelSize: Qt.application.font.pixelSize
                                                Material.foreground: "#5e5e5e"

                                                Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                                RowLayout{
                                                    anchors.fill: parent
                                                    anchors.margins: 3

                                                    //-- user --//
                                                    TxtItmOfListView{
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        txt:{

                                                           var user = model.username
                                                            if(user === "ALL USER") return "تمامی کاربران"
                                                            else return user
                                                        }
                                                    }

                                                }

                                                //-- spliter --//
                                                Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                                MouseArea{
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        log("current user = " + index)

                                                        lv_users.currentIndex = index

                                                        //-- fetch data from DB based of filtered items --//
                                                        filteredFetch()
                                                    }
                                                }


                                            }


                                            onCurrentIndexChanged:{

                                                log("lv_users.currentIndex = " + lv_users.currentIndex)

                                                //-- controll count of listview --//
                                                if(lv_users.count < 1) return

                                                //-- controll currentIndex of listview --//
                                                if(lv_users.currentIndex < 0) return
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

                                }

                                //-- search users --//
                                function searchUser(searchtxt){

                                    //-- verify token --//
                                    checkToken(function(resp){

                                        //-- search based on title --//
                                        var endpoint = "api/kootwall/Users?q=" + searchtxt

                                        Service.get_all_users(_token_access, endpoint, function(resp, http) {
                                            log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

                                            //-- check ERROR --//
                                            if(resp.hasOwnProperty('error')) // chack exist error in resp
                                            {
                                                log("error detected; " + resp.error)
                                                message.text = resp.error
                                                triggerMsg(resp.error, "RED")
                                                return

                                            }

                                            listmodel_users.clear()

                                            listmodel_users.append({
                                                                   "username": "ALL USER"
                                                                   })

                                            for(var i=0; i<resp.length; i++) {
                                                listmodel_users.append(resp[i])
                                            }

                                            message.text = "searched data recived"
                                            triggerMsg("جست و جو انجام شد", "LOG")
                                        })
                                    })
                                }

                            }

                            //-- operation filter --//
                            GroupBox{
                                id: filter_operation

                                Layout.fillHeight: true
                                Layout.minimumWidth: lblSizeOperation.implicitWidth + 20
                                Layout.fillWidth: true
                                Layout.margins: 5
                                title: "فیلتر عملیات"

                                Label{ id: lblSizeOperation; text: "تمامی عملیات"; visible: false }

                                //-- body --//
                                ColumnLayout{
                                    anchors.fill: parent

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

                                            //-- user --//
                                            Item{
                                                visible: lv_isUserShow
                                                Layout.fillWidth: true
                                                Label{
                                                    text: "عملیات"
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                    }

                                    //-- ListView --//
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true

                                        ListModel{
                                            id: listmodel_operation

                                            ListElement{
                                                title: "تمامی عملیات"
                                                operetion: "ALLOPERATION"
                                            }

                                            ListElement{
                                                title: "افزودن"
                                                operetion: "CREATE"
                                            }

                                            ListElement{
                                                title: "ویرایش"
                                                operetion: "UPDATE"
                                            }

                                            ListElement{
                                                title: "حذف"
                                                operetion: "DELETE"
                                            }
                                        }

                                        ListView{
                                            id: lv_operation

                                            anchors.fill: parent

                                            ScrollBar.vertical: ScrollBar {
                                                id: control5
                                                size: 0.1
                                                position: 0.2
                                                active: true
                                                orientation: Qt.Vertical
                                                policy: listmodel_operation.count>(lv_operation.height/30) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                                contentItem: Rectangle {
                                                    implicitWidth: 6
                                                    implicitHeight: 100
                                                    radius: width / 2
                                                    color: control5.pressed ? "#aa32aaba" : "#5532aaba"
                                                }

                                            }

                                            model: listmodel_operation

                                            delegate: ItemDelegate{

                                                width: parent.width
                                                height: 30

                                                font.pixelSize: Qt.application.font.pixelSize
                                                Material.foreground: "#5e5e5e"

                                                Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                                RowLayout{
                                                    anchors.fill: parent
                                                    anchors.margins: 3

                                                    //-- operation --//
                                                    TxtItmOfListView{
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        txt: model.title
                                                    }

                                                }

                                                //-- spliter --//
                                                Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                                MouseArea{
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        log("current operation = " + index)

                                                        lv_operation.currentIndex = index

                                                        //-- fetch data from DB based of filtered items --//
                                                        filteredFetch()

                                                    }
                                                }


                                            }

                                            highlight: Rectangle { color: "lightsteelblue"; radius: 2 }
                                            focus: true
                                        }

                                    }

                                }

                            }

                            //-- section filter --//
                            GroupBox{
                                id: filter_section

                                Layout.fillHeight: true
                                Layout.minimumWidth: lblSizeSection.implicitWidth + 10
                                Layout.fillWidth: true
                                Layout.margins: 5
                                title: "فیلتر بخش ها"

                                Label{ id: lblSizeSection; text: "مدیریت محصول ها"; visible: false }

                                //-- body --//
                                ColumnLayout{
                                    anchors.fill: parent

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

                                            //-- user --//
                                            Item{
                                                Layout.fillWidth: true
                                                Label{
                                                    text: "بخش ها"
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                    }

                                    //-- ListView --//
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true


                                        ListModel{
                                            id: listmodel_section

                                            ListElement{
                                                title: "تمامی بخش ها"
                                                section: "ALLSECTIONS"
                                            }

                                            ListElement{
                                                title: "مدیریت محصول ها"
                                                section: "COMPANYPRODUCT"
                                            }

                                            ListElement{
                                                title: "مدیریت شرکت ها"
                                                section: "COMPANY"
                                            }

                                            ListElement{
                                                title: "لیست فهرست بها"
                                                section: "CATEGORY"
                                            }

                                            ListElement{
                                                title: "لیست فصول اصلی"
                                                section: "BASECATEGORY"
                                            }

                                            ListElement{
                                                title: "لیست بخش 1"
                                                section: "CATEGORYMATERIAL"
                                            }

                                            ListElement{
                                                title: "لیست بخش 2"
                                                section: "MATERIAL"
                                            }

                                            ListElement{
                                                title: "لیست بخش 3"
                                                section: "SUBMATERIAL"
                                            }

                                            ListElement{
                                                title: "لیست بخش 4"
                                                section: "SUBSUBMATERIAL"
                                            }
                                        }

                                        ListView{
                                            id: lv_section

                                            anchors.fill: parent

                                            ScrollBar.vertical: ScrollBar {
                                                id: control6
                                                size: 0.1
                                                position: 0.2
                                                active: true
                                                orientation: Qt.Vertical
                                                policy: listmodel_section.count>(lv_section.height/30) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                                contentItem: Rectangle {
                                                    implicitWidth: 6
                                                    implicitHeight: 100
                                                    radius: width / 2
                                                    color: control6.pressed ? "#aa32aaba" : "#5532aaba"
                                                }

                                            }

                                            model: listmodel_section

                                            delegate: ItemDelegate{

                                                width: parent.width
                                                height: 30

                                                font.pixelSize: Qt.application.font.pixelSize
                                                Material.foreground: "#5e5e5e"

                                                Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                                RowLayout{
                                                    anchors.fill: parent
                                                    anchors.margins: 3

                                                    //-- operation --//
                                                    TxtItmOfListView{
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        txt: model.title
                                                    }

                                                }

                                                //-- spliter --//
                                                Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                                MouseArea{
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        log("current section = " + index)

                                                        lv_section.currentIndex = index

                                                        //-- fetch data from DB based of filtered items --//
                                                        filteredFetch()

                                                    }
                                                }


                                            }

                                            highlight: Rectangle { color: "lightsteelblue"; radius: 2 }
                                            focus: true
                                        }

                                    }

                                }

                            }

                            //-- approve filter --//
                            GroupBox{
                                id: filter_approve

                                Layout.fillHeight: true
                                Layout.minimumWidth: lblSizeapprove.implicitWidth + 10
                                Layout.fillWidth: true
                                Layout.margins: 5
                                title: "فیلتر بازبینی"

                                Label{ id: lblSizeapprove; text: "پیام های بررسی نشده"; visible: false }

                                //-- body --//
                                ColumnLayout{
                                    anchors.fill: parent

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

                                            //-- user --//
                                            Item{
                                                Layout.fillWidth: true
                                                Label{
                                                    text: "وضعیت بازبینی"
                                                    anchors.centerIn: parent
                                                }
                                            }
                                        }
                                    }

                                    //-- ListView --//
                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        clip: true


                                        ListModel{
                                            id: listmodel_approve

                                            ListElement{
                                                title: "تمامی پیام ها"
                                                status: "ALLAPPROVE"
                                            }

                                            ListElement{
                                                title: "پیام های بررسی نشده"
                                                status: "UNAPPROVED"
                                            }

                                            ListElement{
                                                title: "پیام های بررسی شده"
                                                status: "APPROVED"
                                            }
                                        }

                                        ListView{
                                            id: lv_approve

                                            anchors.fill: parent

                                            ScrollBar.vertical: ScrollBar {
                                                id: control7
                                                size: 0.1
                                                position: 0.2
                                                active: true
                                                orientation: Qt.Vertical
                                                policy: listmodel_approve.count>(lv_approve.height/30) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                                contentItem: Rectangle {
                                                    implicitWidth: 6
                                                    implicitHeight: 100
                                                    radius: width / 2
                                                    color: control7.pressed ? "#aa32aaba" : "#5532aaba"
                                                }

                                            }

                                            model: listmodel_approve

                                            delegate: ItemDelegate{

                                                width: parent.width
                                                height: 30

                                                font.pixelSize: Qt.application.font.pixelSize
                                                Material.foreground: "#5e5e5e"

                                                Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                                RowLayout{
                                                    anchors.fill: parent
                                                    anchors.margins: 3

                                                    //-- operation --//
                                                    TxtItmOfListView{
                                                        Layout.fillWidth: true
                                                        Layout.fillHeight: true
                                                        txt: model.title
                                                    }

                                                }

                                                //-- spliter --//
                                                Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                                MouseArea{
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        log("current approve = " + index)

                                                        lv_approve.currentIndex = index

                                                        //-- fetch data from DB based of filtered items --//
                                                        filteredFetch()

                                                    }
                                                }


                                            }

                                            highlight: Rectangle { color: "lightsteelblue"; radius: 2 }
                                            focus: true
                                        }

                                    }

                                }

                            }

                        }
                    }


                    //-- listview item --//
                    Rectangle{
                        id: lvSection

                        property bool isCheckBoxDirty: false

                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.margins: 5
                        Layout.leftMargin: 0
                        Layout.topMargin: 0
                        color: "#FFFFFF"

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
                        ColumnLayout{
                            anchors.fill: parent
                            anchors.margins: 10

                            //-- table header and GET/ADD/EDIT buttons --//
                            Button{
                                Layout.fillWidth: true
                                text: pageTitle
                                flat: true
                                down: true

                                //-- get/add/edit buttons --//
                                RowLayout{
                                    height: parent.height
                                    width: 100
                                    anchors.left: parent.left
                                    anchors.margins: 2

                                    //-- get(referesh) --//
                                    MButton{
                                        id: btnCatGet

                                        Layout.fillHeight: true
                                        Layout.preferredWidth: height
                                        icons: MdiFont.Icon.refresh //"Get"
                                        tooltip: "بارگذاری"

                                        onClicked: {

        //                                    var d = new Date();
        //                                    var dd = "2019-04-22T18:19:58.011615Z"
        //                                    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

                                            //-- initial listvies currentIndexs --//
                                            lv_approve.currentIndex = 0
                                            lv_operation.currentIndex = 0
                                            lv_section.currentIndex = 0
                                            lv_users.currentIndex = 0
                                            lvPageSizeOffset = 0

                                            //-- verify token --//
                                            checkToken(function(resp){

//                                                var endpoint = "api/kootwall/activity-list-generic-view/"
                                                var endpoint = "api/kootwall/activity-list-generic-view?pageSize=" + lvPageSize

                                                Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                                                    log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                                    //-- check ERROR --//
                                                    if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                    {
                                                        log("error detected; " + resp.error)
                                                        message.text = resp.error
                                                        triggerMsg(resp.error, "RED")
                                                        return

                                                    }

                                                    _resp = resp

                                                    listmodel_category.clear()

                                                    for(var i=0; i<resp.length; i++) {
                                                        listmodel_category.append(resp[i])

                                                    }

                                                    //-- sort based on date --//
                                                    var sortedData = sortBaseonDate(_resp[0].ordered_meals)

                                                    //-- clear and fill listmodel of detail active --//
                                                    listmodel.clear()

                                                    for(var i=0; i< sortedData.length; i++){

                                                        listmodel.append(sortedData[i])

                                                        var dd = sortedData[i].activityDate
                                                        var list = dd.split("T")
                                                        var date = list[0]
                                                        var temp = list[1].split(":")
                                                        var time = temp[0] + ":" + temp[1]

                                                        listmodel.setProperty(i, "activityDate", (date + " " + time))
                                                        listmodel.setProperty(i,"isSelected", false)

                                                    }

                                                    message.text = "all data recived"
                                                    triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")

                                                    filter_user.searchUser("")
                                                })

                                            })
                                        }

                                    }

                                    //-- edit/Confirm --//
                                    MButton{
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: height
                                        icons: MdiFont.Icon.check
                                        visible: lvSection.isCheckBoxDirty
                                        tooltip: "تایید"

                                        onClicked: {

                                            //-- chech existense of dirty chenge (check any CheckBox clicked) --//
                                            if(!lvSection.isCheckBoxDirty) return

                                            lvSection.isCheckBoxDirty = false

                                            var sendData

                                            //-- verify token --//
                                            checkToken(function(resp){

                                                var endpoint = "api/kootwall/activity-list-generic-view?n=" + listmodel_category.get(lv_category.currentIndex).title

                                                Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                                                    log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                                    //-- check ERROR --//
                                                    if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                    {
                                                        log("error detected; " + resp.error)
                                                        message.text = resp.error
                                                        triggerMsg(resp.error, "RED")
                                                        return

                                                    }


                                                    for(var j=0; j< listmodel.count; j++){

                                                        if(listmodel.get(j).isSelected){

                                                            for(var i=0; i<resp[0].ordered_meals.length; i++) {

                                                                if(resp[0].ordered_meals[i].id == listmodel.get(j).id){
                                                                    resp[0].ordered_meals[i].approve = true

                                                                    break
                                                                }
                                                            }
                                                        }
                                                    }

                                                    /*for(var i=0; i<resp[0].ordered_meals.length; i++) {

                                                        for(var j=0; j< listmodel.count; j++){

                                                            if(resp[0].ordered_meals[i].id == listmodel.get(j).id){
                                                                resp[0].ordered_meals[i].approve = listmodel.get(j).approve

                                                                break
                                                            }
                                                        }
                                                    }
                                                    listmodel.setProperty(i,"isSelected", checked)*/

                                                    sendData = resp[0]


                                                    //-- update item --//

                                                    log("sendData update = " + JSON.stringify(sendData))//, true)

                                                    var endpoint = "api/kootwall/activity-update-mixin/" + resp[0].id

                                                    Service.update_item(_token_access, endpoint, sendData, function(resp_update, http) {

                                                        log( "state = " + http.status + " " + http.statusText + ', /n handle update resp_update: ' + JSON.stringify(resp_update))

                                                        //-- check ERROR --//
                                                        if(resp_update.hasOwnProperty('error')) // chack exist error in resp_update
                                                        {
                                                            log("error detected; " + resp_update.error)
                                                            message.text = resp_update.error
                                                            triggerMsg(resp_update.error, "RED")
                                                            return

                                                        }

                                                        //-- Authentication --//
                                                        if(resp_update.hasOwnProperty('detail')) // chack exist detail in resp_update
                                                        {
                                                            if(resp_update.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                                message.text = "Authentication credentials were not provided"
                                                                triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                                return
                                                            }

                                                            //-- handle token expire --//
                                                            //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                            message.text = resp_update.detail
                                                            triggerMsg(resp_update.detail, "RED")
                                                            return
                                                        }

                                                        if(resp_update.hasOwnProperty('title')) // chack exist title in resp_update
                                                        {
                                                            var txt = resp_update.title
                                                            if(txt.indexOf("This title has already been used") > -1){

                                                                message.text = "This title has already been used"
                                                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                                return
                                                            }
                                                        }

                                                        _resp[lv_category.currentIndex] = sendData


                                                        for(var i=0; i<listmodel.count; i++){

                                                            log("listmodel.get("+i+").isSelected = " + listmodel.get(i).isSelected, true)
                                                            if(listmodel.get(i).isSelected){
                                                                listmodel.setProperty(i, "approve", true)
                                                                listmodel.setProperty(i, "isSelected", false)
                                                            }
                                                        }

                                                        //-- deselect checkbox all --//
                                                        chbx_allItem.checked = false


                                                        message.text = "Item updated"
                                                        triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")
                                                        triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "BLUE")

                                                    })


                                                    message.text = "all data recived"
                                                    triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                                })

                                            })


                                        }
                                    }

                                    //-- delete --//
                                    MButton{
                                        Layout.fillHeight: true
                                        Layout.preferredWidth: height
                                        icons: MdiFont.Icon.delete_ //"Delete"
                                        visible: lvSection.isCheckBoxDirty
                                        tooltip: "حذف"

                                        onClicked: {

                                            delSelectedWin.show()
                                        }

                                        DeleteWin{
                                            id: delSelectedWin

                                            mainPage: root.parent

                                            onConfirm: {


                                                //-- chech existense of dirty chenge (check any CheckBox clicked) --//
                                                if(!lvSection.isCheckBoxDirty) return

                                                lvSection.isCheckBoxDirty = false

                                                var sendData

                                                //-- verify token --//
                                                checkToken(function(resp){

                                                    var endpoint = "api/kootwall/activity-list-generic-view?n=" + listmodel_category.get(lv_category.currentIndex).title

                                                    Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                                                        log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                                        //-- check ERROR --//
                                                        if(resp.hasOwnProperty('error')) // chack exist error in resp
                                                        {
                                                            log("error detected; " + resp.error)
                                                            message.text = resp.error
                                                            triggerMsg(resp.error, "RED")
                                                            return

                                                        }

                                                        var resTemp = []
                                                        for(var i=0; i<resp[0].ordered_meals.length; i++) {

                                                            var isFind = false
                                                            for(var j=0; j< listmodel.count; j++){

                                                                //-- ignor unselected items --//
                                                                if(!listmodel.get(j).isSelected) continue

                                                                if(resp[0].ordered_meals[i].id == listmodel.get(j).id
                                                                        && listmodel.get(j).isSelected == true){

                                                                    isFind = true

                                                                    break
                                                                }
                                                            }

                                                            if(!isFind) resTemp.push(resp[0].ordered_meals[i])

                                                        }

        //                                                log("resTemp = " + resTemp)

                                                        resp[0].ordered_meals = resTemp
                                                        sendData = resp[0]


                                                        //-- update item --//

                                                        log("sendData update = " + JSON.stringify(sendData))

                                                        var endpoint = "api/kootwall/activity-update-mixin/" + resp[0].id

                                                        Service.update_item(_token_access, endpoint, sendData, function(resp_update, http) {

                                                            log( "state = " + http.status + " " + http.statusText + ', /n handle update resp_update: ' + JSON.stringify(resp_update))

                                                            //-- check ERROR --//
                                                            if(resp_update.hasOwnProperty('error')) // chack exist error in resp_update
                                                            {
                                                                log("error detected; " + resp_update.error)
                                                                message.text = resp_update.error
                                                                triggerMsg(resp_update.error, "RED")
                                                                return

                                                            }

                                                            //-- Authentication --//
                                                            if(resp_update.hasOwnProperty('detail')) // chack exist detail in resp_update
                                                            {
                                                                if(resp_update.detail.indexOf("Authentication credentials were not provided.") > -1){

                                                                    message.text = "Authentication credentials were not provided"
                                                                    triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                                                    return
                                                                }

                                                                //-- handle token expire --//
                                                                //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                                message.text = resp_update.detail
                                                                triggerMsg(resp_update.detail, "RED")
                                                                return
                                                            }

                                                            if(resp_update.hasOwnProperty('title')) // chack exist title in resp_update
                                                            {
                                                                var txt = resp_update.title
                                                                if(txt.indexOf("This title has already been used") > -1){

                                                                    message.text = "This title has already been used"
                                                                    triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                                    return
                                                                }
                                                            }

                                                            _resp[lv_category.currentIndex] = sendData

                                                            //-- remove checked item from listmodel --//
                                                            for(var j=listmodel.count-1; j>= 0; j--){

                                                                if(listmodel.get(j).isSelected == true){
                                                                    listmodel.remove(j)
                                                                }
                                                            }

                                                            message.text = "Item updated"
                                                            triggerMsg("عملیات حذف با موفقیت انجام شد", "LOG")
                                                            triggerMsg("عملیات حذف با موفقیت انجام شد", "BLUE")

                                                        })


                                                        message.text = "all data recived"
                                                        triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                                    })

                                                })

                                                return
                                                //-- delete cat filter item --//
                                                //-- verify token --//
                                                checkToken(function(resp){

                                                    //-- token expire, un logined user --//
                                                    if(!resp){
                                                        message.text = "access denied"
                                                        triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                                        return
                                                    }

        //                                            log("id = " + listmodel_category.get(lv_category.currentIndex).id)

                                                    //-- can use gridModel.get(lview.currentIndex).url --//
        //                                            var endpoint = "api/kootwall/ActivityLog/" + listmodel.get(lv.currentIndex).id + "/"
                                                    var endpoint = "api/kootwall/activity/" + listmodel_category.get(lv_category.currentIndex).id

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

                                                                listmodel_category.remove(lv_category.currentIndex, 1)
                                                            }

                                                            //-- handle token expire --//
                                                            //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                                                            message.text = resp.del
                                                            triggerMsg(resp.del, "LOG")

                                                            //-- clear all textfileds --//
                                                            clearCategoriesTextfields()
                                                        }



                                                    })

                                                })
                                            }
                                        }
                                    }
                                }


                                //-- page indicator --//
                                RowLayout{
                                    height: parent.height
                                    width: lbl_currentPages.implicitWidth + btn_previous.implicitWidth + btn_next.implicitWidth
                                    anchors.right: parent.right
                                    anchors.margins: 2

                                    //-- previous button --//
                                    MButton{
                                        id: btn_previous

                                        Layout.fillHeight: true
                                        Layout.preferredWidth: height
                                        icons: MdiFont.Icon.chevron_double_left
                                        tooltip: "صفحه قبل"
                                        flat: true
                                        enabled: lvPageSizeOffset > 0
                                        Material.background:"transparent"

                                        onClicked: {

                                            if(lvPageSizeOffset > 0){
                                                lvPageSizeOffset--
                                                filteredFetch()
                                            }
                                        }

                                    }

                                    Label{
                                        id: lbl_currentPages

                                        text: (lvPageSize*lvPageSizeOffset) + "-" + ((lvPageSize*(lvPageSizeOffset+1))-1)
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
                                        enabled: (lvPageSizeOffset+1) < (listmodel_category.get(lv_category.currentIndex).product_count / lvPageSize)
                                        Material.background:"transparent"

                                        onClicked: {

                                            if(lvPageSizeOffset >= 0){
                                                lvPageSizeOffset++
                                                filteredFetch()
                                            }
                                        }

                                    }

                                }

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
                                        visible: lv_isApproveShow
                                        Layout.preferredWidth: Math.max(lbl_approve.implicitWidth * 2, _widthApprove)
                                        Layout.fillHeight: true

                                        RowLayout{
                                            anchors.fill: parent

                                            CheckBox{
                                                id: chbx_allItem
                                                Layout.fillHeight: true
                                                Layout.margins: 3
                                                Material.accent : Util.color_kootwall_light //Material.BlueGrey

                                                onCheckedChanged: {

                                                    for(var i=0; i< listmodel.count; i++){

                                                        listmodel.setProperty(i,"isSelected", checked)
                                                    }

                                                    lvSection.isCheckBoxDirty = true
                                                }

                                            }
                                            Label{
                                                id: lbl_approve
                                                text: "تایید"
//                                                anchors.centerIn: parent
                                                Layout.alignment: Qt.AlignVCenter
                                            }
                                        }

                                    }

                                    //-- description --//
                                    Item{
                                        visible: lv_isDescriptionShow
                                        Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthDescription)
                                        Label{
                                            id: lbl_description
                                            text: "توضیحات"
                                            anchors.centerIn: parent
                                        }
                                    }

                                    //-- date --//
                                    Item{
                                        visible: lv_isDateShow
                                        Layout.preferredWidth: Math.max(lbl_date.implicitWidth * 2, _widthDate)
                                        Label{
                                            id: lbl_date
                                            text: "تاریخ"
                                            anchors.centerIn: parent
                                        }
                                    }

                                    //-- action --//
                                    Item{
                                        visible: lv_isActionShow
                                        Layout.preferredWidth: Math.max(lbl_action.implicitWidth * 2, _widthAction)
                                        Label{
                                            id: lbl_action
                                            text: "عملیات"
                                            anchors.centerIn: parent
                                        }
                                    }

                                    //-- section --//
                                    Item{
                                        visible: lv_isSectionShow
                                        Layout.preferredWidth: Math.max(lbl_section.implicitWidth * 2, _widthSection)
                                        Label{
                                            id: lbl_section
                                            text: "بخش"
                                            anchors.centerIn: parent
                                        }
                                    }

                                    //-- user --//
                                    Item{
                                        visible: lv_isUserShow
                                        Layout.preferredWidth: Math.max(lbl_user.implicitWidth * 2, _widthUser)
        //                                Layout.fillWidth: true
                                        Label{
                                            id: lbl_user
                                            text: "کاربر"
                                            anchors.centerIn: parent
                                        }
                                    }

                                    //-- activityID --//
                                    Item{
                                        visible: lv_isIdShow
                                        Layout.preferredWidth: Math.max(lbl_activityID.implicitWidth * 2, _widthID)
                                        Label{
                                            id: lbl_activityID
                                            text: "شماره"
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
                                        id: control2
                                        size: 0.1
                                        position: 0.2
                                        active: true
                                        orientation: Qt.Vertical
                                        policy: listmodel.count>(lv.height/40) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                        contentItem: Rectangle {
                                            implicitWidth: 6
                                            implicitHeight: 100
                                            radius: width / 2
                                            color: control2.pressed ? "#aa32aaba" : "#5532aaba"
                                        }

                                    }

                                    model: listmodel

                                    delegate: ItemDelegate{
                                        id: delegItm

                                        width: parent.width
                                        height: 40

                                        font.pixelSize: Qt.application.font.pixelSize
                                        Material.foreground: "#5e5e5e"

                                        Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                        RowLayout{
                                            anchors.fill: parent
                                            anchors.margins: 3

                                            //-- approve --//
                                            Item{
                                                visible: lv_isApproveShow
                                                Layout.preferredWidth: Math.max(lbl_approve.implicitWidth * 2, _widthApprove)
                                                Layout.fillHeight: true
                                                /*Label{
                                                    text: model.approve
                                                    anchors.centerIn: parent
                                                    width: Math.min(parent.width, implicitWidth)
                                                    elide: Text.ElideMiddle
                                                }
                                                CheckBox{
                                                    checked: model.approve
                                                    height: parent.height
                                                    anchors.margins: 3
                                                    Material.accent : Util.color_kootwall_light
                                                    onCheckedChanged: {

                                                    }
                                                }
                                                */

                                                RowLayout{
                                                    anchors.fill: parent

                                                    CheckBox{
                                                        Layout.fillHeight: true
                                                        Layout.margins: 3
                                                        Material.accent : Util.color_kootwall_light //Material.BlueGrey
                                                        checked: model.isSelected

                                                        onCheckedChanged: {

                                                            lvSection.isCheckBoxDirty = true
                                                            listmodel.setProperty(index,"isSelected", checked)
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

                                            //-- description --//
                                            TxtItmOfListView{
                                                visible: lv_isDescriptionShow
                                                Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthDescription)
                                                Layout.fillHeight: true
                                                txt: model.description
                                            }

                                            //-- date --//
                                            Item{
                                                visible: lv_isDateShow
                                                Layout.preferredWidth: Math.max(lbl_date.implicitWidth * 2, _widthDate)
                                                Label{
                                                    text: model.activityDate
                                                    anchors.centerIn: parent
                                                    width: Math.min(parent.width, implicitWidth)
                                                    elide: Text.ElideMiddle
                                                }
                                            }

                                            //-- action --//
                                            Item{
                                                visible: lv_isActionShow
                                                Layout.preferredWidth: Math.max(lbl_action.implicitWidth * 2, _widthAction)
                                                Label{
                                                    text:{
                                                        var act = model.action
                                                        if(act === "CREATE") return "افزودن"
                                                        else if(act === "UPDATE") return "ویرایش"
                                                        else if(act === "DELETE") return "حذف"
                                                    }
                                                    anchors.centerIn: parent
                                                    width: Math.min(parent.width, implicitWidth)
                                                    elide: Text.ElideMiddle
                                                }
                                            }

                                            //-- section --//
                                            Item{
                                                visible: lv_isSectionShow
                                                Layout.preferredWidth: Math.max(lbl_section.implicitWidth * 2, _widthSection)
                                                Label{
                                                    text:{
                                                        var sec = model.section
                                                        if(sec === "COMPANYPRODUCT") return "مدیریت محصول ها"
                                                        else if(sec === "COMPANY") return "مدیریت شرکت ها"
                                                        else if(sec === "CATEGORY") return "لیست فهرست بها"
                                                        else if(sec === "BASECATEGORY") return "لیست فصول اصلی"
                                                        else if(sec === "CATEGORYMATERIAL") return "لیست بخش 1"
                                                        else if(sec === "MATERIAL") return "لیست بخش 2"
                                                        else if(sec === "SUBMATERIAL") return "لیست بخش 3"
                                                        else if(sec === "SUBSUBMATERIAL") return "لیست بخش 4"
                                                    }
                                                    anchors.centerIn: parent
                                                    width: Math.min(parent.width, implicitWidth)
                                                    elide: Text.ElideMiddle
                                                }
                                            }

                                            //-- user --//
                                            TxtItmOfListView{
                                                visible: lv_isUserShow
        //                                        Layout.preferredWidth: Math.max(lbl_title.implicitWidth * 2, _widthTitle)
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true
                                                txt: model.user //model.hasOwnProperty('user') ? model.user.username : ""
                                            }

                                            //-- categoryID --//
                                            Item{
                                                visible: lv_isIdShow
                                                Layout.preferredWidth: Math.max(lbl_activityID.implicitWidth * 2, _widthID)
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

//                                        MouseArea{
//                                            anchors.fill: parent

                                            onClicked: {
                                                lv.currentIndex = index

                                                txf_activity_ID.text            = listmodel.get(lv.currentIndex).id
                                                txf_activity_action.text        = listmodel.get(lv.currentIndex).action
                                                txf_activity_section.text       = listmodel.get(lv.currentIndex).section
                                                txf_activity_approve.text       = listmodel.get(lv.currentIndex).approve
                                                txf_activity_date.text          = listmodel.get(lv.currentIndex).activityDate
                                                txf_activity_description.text   = listmodel.get(lv.currentIndex).description
                                                txf_activity_user.text          = listmodel.get(lv.currentIndex).user
                                            }
//                                        }


                                    }


                                    onCurrentIndexChanged:{

                                        log("lv.currentIndex = " + lv.currentIndex)

                                        //-- controll count of listview --//
                                        if(lv.count < 1) return

                                        //-- controll currentIndex of listview --//
                                        if(lv.currentIndex < 0) return
                                        txf_activity_ID.text            = listmodel.get(lv.currentIndex).id
                                        txf_activity_action.text        = listmodel.get(lv.currentIndex).action
                                        txf_activity_section.text       = listmodel.get(lv.currentIndex).section
                                        txf_activity_approve.text       = listmodel.get(lv.currentIndex).approve
                                        txf_activity_date.text          = listmodel.get(lv.currentIndex).activityDate
                                        txf_activity_description.text   = listmodel.get(lv.currentIndex).description
                                        txf_activity_user.text          = listmodel.get(lv.currentIndex).user
                                    }

//                                    highlight: Rectangle { color: "lightsteelblue"; radius: 2 }
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

                        }

                    }

                }

            }


            //-- Date listview item --//
            Rectangle{
                id: lvCategoryoSection

                Layout.fillHeight: true
                Layout.preferredWidth: 200
                Layout.margins: 5
                Layout.leftMargin: 0
                color: "#FFFFFF"

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
                ColumnLayout{
                    anchors.fill: parent
                    anchors.margins: 10

                    //-- table header --//
                    Button{
                        Layout.fillWidth: true
                        text: "تاریخ"
                        flat: true
                        down: true
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

                            Item { Layout.fillWidth: true } //-- filler --//

                            //-- date --//
                            Item{
                                Layout.fillWidth: true
                                Label{
                                    text: "تاریخ"
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
                            id: listmodel_category
                        }

                        ListView{
                            id: lv_category

                            anchors.fill: parent

                            ScrollBar.vertical: ScrollBar {
                                id: control3
                                size: 0.1
                                position: 0.2
                                active: true
                                orientation: Qt.Vertical
                                policy: listmodel_category.count>(lv_category.height/40) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

                                contentItem: Rectangle {
                                    implicitWidth: 6
                                    implicitHeight: 100
                                    radius: width / 2
                                    color: control3.pressed ? "#aa32aaba" : "#5532aaba"
                                }

                            }

                            model: listmodel_category

                            delegate: ItemDelegate{
                                id: delegItm2

                                width: parent.width
                                height: 40

                                font.pixelSize: Qt.application.font.pixelSize
                                Material.foreground: "#5e5e5e"

                                Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                //-- data --//
                                RowLayout{
                                    anchors.fill: parent
                                    anchors.margins: 3

                                    Item { Layout.fillWidth: true }

                                    //-- date --//
                                    Item{
                                        visible: lv_isDateShow
                                        Layout.preferredWidth: lblDateItm.implicitWidth
                                        Layout.fillHeight: true
                                        Label{
                                            id: lblDateItm
                                            text: model.groupedDate
                                            anchors.centerIn: parent
                                        }
                                    }
                                    //-- count --//
                                    Item{
                                        Layout.preferredWidth: countRec.width
                                        Layout.fillHeight: true

                                        Rectangle{
                                            id: countRec

                                            width: Math.max(lblCount.implicitWidth + 4, height)
                                            height: lblCount.implicitHeight + 4
                                            radius: height/2
                                            anchors.centerIn: parent
                                            color: "transparent"
                                            border{width: 1; color: "#665e5e5e"}

                                            Label{
                                                id: lblCount
                                                text: model.product_count
//                                                anchors.centerIn: parent
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                color: Util.color_kootwall_light
                                                font.pixelSize: Qt.application.font.pixelSize * 0.7
                                            }
                                        }
                                    }
                                    Item { Layout.fillWidth: true }


                                }

                                //-- spliter --//
                                Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                onClicked: {

//                                    if(index === lv_category.currentIndex) return


                                    lv_category.currentIndex = index

                                    log("id = " + listmodel_category.get(lv_category.currentIndex).id + ", index = " + index)//, true)

                                    //- decheck allcheck --//
                                    chbx_allItem.checked = false

                                    //-- clear listmodel of detail active --//
                                    listmodel.clear()

                                    //-- sort based on date --//
                                    var sortedData = sortBaseonDate(_resp[index].ordered_meals)

                                    for(var i=0; i< sortedData.length; i++){

                                        listmodel.append(sortedData[i])

                                        var dd = sortedData[i].activityDate
                                        log("date["+i+"]=" + dd)
                                        var list = dd.split("T")
                                        var date = list[0]
                                        var tempt = list[1].split(":")
                                        var time = tempt[0] + ":" + tempt[1]

                                        listmodel.setProperty(i, "activityDate", (date + " " + time))
                                        listmodel.setProperty(i,"isSelected", false)

                                        log("seted time = " + listmodel.get(i).activityDate)

                                    }

                                }


                            }


                            onCurrentIndexChanged:{

                                log("lv.currentIndex = " + lv_category.currentIndex)

                                //-- controll count of listview --//
                                if(lv_category.count < 1) return

                                //-- controll currentIndex of listview --//
                                if(lv_category.currentIndex < 0) return

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

                }
            }

        }
    }

    //-- message handler --//
    MsgPopup{
        id: msgHandler

    }

    //-- return current date --//
    function currentDate(){

        var d = new Date()

//        log("d = "+  d.toISOString())
        var dd =d.toISOString()
        var list = dd.split("T")
        var date = list[0]
        var temp = list[1].split(":")
        var time = temp[0] + ":" + temp[1]
//        log("date = " + date)

        return date
    }


    //-- add log activity externaly --//
    function addActivityLog(action, section, description, approve, user, callBack){

        var nowDate = currentDate()


        //-- verify token --//
        checkToken(function(resp){

            var endpoint = "api/kootwall/activity-list-generic-view?n=" + nowDate

            Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                //-- check ERROR --//
                if(resp.hasOwnProperty('error')) // chack exist error in resp
                {
                    log("error detected; " + resp.error)
                    message.text = resp.error
                    triggerMsg(resp.error, "RED")
                    return

                }

                /*_resp = resp

                listmodel_category.clear()

                for(var i=0; i<resp.length; i++) {
                    listmodel_category.append(resp[i])

                }*/

                log("res = " + resp + ", len = " + resp.length)

                //------------//
                //-- Update --//
                //------------//
                if(resp.length > 0){

                    var d1 = []

                    var data = {
                        "action"        : action      ,
                        "description"   : description ,
                        "approve"       : approve, //(approve == "False" ? false : true)     ,
                        "section"       : section,
                        "user"          : user
                    }
//                    var count = resp[0].ordered_meals.length
                    log("1 - last len = " + resp[0].ordered_meals.length + ", data = " + JSON.stringify(resp[0].ordered_meals[resp[0].ordered_meals.length-1]))
                    resp[0].ordered_meals.push(data)
                    log("2 - last len = " + resp[0].ordered_meals.length + ", data = " + JSON.stringify(resp[0].ordered_meals[resp[0].ordered_meals.length-1]))
                    var sendData = resp[0]                   

                    log("sendData update = " + JSON.stringify(sendData) + ", count = " + sendData.length)

                    var endpoint = "api/kootwall/activity-update-mixin/" + resp[0].id

                    Service.update_item(_token_access, endpoint, sendData, function(resp_update, http) {

                        log( "state = " + http.status + " " + http.statusText + ', /n handle update resp_update: ' + JSON.stringify(resp_update))

                        //-- check ERROR --//
                        if(resp_update.hasOwnProperty('error')) // chack exist error in resp_update
                        {
                            log("error detected; " + resp_update.error)
                            message.text = resp_update.error
                            triggerMsg(resp_update.error, "RED")
                            return

                        }

                        //-- Authentication --//
                        if(resp_update.hasOwnProperty('detail')) // chack exist detail in resp_update
                        {
                            if(resp_update.detail.indexOf("Authentication credentials were not provided.") > -1){

                                message.text = "Authentication credentials were not provided"
                                triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                return
                            }

                            //-- handle token expire --//
                            //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                            message.text = resp_update.detail
                            triggerMsg(resp_update.detail, "RED")
                            return
                        }

                        if(resp_update.hasOwnProperty('title')) // chack exist title in resp_update
                        {
                            var txt = resp_update.title
                            if(txt.indexOf("This title has already been used") > -1){

                                message.text = "This title has already been used"
                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                return
                            }
                        }


                        message.text = "Item updated"
                        triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")
                    })

                    //-- end Update --//
                }
                //------------//
                //-- create --//
                //------------//
                else{

                    var d1 = []
                    //-- send data --//
                    var data = {
                        "action"        : action      ,
                        "description"   : description ,
//                        "approve"       : approve     ,
                        "section"       : section,
                        "user"          : user
                    }
                    d1.push(data)

                    var sendData = {
                        "ordered_meals": d1,
                        "title": currentDate()
                    }

                    log("sendData to create = " + JSON.stringify(sendData), true)

                    var endpoint = "api/kootwall/activity-create-generic-view/"

                    Service.create_item(_token_access, endpoint, sendData, function(resp_create, http) {

                        log( "state = " + http.status + " " + http.statusText + ', /n handle creat resp_create: ' + JSON.stringify(resp_create))

                        //-- check ERROR --//
                        if(resp_create.hasOwnProperty('error')) // chack exist error in resp_create
                        {
                            log("error detected; " + resp_create.error)
                            message.text = resp_create.error
                            triggerMsg(resp_create.error, "RED")
                            return

                        }

                        //-- Authentication --//
                        if(resp_create.hasOwnProperty('detail')) // chack exist detail in resp_create
                        {
                            //-- invalid Authentication --//
                            if(resp_create.detail.indexOf("Authentication credentials were not provided.") > -1){

                                message.text = "Authentication credentials were not provided"
                                triggerMsg("احراز هویت موفقیت آمیز نبود", "RED")
                                return
                            }

                            //-- handle token expire --//
                            if(resp_create.detail.indexOf("Given token not valid for any token type") > -1){

                                message.text = "Given token not valid for any token type"
                                triggerMsg("لطفا با نام کاربرید و رمز عبور وارد شوید", "RED")
                                return
                            }

                            //{"detail":"Given token not valid for any token type","code":"token_not_valid","messages":[{"token_class":"AccessToken","token_type":"access","message":"Token is invalid or expired"}]}
                            message.text = resp_create.detail
                            triggerMsg(resp_create.detail, "RED")
                            return
                        }

                        if(resp_create.hasOwnProperty('title')) // chack exist detail in resp_create
                        {
                            var txt = resp_create.title
                            if(txt.indexOf("This title has already been used") > -1){

                                message.text = "This title has already been used"
                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                return
                            }
                        }

                        message.text = "Item created"
                        triggerMsg("عنوان جدید ایجاد شد", "LOG")



                    })

                    //-- end create --//
                }

                callBack()
            })

        })

    }


    //-- fetch DB based on selected filters --//
    function filteredFetch(){

        //-- SAVE CURRENT DATE  --//
        var currentDateIndex = lv_category.currentIndex
        log("saved currentDateIndex = " + currentDateIndex)

        //-- decheck chbx_allItem --//
        chbx_allItem.checked = false

        var user        = listmodel_users.get(lv_users.currentIndex).username
        var operation   = listmodel_operation.get(lv_operation.currentIndex).operetion
        var section     = listmodel_section.get(lv_section.currentIndex).section
        var approved    = listmodel_approve.get(lv_approve.currentIndex).status

        log("--user      = " + user      + "," +
            "operation = " + operation + "," +
            "section   = " + section   + "," +
            "approved  = " + approved === "UNAPPROVED" ? "False" : "True" )

        //-- verify token --//
        checkToken(function(resp){

//            var endpoint = "api/kootwall/activity-list-generic-view?"
            var endpoint = "api/kootwall/activity-list-generic-view?pageSize=" + lvPageSize + "&offset=" + lvPageSizeOffset + "&"

            if(user !== "ALL USER"){
                endpoint += "user=" + user
            }
            if(operation !== "ALLOPERATION"){
                if(user !== "ALL USER") endpoint += "&operation=" + operation
                else endpoint += "operation=" + operation
            }
            if(section !== "ALLSECTIONS"){
                 if(user !== "ALL USER" || operation !== "ALLOPERATION") endpoint += "&section=" + section
                 else endpoint += "section=" + section
            }
            if(approved !== "ALLAPPROVE"){
                if(user !== "ALL USER" || operation !== "ALLOPERATION" || section !== "ALLSECTION") endpoint += "&approve=" + (approved === "UNAPPROVED" ? "False" : "True")
                else endpoint += "approve=" + (approved === "UNAPPROVED" ? "False" : "True")
            }

            log("--endpoint = " + endpoint)

            Service.get_all_users(_token_access,  endpoint, function(resp, http) {
                log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                //-- check ERROR --//
                if(resp.hasOwnProperty('error')) // chack exist error in resp
                {
                    log("error detected; " + resp.error)
                    message.text = resp.error
                    triggerMsg(resp.error, "RED")
                    return

                }

                _resp = resp

                listmodel_category.clear()

                for(var i=0; i<resp.length; i++) {
                    listmodel_category.append(resp[i])

                }

                //-- sort data based on date --//
                var sortedData = sortBaseonDate(_resp[currentDateIndex].ordered_meals)

                //-- clear and fill listmodel of detail active --//
                listmodel.clear()
                for(var i=0; i< sortedData.length; i++){

                    listmodel.append(sortedData[i])

                    var dd = sortedData[i].activityDate
//                                        log("date["+i+"]=" + dd)
                    var list = dd.split("T")
                    var date = list[0]
                    var temp = list[1].split(":")
                    var time = temp[0] + ":" + temp[1]

                    listmodel.setProperty(i, "activityDate", (date + " " + time))
                    listmodel.setProperty(i,"isSelected", false)

                }

                //-- set current index to saved one --//
                lv_category.currentIndex = currentDateIndex

                message.text = "all data recived"
                triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
            })

        })
    }

    //-- sort array based on date --//
    function sortBaseonDate(itm){

        var temp = itm

        //-- sort based on date --//
        temp.sort(function(a,b){
          // Turn your strings into dates, and then subtract them
          // to get a value that is either negative, positive, or zero.
          return new Date(b.activityDate) - new Date(a.activityDate);
        });

        return temp
    }

    //-- clear all text of esit section --//
    function clearCategoriesTextfields(){
        if(isIdShow             && txf_activity_ID.enabled)             txf_activity_ID.text            = ""
        if(isDateShow           && txf_activity_date.enabled)           txf_activity_date.text          = ""
        if(isActionShow         && txf_activity_action.enabled)         txf_activity_action.text        = ""
        if(isApproveShow        && txf_activity_approve.enabled)        txf_activity_approve.text       = ""
        if(isUserShow           && txf_activity_user.enabled)           txf_activity_user.text          = ""
        if(isDescriptionShow    && txf_activity_description.enabled)    txf_activity_description.text   = ""
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
