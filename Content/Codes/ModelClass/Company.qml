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


//-- Categories --//
Rectangle{
    id: root


    //-- visible window --//
    signal openWin()
    onOpenWin:{

        //-- load companies list from DataBase --//
        btnCategoriesGet.clicked()
    }


    //-- trigger message win --//
    signal triggerMsg(string msg, string alarmType)
    onTriggerMsg: {
        msgHandler.show(msg, alarmType)
    }


    property string  pageTitle:      "شرکت ها"  //-- modul header title --//
    property bool    isLogEnabled:   true       //-- global log permission --//
    property bool    isShowStatus:   false      //-- show/hide status bar --//
    property int     lvCurrentPage   :   1      //-- current page of ListView elements --//
    property int     lvPageSize      :   50     //-- current page of ListView elements --//
    property int     totalCompany    :   0      //-- total element of company elements --//
    property variant categoryListmodel          //-- JSON of category model --//

    property bool   _isEditable:            true   //-- allow user to edit text Item --//
    property bool   _localLogPermission:    true   //-- local log permission --//

    //-- show permission for editable items --//
    property bool isIdShow              : false
    property bool isTitleShow           : true
    property bool isPicShow             : false
    property bool isDateShow            : false
    property bool isCityShow            : true
    property bool isAddressShow         : true
    property bool isAddressCompanyShow  : true
    property bool isTellShow            : true
    property bool isTellCompanyShow     : true
    property bool isFaxShow             : true
    property bool isFaxCompanyShow      : true
    property bool isDescriptionShow     : true
    property bool isAbstractShow        : true
    property bool isSiteShow            : true
    property bool isEmailShow           : true
    property bool isTagShow             : true



    //-- show permission for listvie items --//
    property bool lv_isIdShow               : false
    property bool lv_isTitleShow            : true
    property bool lv_isPicShow              : false
    property bool lv_isDateShow             : false
    property bool lv_isCityShow             : true
    property bool lv_isAddressShow          : false
    property bool lv_isAddressCompanyShow   : false
    property bool lv_isTellShow             : false
    property bool lv_isTellCompanyShow      : false
    property bool lv_isFaxShow              : false
    property bool lv_isFaxCompanyShow       : false
    property bool lv_isDescriptionShow      : true
    property bool lv_isAbstractShow         : false
    property bool lv_isSiteShow             : false
    property bool lv_isEmailShow            : false
    property bool lv_isTagShow              : false
    property int  visibleItmCount           : 3     //-- hold visible item count for size porpose (in edit win height) --//

    //-- width size porpos --//
    property real slot: (lvSection.width -20) / visibleItmCount //-- (-20) for margins --/
    property int _widthID               : slot * 1
    property int _widthTitle            : slot * 1.25 // t
    property int _widthPic              : slot * 1
    property int _widthDate             : slot * 1
    property int _widthCity             : slot * 0.5 //t
    property int _widthAddress          : slot * 2
    property int _widthAddressCompany   : slot * 1
    property int _widthTell             : slot * 0.5
    property int _widthTellCompany      : slot * 1
    property int _widthFax              : slot * 0.5
    property int _widthFaxCompany       : slot * 1
    property int _widthDescription      : slot * 1.25 //T
    property int _widthAbstract         : slot * 1
    property int _widthSite             : slot * 1
    property int _widthEmail            : slot * 0.5
    property int _widthTag              : slot * 1

    objectName: "Company"
    color: "#FFFFFF"
    radius: 3
    border{width: 1; color: "#999e9e9e"}

    Component.onCompleted: {
        log("start to fecth data: ")
        //        dataSource.categories_getAll()
    }

    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name

        RowLayout{
            anchors.fill: parent
            spacing: 0

            //-- edit item --//
            Rectangle{
                Layout.fillHeight: true
                Layout.preferredWidth: 300
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

                                contentHeight: txf_categories_categoryID.implicitHeight * (21) + txf_categories_tags.height

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

                                    rows: 18
                                    columns: 2

                                    //-- Serach --//
                                    SearchField{
                                        id: txf_categories_search

                                        Layout.row: 0
                                        Layout.column: 1
                                        Layout.columnSpan: 2
                                        Layout.fillWidth: true

                                        //-- string text --//
                                        onEnteredText: {

                                            lvCurrentPage = 1 //-- load first page --//
                                            txf_categories_search.searchCompanies()
                                        }

                                        function searchCompanies(){

                                            //-- search based on title --//

//                                            var endpoint = "api/kootwall/Company?q=" + txf_categories_search.searchedTxt
                                            var endpoint = "api/kootwall/Company?page=" + lvCurrentPage + "&page_size=" + lvPageSize + "&q=" + txf_categories_search.searchedTxt

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
                                                }

                                                message.text = "searched data recived"
                                                triggerMsg("جست و جو انجام شد", "LOG")
                                            })
                                        }
                                    }

                                    //-- Tags of category --//
                                    Label{
                                        visible: isTagShow
                                        Layout.row: 1
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "برچسب"
                                    }
                                    Rectangle{
                                        id: txf_categories_tags
                                        visible: isTagShow
                                        Layout.row: 1
                                        Layout.column: 1
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: categoryListmodel.count * 30 + headerChoises.implicitHeight + btn_chooseAll.height
                                        color: "transparent"
                                        radius: 5
                                        smooth: true
                                        border{width: 1; color: "#e1e1e1"}

                                        //-- body --//
                                        RowLayout{
                                            anchors.fill: parent
                                            anchors.margins: 5
                                            spacing: 0

                                            //-- category items --//
                                            Item {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true


                                                ColumnLayout{
                                                    anchors.fill: parent

                                                    //-- header --//
                                                    Button{
                                                        id: headerChoises
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: implicitHeight * 0.8
                                                        flat: true
                                                        down: true
                                                        text: "لیست برچسب ها"
                                                        font.pixelSize: Qt.application.font.pixelSize * 0.7

                                                        ToolTip.visible: hovered
                                                        ToolTip.text: "لیست برچسب ها"
                                                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                                                        ToolTip.timeout: 5000
                                                    }

                                                    //-- list of unselected tags --//
                                                    ListView{
                                                        id: lv_categories

                                                        Layout.fillHeight: true
                                                        Layout.fillWidth: true
                                                        spacing: 1
                                                        model: ListModel{
                                                            id: listmodel_unselectedTags
                                                        }

                                                        delegate: ItemDelegate{
                                                            width: parent.width
                                                            height: 30

                                                            font.pixelSize: Qt.application.font.pixelSize
                                                            Material.foreground: "#5e5e5e"

                                                            Rectangle{anchors.fill: parent; color: model.isSelected ? "#6632aaba" : "#44e0e0e0"; }

                                                            Label{
                                                                text: model.title
                                                                anchors.centerIn: parent
                                                            }

                                                            onClicked: {
                                                                listmodel_unselectedTags.setProperty(index, "isSelected", !model.isSelected)
                                                            }

                                                        }

                                                    }

                                                    //-- choose all --//
                                                    Button{
                                                        id: btn_chooseAll
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: implicitHeight * 0.8
                                                        flat: true
                                                        Material.foreground: Util.color_kootwall_dark
                                                        text: "انتخاب همه"
                                                        font.pixelSize: Qt.application.font.pixelSize * 0.7

                                                        onClicked: {

                                                            //-- ignore condition --//
                                                            if(listmodel_unselectedTags.count === 0) return

                                                            listmodel_tag.clear()
                                                            listmodel_unselectedTags.clear()

                                                            //-- add all tags to list --//
                                                            for(var i=0; i< categoryListmodel.count; i++){

                                                                listmodel_tag.append({
                                                                                     "title": categoryListmodel.get(i).title
                                                                                         , "isSelected": false
                                                                                     })

                                                            }
                                                        }
                                                    }

                                                }
                                            }

                                            //-- choicer --//
                                            Item {
                                                Layout.fillHeight: true
                                                Layout.preferredWidth: btnChoicer.implicitWidth


                                                ColumnLayout{
                                                    anchors.fill: parent
                                                    spacing: 0

                                                    Item{Layout.fillHeight: true;} //-- filler --//

                                                    //-- move selected items to list of tags --//
                                                    RoundButton{
                                                        id: btnChoicer

                                                        Layout.preferredHeight: implicitHeight*0.7
                                                        font.family: font_material.name
                                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                                        text: MdiFont.Icon.arrow_right_bold_circle_outline
                                                        flat: true

                                                        onClicked: {

                                                            //-- ignore condition --//
                                                            if(listmodel_unselectedTags.count === 0) return

                                                            //-- add all tags to list --//
                                                            for(var i=listmodel_unselectedTags.count-1; i>=0 ; i--){

                                                                if(listmodel_unselectedTags.get(i).isSelected){

                                                                    listmodel_tag.append({
                                                                                             "title": listmodel_unselectedTags.get(i).title
                                                                                             , "isSelected": false
                                                                                         })
                                                                    listmodel_unselectedTags.remove(i)
                                                                }

                                                            }
                                                        }
                                                    }

                                                    //-- remove selected items from list of tags --//
                                                    RoundButton{
                                                        id: btnDeChoicer

                                                        Layout.preferredHeight: implicitHeight*0.7
                                                        font.family: font_material.name
                                                        font.pixelSize: Qt.application.font.pixelSize * 1.5
                                                        text: MdiFont.Icon.arrow_left_bold_circle_outline
                                                        flat: true

                                                        onClicked: {

                                                            //-- ignore condition --//
                                                            if(listmodel_tag.count === 0) return

                                                            //-- add all tags to list --//
                                                            for(var i=listmodel_tag.count-1; i>=0 ; i--){

                                                                if(listmodel_tag.get(i).isSelected){

                                                                    listmodel_unselectedTags.append({
                                                                                             "title": listmodel_tag.get(i).title
                                                                                             , "isSelected": false
                                                                                         })
                                                                    listmodel_tag.remove(i)
                                                                }

                                                            }
                                                        }
                                                    }

                                                    Item{Layout.fillHeight: true;} //-- filler --//
                                                }

                                            }

                                            //-- tag items --//
                                            Item {
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true


                                                ColumnLayout{
                                                    anchors.fill: parent

                                                    //-- table header --//
                                                    Button{
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: implicitHeight * 0.8
                                                        flat: true
                                                        down: true
                                                        text: "انتخاب ها"
                                                        font.pixelSize: Qt.application.font.pixelSize * 0.7

                                                        ToolTip.visible: hovered
                                                        ToolTip.text: "برچسب های انتخاب شده"
                                                        ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
                                                        ToolTip.timeout: 5000
                                                    }

                                                    //-- list of selected tags --//
                                                    ListView{
                                                        id: lv_tags

                                                        Layout.fillHeight: true
                                                        Layout.fillWidth: true
                                                        spacing: 1
                                                        model: ListModel{
                                                            id: listmodel_tag
                                                        }

                                                        delegate: ItemDelegate{
                                                            width: parent.width
                                                            height: 30

                                                            font.pixelSize: Qt.application.font.pixelSize
                                                            Material.foreground: "#5e5e5e"

                                                            Rectangle{anchors.fill: parent; color: model.isSelected ? "#6632aaba" : "#44e0e0e0"; }

                                                            Label{
                                                                text: model.title
                                                                anchors.centerIn: parent
                                                            }

                                                            onClicked: {
                                                                listmodel_tag.setProperty(index, "isSelected", !model.isSelected)
                                                            }

                                                        }

                                                    }

                                                    //-- remove all --//
                                                    Button{
                                                        id: btn_removeAll
                                                        Layout.fillWidth: true
                                                        Layout.preferredHeight: implicitHeight * 0.8
                                                        flat: true
                                                        Material.foreground: Util.color_kootwall_dark
                                                        text: "حذف همه"
                                                        font.pixelSize: Qt.application.font.pixelSize * 0.7

                                                        onClicked: {

                                                            //-- ignore condition --//
                                                            if(listmodel_tag.count === 0) return

                                                            listmodel_tag.clear()
                                                            listmodel_unselectedTags.clear()

                                                            //-- add all tags to unselected list --//
                                                            for(var i=0; i< categoryListmodel.count; i++){

                                                                listmodel_unselectedTags.append({
                                                                                     "title": categoryListmodel.get(i).title
                                                                                         , "isSelected": false
                                                                                     })

                                                            }
                                                        }
                                                    }

                                                }
                                            }
                                        }

                                    }

                                    //-- MaterialCategoryID --//
                                    Label{
                                        id: lbl_catId
                                        visible: isIdShow
                                        Layout.row: 2
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "شماره:"
                                    }
                                    TextField{
                                        id: txf_categories_categoryID
                                        visible: isIdShow
                                        Layout.row: 2
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

                                        text: "شرکت:"
                                    }
                                    TextField{
                                        id: txf_categories_title
                                        visible: isTitleShow
                                        Layout.row: 3
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "شرکت"
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

                                    //-- city --//
                                    Label{
                                        visible: isCityShow
                                        Layout.row: 6
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "استان:"
                                    }
                                    TextField{
                                        id: txf_categories_city
                                        visible: isCityShow
                                        Layout.row: 6
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "استان"
                                        selectByMouse: true
                                    }

                                    //-- address office --//
                                    Label{
                                        visible: isAddressShow
                                        Layout.row: 7
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "آدرس دفتر:"
                                    }
                                    TextField{
                                        id: txf_categories_address
                                        visible: isAddressShow
                                        Layout.row: 7
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "آدرس"
                                        selectByMouse: true
                                        wrapMode: Text.Wrap
                                    }


                                    //-- address company --//
                                    Label{
                                        visible: isAddressCompanyShow
                                        Layout.row: 8
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "آدرس کارخانه:"
                                    }
                                    TextField{
                                        id: txf_categories_addressCompany
                                        visible: isAddressCompanyShow
                                        Layout.row: 8
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "آدرس"
                                        selectByMouse: true
                                        wrapMode: Text.Wrap
                                    }

                                    //-- tell office --//
                                    Label{
                                        visible: isTellShow
                                        Layout.row: 9
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "تلفن دفتر:"
                                    }
                                    TextField{
                                        id: txf_categories_tell
                                        visible: isTellShow
                                        Layout.row: 9
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "+98 21 9999 9999"
                                        selectByMouse: true
                                        //-- validate tell format --//
                                        validator: RegExpValidator { regExp:/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$/ }
//                                        inputMask: "99.9999.9999"
                                    }

                                    //-- tell company --//
                                    Label{
                                        visible: isTellCompanyShow
                                        Layout.row: 10
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "تلفن کارخانه:"
                                    }
                                    TextField{
                                        id: txf_categories_tellCompany
                                        visible: isTellCompanyShow
                                        Layout.row: 10
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "+98 21 9999 9999"
                                        selectByMouse: true
                                        //-- validate tell format --//
                                        validator: RegExpValidator { regExp:/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$/ }
                                    }

                                    //-- fax office --//
                                    Label{
                                        visible: isFaxShow
                                        Layout.row: 11
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "فکس دفتر:"
                                    }
                                    TextField{
                                        id: txf_categories_fax
                                        visible: isFaxShow
                                        Layout.row: 11
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "فکس"
                                        selectByMouse: true
                                        //-- validate fax format --//
                                        validator: RegExpValidator { regExp:/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$/ }
                                    }

                                    //-- fax company --//
                                    Label{
                                        visible: isFaxCompanyShow
                                        Layout.row: 12
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "فکس کارخانه:"
                                    }
                                    TextField{
                                        id: txf_categories_faxCompany
                                        visible: isFaxCompanyShow
                                        Layout.row: 12
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "فکس"
                                        selectByMouse: true
                                        //-- validate fax format --//
                                        validator: RegExpValidator { regExp:/^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$/ }
                                    }

                                    //-- abstract --//
                                    Label{
                                        visible: isAbstractShow
                                        Layout.row: 13
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "حوزه فعالیت"
                                    }
                                    TextField{
                                        id: txf_categories_abstract
                                        visible: isAbstractShow
                                        Layout.row: 13
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "حوزه فعالیت حداکثر در 10 کلمه"
                                        selectByMouse: true
                                        wrapMode: Text.Wrap
                                    }

                                    //-- description --//
                                    Label{
                                        visible: isDescriptionShow
                                        Layout.row: 14
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "توضیحات:"
                                    }
                                    TextField{
                                        id: txf_categories_description
                                        visible: isFaxShow
                                        Layout.row: 14
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "توضیحات"
                                        selectByMouse: true
                                        wrapMode: Text.Wrap
                                    }

                                    //-- site --//
                                    Label{
                                        visible: isSiteShow
                                        Layout.row: 15
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "وبسایت:"
                                    }
                                    TextField{
                                        id: txf_categories_site
                                        visible: isSiteShow
                                        Layout.row: 15
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "سایت"
                                        selectByMouse: true
                                        //-- validate website format --//
                                        validator: RegExpValidator { regExp:/^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ }
                                    }

                                    //-- email --//
                                    Label{
                                        visible: isEmailShow
                                        Layout.row: 16
                                        Layout.column: 2
                                        Layout.alignment: Qt.AlignRight

                                        text: "ایمیل"
                                    }
                                    TextField{
                                        id: txf_categories_email
                                        visible: isEmailShow
                                        Layout.row: 16
                                        Layout.column: 1
                                        Layout.fillWidth: true

                                        placeholderText: "ایمیل"
                                        selectByMouse: true
                                        //-- validate email format --//
                                        validator: RegExpValidator { regExp:/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/ }

                                        onAccepted: {
                                            log("entered data = " + text)
                                        }

                                        Button{
                                            visible: false
                                            text: "t"
                                            onClicked: {

                                                log("tellCompany:" + txf_categories_tellCompany.acceptableInput)
                                                log("web:" + txf_categories_site.acceptableInput)
                                                log("email:" + txf_categories_email.acceptableInput)
                                                log(txf_categories_email.text)
                                            }
                                        }
                                    }

                                    //-- filler --//
                                    Item {
                                        Layout.row: 18
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
                                visible: false
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.arrow_down_bold_circle_outline //"Get"
                                tooltip: "بارگذاری"

                                onClicked: {

                                    var endpoint = "api/kootwall/Company?page=" + lvCurrentPage + "&page_size=" + lvPageSize

                                    //-- start busy animation --//
                                    busyLoader.running = true

                                    Service.get_all( endpoint, function(resp, http) {
                                        log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

                                        //-- busy animation --//
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
                                        }

                                        message.text = "all data recived"
                                        triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
                                    })
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
                                            var endpoint = "api/kootwall/Company/" + listmodel.get(clickedIndex).id + "/"

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
                                                        logActivity(_ACTIVITY_DELETE, _COMPANY, ("حذف شرکت در مدیریت شرکت ها: " + txf_categories_title.text))

                                                        listmodel.remove(clickedIndex, 1)
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

                                    //-- check input validation --//
                                    var m = validateTxtInput()
                                    if(m !== ""){

                                        log("validation error")
                                        message.text = "validation error"
                                        triggerMsg(m, "RED")
                                        return
                                    }

                                    editWin.show()

                                }


                                EditWin{
                                    id: editWin

                                    mainPage: root.parent

                                    onConfirm: {

                                        //-- create tag string --//
                                        var tagList = []
                                        for(var i=0; i<listmodel_tag.count; i++){

                                            tagList.push(listmodel_tag.get(i).title)
                                        }
                                        var tags = tagList.join('_')

                                        //-- send data --//
                                        var data = {
                                            "title"             : txf_categories_title.text             ,
//                                            "pic"               : txf_categories_pic.text               ,
                                            "city"              : txf_categories_city.text              ,
                                            "address"           : txf_categories_address.text           ,
                                            "addressCompany"    : txf_categories_addressCompany.text    ,
                                            "tell"              : txf_categories_tell.text              ,
                                            "tellCompany"       : txf_categories_tellCompany.text       ,
                                            "fax"               : txf_categories_fax.text               ,
                                            "faxCompany"        : txf_categories_faxCompany.text        ,
                                            "description"       : txf_categories_description.text       ,
                                            "abstract"          : txf_categories_abstract.text          ,
                                            "site"              : txf_categories_site.text              ,
                                            "email"             : txf_categories_email.text             ,
                                            "tagOfcategoryId"   : tags
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
                                            var endpoint = "api/kootwall/Company/" + listmodel.get(clickedIndex).id + "/"

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

                                                listmodel.setProperty(clickedIndex, 'title'          , resp.title)
                                                listmodel.setProperty(clickedIndex, 'city'           , resp.city)
                                                listmodel.setProperty(clickedIndex, 'address'        , resp.address)
                                                listmodel.setProperty(clickedIndex, 'addressCompany' , resp.addressCompany)
                                                listmodel.setProperty(clickedIndex, 'tell'           , resp.tell)
                                                listmodel.setProperty(clickedIndex, 'tellCompany'    , resp.tellCompany)
                                                listmodel.setProperty(clickedIndex, 'fax'            , resp.fax)
                                                listmodel.setProperty(clickedIndex, 'faxCompany'     , resp.faxCompany)
                                                listmodel.setProperty(clickedIndex, 'description'    , resp.description)
                                                listmodel.setProperty(clickedIndex, 'abstract'       , resp.abstract)
                                                listmodel.setProperty(clickedIndex, 'site'           , resp.site)
                                                listmodel.setProperty(clickedIndex, 'email'          , resp.email)
                                                listmodel.setProperty(clickedIndex, 'tagOfcategoryId', resp.tagOfcategoryId)


                                                message.text = "Item updated"
                                                triggerMsg("عملیات به روز رسانی با موفقیت انجام شد", "LOG")

                                                //-- log activity --//
                                                logActivity(_ACTIVITY_UPDATE, _COMPANY, ("به روز رسانی شرکت در مدیریت شرکت ها: " + txf_categories_title.text))

                                            })
                                        })
                                    }
                                }
                            }

                            //-- clear --//
                            MButton{
                                Layout.fillWidth: true
                                icons: MdiFont.Icon.eraser
                                tooltip: "پاک کردن ورودی ها"

                                onClicked: {
                                    clearCategoriesTextfields()

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

                                    //-- check input validation --//
                                    var m = validateTxtInput()
                                    if(m !== ""){

                                        log("validation error")
                                        message.text = "validation error"
                                        triggerMsg(m, "RED")
                                        return
                                    }

                                    //-- create tag string --//
                                    var tagList = []
                                    for(var i=0; i<listmodel_tag.count; i++){

                                        tagList.push(listmodel_tag.get(i).title)
                                    }
                                    var tags = tagList.join('_')

                                    //-- send data --//
                                    var data = {
                                        "title"         : txf_categories_title.text             ,
//                                        "pic"           : txf_categories_pic.text               ,
                                        "city"          : txf_categories_city.text              ,
                                        "address"       : txf_categories_address.text           ,
                                        "addressCompany": txf_categories_addressCompany.text    ,
                                        "tell"          : txf_categories_tell.text              ,
                                        "tellCompany"   : txf_categories_tellCompany.text       ,
                                        "fax"           : txf_categories_fax.text               ,
                                        "faxCompany"    : txf_categories_faxCompany.text        ,
                                        "description"   : txf_categories_description.text       ,
                                        "abstract"      : txf_categories_abstract.text          ,
                                        "site"          : txf_categories_site.text              ,
                                        "email"         : txf_categories_email.text             ,
                                        "tagOfcategoryId"   : tags
                                    }

                                    //-- verify token --//
                                    checkToken(function(resp){

                                        //-- token expire, un logined user --//
                                        if(!resp){
                                            message.text = "access denied"
                                            triggerMsg("لطفا ابتدا وارد شوید", "RED")
                                            return
                                        }

                                        var endpoint = "api/kootwall/Company"

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

                                            var txt = resp.title
                                            if(txt.indexOf("This title has already been used") > -1){

                                                message.text = "This title has already been used"
                                                triggerMsg("این عنوان قبلا انتخاب شده است", "RED")
                                                return
                                            }


//                                            listmodel.append(resp)
//                                            lv.currentIndex = lv.count-1
                                            listmodel.insert(0,resp)
                                            lv.currentIndex = 0
                                            message.text = "Item created"
                                            triggerMsg("عنوان جدید ایجاد شد", "LOG")

                                            //-- log activity --//
                                            logActivity(_ACTIVITY_CREATE, _COMPANY, ("شرکت جدید در مدیریت شرکت ها ایجاد شد: " + txf_categories_title.text))

                                            //-- clear text fields --//
                                            clearCategoriesTextfields()


                                        })
                                    })



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
                            height: parent.height
                            width: 100
                            anchors.left: parent.left
                            anchors.margins: 2
                            spacing: 10


                            //-- get(referesh) --//
                            MButton{
                                id: btnCatGet

                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                icons: MdiFont.Icon.refresh //"Get"
                                tooltip: "بارگذاری"

                                onClicked: {
                                    btnCategoriesGet.clicked()
                                }

                            }

                            //-- total company count --//
                            Label{
                                Layout.alignment: Qt.AlignVCenter
                                text: "تعداد کل: " +  totalCompany
                                font.pixelSize: Qt.application.font.pixelSize * 0.7
                            }

                            BusyIndicator {
                                id: busyLoader

                                Layout.fillHeight: true
                                Layout.margins: 4
                                running: false
                            }
                        }

                        //-- pagination --//
                        Pagination{
                            id: itm_pagination
                            height: parent.height
                            anchors.right: parent.right
                            anchors.margins: 2

                            currentPage: root.lvCurrentPage
                            totalItem: root.totalCompany
                            pageSize: root.lvPageSize

                            onFirstPage: {

                                lvCurrentPage = 1

                                if(txf_categories_search.searchedTxt === ""){
                                    btnCategoriesGet.clicked()
                                }
                                else{
                                    txf_categories_search.searchCompanies()
                                }
                            }

                            onNextPage: {

                                if(lvCurrentPage >= 0){
                                    lvCurrentPage++

                                    if(txf_categories_search.searchedTxt === ""){
                                        btnCategoriesGet.clicked()
                                    }
                                    else{
                                        txf_categories_search.searchCompanies()
                                    }
                                }
                            }

                            onPreviousPage: {

                                if(lvCurrentPage > 1){
                                    lvCurrentPage--

                                    if(txf_categories_search.searchedTxt === ""){
                                        btnCategoriesGet.clicked()
                                    }
                                    else{
                                        txf_categories_search.searchCompanies()
                                    }
                                }
                            }

                            onLastPage: {

                                lvCurrentPage = totalCompany/lvPageSize + 1

                                if(txf_categories_search.searchedTxt === ""){
                                    btnCategoriesGet.clicked()
                                }
                                else{
                                    txf_categories_search.searchCompanies()
                                }
                            }

                            //-- int customPage --//
                            onCustomPage: {

                                if(customPage >= 1 && customPage <= (totalCompany/lvPageSize)){
                                    lvCurrentPage = customPage

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

                            //-- site --//
                            Item{
                                visible: lv_isSiteShow
                                Layout.preferredWidth: Math.max(lbl_site.implicitWidth * 2, _widthSite)
                                Label{
                                    id: lbl_site
                                    text: "سایت"
                                    anchors.centerIn: parent
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

                            //-- abstract --//
                            Item{
                                visible: lv_isAbstractShow
                                Layout.preferredWidth: Math.max(lbl_abstract.implicitWidth * 2, _widthAbstract)
                                Label{
                                    id: lbl_abstract
                                    text: "حوزه فعالیت"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- fax company --//
                            Item{
                                visible: lv_isFaxCompanyShow
                                Layout.preferredWidth: Math.max(lbl_faxCompany.implicitWidth * 2, _widthFaxCompany)
                                Label{
                                    id: lbl_faxCompany
                                    text: "فکس کارخانه"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- fax office --//
                            Item{
                                visible: lv_isFaxShow
                                Layout.preferredWidth: Math.max(lbl_fax.implicitWidth * 2, _widthFax)
                                Label{
                                    id: lbl_fax
                                    text: "فکس دفتر"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- tell company --//
                            Item{
                                visible: lv_isTellCompanyShow
                                Layout.preferredWidth: Math.max(lbl_tellCompany.implicitWidth * 2, _widthTellCompany)
                                Label{
                                    id: lbl_tellCompany
                                    text: "تلفن کارخانه"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- tell office --//
                            Item{
                                visible: lv_isTellShow
                                Layout.preferredWidth: Math.max(lbl_tell.implicitWidth * 2, _widthTell)
                                Label{
                                    id: lbl_tell
                                    text: "تلفن دفتر"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- address company --//
                            Item{
                                visible: lv_isAddressCompanyShow
                                Layout.preferredWidth: Math.max(lbl_addressCompany.implicitWidth * 2, _widthAddressCompany)
                                Label{
                                    id: lbl_addressCompany
                                    text: "آدرس کارخانه"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- address office --//
                            Item{
                                visible: lv_isAddressShow
                                Layout.preferredWidth: Math.max(lbl_address.implicitWidth * 2, _widthAddress)
                                Label{
                                    id: lbl_address
                                    text: "آدرس دفتر فروش"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- city --//
                            Item{
                                visible: lv_isCityShow
                                Layout.preferredWidth: Math.max(lbl_city.implicitWidth * 2, _widthCity)
                                Label{
                                    id: lbl_city
                                    text: "شهر"
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

                            //-- pic --//
                            Item{
                                visible: lv_isPicShow
                                Layout.preferredWidth: Math.max(lbl_pic.implicitWidth * 2, _widthPic)
                                Label{
                                    id: lbl_pic
                                    text: "تصویر"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- company --//
                            Item{
                                visible: lv_isTitleShow
                                Layout.preferredWidth: Math.max(lbl_title.implicitWidth * 2, _widthTitle)
                                Label{
                                    id: lbl_title
                                    text: "شرکت"
                                    anchors.centerIn: parent
                                }
                            }

                            //-- categoryID --//
                            Item{
                                visible: lv_isIdShow
                                Layout.preferredWidth: Math.max(lbl_ccategoryID.implicitWidth * 2, _widthID)
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
                            highlightFollowsCurrentItem: true
                            highlightMoveDuration: height

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

                                    //-- site --//
                                    Item{
                                        visible: lv_isSiteShow
                                        Layout.preferredWidth: Math.max(lbl_site.implicitWidth * 2, _widthSite)
                                        Label{
                                            text: model.site
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- description --//
                                    TxtItmOfListView{
                                        visible: lv_isDescriptionShow
                                        Layout.preferredWidth: Math.max(lbl_description.implicitWidth * 2, _widthDescription)
                                        Layout.fillHeight: true
                                        txt: model.description
                                    }

                                    //-- abstract --//
                                    TxtItmOfListView{
                                        visible: lv_isAbstractShow
                                        Layout.preferredWidth: Math.max(lbl_abstract.implicitWidth * 2, _widthAbstract)
                                        Layout.fillHeight: true
                                        txt: model.abstract
                                    }

                                    //-- fax company --//
                                    Item{
                                        visible: lv_isFaxCompanyShow
                                        Layout.preferredWidth: Math.max(lbl_faxCompany.implicitWidth * 2, _widthFaxCompany)
                                        Label{
                                            text: model.faxCompany
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- fax office --//
                                    Item{
                                        visible: lv_isFaxShow
                                        Layout.preferredWidth: Math.max(lbl_fax.implicitWidth * 2, _widthFax)
                                        Label{
                                            text: model.fax
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- tell company --//
                                    Item{
                                        visible: lv_isTellCompanyShow
                                        Layout.preferredWidth: Math.max(lbl_tellCompany.implicitWidth * 2, _widthTellCompany)
                                        Label{
                                            text: model.tellCompany
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- tell office --//
                                    Item{
                                        visible: lv_isTellShow
                                        Layout.preferredWidth: Math.max(lbl_tell.implicitWidth * 2, _widthTell)
                                        Label{
                                            text: model.tell
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- address company --//
                                    Item{
                                        visible: lv_isAddressCompanyShow
                                        Layout.preferredWidth: Math.max(lbl_addressCompany.implicitWidth * 2, _widthAddressCompany)
                                        Label{
                                            text: model.addressCompany
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- address office --//
                                    Item{
                                        visible: lv_isAddressShow
                                        Layout.preferredWidth: Math.max(lbl_address.implicitWidth * 2, _widthAddress)
                                        Label{
                                            text: model.address
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- city --//
                                    TxtItmOfListView{
                                        visible: lv_isCityShow
                                        Layout.preferredWidth: Math.max(lbl_city.implicitWidth * 2, _widthCity)
                                        txt: model.city
                                    }

                                    //-- date --//
                                    Item{
                                        visible: lv_isDateShow
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
                                        visible: lv_isPicShow
                                        Layout.preferredWidth: Math.max(lbl_pic.implicitWidth * 2, _widthPic)
                                        Label{
                                            text: ""//model.pic
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, implicitWidth)
                                            elide: Text.ElideMiddle
                                        }
                                    }

                                    //-- title --//
                                    TxtItmOfListView{
                                        visible: lv_isTitleShow
//                                        Layout.preferredWidth: Math.max(lbl_title.implicitWidth * 2, _widthTitle)
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        txt: model.title
                                    }

                                    //-- categoryID --//
                                    Item{
                                        visible: lv_isIdShow
                                        Layout.preferredWidth: Math.max(lbl_ccategoryID.implicitWidth * 2, _widthID)
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

                                MouseArea{
                                    anchors.fill: parent

                                    onClicked: {
                                        lv.currentIndex = index

                                        txf_categories_categoryID.text      = listmodel.get(lv.currentIndex).id
                                        txf_categories_title.text           = listmodel.get(lv.currentIndex).title
                                        txf_categories_pic.text             = ""//listmodel.get(lv.currentIndex).pic
                                        txf_categories_date.text            = listmodel.get(lv.currentIndex).date
                                        txf_categories_city.text            = listmodel.get(lv.currentIndex).city
                                        txf_categories_address.text         = listmodel.get(lv.currentIndex).address
                                        txf_categories_addressCompany.text  = listmodel.get(lv.currentIndex).addressCompany
                                        txf_categories_tell.text            = listmodel.get(lv.currentIndex).tell
                                        txf_categories_tellCompany.text     = listmodel.get(lv.currentIndex).tellCompany
                                        txf_categories_fax.text             = listmodel.get(lv.currentIndex).fax
                                        txf_categories_faxCompany.text      = listmodel.get(lv.currentIndex).faxCompany
                                        txf_categories_description.text     = listmodel.get(lv.currentIndex).description
                                        txf_categories_abstract.text        = listmodel.get(lv.currentIndex).abstract
                                        txf_categories_site.text            = listmodel.get(lv.currentIndex).site
                                        txf_categories_email.text           = listmodel.get(lv.currentIndex).email
                                    }
                                }




                            }


                            onCurrentIndexChanged:{

                                log("lv.currentIndex = " + lv.currentIndex)

                                //-- controll count of listview --//
                                if(lv.count < 1) return

                                //-- controll currentIndex of listview --//
                                if(lv.currentIndex < 0) return

                                txf_categories_categoryID.text      = listmodel.get(lv.currentIndex).id
                                txf_categories_title.text           = listmodel.get(lv.currentIndex).title
                                txf_categories_pic.text             = ""//listmodel.get(lv.currentIndex).pic
                                txf_categories_date.text            = listmodel.get(lv.currentIndex).date
                                txf_categories_city.text            = listmodel.get(lv.currentIndex).city
                                txf_categories_address.text         = listmodel.get(lv.currentIndex).address
                                txf_categories_addressCompany.text  = listmodel.get(lv.currentIndex).addressCompany
                                txf_categories_tell.text            = listmodel.get(lv.currentIndex).tell
                                txf_categories_tellCompany.text     = listmodel.get(lv.currentIndex).tellCompany
                                txf_categories_fax.text             = listmodel.get(lv.currentIndex).fax
                                txf_categories_faxCompany.text      = listmodel.get(lv.currentIndex).faxCompany
                                txf_categories_description.text     = listmodel.get(lv.currentIndex).description
                                txf_categories_abstract.text        = listmodel.get(lv.currentIndex).abstract
                                txf_categories_site.text            = listmodel.get(lv.currentIndex).site
                                txf_categories_email.text           = listmodel.get(lv.currentIndex).email

                                handleTags()
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

                            //-- handle Tags --//
                            function handleTags(){

                                //-- clear listmodels of selected and unselected tags --//
                                listmodel_tag.clear()
                                listmodel_unselectedTags.clear()

                                //-- handle tags --//
                                var tagList = listmodel.get(lv.currentIndex).tagOfcategoryId.split("_")
                                //-- fill tags list model --//
                                for(var i=0; i< tagList.length; i++){

                                    if(tagList[i] != "" && tagList[i] != undefined)
                                        listmodel_tag.append({
                                                                 "title": tagList[i]
                                                                 , "isSelected": false
                                                             })
                                }

//                                log("`" + tagList + ", data = `" + listmodel.get(lv.currentIndex).tagOfcategoryId + "`" )
//                                log(categoryListmodel.count + ", len; " + listmodel_tag.count)

                                //-- fill unselected tags list model --//
                                for(i=0; i< categoryListmodel.count; i++){

                                    var isFind = false
                                    for(var j=0; j< listmodel_tag.count; j++){

                                        if(categoryListmodel.get(i).title == tagList[j]){
                                            isFind = true
                                        }
                                    }

                                    //-- if tag un selected --//
                                    if(!isFind){
                                        listmodel_unselectedTags.append({
                                                                            "title": categoryListmodel.get(i).title
                                                                            , "isSelected": false
                                                                        })
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

    //-- validate input text --//
    function validateTxtInput(){

        var msg = ""
        var existError = false

        if(txf_categories_tell.text != "" && !txf_categories_tell.acceptableInput){

            msg += "\n اطلاعات وارد شده برای تلفن دفتر صحیح نمی باشد"
            existError = true
        }
        if(txf_categories_tellCompany.text != "" && !txf_categories_tellCompany.acceptableInput){
            msg += "\n اطلاعات وارد شده برای تلفن کارخانه صحیح نمی باشد"
            existError = true
        }
        if(txf_categories_fax.text != "" && !txf_categories_fax.acceptableInput){
            msg += "\n اطلاعات وارد شده برای فکس دفتر صحیح نمی باشد"
            existError = true
        }
        if(txf_categories_faxCompany.text != "" && !txf_categories_faxCompany.acceptableInput){
            msg += "\n اطلاعات وارد شده برای فکس کارخانه صحیح نمی باشد"
            existError = true
        }
        if(txf_categories_site.text != "" && !txf_categories_site.acceptableInput){
            msg += "\n اطلاعات وارد شده برای آدرس وب سایت صحیح نمی باشد"
            existError = true
        }
        if(txf_categories_email.text != "" && !txf_categories_email.acceptableInput){
            msg += "\n اطلاعات وارد شده برای آدرس ایمیل صحیح نمی باشد"
            existError = true
        }

        if(existError){
            msg = "لطفا موارد زیر را بررسی کنید \n" + msg
        }

        return msg
    }

    //-- fetch data based on MaterialCategoryId --//
    function fetchBasedonMaterialCategory(categoryID){

        //-- validate inpute --//
        if(isNaN(categoryID)){
            log("invalid categoryID")
            return
        }


        //-- search based on categoryID --//
        var endpoint = "api/kootwall/Company?c=" + categoryID

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

            //-- triger selected item when new models fetched --//
            if(listmodel.count > 0){

                root.state = "FILL"

                lv.currentIndex = -1 //-- trigger current index --//
                lv.currentIndex = 0
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

    //-- clear all text of esit section --//
    function clearCategoriesTextfields(){
        if(isIdShow             && txf_categories_categoryID.enabled)       txf_categories_categoryID.text      = ""
        if(isDateShow           && txf_categories_date.enabled)             txf_categories_date.text            = ""
        if(isPicShow            && txf_categories_pic.enabled)              txf_categories_pic.text             = ""
        if(isTitleShow          && txf_categories_title.enabled)            txf_categories_title.text           = ""
        if(isCityShow           && txf_categories_city.enabled)             txf_categories_city.text            = ""
        if(isAddressShow        && txf_categories_address.enabled)          txf_categories_address.text         = ""
        if(isAddressCompanyShow && txf_categories_addressCompany.enabled)   txf_categories_addressCompany.text  = ""
        if(isFaxShow            && txf_categories_fax.enabled)              txf_categories_fax.text             = ""
        if(isFaxCompanyShow     && txf_categories_faxCompany.enabled)       txf_categories_faxCompany.text      = ""
        if(isTellShow           && txf_categories_tell.enabled)             txf_categories_tell.text            = ""
        if(isTellCompanyShow    && txf_categories_tellCompany.enabled)      txf_categories_tellCompany.text     = ""
        if(isDescriptionShow    && txf_categories_description.enabled)      txf_categories_description.text     = ""
        if(isAbstractShow       && txf_categories_abstract.enabled)         txf_categories_abstract.text        = ""
        if(isSiteShow           && txf_categories_site.enabled)             txf_categories_site.text            = ""
        if(isEmailShow          && txf_categories_email.enabled)            txf_categories_email.text           = ""
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

