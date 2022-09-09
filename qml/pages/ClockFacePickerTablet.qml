import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"
import "../clockfacepickeritems"

Page{
    signal clearSelected
    property bool tutorialMode:false
    property string a
    property int selectedIndex: -1
    id: clockFacePicker
    signal repaintFaces
Rectangle{
id: liveView
property alias source: liveLoader.source
anchors.fill: parent
z:Infinity
opacity: 0
scale:0.97

function show(file){
    source = file;
    opacity = 1;
    scale = 1;
}
function hide(){
    opacity = 0;
    scale = 0.97;
    source = "";
}

Behavior on scale {ScaleAnimator{}}
Behavior on opacity {OpacityAnimator{}}
color:"Transparent"

Loader{
id: liveLoader
z:1
anchors.centerIn: parent;
asynchronous: true

BusyIndicator{
   running: liveLoader.status == Loader.Loading?true:false
   id: busyy
   size: BusyIndicatorSize.Large
   anchors{centerIn:parent}
   }

}
Rectangle{
anchors.fill: parent
opacity: 0.8
color:Qt.darker(Theme.highlightBackgroundColor)
}
}
  onSelectedIndexChanged: {
      console.log(selectedIndex);
  }
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
               clockFacePicker.selectedIndex = 0;
               usingCustomClockFace = false;
               customClockFaceURL = "";
               usingCustomClockFace = false;
           }
           else{
               usingCustomClockFace = true;
               appsettings.saveSystemSetting("clockFacePickerIndex", listView.currentIndex);
               appsettings.saveSystemSetting("usingExternalClockFace", "true");
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
        a = listModel.get(listView.currentIndex).url;
        a = "clockfaces/"+a.substring(24, a.length);
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

    Timer{
        interval: 400;
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
            listModel.append({"url":"../clockfacepickeritems/GreeniumColour.qml"});l
            istModel.append({"url":"../clockfacepickeritems/GreeniumNoSeconds.qml"});
            listModel.append({"url":"../clockfacepickeritems/GreeniumNoSecondsColour.qml"});
            listModel.append({"url":"../clockfacepickeritems/ExternalClockFacePickerLargeScreen.qml"});
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
            title:qsTr( "Choose a clock style")
        }

 BusyIndicator{
        running: true
        id: busy
        size: BusyIndicatorSize.Large
        anchors{
            centerIn:parent
        }
    }
 ComboBox{
         id: fontSizeCombo
         visible: false
         opacity: listView.currentIndex===0? 1:0
         onOpacityChanged:{
             if(opacity === 0) visible = false;
             else visible = true
         }
         Behavior on opacity {OpacityAnimator{}}

         Component.onCompleted: {
             if(appsettings.getSystemSetting("clocksizeLabel", "") === "")fontSizeCombo.currentIndex=0
             else fontSizeCombo.currentIndex= parseInt(appsettings.getSystemSetting("clocksizeLabel", ""))
         }
         onCurrentIndexChanged:{
             appsettings.saveSystemSetting("clocksizeLabel", fontSizeCombo.currentIndex);
         }
         anchors{
             top:pHeader.bottom;
             topMargin: Theme.paddingSmall
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
                 onClicked:{
                     appsettings.saveSystemSetting("fontSize", value);
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

GridView{
id: listView;
opacity: 0
visible: false
clip:true;
cellWidth: listView.width/3;
cellHeight: cellWidth
Behavior on opacity {OpacityAnimator{}}

anchors{
    top:fontSizeCombo.bottom;
    bottom:parent.bottom;
    right:parent.right;
    left:parent.left
}

boundsBehavior: Flickable.StopAtBounds;
currentIndex: 0
model: listModel
highlight: clockFacePicker.selectedIndex===13? null: highlight
highlightFollowsCurrentItem: true

// Makes touchwiz look smooth without these loading delays
Timer{
    id: fadeInDelay;
    interval: 800;
    onTriggered:{
        busy.visible=false;
        busy.running=false;
        listView.visible=true;
        fontSizeCombo.visible=true;
        listView.opacity=1;
    }
}

Timer{
    id: indexTimer;
    interval: 550;
    onTriggered:{
        listView.currentIndex=clockFacePicker.savedSelectedIndex;
    }
}

Component.onCompleted: {
   fadeInDelay.start();
}

Component {
    id: highlight
    Rectangle {
        opacity: 0.2
        width: listView.cellWidth;
        height: listView.cellHeight
        color: Theme.highlightColor;
        radius: 5
        x: listView.currentItem.x
        y: listView.currentItem.y
        Behavior on x { NumberAnimation {}}
        Behavior on y { NumberAnimation {}}
    }
}

delegate:
    Rectangle {
     border.color:Qt.darker(Theme.secondaryHighlightColor);
     border.width: 0.5
     property bool selected
     Connections{
         target: clockFacePicker;
         onClearSelected:{
             selected=false;
         }
     }

     onSelectedChanged: {
         if(selected) clockFacePicker.selectedIndex= listView.currentIndex;
         else clockFacePicker.selectedIndex= -1;

     }
       color: "Transparent"
       id: delg
       width:  listView.cellWidth
       height: listView.cellHeight
    Loader{
    asynchronous: true
    source: model.url
    MouseArea{
        anchors.fill: parent;
        property string ab
        z:1;
        propagateComposedEvents: true

 onPressAndHold: {
     ab= model.url;
     ab= "../clockfaces/"+ab.substring(24, ab.length);
     liveView.show(ab);
 }

 onReleased: {
     liveView.hide();
 }

 onExited: {
     console.log("Exited")
 }
 }

 Behavior on opacity{OpacityAnimator{}}
visible: status == Loader.Ready
anchors.centerIn: parent

    }

}

}
}
