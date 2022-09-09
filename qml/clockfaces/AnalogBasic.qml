import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import "../"

Item {
    id: analogclock
    property bool showDateOnMain:true
    Component.onCompleted: {
        customClockFaceWantsDate = showDateOnMain;
    }

    opacity:powerSaving? 0.6 : 1.0

    Timer{
        running:true;
        repeat: true;
        id: upMovement;
        interval: globalScreenSaverInterval

        onTriggered: {
        if(analogclock.anchors.horizontalCenterOffset >=0) {
            analogclock.anchors.horizontalCenterOffset +=1;
        }

    if(analogclock.anchors.horizontalCenterOffset>20){
        downMovement.start();
        upMovement.stop();
    }
    }
    }

    Timer{
        id: downMovement;
        repeat: true;
        interval: globalScreenSaverInterval;
        onTriggered: {
            if(analogclock.anchors.horizontalCenterOffset === 0){
                downMovement.stop();
                upMovement.start();
        }
        else{
                analogclock.anchors.horizontalCenterOffset-=1;
            }

        }
    }

    width: Screen.sizeCategory == Screen.Large? Screen.width/1.3 : Screen.width/1.2

        height: width
        anchors{
            top: parent.top;
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }


    function getHours() {
        var date = new Date
        return date.getHours()
    }

    function getMinutes(){
        var date = new Date
        return date.getMinutes()
    }

    function getSeconds(){
        var date = new Date
        return date.getSeconds()
    }

    property int hours: getHours()
    property int minutes: getMinutes()
    property int seconds: getSeconds()
    property int milliseconds


    function timeChanged() {
        var date = new Date;
        hours = getHours();
        minutes = getMinutes();
        seconds = getSeconds();
    }
    property bool running: true
    Connections{
        target:running? main:null;
        onTimeUpdated:{
            analogclock.timeChanged()
        }
    }


     Image {
         id: face
         source: "../images/analog_basic.svg"
         sourceSize.height:sourceSize.width
         width: sourceSize.width
         height: sourceSize.height
         sourceSize.width: analogclock.width
         anchors.
         centerIn: parent
     }
     ColorOverlay {
               anchors.fill:face
               source: face
               color:colour
           }


     Rectangle{
     height: Theme.itemSizeExtraSmall/2.3
     width: height;
     radius: 30;
     anchors.centerIn: parent;
     color:colour
     }

HourHand{
    parent: face
    id: hourHand
      anchors.centerIn: parent
      transform: Rotation {
          id: hourRotation
          origin.x: hourHand.width/2;
          origin.y: hourHand.height/2;
          angle: (analogclock.hours * 30) + (analogclock.minutes * 0.5)
          Behavior on angle {
              SpringAnimation { spring: powerSaving?1:2; damping: 0.2; modulus: 360 }

              //RotationAnimation{ direction: RotationAnimation.Clockwise }
          }
      }
}

MinuteHand{
    id: minuteHand
    anchors.centerIn: parent
    parent: face
    smooth: true
    transform: Rotation {
        id: minuteRotation
        origin.x: minuteHand.width/2;
        origin.y: minuteHand.height/2;
        angle: analogclock.minutes * 6
        Behavior on angle {
            SpringAnimation { spring: powerSaving?1:2; damping: 0.2; modulus: 360 }
        }
    }
}


SecondHand{
     id: secondHand
     anchors.centerIn: parent
     parent: face
     smooth: true
     transform: Rotation {
         id: secondRotation
         origin.x: secondHand.width/2;
         origin.y: secondHand.height/2;
         angle: analogclock.seconds * 6
         Behavior on angle {
             SpringAnimation { spring: powerSaving?1:2; damping: 0.2; modulus: 360 }
         }
     }
}

}
