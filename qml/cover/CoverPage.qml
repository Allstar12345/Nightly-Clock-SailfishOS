import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"


CoverBackground {
    property bool active: status == Cover.Active
    onActiveChanged: console.log("Cover  "+active)

    Item{
    id: analogView
    visible: usingCustomClockFace
    anchors.fill: parent

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

    Timer {
        interval: 1000;
        running: usingCustomClockFace;
        repeat: true;
        onTriggered: analogView.timeChanged()
    }

     Image {
         id: face
         source:"image://theme/graphic-clock-face-3"
         anchors{
             top:parent.top;
             horizontalCenter: parent.horizontalCenter;
             topMargin: Theme.paddingLarge
         }
     }



     Rectangle {
         id: hourHand
         anchors {
             bottom: face.verticalCenter
             bottomMargin: -radius
             horizontalCenter: face.horizontalCenter
         }

         color: Theme.primaryColor
         opacity: 0.9
         height: face.height * 0.25
         width: 7 * Theme.pixelRatio
         radius: width/2

         transform: Rotation {
             origin.x: hourHand.width/2
             origin.y: hourHand.height - hourHand.radius
             angle:(analogView.hours * 30) + (analogView.minutes * 0.5)
         }
     }

Rectangle {
    id: minuteHand
    anchors {
        bottom: face.verticalCenter
        bottomMargin: -radius
        horizontalCenter: face.horizontalCenter
    }

    color: Theme.primaryColor
    opacity: 0.9
    height: face.height * 0.37
    width: 7 * Theme.pixelRatio
    radius: width/2

    transform: Rotation {
        origin.x: minuteHand.width/2
        origin.y: minuteHand.height - minuteHand.radius
        angle: analogView.minutes * 6
    }
}

Image{
    id: img11
    anchors{
        bottom:parent.bottom;
        bottomMargin:parent.height/5;
        horizontalCenter: parent.horizontalCenter
    }
    visible: alarmEnabled
    source: intervalAlarm? "image://theme/icon-m-clock" : "image://theme/icon-m-alarm"
}
    }

    Item{
        anchors.fill: parent
        visible: usingCustomClockFace?false:true
    Text {
        id: label
        anchors{
            top:parent.top;
            horizontalCenter: parent.horizontalCenter
        }
        text:clockTime
        color: Theme.primaryColor
        font.pointSize:Theme.fontSizeLarge-8
    }

    Image{
        id: img
        anchors{
            top:label.bottom;
            topMargin: 40;
            horizontalCenter: parent.horizontalCenter
        }
        visible: alarmEnabled
        width: sourceSize.width;
        height: sourceSize.width
        sourceSize.height: Theme.iconSizeLarge
        sourceSize.width: Theme.iconSizeLarge

         source:intervalAlarm? "image://theme/icon-m-clock": "image://theme/icon-m-alarm"
    }



    Image{
        id: img1
        anchors{
            top:label.bottom;
            topMargin: 40;
            horizontalCenter: parent.horizontalCenter
        }
        visible: alarmServer.snoozed
        source:"image://theme/icon-l-snooze"
    }
    Text {
        id: label1
        visible: alarmEnabled
        anchors{
            bottom:parent.bottom;
            bottomMargin:Theme.paddingLarge*4
            horizontalCenter: parent.horizontalCenter
        }
        text:qsTr("Next Alarm:")
        color: Theme.primaryColor
        font.pointSize: Theme.fontSizeExtraSmall/1.2

    }
    Text {
        id: label2
        visible: alarmEnabled
        anchors{
            bottom:parent.bottom;
            bottomMargin:Theme.paddingLarge*3
            horizontalCenter: parent.horizontalCente
        }
        text:alarmTime
        color: Theme.primaryColor
        font.pointSize:Theme.fontSizeExtraSmall/1.2


    }
    }

    //maybe three for the future, sunrise ?
CoverActionList{
    id: actionslist
    CoverAction{
        id: action1
        iconSource:"image://theme/icon-s-time"
        onTriggered:{
            if(alarmServer.snoozed){}
            else{
            if(intervalAlarm){
                alarmServer.disableIntervalAlarm();
            }
            else{
                alarmServer.enableIntervalAlarm();
            }
            }
        }
    }

    CoverAction{
        iconSource:"image://theme/icon-s-alarm"
        onTriggered:{
            if(alarmServer.snoozed){}
            else{
            if(alarmEnabled){
                alarmServer.disableAlarm();
            }
            else{
                alarmServer.enableAlarm();
            }
            }
        }
    }

}
}
