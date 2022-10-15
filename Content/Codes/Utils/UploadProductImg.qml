import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import QtGraphicalEffects 1.0
import Qt.labs.platform 1.0

import "./../../font/Icon.js" as MdiFont
import "./../REST/apiservice.js" as Service
import "./../Utils/Util.js" as Util
import "./../Utils"

ApplicationWindow{
    id: root

    visible: false

    property Item displayItem: null

    //-- visible window --//
    signal openWin(string selectedProductId, string selectedProductTitle, string selectedCompanyTitle)
    onOpenWin:{

        //-- load companies list from DataBase --//

        root.visible = true

        //        console.log(selectedProductId)
        _selectedProductId = selectedProductId

        lbl_product_title.text = selectedProductTitle
        lbl_product_id.text = selectedProductId
        lbl_companyTitle.text = selectedCompanyTitle

        //        getProduct(selectedProductId)
        getProductImages(selectedProductId)

    }

    property string pageTitle:      "بارگذاری تصویر"   //-- modul header title --//
    property bool   isLogEnabled:   true       //-- global log permission --//

    property bool   _localLogPermission:    true   //-- local log permission --//
    property string  _selectedProductId: ""

    objectName: "UploadProductImage"

    width: 400
    height: 500

    //    visible: false


    Connections{
        target: imageUploader

        //-- int errorCode, const QString& errorMessage --//
        onImageUploaded:{

            console.log(errorCode + ", " + errorMessage)
        }
    }


    //-- body --//
    Page{
        anchors.fill: parent
        font.family: font_irans.name


        //-- edit item  --//
        Rectangle{
            anchors.fill: parent
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


            ColumnLayout{
                anchors.fill: parent

                //-- slide show --//
                ItemDelegate{
                    id: itmDelImg

                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.5
                    Layout.margins: 3

                    Image {
                        visible: false
                        id: img1
                        source: "http://127.0.0.1:8000/media/debt-relief-icon-vector-20994518.jpg"
                        anchors.fill: parent
                        sourceSize: Qt.size(parent.width, parent.height)
                    }

                    SwipeView{
                        id:slider
                        anchors.fill: parent
                        //                        height: parent.height/1.7
                        //                        width: height
                        //                        x:(parent.width-width)/2//make item horizontally center
                        property var model :ListModel{}
                        clip:true
                        Repeater {
                            model:listmodel_images
                            Image{
                                width: slider.width
                                height: slider.height
                                source:pic
                                fillMode: Image.Stretch

                                RoundButton{
                                    text: MdiFont.Icon.delete_forever
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 10
                                    radius: implicitHeight

                                    font.pixelSize: Qt.application.font.pixelSize * 1

                                    onClicked: {

                                        var url = Service.BASE
                                        Qt.openUrlExternally(url +"/"+model.id+"/delete-product-image")
                                    }

                                }
                            }
                        }
                    }

                    PageIndicator {
                        anchors.bottom: slider.bottom
                        anchors.bottomMargin: 10
                        x:(parent.width-width)/2
                        currentIndex: slider.currentIndex
                        count: slider.count
                    }

                    //-- border --//
                    Rectangle{
                        anchors.fill: parent
                        color: "#00000000"
                        border{width: 1; color: "#9e9e9e"}
                    }
                }

                //-- add new image --//
                Button{
                    text: "افزودن تصویر جدید"
                    Layout.alignment: Qt.AlignHCenter
                    Material.background: Util.color_kootwall_dark
                    Material.foreground: "white"

                    onClicked: {

                        var url = Service.BASE
//                        Qt.openUrlExternally(url +"/"+_selectedProductId+"/product-image-list")
                        Qt.openUrlExternally(url +"/"+_selectedProductId+"/upload-product-image")

//                        return
//                        fileDialog.open()

                    }
                }

                /*FileDialog{
                    id: fileDialog

                    onAccepted: {
                        console.log(file)

                        var addresFile = file.toString().substring(8,file.length)
                        //-- verify token --//
                        checkToken(function(resp){

                            console.log("start to upload ... ")

                            imageUploader.uploadImage(addresFile, _token_access)

                        })
                    }
                }*/

                //-- seperetor --//
                Rectangle{
                    Layout.fillWidth: true
                    height: 1
                    color: "#9e9e9e"
                }

                //-- information of company and product --//
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: lbl_companyTitle.implicitHeight * 6

                    //                    Rectangle{anchors.fill: parent; color: "#33FF3000"}

                    ColumnLayout{
                        //                        visible: false
                        anchors.fill: parent
                        anchors.margins: 10

                        //-- company lable --//
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: lbl_companyTitle.implicitHeight * 2

                            RowLayout{
                                anchors.fill: parent

                                Label{
                                    id: lbl_companyTitle

                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight
                                    font.family: font_irans.name

                                    text: ""
                                }

                                Label{

                                    Layout.alignment: Qt.AlignRight
                                    font.family: font_irans.name

                                    text: "شرکت:"


                                }
                            }
                        }

                        //-- product lable --//
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: lbl_companyTitle.implicitHeight * 2
                            //                            Rectangle{anchors.fill: parent; color: "#33FF4400"}

                            RowLayout{
                                anchors.fill: parent

                                Label{
                                    id: lbl_product_title

                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight
                                    font.family: font_irans.name

                                    text: ""
                                }

                                Label{

                                    Layout.alignment: Qt.AlignRight
                                    font.family: font_irans.name

                                    text: "محصول:"


                                }
                            }
                        }

                        //-- id lable --//
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: lbl_companyTitle.implicitHeight * 2
                            //                            Rectangle{anchors.fill: parent; color: "#33FF4400"}

                            RowLayout{
                                anchors.fill: parent

                                Label{
                                    id: lbl_product_id

                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight
                                    font.family: font_irans.name

                                    text: ""
                                }

                                Label{

                                    Layout.alignment: Qt.AlignRight
                                    font.family: font_irans.name

                                    text: "شماره شناسایی:"


                                }

                            }
                        }

                    }
                }


                //-- filler --//
                Item{Layout.fillHeight: true}
            }

        }

    }

    //-- lis model of product images --//
    ListModel{
        id: listmodel_images
    }

    //-- get production info based on selected product id --//
    function getProduct(productId){

        var endpoint = "api/kootwall/CompanyProduct?n=" + productId

        Service.get_all( endpoint, function(resp, http) {
            console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
                message.text = resp.error
                triggerMsg(resp.error, "RED")
                return

            }

            var dataRec = resp.results[0]
            lbl_product_id.text = dataRec.id
            //            lbl_product_pic.text = dataRec.pic1

            //-- set branchTitles and Title --//
            var branchStr = ""
            if(dataRec.category !== null){

                branchStr += dataRec.category.title
            }
            if(dataRec.baseCategory !== null){

                branchStr += " > " + dataRec.baseCategory.title
            }
            if(dataRec.materialCategory !== null){

                branchStr += " > " +  dataRec.materialCategory.title
            }
            if(dataRec.material !== null){

                branchStr +=  " > " + dataRec.material.title
            }
            if(dataRec.subMaterial !== null){

                branchStr +=  " > " + dataRec.subMaterial.title
            }
            if(dataRec.subSubMaterial !== null){

                branchStr +=  " > " + dataRec.subSubMaterial.title
            }

            var titleList = branchStr.split(" > ")
            var title = titleList[titleList.length-1]
            lbl_product_title.text = title

            /*listmodel.clear()

            for(var i=0; i<resp.length; i++) {
                listmodel.append(resp[i])
                listmodel.setProperty(i, "isSelected", false)
                listmodel.setProperty(i, "orderSelected", -1)

            }

            //-- save fetched data to global category listmodel --//
            lm_category = listmodel

            message.text = "all data recived"
            triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")*/
        })
    }

    //-- get production image list based on selected product id --//
    function getProductImages(productId){

        var endpoint = "api/kootwall/ProductPicture?k=" + productId

        Service.get_all( endpoint, function(resp, http) {
            console.log( "state = " + http.status + " " + http.statusText + ', /n handle get all resp: ' + JSON.stringify(resp))

            //-- check ERROR --//
            if(resp.hasOwnProperty('error')) // chack exist error in resp
            {
                log("error detected; " + resp.error)
                //                message.text = resp.error
                //                triggerMsg(resp.error, "RED")
                return

            }


            listmodel_images.clear()

            for(var i=0; i<resp.length; i++) {
                listmodel_images.append(resp[i])
                //                listmodel.setProperty(i, "isSelected", false)
                //                listmodel.setProperty(i, "orderSelected", -1)
                console.log("["+i+"] = " + listmodel_images.get(i).pic)

            }


            //            message.text = "all data recived"
            //            triggerMsg("بارگذاری با موفقیت انجام شد", "LOG")
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
