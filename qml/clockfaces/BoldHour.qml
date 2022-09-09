import QtQuick 2.1
import Sailfish.Silica 1.0


Item {
    opacity:powerSaving?0.6:1.0

    width:Screen.sizeCategory== Screen.Large? Screen.width/1.3: Screen.width/1.2
    property bool showDateOnMain:true
    id: wallClock

    Timer{
        running:true;
        repeat: true;
        id: upMovement;
        interval: globalScreenSaverInterval
    onTriggered: {
        if(wallClock.anchors.horizontalCenterOffset>=0){
            wallClock.anchors.horizontalCenterOffset+=1;
        }
    if(wallClock.anchors.horizontalCenterOffset>20){
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
            if(wallClock.anchors.horizontalCenterOffset===0){
                downMovement.stop();
                upMovement.start();
            }
        else{
                wallClock.anchors.horizontalCenterOffset-=1;
            }
        }
    }
        height: width
       anchors{
           top:parent.top;
           topMargin: Theme.paddingLarge
           horizontalCenter: parent.horizontalCenter
       }

    function timeChanged(){  minuteCircle.requestPaint()
    }
    property bool running: true
    Connections{
        target:running? main:null;
        onTimeUpdated:{wallClock.timeChanged()}
    }


    Text {
        id: hourDisplay
        property var offset: height*0.38
        renderType: Text.NativeRendering
        font.pixelSize: parent.height/1.5
        font.family: "Bebas Neue"
        font.styleName:"Bold"
        color: Qt.rgba(1, 1, 1, 0.85)
        style: Text.Outline;
        styleColor: Qt.rgba(0, 0, 0, 0.4)
        horizontalAlignment: Text.AlignHCenter
        x: parent.width/2-width/1.88
        y: parent.height/2-offset
        text: Qt.formatDateTime (new Date(), "HH")

    }

    Canvas {
        id: minuteCircle
        property var rotM: (Qt.formatDateTime (new Date(), "mm") - 15)/60
        property var centerX: parent.width/2
        property var centerY: parent.height/2
        property var minuteX: centerX+Math.cos(rotM * 2 * Math.PI)*width/2.75
        property var minuteY: centerY+Math.sin(rotM * 2 * Math.PI)*height/2.75
        anchors.fill: parent
        smooth: true
        renderTarget: Canvas.FramebufferObject
        onPaint: {
            var ctx = getContext("2d")
            var rot1 = (0 -15 )*6 *0.01745
            var rot2 = (60 -15 )*6 *0.01745
            ctx.reset()
            ctx.lineWidth = 3
            ctx.fillStyle = Qt.rgba(0.184, 0.184, 0.184, 0.98)
            ctx.beginPath()
            ctx.moveTo(minuteX, minuteY)
            ctx.arc(minuteX, minuteY, width / 8.8, rot1, rot2, false);
            ctx.lineTo(minuteX, minuteY);
            ctx.fill();
        }
    }

    Text {
        id: minuteDisplay
        property var rotM: (Qt.formatDateTime (new Date(), "mm") - 15)/60
        property var centerX: parent.width/2-width/2
        property var centerY: parent.height/2-height/2
        font.pixelSize: parent.height/5.6
        font.family: "BebasKai"
        font.styleName:'Condensed'
        color: "white"
        opacity: 1.00
        x: centerX+Math.cos(rotM * 2 * Math.PI)*parent.width*0.364
        y: centerY+Math.sin(rotM * 2 * Math.PI)*parent.width*0.364
        text: Qt.formatDateTime (new Date(), "mm")
    }



    Component.onCompleted: {
        minuteCircle.requestPaint()
        customClockFaceWantsDate=showDateOnMain;
    }
}
