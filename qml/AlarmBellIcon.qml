import QtQuick 2.0
import Sailfish.Silica 1.0

Image{
    id: root
    signal clicked
    signal longPressed
    Timer{
        running:true;
        repeat: true;
        id: upMovement;
        interval: globalScreenSaverInterval

        onTriggered: {
        if(anchors.bottomMargin>=15) {
            anchors.bottomMargin+=1;
        }

        if(anchors.bottomMargin>70){
            downMovement.start();
            upMovement.stop();
        }
        }
    }
    Timer{
        id: downMovement;
        repeat: true;
        interval:globalScreenSaverInterval;
        onTriggered: {
            if(anchors.bottomMargin===15){
                downMovement.stop();
                upMovement.start();
            }
        else{
                anchors.bottomMargin-=1;
            }
        }
    }
    opacity:powerSaving?0.6: 1
    visible:alarmServer.snoozed? true: alarmEnabled?true:false
    Behavior on opacity{ NumberAnimation{}}
    anchors{
        bottom:parent.bottom;
        right:parent.right;
        rightMargin: 20;
        bottomMargin: 20
    }
    source: sunriseMode? "image://theme/icon-m-day?" + colour: alarmServer.snoozed?"image://theme/icon-l-snooze?"+colour: intervalAlarm?  "image://theme/icon-m-clock?"+colour: "image://theme/icon-m-alarm?"+colour
    sourceSize.height: Theme.iconSizeLarge-15
    sourceSize.width:Theme.iconSizeLarge-15
    width: sourceSize.width
    height: sourceSize.height
    MouseArea{
        id: mouse
        anchors.fill: parent;
        onClicked:{
            resetStandbyTimer();
            root.clicked();
        }
        onPressAndHold: {
            resetStandbyTimer();
            root.longPressed();
        }
    }
}
