import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0
import "../"
import Nemo.DBus 2.0
Page {
    id: triggerPage
    z:10

 Component.onCompleted: {
     stopSunrise();
     if(flashCameraLight){
         flashlightOn = flashlight.getProperty("flashlightOn");
         cameraLightOn.start();
     }
 }
 Component.onDestruction: {
     if(flashCameraLight){
         if(flashlight.getProperty("flashlightOn")===true) {
             toggleFlashlight();
         }
     }
 }

    property bool flashlightOn
    function toggleFlashlight() {
           flashlightOn = !flashlightOn;
           flashlight.call("toggleFlashlight", undefined);
       }

       DBusInterface {
           id: flashlight
           service: "com.jolla.settings.system.flashlight"
           path: "/com/jolla/settings/system/flashlight"
           iface: "com.jolla.settings.system.flashlight"
   }
    backNavigation: false
    allowedOrientations: decideOrientation();

    Timer{
        id: cameraLightOn;
        interval:flashSpeed;
        onTriggered: {
            toggleFlashlight();
            cameraLightOff.start();
        }
    }

      Timer{
          id: cameraLightOff;
          interval: flashSpeed;
          onTriggered: {
              toggleFlashlight();
              cameraLightOn.start();
          }
      }

     function stopCameraLight(){
         cameraLightOff.stop();
         cameraLightOn.stop();
         toggleFlashlight();
     }

    SilicaFlickable {
        contentHeight: parent.height
        anchors.fill: parent
        Rectangle{
            Behavior on color {ColorAnimation{duration: 3000}}
            id: backgroundRect;
            anchors.fill: parent;
            visible:sunriseMode;
            color: sunriseColourString
        }
            PageHeader {
                id: header
                title: appsettings.getSystemSetting("alarmCompletedMessage", "") === "" ? qsTr("Alarm!") : appsettings.getSystemSetting("alarmCompletedMessage", "")
            }

            Button{
                color: sunriseMode? Qt.darker(Theme.primaryColor, 3.0): Theme.primaryColor
                width: parent.width
                anchors{top:header.bottom}
                 text:qsTr("Stop Alarm")
                 onClicked:{
                     alarmServer.stopAlarm();
                     pageStack.pop();
                     triggerPage.destroy(500);
                 }
                 id: stop
            }
            Image{
                id: img
                opacity: 0.9
                anchors{
                    horizontalCenter: parent.horizontalCenter;
                    verticalCenter: parent.verticalCenter;
                    verticalCenterOffset: 30
                }
                sourceSize.width: Screen.width/1.7
                sourceSize.height: Screen.width/2.1
                width: sourceSize.width
                height: sourceSize.height
                source:"../images/alarm_bell.svg"

            }
            ColorOverlay {
                    anchors.fill: img
                    source: img
                    color: Qt.darker(colour, 1.5)
                }

            Button{
                color:sunriseMode? Qt.darker(Theme.primaryColor, 3.0): Theme.primaryColor
                width: parent.width
                anchors{bottom:parent.bottom}
                text:qsTr("Snooze Alarm")
                onClicked:{
                    alarmServer.snooze();
                    pageStack.pop();
                    triggerPage.destroy(500);
                }
            }

            BusyIndicator{
               anchors{
                   verticalCenter: parent.verticalCenter;
                   right:parent.right;
                   rightMargin:Theme.paddingLarge
               }
               running: alarmServer.mediaStatus==="Buffering"? true:false
               visible: alarmServer.mediaStatus==="Buffering"? true:false
            }

    }
}

