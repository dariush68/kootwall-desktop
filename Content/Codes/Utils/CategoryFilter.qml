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


    property string pageTitle:              "فیلتر" //-- modul header title --//
    property bool   isExpand:               true        //-- keep Expand mode status --//
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
        if(listmodel.count > 0 /*&& lv_categories.currentIndex < 0*/){

            var temp = lv_categories.currentIndex
            lv_categories.currentIndex = -1
            lv_categories.currentIndex = temp

        }
    }

    property bool   _isEditable:            false  //-- allow user to edit text Item --//
    property bool   _localLogPermission:    true   //-- local log permission --//

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

    //-- load categories from DB --//
    signal loadCatsFromDB()
    onLoadCatsFromDB: {

        listmodel.clear()

        //-- get categories list from global category listmodel --//
        for(var i=0; i< lm_category.count; i++){
            listmodel.append(lm_category.get(i))
        }


        //-- go to first item and load them data --//
        if(listmodel.count > 0){

            lv_categories.currentIndex = -1
            lv_categories.currentIndex = 0

        }
    }

    Component.onCompleted: {
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

                    Item { Layout.fillWidth: true } //-- filler --//

                    //-- categoryID --//
                    Label{
                        visible: isIdShow
                        text: "شماره"
                    }

                    //-- title --//
                    Label{
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

                    Item { Layout.fillWidth: true } //-- filler --//
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

                    model: listmodel

                    delegate: ItemDelegate{
                        width: parent.width
                        height: 40

                        font.pixelSize: Qt.application.font.pixelSize
                        Material.foreground: "#5e5e5e"

                        Rectangle{anchors.fill: parent; color: index%2 ? "transparent" : "#44e0e0e0"; }

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

                        //-- spliter --//
                        Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                        onClicked: {
                            lv_categories.currentIndex = index
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


            //-- Serach --//
            SearchField{
                id: txf_categories_search

                Layout.fillWidth: true
                visible: isExpand && false

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
                        }

                        //-- triger subcategory list --//
                        returnSelectedCategory(listmodel.get(lv_categories.currentIndex).id)

                        message.text = "searched data recived"
                        triggerMsg("جست و جو انجام شد", "LOG")
                    })
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
                                      + (isIdShow    ? listmodel.get(lv_categories.currentIndex).id      : "")
                                      + (isTitleShow ? "  " + listmodel.get(lv_categories.currentIndex).title    : "")
                                      + (isPicShow   ? "  " + listmodel.get(lv_categories.currentIndex).pic      : "")
                                      + (isDateShow  ? "  " + listmodel.get(lv_categories.currentIndex).date     : "")
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
                visible: isExpand && _isEditable

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

