import QtQuick 2.6
import Sailfish.Silica 1.0
import QtMultimedia 5.2
import Sailfish.Pickers 1.0

 // Yes this page is shockingly coded, I know
Page {
    id: pagese
    signal killPlayers
   signal clearSwitch
    allowedOrientations: decideOrientation();
    Component.onDestruction: {
        if(alarmSound === ""){
            alarmSound = "sounds/1.mp3";
            appsettings.saveSystemSetting("alarmSound", alarmSound);
            appsettings.saveSystemSetting("usingShoutForAlarm", "");
            appsettings.saveSystemSetting("alarmSoundsPickerSelected", 3);
            selected = 3
        }
    }

    property int selected: parseInt(appsettings.getSystemSetting("alarmSoundsPickerSelected", 3))
    Component {
        id: musicPickerPage
        MusicPickerPage {
            onSelectedContentPropertiesChanged: {
                alarmSound = "file://" + selectedContentProperties.filePath;
                appsettings.saveSystemSetting("alarmSound", "file://" + selectedContentProperties.filePath);
                appsettings.saveSystemSetting("alarmSoundsPickerSelected", 0);selected = 0;
            }
        }
    }

    MediaPlayer{
        id: media;
        volume:0.5;
        property bool isPlayingMedia;
        onPlaying: {
            isPlayingMedia = true;
        }
        onPaused: {
            isPlayingMedia = false;
        }
        onStopped: {
            isPlayingMedia = false;
        }
    }

    SilicaFlickable {
        id: flickable1
        contentHeight: content.height
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingMedium
        ScrollDecorator{flickable: flickable1}
    Column{
        id: content
        width: parent.width
        PageHeader {id: header;title: qsTr("Alarm Sound")}

    ExpandingSection{
        Rectangle{
            z:1;
            Behavior on opacity{OpacityAnimator{}}
            opacity:selected === 0 ? 0.4 : 0;
            anchors.fill: parent;
            color:Theme.secondaryHighlightColor;
        }

        title: qsTr("Music on your device");
        content.sourceComponent:SilicaControl{
        height: 150
        Connections{
            target:pagese;
            onKillPlayers:{
                media.stop();
            }
        }


        Button{
            onClicked:{
                appsettings.saveSystemSetting("usingShoutForAlarm", "");
                pageStack.push(musicPickerPage)
            }

            text:"Choose Song";
            anchors{
                left:parent.left;
                leftMargin: Theme.paddingLarge;
                verticalCenter: parent.verticalCenter
            }
        }

        IconButton{
            visible: alarmSound.indexOf("file://")? false : true
            icon.source: media.isPlayingMedia? "image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
            onClicked: {
                if(media.isPlayingMedia){
                    media.pause();
                }
                else{
                    pagese.killPlayers();
                    media.source = alarmSound;
                    media.play();
                }
            }

            anchors{
                right:parent.right;
                rightMargin: Theme.paddingLarge;
                verticalCenter: parent.verticalCenter
            }
        }
    }
    }

    ExpandingSection{
        Rectangle{
            z:1;
            Behavior on opacity{OpacityAnimator{}}
            opacity:selected === 1? 0.4 : 0;
            anchors.fill: parent;
            color:Theme.secondaryHighlightColor;
        }

        title:qsTr("Internet radio");
        MouseArea{
            anchors.fill: parent;
            onClicked: {
                if(networkOnline) pageStack.push(Qt.resolvedUrl("ShoutcastFirstPage.qml"));
                else{
                    qmlUtils.showBanner("Nightly Clock", "No Internet Connection", 3000);
                }
            }
        }
    }

   ExpandingSection{
       Rectangle{
           z:1;
           Behavior on opacity{OpacityAnimator{}}
           opacity:selected === 3 ? 0.4 : 0;
           anchors.fill: parent;
           color:Theme.secondaryHighlightColor;
       }
       title: qsTr("In-app sounds");
       content.sourceComponent:SilicaControl{
       height: column.height

       Column{
       width: parent.width
       id: column

       ListItem {
           highlighted: value === alarmSound
           MediaPlayer{
               id: media1;
               volume:0.5;
               property bool isPlayingMedia;
               onPlaying: {
                   isPlayingMedia = true;
               }
               onPaused: {
                   isPlayingMedia = false;
               }
               onStopped: {
                   isPlayingMedia = false;
               }
           }

           width: parent.width
           IconButton{
               icon.source: media1.isPlayingMedia?"image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
               onClicked: {
                   if(media1.isPlayingMedia){
                       media1.pause();
                   }
                   else{
                       pagese.killPlayers();
                       media1.source = "../" + switch1.value;
                       media1.play()
                   }
               }
               anchors{
                   right:parent.right;
                   rightMargin: Theme.paddingLarge;
                   verticalCenter: parent.verticalCenter
               }
           }

           Connections{
               target:pagese;
               onKillPlayers:{
                   media1.stop();
               }
           }

           property string value:"sounds/1.mp3";
           id: switch1

           Label {
               id: label
               text: qsTr("Alarm sound 1")
               width: parent.width/2
               opacity: parent.enabled ? 1.0 : Theme.opacityLow
               wrapMode: Text.Wrap
               anchors {
                   verticalCenter: parent.verticalCenter
                   verticalCenterOffset: lineCount > 1 ? (lineCount-1)*height/lineCount/2 : 0
                   left:parent.left
                   leftMargin: Theme.paddingLarge
               }
           }
           onClicked: {
               if(alarmSound === ""){
                   alarmSound=value;
                   appsettings.saveSystemSetting("alarmSound", value);
                   appsettings.saveSystemSetting("usingShoutForAlarm", "");
                   appsettings.saveSystemSetting("alarmSoundsPickerSelected", 3);
                   selected = 3;
                   qmlUtils.showBanner("", "Alarm sound changed", 2000);
               }
               else{
                   alarmSound = "";
               }
           }
       }
       ListItem {
           highlighted: value === alarmSound

           MediaPlayer{
               id: media2;
               volume: 0.5;
               property bool isPlayingMedia;
               onPlaying: {
                   isPlayingMedia = true;
               }
               onPaused: {
                   isPlayingMedia = false;
               }
               onStopped: {
                   isPlayingMedia = false;
               }
           }

           width: parent.width
           IconButton{
               icon.source: media2.isPlayingMedia? "image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
               onClicked: {
                   if(media2.isPlayingMedia){
                       media2.pause();
                   }
                   else{
                       pagese.killPlayers();
                       media2.source = "../" + switch2.value;
                       media2.play();
                   }
               }
               anchors{
                   right: parent.right;
                   rightMargin: Theme.paddingLarge;
                   verticalCenter: parent.verticalCenter
               }
           }
           Connections{
               target: pagese;
               onKillPlayers:{
                   media2.stop();
               }

           }

           property string value: "sounds/2.mp3";
           id: switch2
           Label {
               text: qsTr("Alarm sound 2")
               width: parent.width/2
               opacity: parent.enabled ? 1.0 : Theme.opacityLow
               anchors {
                   verticalCenter: parent.verticalCenter
                   verticalCenterOffset: lineCount > 1 ? (lineCount-1)*height/lineCount/2 : 0
                   left:parent.left
                   leftMargin: Theme.paddingLarge
               }
               wrapMode: Text.Wrap
           }
           onClicked: {
               if(alarmSound === ""){
                   alarmSound = value;
                   appsettings.saveSystemSetting("alarmSound", value);
                   appsettings.saveSystemSetting("usingShoutForAlarm", "");
                   appsettings.saveSystemSetting("alarmSoundsPickerSelected", 3);
                   selected = 3;
                   qmlUtils.showBanner("", "Alarm sound changed", 2000);
               }
               else{
                   alarmSound = "";
               }
           }

       }
      ListItem {
          highlighted:value === alarmSound

           MediaPlayer{
               id: media3;
               volume:0.5;
               property bool isPlayingMedia;
               onPlaying: {
                   isPlayingMedia = true;
               }
               onPaused: {
                   isPlayingMedia = false;
               }
               onStopped: {
                   isPlayingMedia = false;
               }
           }

           width: parent.width
           IconButton{
               icon.source: media3.isPlayingMedia? "image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
               onClicked: {
                   if(media3.isPlayingMedia){
                       media3.pause();
                   }

                   else{
                       pagese.killPlayers();
                       media3.source = "../" + switch3.value;
                       media3.play()
                   }
               }
               anchors{
                   right:parent.right;
                   rightMargin: Theme.paddingLarge;
                   verticalCenter: parent.verticalCenter
               }
           }

           Connections{
               target:pagese;
               onKillPlayers:{
                   media3.stop();
               }
           }

           property string value:"sounds/3.mp3";
           id: switch3

           Label {
               text: qsTr("Alarm sound 3")
               width: parent.width/2
               opacity: parent.enabled ? 1.0 : Theme.opacityLow
               anchors {
                   verticalCenter: parent.verticalCenter
                   verticalCenterOffset: lineCount > 1 ? (lineCount-1)*height/lineCount/2 : 0
                   left:parent.left
                   leftMargin:  Theme.paddingLarge
               }
               wrapMode: Text.Wrap
           }

           onClicked: {
               if(alarmSound === ""){
                   alarmSound=value;
                   appsettings.saveSystemSetting("alarmSound", value);
                   appsettings.saveSystemSetting("usingShoutForAlarm", "");
                   appsettings.saveSystemSetting("alarmSoundsPickerSelected", 3);
                   selected = 3;
                   qmlUtils.showBanner("", "Alarm sound changed", 2000);
               }

               else{
                   alarmSound = "";
               }
           }

       }

      ListItem {

          highlighted: value === alarmSound

           MediaPlayer{
               id: media4;
               volume: 0.5;
               property bool isPlayingMedia;
               onPlaying: {
                   isPlayingMedia = true;
               }
               onPaused: {
                   isPlayingMedia = false;
               }
               onStopped: {
                   isPlayingMedia = false;
               }
           }

           width: parent.width
           IconButton{
               icon.source: media4.isPlayingMedia?"image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
               onClicked: {
                   if(media4.isPlayingMedia){
                       media4.pause();
                   }
                   else{
                       pagese.killPlayers();
                       media4.source = "../" + switch4.value;
                       media4.play();
                   }
               }

               anchors{
                   right:parent.right;rightMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter}}
           Connections{target:pagese; onKillPlayers:{media4.stop();}}

            property string value:"sounds/4.mp3";
           id: switch4
           Label {
               text: qsTr("Alarm sound 4")

               width: parent.width/2
               opacity: parent.enabled ? 1.0 : Theme.opacityLow
               anchors {
                   verticalCenter: parent.verticalCenter
                   verticalCenterOffset: lineCount > 1 ? (lineCount-1)*height/lineCount/2 : 0
                   left: parent.left
                   leftMargin: Theme.paddingLarge
               }
               wrapMode: Text.Wrap
           }
           onClicked: {
               if(alarmSound === ""){
                   alarmSound=value;
                   appsettings.saveSystemSetting("alarmSound", value);
                   appsettings.saveSystemSetting("usingShoutForAlarm", "");
                   appsettings.saveSystemSetting("alarmSoundsPickerSelected", 3);
                   selected = 3;
                   qmlUtils.showBanner("", "Alarm sound changed", 2000);}

               else{
                   alarmSound = "";
               }
           }

       }
     ListItem {
           highlighted: value === alarmSound

           MediaPlayer{
               id: media5;
               volume:0.5;
               property bool isPlayingMedia;
               onPlaying: {
                   isPlayingMedia = true;
               }

               onPaused: {
                   isPlayingMedia = false;
               }

               onStopped: {
                   isPlayingMedia = false;
               }
           }
           width: parent.width
           IconButton{
               icon.source: media5.isPlayingMedia?"image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
               onClicked: {
                   if(media5.isPlayingMedia){
                       media5.pause();
                   }

                   else{
                       pagese.killPlayers();
                       media5.source = "../"+switch5.value;
                       media5.play();
                   }
               }

               anchors{
                   right:parent.right;
                   rightMargin: Theme.paddingLarge;
                   verticalCenter: parent.verticalCenter
               }
           }

           Connections{
               target: pagese;
               onKillPlayers:{
                   media5.stop();
               }
           }

           property string value:"sounds/5.mp3";
           id: switch5

           Label {
               text: qsTr("Alarm sound 5")
               width: parent.width/2
               opacity: parent.enabled ? 1.0 : Theme.opacityLow
               anchors {
                   verticalCenter: parent.verticalCenter
                   verticalCenterOffset: lineCount > 1 ? (lineCount-1)*height/lineCount/2 : 0
                   left:parent.left
                   leftMargin: Theme.paddingLarge
               }
               wrapMode: Text.Wrap
           }
           onClicked: {
               if(alarmSound === ""){
                   alarmSound=value;
                   appsettings.saveSystemSetting("alarmSound", value);
                   appsettings.saveSystemSetting("usingShoutForAlarm", "");
                   appsettings.saveSystemSetting("alarmSoundsPickerSelected", 3);
                   selected = 3;
                   qmlUtils.showBanner("", "Alarm sound changed", 2000);
               }

               else{
                   alarmSound = "";
               }
           }

       }

   }

   }

   }

 ExpandingSection{
     Rectangle{
         z:1;
         Behavior on opacity{OpacityAnimator{}}
         opacity:selected === 4 ? 0.4 : 0;
         anchors.fill: parent;
         color:Theme.secondaryHighlightColor;
     }

title:qsTr("Internet file");
MouseArea{
    anchors.fill: parent;
    onClicked: {
        if(networkOnline) pageStack.push(Qt.resolvedUrl("InternetAlarmSound.qml"));
        else{
            qmlUtils.showBanner("Nightly Clock", "No Internet Connection", 3000);
        }
    }
}
 }

}
    }
}
