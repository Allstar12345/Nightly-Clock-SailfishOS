import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle{
    z: 10
    anchors.fill: parent;
    opacity: 0.95
    Behavior on opacity{OpacityAnimator{}}
    TouchBlocker{
        anchors.fill: parent
    }
    function nextStep(){
        steps++
        if(steps === 1){
            intLabel.text = "Tap on a wallpaper to select and go back to apply";
            hint2.stop();
            hint.start();
        }

        if(steps === 2){
            appsettings.saveSystemSetting("wallpaperfirstRun", "true");
            root.opacity = 0;
            root.destroy(500);
            }
    }

    property int steps
    id: root
    color: Theme.overlayBackgroundColor
    MouseArea {
    id: globalMouseArea
    anchors.fill: parent
    preventStealing: true
    property real velocity: 0.0
    property int xStart: 0
    property int xPrev: 0
    property bool tracing: false

    onPressed: {
    xStart = mouse.x
    xPrev = mouse.x
    velocity = 0
    tracing = true
    }

    onPositionChanged: {
    if ( !tracing ) return
    var currVel = (mouse.x-xPrev)
    velocity = (velocity + currVel)/2.0
    xPrev = mouse.x
    if ( velocity < 15 && mouse.x < parent.width*0.2 ) {
    tracing = false;nextStep();
    }
    }

    onReleased: {
    tracing = false
    if ( velocity > 15 && mouse.x < parent.width*0.2 ) {
    }
    }
    }
    Component.onCompleted: {
        hint2.start();
    }

    IconButton{
        z: 5;
        icon.source:"image://theme/icon-m-right";
        onClicked:{
            nextStep();
        }
        anchors{
            right: parent.right;
            top: parent.top;
            topMargin: Theme.paddingMedium;
            rightMargin: Theme.paddingMedium
        }
    }


    TouchInteractionHint {
        z:5
        id: hint2
        loops: Animation.Infinite
        anchors.centerIn: parent
        interactionMode: TouchInteraction.Swipe
        direction: TouchInteraction.Left
    }
    TapInteractionHint {
        id: hint
        z:5
        running: false
        loops: Animation.Infinite
        anchors.centerIn: parent
    }
    InteractionHintLabel{
        id: intLabel;
        text:"Swipe left to scroll through wallpapers"}
}
