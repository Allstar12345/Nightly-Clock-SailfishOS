/**
Copyright (C) 2020 Allstar Software (Paul Wallace)
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import DownloadManager 1.0

Page {
    id: page
    property bool downloadingFile
    property bool newInstallWaiting
    property int downloadPercentage
    property string updaterNewAppVersionNumber
    property string updaterNewVersionNumber
    property string updaterNewVersionFileName
    property string updaterNewVersionFileSize
    property string updaterNewVersionDate
    property string updaterNewVersionChangelog
    property string updaterNewVersionImage1Url
    property string updaterNewVersionImage2Url
    property string updaterNewVersionImage3Url
    property string updaterNewVersionImage4Url
    property string updaterNewVersionImage5Url
    property string updaterNewVersionImage6Url
    property string updaterNewVersionURLARM
    property string updaterNewVersionURLARM64
    property string updaterNewVersionURLi386
    property string updaterNewVersionFileNameARM
    property string updaterNewVersionFileNameARM64
    property string updaterNewVersionFileNamei386
    allowedOrientations: decideOrientation();

    Rectangle{
        id: liveView;
        property alias source: liveImg.source;
        anchors.fill: parent;
        z:Infinity;
        opacity: 0;
        scale:0.97;

    function show(file){
        source = file;
        opacity = 1;
        scale = 1;
    }

    function hide(){
        opacity = 0;
        scale = 0.97;
        liveImg.source = "";
    }

    function delayedHide(){
        hideTimer.start();
    }

    Timer{
        id: hideTimer;
        interval: 1000;
        onTriggered: {
            liveView.hide();
        }
    }
    Behavior on scale {ScaleAnimator{}}
    Behavior on opacity {FadeAnimation{}}
    color:"Transparent"

    Image{
        z:1;
        id: liveImg;
        width:parent.width/1.2;
        height:parent.height/1.2;
        anchors{
            centerIn: parent
        }

    BusyIndicator{
        running: liveImg.status == Image.Loading? true : false;
        id: busyy
        ;size: BusyIndicatorSize.Large;
        anchors{
            centerIn:parent
        }
    }
    }

    Rectangle{
        anchors.fill: parent;
        opacity: 0.8;
        color:Qt.darker(Theme.highlightBackgroundColor)
    }
    }

    Component.onCompleted: {
        modell.append({"url": updaterNewVersionImage1Url});
        modell.append({"url": updaterNewVersionImage2Url});
    if(updaterNewVersionImage3Url.length>0) modell.append({"url": updaterNewVersionImage3Url})
    if(updaterNewVersionImage4Url.length>0) modell.append({"url": updaterNewVersionImage4Url})
    if(updaterNewVersionImage5Url.length>0) modell.append({"url": updaterNewVersionImage5Url})
    if(updaterNewVersionImage5Url.length>0) modell.append({"url": updaterNewVersionImage6Url})
    }

    DownloadManager{id: down}
    Connections{
        target: down;
        onProgressPercentage: {
            downloadPercentage = percentage;
        }
        onDownloadError:{
            downloadingFile = false;
        }
        onDownloadComplete:{
            if(downloadingFile){
                newInstallWaiting = true;
                downloadingFile = false;
                Notices.show(qsTr("Download complete, pull down to install"), 5000, Notice.Center);
            }
        }
    }

    ListModel{id: modell}
    SilicaFlickable {

        PullDownMenu{
        MenuItem{
            text:newInstallWaiting? qsTr("Install Update"): qsTr("Download Update")+ " "+ updaterNewVersionFileSize;
            onClicked: {
                if(newInstallWaiting){
                    if(qmlUtils.returnArchitecture() === "i386"){
                        qmlUtils.openURL("file://"+qmlUtils.homePath()+ "/"+ updaterNewVersionFileNamei386)
                    }

                    else if(qmlUtils.returnArchitecture() === "arm"){
                        qmlUtils.openURL("file://"+qmlUtils.homePath()+ "/"+ updaterNewVersionFileNameARM)
                    }

                    else if(qmlUtils.returnArchitecture() === "arm64"){
                        qmlUtils.openURL("file://"+qmlUtils.homePath()+ "/"+ updaterNewVersionFileNameARM64)
                    }
                }

                else {
                    downloadingFile=true;
                    if(qmlUtils.returnArchitecture() === "i386"){
                        down.download(updaterNewVersionURLi386, qmlUtils.homePath()+ "/"+ updaterNewVersionFileNamei386)
                    }

                    if(qmlUtils.returnArchitecture() === "arm"){
                        down.download(updaterNewVersionURLARM, qmlUtils.homePath()+ "/"+ updaterNewVersionFileNameARM)
                    }

                   else if(qmlUtils.returnArchitecture() === "arm64"){
                        down.download(updaterNewVersionURLARM64, qmlUtils.homePath()+ "/"+ updaterNewVersionFileNameARM64)
                    }

                }
            }
        }
        }
        id: flickable1;
        contentHeight: content.height;
        anchors.fill: parent;
        bottomMargin: 10;
        ScrollDecorator{flickable: flickable1}

        Column {
            id: content
            width: parent.width
            spacing: 10
            PageHeader {
                id: header;
                title: qsTr("Update Available")

            }
            ProgressBar {
                visible: downloadingFile;
                value: downloadPercentage;
                minimumValue: 0;
                maximumValue: 100;
                id: pro;
                width:parent.width
            }

    SlideshowView {
        id: view;
        clip:true;
        width: parent.width;
        height:compactMode? Screen.height/2.5: Screen.height/3.3;
        snapMode: ListView.SnapOneItem;
        highlightRangeMode: ListView.StrictlyEnforceRange;
        itemWidth: width/3;
        model: modell;

            delegate: Rectangle {
            color: "Transparent"
            width: view.width/3
            height: view.height
            Image{
                id: image;
                fillMode: Image.PreserveAspectFit;
                anchors.fill: parent;
                source:model.url;

                MouseArea{
                enabled: largeScreen? false : true
                anchors.fill: parent;
                z:1
                propagateComposedEvents: true

                onPressAndHold: {
                    liveView.show(image.source);
                }

                onReleased: {
                    liveView.hide();
                }

                onExited: {
                    liveView.delayedHide();
                }
                }
                BusyIndicator{
                    size: BusyIndicatorSize.Medium;
                    anchors.centerIn: parent;
                    running: image.status == Image.Loading ? true : false
                }
            }
        }
    }

        SectionHeader{text: qsTr("Description")}

        Rectangle{
            color:"Transparent";
            height: item1.height*2;
            width: parent.width;

        DetailItem {
            id: item1;
            label: qsTr("Released");
            value: updaterNewVersionDate;
        }

        DetailItem{
            id: item2;
            anchors{
                top:item1.bottom
            }
            label: qsTr("App Version");
            value: updaterNewAppVersionNumber;
        }
        }

        DetailItem {
         anchors{
             top:item2.bottom
         }
         label: qsTr("Build Number")
         value: updaterNewVersionNumber
          }

        SectionHeader{text: qsTr("Changelog")}

        Label{
            x: 15;
            wrapMode: Text.Wrap;
            width: parent.width-30;
            font.pixelSize: Theme.fontSizeExtraSmall;
            text:updaterNewVersionChangelog;
        }
    }
    }
}
