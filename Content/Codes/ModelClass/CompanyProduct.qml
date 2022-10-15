import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.2
import "./../../font/Icon.js" as MdiFont
import "./../REST/apiservice.js" as Service
import "./../Utils"
import "./../Utils/Util.js" as Util


//-- Categories --//
Rectangle{
    id: root


    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)
    onTriggerMsg: {
        msgHandler.show(msg, alarmType)
    }

    //-- visible window --//
    signal openWin()
    onOpenWin:{

        //-- load categories list from DataBase --//
        //        btnCategoriesGet.clicked()
        itm_categories.selModelIndx = -1
        itm_categories.selModelIndx = 0

        itm_categories.loadCatsFromDB()
    }

    property string pageTitle:      "محصول ها"   //-- modul header title --//
    property bool   isLogEnabled:   true       //-- global log permission --//
    property bool   isShowStatus:   false      //-- show/hide status bar --//

    property bool    _isEditable:            true   //-- allow user to edit text Item --//
    property bool    _localLogPermission:    true   //-- local log permission --//
    property variant _resp
    property int     lvPageSize      :       10     //--page size of ListView elements --//
    property int     lvPageSizeOffset:       0      //-- offset for Switch to other pages --//

    //-- show permission for database items --//
    property bool isIdShow          : false
    property bool isTitleShow       : true
    property bool isPic1Show        : false
    property bool isDateShow        : false
    property bool isCatNavigateShow : false
    property bool isBranchShow      : root.width < 900 ? false : true
    property bool isCompanyShow     : false
    property bool isDescriptionShow : true
    property int  visibleItmCount   : root.width < 900 ? 2 : 3     //-- hold visible item count for size porpose (in edit win height) --//

    //-- width size porpos --//
    property real slot: (lvSection.width - 20) / visibleItmCount  //-- (-20) for row margin --//
    property int _widthID           : slot * 1
    property int _widthTitle        : slot * 1.2//
    property int _widthPic          : slot * 1
    property int _widthDate         : slot * 1
    property int _widthCatNavigate  : slot * 1//
    property int _widthCompany      : slot * 0.5
    property int _widthDescription  : slot * 0.8//

    objectName: "CompanyProduct"
    color: "#FFFFFF"
    radius: 3
    border{width: 1; color: "#999e9e9e"}


    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name

        //-- row of edit, ListView and filters --//
        RowLayout{
            anchors.fill: parent
            spacing: 0

            //-- edit item --//
            Rectangle{
                Layout.fillHeight: true
                Layout.preferredWidth: 400
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

                //-- texts/Btns and companyList --//
                RowLayout{
                    anchors.fill: parent
                    spacing: 0

                    //-- edit item --//
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 200

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

                                GridLayout{
                                    anchors.fill: parent

                                    rows: 10
                                    columns: 2

                                    //-- Serach --//
                                    SearchField{
                                        id: txf_categories_search

                                        Layout.row: 0
                                        Layout.column: 1
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true

//                                        onAcceptedText: {
                                        onEnteredText: {

                                            //-- search based on title --//
                                            fetchCompanyProduct(itm_categories.modelItm.get(itm_categories.selModelIndx).id)

/*
                                            var endpoint = "api/kootwall/CompanyProduct?q=" + text

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
                                                }

                                                message.text = "searched data recived"
                                                triggerMsg("جست و جو انجام شد", "LOG")
                                            })
                                            */
                                        }
                                    }

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

                                        text: "محصول:"
                                    }
                                    TextField{
                                        id: txf_categories_title
                                        visible: isTitleShow
                                        Layout.row: 3
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        readOnly: true
                                        placeholderText: "محصول"
                                        selectByMouse: true
                                        onAccepted: btnCategoriesAdd.clicked()
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

                                    //-- Branch id --//
                                    Label{
                                        visible: isCatNavigateShow
                                        Layout.row: 6
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "انشعاب:"
                                    }
                                    ItemDelegate {
                                        id: txf_categories_catNavigate
                                        visible: isCatNavigateShow
                                        Layout.row: 6
                                        Layout.column: 1
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: nav_category.implicitHeight * 9

                                        ColumnLayout{
                                            anchors.fill: parent
                                            spacing: 0

                                            //-- category --//
                                            ItemDelegate{
                                                opacity: nav_category.text === "" ? 0.0 : 1.0
                                                Layout.fillWidth: true
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_category
                                                    text: ""
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_baseCategory.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_down //arrow_down_thick
                                                Layout.alignment: Qt.AlignHCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- BaseCategory --//
                                            ItemDelegate{
                                                opacity: nav_baseCategory.text === "" ? 0.0 : 1.0
                                                Layout.fillWidth: true
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_baseCategory
                                                    text: ""
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_materialCategory.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_down //arrow_down_thick
                                                Layout.alignment: Qt.AlignHCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- MaterialCategory --//
                                            ItemDelegate{
                                                opacity: nav_materialCategory.text === "" ? 0.0 : 1.0
                                                Layout.fillWidth: true
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_materialCategory
                                                    text: ""
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_material.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_down //arrow_down_thick
                                                Layout.alignment: Qt.AlignHCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- Material --//
                                            ItemDelegate{
                                                opacity: nav_material.text === "" ? 0.0 : 1.0
                                                Layout.fillWidth: true
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_material
                                                    text: ""
                                                    anchors.centerIn: parent
                                                }
                                            }

                                            //-- down icon--//
                                            Label{
                                                opacity: nav_subMaterial.text === "" ? 0.0 : 1.0
                                                font.family: font_material.name
                                                text: MdiFont.Icon.chevron_down //arrow_down_thick
                                                Layout.alignment: Qt.AlignHCenter
                                                Behavior on opacity{ NumberAnimation{duration: 100}}
                                            }

                                            //-- SubMaterial --//
                                            ItemDelegate{
                                                opacity: nav_subMaterial.text === "" ? 0.0 : 1.0
                                                Layout.fillWidth: true
                                                Behavior on opacity{ NumberAnimation{duration: 100}}

                                                Label{
                                                    id: nav_subMaterial
                                                    text: ""
                                                    anchors.centerIn: parent
                                                }
                                            }

                                        }

                                    }

                                    //-- company --//
                                    Label{
                                        visible: isCompanyShow
                                        Layout.row: 7
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "شرکت:"
                                    }
                                    TextField{
                                        id: txf_categories_company
                                        visible: isCompanyShow
                                        Layout.row: 7
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "شرکت"
                                        selectByMouse: true
                                        readOnly: true
                                    }

                                    //-- Branch --//
                                    Label{
                                        visible: isBranchShow || true
                                        Layout.row: 8
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "انشعاب:"
                                    }
                                    TextField{
                                        id: txf_categories_branch
                                        visible: isBranchShow || true
                                        Layout.row: 8
                                        Layout.column: 1
                                        Layout.fillWidth: true
                                        readOnly: true

                                        placeholderText: "انشعاب"
                                        selectByMouse: true
                                        wrapMode: Text.Wrap
                                    }

                                    //-- description --//
                                    Label{
                                        visible: isDescriptionShow || true
                                        Layout.row: 9
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "شرح کالا:"
                                    }
                                    TextField{
                                        id: txf_categories_description
                                        visible: isDescriptionShow || true
                                        Layout.row: 9
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "شرح کالا"
                                        selectByMouse: true
                                        wrapMode: Text.Wrap
                                    }

                                    //-- filler --//
                                    Item {
                                        Layout.row: 10
                                        Layout.column: 2
                                        Layout.fillHeight: true

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
                                        visible: false
                                        Layout.fillWidth: true
                                        icons: MdiFont.Icon.arrow_down_bold_circle_outline //"Get"
                                        tooltip: "بارگذاری"

                                        onClicked: {


//                                            var endpoint = "api/kootwall/CompanyProduct"
                                            var endpoint = "api/kootwall/orders-list-generic-view"

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
                                                }


                                                message.text = "all data recived"
                                                triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                            })
                                        }

                                    }

                                    //-- add --//
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

                                        }
                                    }

                                    //-- edit --//
                                    MButton{
                                        Layout.fillWidth: true
                                        icons: MdiFont.Icon.pencil //"Edit"
                                        tooltip: "ویرایش"

                                        onClicked: {

                                            if(txf_categories_categoryID.text === ""){
                                                log("select one item, pleaze")
                                                message.text = "select one item, pleaze"
                                                triggerMsg("لطفا ابتدا عنصر موردنظر را انتخاب کنید", "RED")
                                                return
                                            }

                                            editWin.show()

                                        }


                                        EditWin{
                                            id: editWin

                                            mainPage: root.parent

                                            onConfirm: {

                                                //-- send data --//
                                                /*var data = {
                                                        "title"        : txf_categories_title.text  ,
                                                        "company"      : listmodel.get(lv.currentIndex).company,//txf_categories_company.text ,
                                                        "description"  : txf_categories_description.text
                                                    }*/

                                                var d1 = []

                                                for(var i=0; i<listmodel_companies.count; i++){

                                                    //-- ignore unselected companies --//
                                                    if(listmodel_companies.get(i).isSelected) continue

                                                    //-- send data --//
                                                    var data4 = {
                                                        "company"         : listmodel_companies.get(i).company.id     ,
                                                        "description"     : txf_categories_description.text
                                                        /*,
                                                            "category"           : listmodel_companies.get(i).category         ,
                                                            "baseCategory"       : listmodel_companies.get(i).baseCategory     ,
                                                            "materialCategory"   : listmodel_companies.get(i).materialCategory ,
                                                            "material"           : listmodel_companies.get(i).material         ,
                                                            "subMaterial"        : listmodel_companies.get(i).subMaterial      ,
                                                            "subSubMaterial"     : listmodel_companies.get(i).subSubMaterial   ,
                                                            "branchTitles"       : listmodel_companies.get(i).branchTitles     ,
                                                            "companyTitle"       : listmodel_companies.get(i).companyTitle     ,
                                                            "title = "              : listmodel_companies.get(i).title            ,
                                                            "pic1 = "               : listmodel_companies.get(i).pic1*/
                                                    }

                                                    d1.push(data4)
                                                }

                                                /*log("selected id = " + listmodel.get(lv.currentIndex).id)
                                                    log("branchTitles = " + listmodel.get(lv.currentIndex).branchTitles)
                                                    log("title = " + listmodel.get(lv.currentIndex).title)
                                                    log("pic1 = " + listmodel.get(lv.currentIndex).pic1)
                                                    log("description = " + listmodel.get(lv.currentIndex).description)
                                                    log("category = " + listmodel.get(lv.currentIndex).category)*/

                                                var d4 = {
                                                    "ordered_meals"     : d1,
                                                    "description"       : txf_categories_description.text
                                                    /*"title"             : listmodel.get(lv.currentIndex).title, //txf_categories_title.text         ,
                                                        "pic1"              : txf_categories_pic.text           ,
                                                        "description"       : txf_categories_description.text  ,
                                                        "branchTitles"      : listmodel.get(lv.currentIndex).branchTitles,
                                                        "category = "       : listmodel.get(lv.currentIndex).category*/
                                                }

                                                log("jd4 = " + JSON.stringify(d4))

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
    //                                                var endpoint = "api/kootwall/CompanyProduct/" + listmodel.get(lv.currentIndex).id + "/"
                                                    var endpoint = "api/kootwall/orders2-update-mixin/"+ listmodel.get(clickedIndex).id //+ "/"

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

                                                        if(resp.hasOwnProperty('title')) // chack exist title in resp
                                                        {
                                                            var txt = resp.title
                                                            if(txt.indexOf("This title has already been used") > -1){

                                                                message.text = "This title has already been used"
                                                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                                return
                                                            }

                                                        }
                                                        listmodel.setProperty(clickedIndex, 'title',         resp.title)
                                                        listmodel.setProperty(clickedIndex, 'description',   resp.description)
                                                        listmodel.setProperty(clickedIndex, 'branchTitles',  resp.branchTitles)


    //                                                    var d = _resp[lv_companies.currentIndex]

    //                                                    for(var i=0; i<d.ordered_meals.length; i++) {
    //                                                        listmodel_companies.append(d.ordered_meals[i])
    //                                                        listmodel_companies.setProperty(i, 'isSelected', false)
    //                                                    }

    //                                                    log("d = " + JSON.stringify(_resp[lv.currentIndex]))

                                                        //-- remove selected companies --//
                                                        for(var i=listmodel_companies.count-1; i>=0; i--){

                                                            //-- ignore unselected companies --//
                                                            if(listmodel_companies.get(i).isSelected) {

                                                                listmodel_companies.remove(i)
                                                                _resp[clickedIndex].ordered_meals.splice(i,1)

                                                            }

                                                        }

                                                        _resp[clickedIndex] = resp

    //                                                    log("d after = " + JSON.stringify(_resp[lv.currentIndex]))

                                                        message.text = "Item updated"
                                                        triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")
                                                        triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "BLUE")

                                                        //-- log activity --//
                                                        logActivity(_ACTIVITY_UPDATE, _COMPANYPRODUCT, ("به روز رسانی محصول در مدیریت محصول ها: " + txf_categories_title.text))

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
//                                                    var endpoint = "api/kootwall/CompanyProduct/" + listmodel.get(lv.currentIndex).id + "/"
                                                    var endpoint = "api/kootwall/orders2/" + listmodel.get(clickedIndex).id// + "/"

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
                                                                logActivity(_ACTIVITY_DELETE, _COMPANYPRODUCT, ("حذف محصول در مدیریت محصول ها: " + txf_categories_title.text))

                                                                listmodel.remove(clickedIndex, 1)
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

                    //-- splitter --//
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.preferredWidth: 1
                        Layout.margins: 10
                        color: "#5e5e5e"
                    }

                    //-- companies of selected product --//
                    Pane {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        font.pixelSize: Qt.application.font.pixelSize

                        ColumnLayout{
                            anchors.fill: parent
                            spacing: 0

                            //-- company header --//
                            Button{
                                Layout.fillWidth: true
                                text: ""
                                flat: true
                                down: true
                                Text {
                                    id: txt_title
                                    text: "لیست شرکت ها"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- add --//
                            MButton{
                                id: btnCompanyAdd
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.plus //"Add"
                                tooltip: "افزودن شرکت به محصول انتخاب شده"

                                onClicked: {

                                    companySearch.show()

                                }
                            }

                            //-- company --//
                            Rectangle{
//                                visible: isCompanyShow
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                color: "#00000000"
                                radius: 3
//                                border{width: 1; color: "#66000000"}

                                ListModel{
                                    id: listmodel_companies
                                }

                                ListView{
                                    id: lv_companies

                                    anchors.fill: parent
                                    anchors.margins: 4
                                    layoutDirection: Qt.RightToLeft
                                    //                                            orientation: ListView.Horizontal
                                    spacing: 0
                                    clip: true

                                    ScrollBar.vertical: ScrollBar {
                                        id: control2
                                        size: 0.1
                                        position: 0.2
                                        active: true
                                        orientation: Qt.Vertical

                                        contentItem: Rectangle {
                                            implicitWidth: 6
                                            implicitHeight: 100
                                            radius: width / 2
                                            color: control2.pressed ? "#aa32aaba" : "#5532aaba"
                                        }

                                    }

                                    model: listmodel_companies

                                    delegate: ItemDelegate{

                                        width: parent.width //lblCmp.implicitWidth+20
                                        height: lblCmp.implicitHeight+10
                                        font.pixelSize: Qt.application.font.pixelSize

                                        //-- border --//
                                        Rectangle{
                                            anchors.fill: parent
                                            anchors.margins: 1
                                            color: "#00FFFFFF"
                                            radius: 5
                                            border{width: 1; color: Util.color_kootwall_dark}
                                        }


                                        RowLayout{
                                            anchors.fill: parent
                                            anchors.margins: 3
                                            spacing: 0

                                            //-- Company title --//
                                            Rectangle{
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                color: "#00FF0000"

                                                TxtItmOfListView{
                                                    width: parent.width
                                                    height: parent.height

                                                    txt: model.companyTitle

                                                }

                                                MouseArea{
                                                    anchors.fill: parent
                                                    onClicked: {
//                                                        console.log("1")
                                                        listmodel_companies.setProperty(index, 'isSelected', !listmodel_companies.get(index).isSelected)
                                                    }
                                                }
                                            }

                                            //-- gallery --//
                                            Rectangle{
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: lblPicIcon.width + 20
                                                color: "#00FF00ff"



                                                //-- gallery icon --//
                                                Label{
                                                    id: lblPicIcon
                                                    text: MdiFont.Icon.image_filter
                                                    font.family: font_material.name
                                                    color: Util.color_kootwall_dark
                                                    anchors.centerIn: parent

                                                }

                                                MouseArea{
                                                    anchors.fill: parent
//                                                    anchors.margins: -5
                                                    hoverEnabled: true
                                                    onEntered: lblPicIcon.color = "#00BCD4"
                                                    onExited:  lblPicIcon.color = Util.color_kootwall_dark
                                                    onClicked: {
                                                        console.log( model.id + ",-- " + listmodel.get(lv.currentIndex).title)

                                                        upimageWin.openWin(model.id, listmodel.get(lv.currentIndex).title, model.companyTitle)
                                                    }
                                                }
                                            }
                                        }


                                        //-- size porpose --//
                                        Label{
                                            visible: false
                                            id: lblCmp
                                            text: model.companyTitle
                                            anchors.centerIn: parent
                                        }

                                        //-- delete lable --//
                                        Label{
                                            id: lblDel
                                            visible: model.isSelected
                                            font.family: font_material.name
                                            font.pixelSize: Qt.application.font.pixelSize * 2
                                            color: Material.color(Material.Red)
                                            anchors.centerIn: parent
                                            text: MdiFont.Icon.window_close
                                        }
                                    }


                                    // some fun with transitions :-)
                                    add: Transition {
                                        // applied when entry is added
                                        NumberAnimation {
                                            properties: "x"; from: -lv_companies.width;
                                            duration: 250;
                                        }
                                    }
                                    remove: Transition {
                                        // applied when entry is removed
                                        NumberAnimation {
                                            properties: "x"; to: lv_companies.width;
                                            duration: 250;
                                        }
                                    }

                                }

                            }


                        }
                    }
                }

            }

            //-- listview item --//
            Rectangle{
                id: lvSection

                Layout.fillHeight: true
                Layout.fillWidth: true
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
                    anchors.fill: parent
                    anchors.margins: 10

                    //-- table header --//
                    Button{
                        Layout.fillWidth: true
                        text: pageTitle
                        flat: true
                        down: true

                        //-- get/load beasy buttons --//
                        RowLayout{
//                            visible: false
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

                                    //-- reset page offset --//
                                    lvPageSizeOffset = 0

                                    //-- fetch product based on selected category --//
                                    fetchCompanyProduct(itm_categories.modelItm.get(itm_categories.selModelIndx).id)
                                }

                            }


                            BusyIndicator {
                                id: busyLoader

                                Layout.fillHeight: true
                                Layout.margins: 4
                                running: false
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

                                        //-- fetch product based on selected category --//
                                        fetchCompanyProduct(itm_categories.modelItm.get(itm_categories.selModelIndx).id)
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
//                                enabled: (lvPageSizeOffset+1) < (listmodel.get(lv.currentIndex).product_count / lvPageSize)
                                Material.background:"transparent"

                                onClicked: {

                                    if(lvPageSizeOffset >= 0){
                                        lvPageSizeOffset++

                                        //-- fetch product based on selected category --//
                                        fetchCompanyProduct(itm_categories.modelItm.get(itm_categories.selModelIndx).id)
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

                            //-- description --//
                            Item{
                                visible: isDescriptionShow
                                Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthDescription)
                                Layout.fillHeight: true
                                Label{
                                    id: lbl_description
                                    text: "شرح کالا"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- navigation --//
                            Item{
                                visible: isBranchShow
                                Layout.preferredWidth: Math.max(lbl_catNav.implicitWidth * 2, _widthCatNavigate)
                                Layout.fillHeight: true
                                Label{
                                    id: lbl_catNav
                                    text: "انشعاب محصول"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- company --//
                            Item{
                                visible: isCompanyShow
                                Layout.preferredWidth: Math.max(lbl_company.implicitWidth * 2, _widthCompany)
                                Label{
                                    id: lbl_company
                                    text: "شرکت"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- date --//
                            Item{
                                visible: isDateShow
                                Layout.preferredWidth: Math.max(lbl_date.implicitWidth * 2, _widthDate)
                                Label{
                                    id: lbl_date
                                    text: "تاریخ"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- pic --//
                            Item{
                                visible: isPic1Show
                                Layout.preferredWidth: Math.max(lbl_pic.implicitWidth * 2, _widthPic)
                                Label{
                                    id: lbl_pic
                                    text: "تصویر"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- title --//
                            Item{
                                visible: isTitleShow
                                Layout.preferredWidth: Math.max(lbl_title.implicitWidth * 2, _widthTitle)
                                Layout.fillHeight: true
                                Label{
                                    id: lbl_title
                                    text: "محصول"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- categoryID --//
                            Item{
                                visible: isIdShow
                                Layout.preferredWidth: Math.max(lbl_ccategoryID.implicitWidth * 2, _widthID)
                                Label{
                                    id: lbl_ccategoryID
                                    text: "ID"
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
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: height

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

                            /*

                            section.property: "title"
                            section.labelPositioning: ViewSection.InlineLabels
                            section.delegate: ItemDelegate {
                                width: lv.width
                                height: sectionLabel.implicitHeight + 20
                                //                                Material.theme: Material.Dark
                                //                                Material.background: Util.color_kootwall_dark
                                font.pixelSize: Qt.application.font.pixelSize
                                Material.foreground: "#5e5e5e"

                                Rectangle{anchors.fill: parent; color: "#44e0e0e0"; }

                                Rectangle{anchors.fill: parent; color: Util.color_kootwall_light; opacity: 0.3; visible: (section === txf_categories_title.text ? true : false) }

                                Label {
                                    visible: false
                                    id: sectionLabel
                                    text: section + "   -    " + serchTitle(section).companyTitle //companyTitle
                                    anchors.centerIn: parent
                                }

                                //-- body --//
                                RowLayout{
                                    anchors.fill: parent
                                    anchors.margins: 3

                                    //-- description --//
                                    Item{
                                        visible: isDescriptionShow
                                        Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthDescription)
                                        Label{
                                            text: serchTitle(section).description
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- category navigation --//
                                    Item{
                                        visible: isBranchShow
                                        Layout.preferredWidth: Math.max(lbl_catNav.implicitWidth * 2, _widthCatNavigate)
                                        Label{
                                            //                                            text: model.category + "-" + model.baseCategory + "-" + model.materialCategory + "-" + model.material + "-" + model.subMaterial
                                            text: serchTitle(section).branchTitles
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- company --//
                                    Item{
                                        visible: isCompanyShow
                                        Layout.preferredWidth: Math.max(lbl_company.implicitWidth * 2, _widthCompany)
                                        Label{
                                            text: serchTitle(section).companyTitle
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- date --//
                                    Item{
                                        visible: isDateShow
                                        Layout.preferredWidth: Math.max(lbl_date.implicitWidth * 2, _widthDate)
                                        Label{
                                            text: serchTitle(section).date
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- pic --//
                                    Item{
                                        visible: isPic1Show
                                        Layout.preferredWidth: Math.max(lbl_pic.implicitWidth * 2, _widthPic)
                                        Label{
                                            text: serchTitle(section).pic1
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- title --//
                                    Item{
                                        visible: isTitleShow
                                        //                                        Layout.preferredWidth: Math.max(lbl_title.implicitWidth * 2, _widthTitle)
                                        Layout.fillWidth: true
                                        Label{
                                            text: serchTitle(section).title //+ ","
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- ID --//
                                    Item{
                                        visible: isIdShow
                                        Layout.preferredWidth: Math.max(lbl_ccategoryID.implicitWidth * 2, _widthID)
                                        Label{
                                            text: serchTitle(section).id
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                }

                                //-- spliter --//
                                Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                onClicked: {

                                    //-- search companies which have this product --//
                                    var d = serchCompanies(section)

                                    //-- fill companies list model of selected product --//
                                    listmodel_companies.clear()
                                    for(var i=0; i<d.length; i++) {
                                        listmodel_companies.append(d[i])
                                        listmodel_companies.setProperty(i, 'isSelected', false)
                                    }


                                    //-- controll count of listview --//
                                    if(d.count < 1) return

                                    txf_categories_categoryID.text  = d[0].id
                                    txf_categories_title.text       = d[0].title
                                    txf_categories_pic.text         = d[0].pic1
                                    txf_categories_date.text        = d[0].date
                                    txf_categories_company.text     = d[0].companyTitle
                                    txf_categories_branch.text      = d[0].branchTitles
                                    txf_categories_description.text = d[0].description

                                }
                            }

                            */

                            delegate:ItemDelegate{
//                                visible: false
                                width: parent.width
                                height: 40

                                font.pixelSize: Qt.application.font.pixelSize
                                Material.foreground: "#5e5e5e"

                                Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

                                //-- body --//
                                RowLayout{
                                    anchors.fill: parent
                                    anchors.margins: 3

                                    //                                    Item { Layout.fillWidth: true } //-- filler --//

                                    //-- description --//
                                    Item{
                                        visible: isDescriptionShow
                                        Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthDescription)
                                        Label{
                                            text: model.description
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- category navigation --//
                                    Item{
                                        visible: isBranchShow
                                        Layout.preferredWidth: Math.max(lbl_catNav.implicitWidth * 2, _widthCatNavigate)
                                        Label{
                                            //                                            text: model.category + "-" + model.baseCategory + "-" + model.materialCategory + "-" + model.material + "-" + model.subMaterial
                                            text: model.branchTitles
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- company --//
                                    Item{
                                        visible: isCompanyShow
                                        Layout.preferredWidth: Math.max(lbl_company.implicitWidth * 2, _widthCompany)
                                        Label{
                                            text: model.hasOwnProperty('companyTitle') ? model.companyTitle : ""
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- date --//
                                    Item{
                                        visible: isDateShow
                                        Layout.preferredWidth: Math.max(lbl_date.implicitWidth * 2, _widthDate)
                                        Label{
                                            text: model.date
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- pic --//
                                    Item{
                                        visible: isPic1Show
                                        Layout.preferredWidth: Math.max(lbl_pic.implicitWidth * 2, _widthPic)
                                        Label{
                                            text: ""//model.pic1
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- title --//
                                    Item{
                                        visible: isTitleShow
                                        //                                        Layout.preferredWidth: Math.max(lbl_title.implicitWidth * 2, _widthTitle)
                                        Layout.fillWidth: true
                                        Label{
                                            text: model.title //+ ","
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- ID --//
                                    Item{
                                        visible: isIdShow
                                        Layout.preferredWidth: Math.max(lbl_ccategoryID.implicitWidth * 2, _widthID)
                                        Label{
                                            text: model.id
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }


                                    //                                    Item { Layout.fillWidth: true } //-- filler --//
                                }

                                //-- spliter --//
                                Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                                onClicked: {
                                    lv.currentIndex = index


                                    var d = _resp[index]

                                    //-- fill companies list model of selected product --//
                                    listmodel_companies.clear()

                                    for(var i=0; i<d.ordered_meals.length; i++) {
                                        listmodel_companies.append(d.ordered_meals[i])
                                        listmodel_companies.setProperty(i, 'isSelected', false)
                                    }

                                    /*txf_categories_categoryID.text  = listmodel.get(lv.currentIndex).id
                                    txf_categories_title.text       = listmodel.get(lv.currentIndex).title
                                    txf_categories_pic.text         = listmodel.get(lv.currentIndex).pic1
                                    txf_categories_date.text        = listmodel.get(lv.currentIndex).date
                                    txf_categories_company.text     = listmodel.get(lv.currentIndex).companyTitle
//                                    nav_category.text               = listmodel.get(lv.currentIndex).category
//                                    nav_baseCategory.text           = listmodel.get(lv.currentIndex).baseCategory
//                                    nav_materialCategory.text       = listmodel.get(lv.currentIndex).materialCategory
//                                    nav_material.text               = listmodel.get(lv.currentIndex).material
//                                    nav_subMaterial.text            = listmodel.get(lv.currentIndex).subMaterial
                                    txf_categories_branch.text      = listmodel.get(lv.currentIndex).branchTitles
                                    txf_categories_description.text = listmodel.get(lv.currentIndex).description*/
                                }


                            }

                            //-- inusable --//
                            onCurrentIndexChanged:{

                                log("lv.currentIndex = " + lv.currentIndex)

                                //-- controll count of listview --//
                                if(lv.count < 1) return

                                //-- controll currentIndex of listview --//
                                if(lv.currentIndex < 0) return

                                txf_categories_categoryID.text  = listmodel.get(lv.currentIndex).id
                                txf_categories_title.text       = listmodel.get(lv.currentIndex).title
                                txf_categories_pic.text         = ""//listmodel.get(lv.currentIndex).pic1
                                txf_categories_date.text        = listmodel.get(lv.currentIndex).date
//                                txf_categories_company.text     = listmodel.get(lv.currentIndex).companyTitle
                                //                                    nav_category.text               = listmodel.get(lv.currentIndex).category
                                //                                    nav_baseCategory.text           = listmodel.get(lv.currentIndex).baseCategory
                                //                                    nav_materialCategory.text       = listmodel.get(lv.currentIndex).materialCategory
                                //                                    nav_material.text               = listmodel.get(lv.currentIndex).material
                                //                                    nav_subMaterial.text            = listmodel.get(lv.currentIndex).subMaterial
                                txf_categories_branch.text      = listmodel.get(lv.currentIndex).branchTitles
                                txf_categories_description.text = listmodel.get(lv.currentIndex).description

                                for(var i=0; i< listmodel_companies.count; i++){
                                    console.log(listmodel_companies.get(i).id)
                                }
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

            //-- category filter --//
            CategoryFilter{
                id: itm_categories

                Layout.fillHeight: true
                Layout.preferredWidth: isExpand ? 150 : 50
                Layout.margins: 5
                headerUnExpandHeight: lblHeaderSize.implicitWidth * 1.7
                isLogEnabled: logPermission

                //-- string categoryID --//
                onReturnSelectedCategory:{

                    //-- reset page offset --//
                    lvPageSizeOffset = 0

                    //-- clear search text field --//
                    txf_categories_search.searchedTxt = ""

                    //-- fetch product based on selected category --//
                    fetchCompanyProduct(categoryID) //itm_baseCategory.setedIndex(categoryID)
                }

                //-- handle message --//
                //-- string msg, , String alarmType --//
                onTriggerMsg: msgHandler.show(msg, alarmType)

            }

        }
    }

    //-- serach in all categories --//
    CompanySearch{
        id: companySearch

        mainPage: parent //-- alighment porpos --//

        //-- ListModel companies --//
        onReturnSelectedCompanies:{

            //listmodel_companies

            for(var i=0; i< companies.count; i++){

                if(isCompExist(companies.get(i)) === -1){

                    //-- add to listmodel_companies, should convert company model to companyProduct model

                    var com = {'id' : companies.get(i).id}
                    listmodel_companies.append({
                                                   'company' : com,
                                                   'companyTitle' : companies.get(i).title
                                               })

                }
            }
        }

    }

    //-- upload image window --//
    UploadProductImg{
        id: upimageWin
    }


    //-- check item exist in listmodel of selected companies --//
    //-- return index or -1 --//
    function isCompExist(itm){

        for(var i=0; i< listmodel_companies.count; i++){

            if(itm.id === listmodel_companies.get(i).company.id) return i
        }

        return -1
    }


    //-- search data based on title in listmodel --//
    function serchTitle(title){

        for(var i=0; i<listmodel.count; i++){

            if(listmodel.get(i).title === title){
                return listmodel.get(i)
            }
        }
        var data = {
            'category'         : "" ,
            'baseCategory'     : "" ,
            'materialCategory' : "" ,
            'material'         : "" ,
            'subMaterial'      : "" ,
            'company'          : "" ,
            'companyTitle'     : "" ,
            'branchTitles'     : "" ,
            'title'            : "" ,
            'pic1'             : "" ,
            'date'             : "" ,
            'description'      : "",
        }

        return data
    }


    //-- search all companies based on title in listmodel --//
    function serchCompanies(title){

        var data = []
        for(var i=0; i<listmodel.count; i++){

            if(listmodel.get(i).title === title){
                data.push(listmodel.get(i))
            }
        }

        return data
    }


    //-- fetch data based on CategoryId --//
    function fetchCompanyProduct(categoryID){

        //-- validate inpute --//
        if(isNaN(categoryID)){
            log("invalid categoryID")
            return
        }

        //-- show busy indicator --//
        busyLoader.running = true

        //-- clear textfields --//
        clearCategoriesTextfields()
        //-- remove companies list --//
        listmodel_companies.clear()

        //-- search based on categoryID --//
        var endpoint = ""

        if(txf_categories_search.searchedTxt !== ""){

//            endpoint = "api/kootwall/orders2-list-generic-view?cat=" + categoryID
            endpoint = "api/kootwall/add-group-product-to-companies?cat=" + categoryID
                    + "&title="     + txf_categories_search.searchedTxt
                    + "&pageSize="  + lvPageSize
                    + "&offset="    + lvPageSizeOffset
        }
        else{
            endpoint = "api/kootwall/orders2-list-generic-view?n=" + categoryID + "&pageSize=" + lvPageSize + "&offset=" + lvPageSizeOffset
        }

        Service.get_all( endpoint, function(resp, http) {
            log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))


            //-- show busy indicator --//
            busyLoader.running = false

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
                message.text = resp.error
                triggerMsg(resp.error, "RED")
                return

            }

            //-- save json file to global var --//
            _resp = resp

//            console.log("data === " + JSON.stringify(_resp))

            listmodel.clear()

            for(var i=0; i<resp.length; i++) {

//                log()
//                if(resp[i].ordered_meals.length === 0) continue

                listmodel.append(resp[i])


                //-- set branchTitles and Title --//
                var branchStr = ""
                if(resp[i].category !== null){

                    branchStr += resp[i].category.title
                }
                if(resp[i].baseCategory !== null){

                    branchStr += " > " + resp[i].baseCategory.title
                }
                if(resp[i].materialCategory !== null){

                    branchStr += " > " +  resp[i].materialCategory.title
                }
                if(resp[i].material !== null){

                    branchStr +=  " > " + resp[i].material.title
                }
                if(resp[i].subMaterial !== null){

                    branchStr +=  " > " + resp[i].subMaterial.title
                }
                if(resp[i].subSubMaterial !== null){

                    branchStr +=  " > " + resp[i].subSubMaterial.title
                }

                var titleList = branchStr.split(" > ")
                var title = titleList[titleList.length-1]

//                log("fetched title = " + titleList + "," + title )

                listmodel.setProperty(i, "branchTitles", branchStr)
                listmodel.setProperty(i, "title", title)
            }

            //-- triger selected item when new models fetched --//
            if(listmodel.count > 0){

                root.state = "FILL"

                lv.currentIndex = -1 //-- trigger current index --//
                lv.currentIndex = 0

                //-- add first item companies --//

                //-- search companies which have this product --//
//                var d = serchCompanies(listmodel.get(0).title)
                var d = resp[0]

                //-- fill companies list model of selected product --//
                listmodel_companies.clear()
                for(var i=0; i<d.ordered_meals.length; i++) {

                    listmodel_companies.append(d.ordered_meals[i])
                    listmodel_companies.setProperty(i, 'isSelected', false)
                }

                log("--- FILL ----")

            }
            else{

                root.state = "EMPTY"
                log("--- EMPTY ----")

            }

            message.text = "searched data recived"
            triggerMsg("جست و جو انجام شد", "LOG")
        })

    }

    //-- message handler --//
    MsgPopup{
        id: msgHandler

    }

    //-- clear all text of esit section --//
    function clearCategoriesTextfields(){
        if(isIdShow             && txf_categories_categoryID.enabled)   txf_categories_categoryID.text  = ""
        if(isDateShow           && txf_categories_date.enabled)         txf_categories_date.text        = ""
        if(isPic1Show           && txf_categories_pic.enabled)          txf_categories_pic.text         = ""
        if(isTitleShow          && txf_categories_title.enabled)        txf_categories_title.text       = ""
        if(isCompanyShow        && txf_categories_company.enabled)      txf_categories_company.text     = ""
        if(isDescriptionShow    && txf_categories_description.enabled)  txf_categories_description.text = ""
        if(isCatNavigateShow    && txf_categories_catNavigate.enabled)  txf_categories_catNavigate.text = ""
        if(isBranchShow         && txf_categories_branch.enabled)       txf_categories_branch.text      = ""
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

