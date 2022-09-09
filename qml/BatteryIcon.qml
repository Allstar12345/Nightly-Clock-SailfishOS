import QtQuick 2.0
import Sailfish.Silica 1.0


Image{
    id: root
    opacity:powerSaving?0.6: 1
    signal clicked
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

    Connections{
        target:mceChargerState;
        onChargingChanged:{
            if(mceChargerState.charging){
                fadeOut.start();
            }
            else{
                fadeOut.stop();
                fadeOut.stop();
                root.opacity=powerSaving? 0.6:1;
            }
        }
    }

    Timer{
        id: fadeIn;
        interval: 900;
        onTriggered: {
            fadeOut.start();
            root.opacity = powerSaving? 0.6:1;
        }
    }

    Timer{
        id: fadeOut;
        interval: 1200;
        onTriggered: {
            root.opacity=0.3;
            fadeIn.start();
        }
    }
    Behavior on opacity{ FadeAnimator {}}
    anchors{
        bottom:parent.bottom;
        left:parent.left;
        leftMargin: 20;
        bottomMargin: 20
    }
    source:"Image://theme/icon-m-battery?" + colour
    sourceSize.height: Theme.iconSizeLarge-15
    sourceSize.width:  Theme.iconSizeLarge-15
    width: sourceSize.width
    height: sourceSize.height
    MouseArea{
        anchors.fill: parent;
        onClicked:{
            resetStandbyTimer();
            root.clicked();
        }
    }
}
