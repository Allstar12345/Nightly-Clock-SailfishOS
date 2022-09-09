import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"
import "../clockfacepickeritems"

Page{
    signal clearSelected
    property string a
    property bool tutorialMode:false
    property int selectedIndex: -1
    property int savedSelectedIndex: parseInt(appsettings.getSystemSetting("clockFacePickerIndex", "0"))
    onStatusChanged: {
        if(status == PageStatus.Inactive){
            changeClockFace();
        }
    }

    function changeClockFace(){
      console.log("LISTVIEW INDEX " + listView.currentIndex + " SELECTED INDEX INT: " + clockFacePicker.selectedIndex)

       if(clockFacePicker.selectedIndex === -1){}
       else if(clockFacePicker.selectedIndex === 13){
           if(customClockFaceURL === ""){
               clockFacePicker.selectedIndex=0;
               changeClockFace();
           }
           else{ usingCustomClockFace=true;
               appsettings.saveSystemSetting("clockFacePickerIndex", listView.currentIndex);
               appsettings.saveSystemSetting("usingExternalClockFace", "");
               usingExternal = false;
               qmlUtils.showBanner(qsTr("Clock style changed"), "", 1000);
           }
       }
        else{
        if(listView.currentIndex === 0){
            usingCustomClockFace = false;
            customClockFaceURL = "";
            usingCustomClockFace = false;
        }

        else{
        a= listModel.get(listView.currentIndex).url;
        a= "clockfaces/" + a.substring(24, a.length);
        usingCustomClockFace = true;
        customClockFaceURL = a;
        }

        appsettings.saveSystemSetting("clockFacePickerIndex", listView.currentIndex);
        appsettings.saveSystemSetting("usingExternalClockFace", "");
        qmlUtils.showBanner(qsTr("Clock style changed"), "", 1000);
        }

       console.log("1: " + usingCustomClockFace + " 2: " + customClockFaceURL)
    }

    QtObject { id: creator; property Component com: null;function createComponent (qmlfile){com = Qt.createComponent(qmlfile);com.createObject( clockFacePicker)} }
    id: clockFacePicker
    signal repaintFaces
    Timer{
        interval: 50;
        id: launchTimer;
        onTriggered: {
            listModel.append({"url":"../clockfacepickeritems/DigitalClock.qml"});
            listModel.append({"url":"../clockfacepickeritems/AnalogDefault.qml"});
            listModel.append({"url":"../clockfacepickeritems/AnalogDefaultDateWindow.qml"});
            listModel.append({"url":"../clockfacepickeritems/AnalogBasic.qml"});
            listModel.append({"url":"../clockfacepickeritems/AnalogPrecision.qml"});
            listModel.append({"url":"../clockfacepickeritems/AnalogRailway.qml"});
            listModel.append({"url":"../clockfacepickeritems/AnalogTactical.qml"});
            listModel.append({"url":"../clockfacepickeritems/Prominent.qml"});
            listModel.append({"url":"../clockfacepickeritems/ProminentColour.qml"});
            listModel.append({"url":"../clockfacepickeritems/Greenium.qml"});
            listModel.append({"url":"../clockfacepickeritems/GreeniumColour.qml"});
            listModel.append({"url":"../clockfacepickeritems/GreeniumNoSeconds.qml"});
            listModel.append({"url":"../clockfacepickeritems/GreeniumNoSecondsColour.qml"});
            listModel.append({"url":"../clockfacepickeritems/ExternalClockFacePicker.qml"});
        }
    }

    Connections{
        target:main;
        onRepaintClockFace:{
            pageStack.pop();
        }
    }

    ListModel{id: listModel}

   allowedOrientations: decideOrientation();
  Component.onCompleted: {
      launchTimer.start();
      if(appsettings.getSystemSetting("clockfacepickerfirstRun", "")===""){
          creator.createComponent("../ClockFacePickerTutorial.qml");
      }
  }

    PageHeader {
            id: pHeader
            title: qsTr("Choose a clock style")
        }
  BusyIndicator{
    running: true
    id: busy
    size: BusyIndicatorSize.Large
    anchors{
        centerIn:parent
    }
    }

ListView{
id: listView;
opacity: 0
visible: false
clip:true;
Behavior on opacity {OpacityAnimator{}}
orientation: Qt.Horizontal
width:parent.width
currentIndex: -1
contentWidth: listView.count * Screen.width
anchors{
    top:pHeader.bottom;
    bottom:pageIndi.top
}
snapMode: ListView.SnapOneItem;
boundsBehavior: Flickable.StopAtBounds;
highlightRangeMode: ListView.StrictlyEnforceRange;
model: listModel
cacheBuffer:1

// Makes touchwiz look smooth without these loading delays
Timer{
    id: fadeInDelay;
    interval: 800;
    onTriggered:{
        busy.visible = false;
        busy.running = false;
        listView.visible = true;
        listView.opacity = 1;
        pageIndi.visible = true;
    }
}

Timer{
    id: timer;
    interval: 400;
    onTriggered:{
    listView.currentIndex = clockFacePicker.savedSelectedIndex;
    }
}

Component.onCompleted: {
    timer.start();
    fadeInDelay.start();
}

delegate: Rectangle {
    property bool selected
    Connections{
        target: clockFacePicker;
        onClearSelected:{
            selected = false;
        }
    }

    onSelectedChanged: {
        if(selected) clockFacePicker.selectedIndex = listView.currentIndex;
        else clockFacePicker.selectedIndex = -1;
    }
    color: "Transparent"
    id: delg
    width:  clockFacePicker.width
    height: listView.height
    ComboBox{
        id: fontSizeCombo
        opacity: listView.currentIndex===0?1:0;
        Behavior on opacity {OpacityAnimator{}}

      Component.onCompleted: {
            if(appsettings.getSystemSetting("clocksizeLabel", "") === "")fontSizeCombo.currentIndex = 0
            else fontSizeCombo.currentIndex = parseInt(appsettings.getSystemSetting("clocksizeLabel", ""))
      }

        anchors{
            bottom:parent.bottom;
            bottomMargin: Theme.paddingSmall
        }

        onCurrentIndexChanged:{
            appsettings.saveSystemSetting("clocksizeLabel", currentIndex);
        }

        label:qsTr("Digital Clock Size")
        menu:ContextMenu{
            MenuItem{
                text:qsTr("Large");
                value:"Large";
                onClicked:{
                    appsettings.saveSystemSetting("fontSize", value);
                    appsettings.saveSystemSetting("fontSizeLabel", text);
                    updateDateSize();
                }
            }

            MenuItem{
                text:qsTr("Medium");
                value:"Medium";
                onClicked:{
                    appsettings.saveSystemSetting("fontSize", value);
                    appsettings.saveSystemSetting("fontSizeLabel", text);
                    updateDateSize();
                }
            }

            MenuItem{
                text:qsTr("Small");
                value:"Small";
                onClicked:{appsettings.saveSystemSetting("fontSize", value);
                    appsettings.saveSystemSetting("fontSizeLabel", text);
                    updateDateSize();
                }
            }
            MenuItem{
                text:qsTr("Very Small");
                value:"XSmall";
                onClicked:{
                    appsettings.saveSystemSetting("fontSize", value);
                    appsettings.saveSystemSetting("fontSizeLabel", text);
                    updateDateSize();
                }
            }

        }
    }
    Image{
        visible:compactMode;
        Behavior on opacity{OpacityAnimator{}}
        opacity:delg.selected ?0.95 : 0;
        z:1;
        sourceSize.height: Theme.iconSizeLarge;
        sourceSize.width: Theme.iconSizeLarge;
        width: sourceSize.width;
        height: sourceSize.height

     anchors{
         top:parent.top;
         topMargin: Theme.paddingMedium;
         horizontalCenter: parent.horizontalCenter
     }
     source:"../images/clockface_picker_selected.svg"}

    Rectangle{
        Behavior on opacity{OpacityAnimator{}}
        opacity:delg.selected? 0.1 : 0;
        anchors.fill: parent;
        color:Theme.secondaryHighlightColor;
    }
    Loader{
    asynchronous: true
    source: model.url
    Behavior on opacity{OpacityAnimator{}}
    visible: status == Loader.Ready
    opacity:status == Loader.Ready? fontSizeCombo._menuOpen?0:1:0
    anchors.centerIn: parent
    }
}
}

Item{
    id: pageIndi;
    visible: false;
    anchors{
        bottom:parent.bottom;
        right:parent.right;
        left:parent.left;
        rightMargin: Theme.paddingSmall/2;
        leftMargin: Theme.paddingSmall/2
    }
    height:Theme.itemSizeExtraSmall/11

Rectangle{
    onXChanged:{
        opacity = 0.6;
        if(opaTimer.running)opaTimer.restart();
        else opaTimer.start();
    }

    Timer{
        id: opaTimer;
        interval: 1500;
        onTriggered: {
            parent.opacity = 0;
        }
    }
    Behavior on opacity {OpacityAnimator{duration: 150;}}
    Behavior on x{NumberAnimation{}}
    color: lightTheme? Theme.darkPrimaryColor : Theme.lightPrimaryColor;
    opacity:0;
    x:listView.currentIndex*width;
    width: clockFacePicker.width/14;
    height: Theme.itemSizeExtraSmall/12;
    anchors{
        verticalCenter: parent.verticalCenter
    }
}
}

}
