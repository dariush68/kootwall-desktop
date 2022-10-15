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

    signal show(string searchedText)
    onShow: {
//                msg = searchedText

        listmodelSearch.clear()

        popupSearch.open()

        popupSearch.searchCategory(searchedText, function() {

            log("search Categor done")
        })

    }

    //-- move to selected category --//
    //-- variant data:'category'           : id of category,
                //    'baseCategory'       : id of baseCategory,
                //    'materialCategory'   : id of materialCategory,
                //    'material'           : id of material,
                //    'subMaterial'        : id of subMaterial,
                //    'subSubMaterial'     : id of subSubMaterial,
                //    'tag'                : _CATEGORY TAG
    signal moveToSelectedCategory(variant data)

    parent: mainPage

    property bool   isLogEnabled:   true       //-- global log permission --//
    objectName: "Global Search"

    modal: true
    focus: true
    //        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    width: parent.width/2 //lblMsg.implicitWidth * 1 + 30
    height: parent.height * 0.8 //lblMsg.contentHeight * 3
    x: parent.width/2 - width/2
    y: parent.height/2 - height/2
    Material.theme: Material.Light  //-- Light, Dark, System

    ListModel{
        id: listmodelSearch
    }


    ColumnLayout{
        anchors.fill: parent
        anchors.margins: 10

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


            //-- title --//
            Label{
                text: "موارد یافت شده"
                anchors.centerIn: parent
                color: "black"
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
                id: lv_search

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

                    Label {
                        id: sectionLabel
                        text: section
                        anchors.centerIn: parent
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

                        //-- title --//
                        Label{
                            text: model.title //+ ","
                        }

                        Item { Layout.fillWidth: true } //-- filler --//
                    }

                    //-- spliter --//
                    Rectangle{width: parent.width; height: 1; color: "#e5e5e5"; anchors.bottom: parent.bottom}

                    onClicked: {
                        lv_search.currentIndex = index

                    }

                    onDoubleClicked: {

                        var tag     = listmodelSearch.get(index).tag
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

                        popupSearch.close()
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

    function searchCategory(searchedtext, cb){

        //-- search based on title --//
        var endpoint = "api/kootwall/CatSearch?category=" + searchedtext

        Service.get_all( endpoint, function(resp, http) {
            log( "state = " + http.status + " " + http.statusText + ', /n handle search resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
//                        message.text = resp.error
//                        triggerMsg(resp.error, "RED")

                cb()

                return

            }


            //-- check Category --//
            if(resp.hasOwnProperty('Category'))
            {

                for(var i=0; i<resp.Category.length; i++) {

                    listmodelSearch.append({
                                               'title'              : resp.Category[i].title,
                                               'category'           : resp.Category[i].id.toString(),
                                               'baseCategory'       : "",
                                               'materialCategory'   : "",
                                               'material'           : "",
                                               'subMaterial'        : "",
                                               'subSubMaterial'     : "",
                                               'cat'                : "فهرست بها",
                                               'tag'                : _CATEGORY
                                           })

                }
            }

            //-- check BaseCategory --//
            if(resp.hasOwnProperty('BaseCategory'))
            {

                for(var i=0; i<resp.BaseCategory.length; i++) {

                    listmodelSearch.append({
                                               'title'              : resp.BaseCategory[i].title,
                                               'category'           : resp.BaseCategory[i].category.toString(),
                                               'baseCategory'       : resp.BaseCategory[i].id.toString(),
                                               'materialCategory'   : "",
                                               'material'           : "",
                                               'subMaterial'        : "",
                                               'subSubMaterial'     : "",
                                               'cat'                : "فصول اصلی",
                                               'tag'                : _BASECATEGORY
                                           })

                }
            }

            //-- check MaterialCategory --//
            if(resp.hasOwnProperty('MaterialCategory'))
            {

                for(var i=0; i<resp.MaterialCategory.length; i++) {

                    listmodelSearch.append({
                                               'title'              : resp.MaterialCategory[i].title,
                                               'category'           : resp.MaterialCategory[i].category.toString(),
                                               'baseCategory'       : resp.MaterialCategory[i].baseCategory.toString(),
                                               'materialCategory'   : resp.MaterialCategory[i].id.toString(),
                                               'material'           : "",
                                               'subMaterial'        : "",
                                               'subSubMaterial'     : "",
                                               'cat'                : "بخش 1",
                                               'tag'                : _CATEGORYMATERIAL
                                           })

                }
            }

            //-- check Material --//
            if(resp.hasOwnProperty('Material'))
            {

                for(var i=0; i<resp.Material.length; i++) {

                    listmodelSearch.append({
                                               'title'              : resp.Material[i].title,
                                               'category'           : resp.Material[i].category.toString(),
                                               'baseCategory'       : resp.Material[i].baseCategory.toString(),
                                               'materialCategory'   : resp.Material[i].materialCategory.toString(),
                                               'material'           : resp.Material[i].id.toString(),
                                               'subMaterial'        : "",
                                               'subSubMaterial'     : "",
                                               'cat'                : "بخش 2",
                                               'tag'                : _MATERIAL
                                           })

                }
            }

            //-- check SubMaterial --//
            if(resp.hasOwnProperty('SubMaterial'))
            {

                for(var i=0; i<resp.SubMaterial.length; i++) {

                    listmodelSearch.append({
                                               'title'              : resp.SubMaterial[i].title,
                                               'category'           : resp.SubMaterial[i].category.toString(),
                                               'baseCategory'       : resp.SubMaterial[i].baseCategory.toString(),
                                               'materialCategory'   : resp.SubMaterial[i].materialCategory.toString(),
                                               'material'           : resp.SubMaterial[i].material.toString(),
                                               'subMaterial'        : resp.SubMaterial[i].id.toString(),
                                               'subSubMaterial'     : "",
                                               'cat'                : "بخش 3",
                                               'tag'                : _SUBMATERIAL
                                           })

                }
            }

            //-- check SubSubMaterial --//
            if(resp.hasOwnProperty('SubSubMaterial'))
            {

                for(var i=0; i<resp.SubSubMaterial.length; i++) {

                    listmodelSearch.append({
                                               'title'              : resp.SubSubMaterial[i].title,
                                               'category'           : resp.SubSubMaterial[i].category.toString(),
                                               'baseCategory'       : resp.SubSubMaterial[i].baseCategory.toString(),
                                               'materialCategory'   : resp.SubSubMaterial[i].materialCategory.toString(),
                                               'material'           : resp.SubSubMaterial[i].material.toString(),
                                               'subMaterial'        : resp.SubSubMaterial[i].subMaterial.toString(),
                                               'subSubMaterial'     : resp.SubSubMaterial[i].id.toString(),
                                               'cat'                : "بخش 4",
                                               'tag'                : _SUBSUBMATERIAL
                                           })

                }
            }



            //--trigger job done --//
            cb()
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

