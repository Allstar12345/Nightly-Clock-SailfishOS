import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle{
    z: 10
    anchors.fill: parent;
    opacity: 0.95
    function nextStep(){
        if(steps === 0){
            step2();
        }
        else if(steps === 1){
            step3();
        }

        else if(steps === 2){
            step4();
        }

        else if(steps === 3){
            root.opacity = 0;
            root.destroy(1500);
            appsettings.saveSystemSetting("firstRun", "true");
        }
    }

    Behavior on opacity{OpacityAnimator{}}
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
    tracing = false;
    nextStep();
    }
    }

    onReleased: {
    tracing = false
    if ( velocity > 15 && mouse.x < parent.width*0.2 ) {
    }
    }
    }

    property int steps
    id: root
    color: Theme.overlayBackgroundColor
    function step2(){
        steps++;
        fadeOut.stop();
        fadeIn.stop();
        hint.stop();
        pill.opacity = 0;
        intLabel.text = qsTr("You can find the app settings from the pulley menu");
        hint2.opacity = 1;
        hint2.start();
    }

    function step3(){
        steps++;
        hint2.interactionMode = TouchInteraction.Swipe;
        hint2.direction = TouchInteraction.Up;
        intLabel.text = qsTr("Areas like Alarm Settings have lot's of features hidden away with just a flick of the screen");
    }

    function step4(){
        steps++;
        hint.anchors.verticalCenterOffset +=100;
        hint2.stop();
        hint.start();
        intLabel.text = qsTr("After 5 minutes Nightly Clock will go into standby mode, this will hide some parts of the UI, tap the screen to leave standby mode");
    }

    Component.onCompleted: {
        hint.start();
        fadeOut.start();
    }

   IconButton{
      id: nextButton;
      z: 5;
      icon.source:"image://theme/icon-m-right";
      onClicked:{
          nextStep();
      }
      anchors{
          right:parent.right;
          top:parent.top;
          topMargin: Theme.paddingMedium;
          rightMargin: Theme.paddingMedium
      }
   }

    TapInteractionHint {
        id: hint
        z:5
        loops: Animation.Infinite
        anchors.centerIn: parent
    }

    TouchInteractionHint {
        z:5
        id: hint2
        opacity: 0
        Behavior on opacity {NumberAnimation{}}
        loops: Animation.Infinite
        interactionMode: TouchInteraction.Pull
        direction: TouchInteraction.Down
    }

    InteractionHintLabel{
        id: intLabel;
        text:qsTr("You can tap the pill button at the bottom of the screen for quick shortcut toggles")
    }

    Timer{
        id: fadeIn;
        interval: 1000;
        onTriggered: {
            fadeOut.start();
            pill.opacity = 1;
        }
    }

    Timer{
        id: fadeOut;
        interval: 3000;
        onTriggered: {
            pill.opacity = 0;
            fadeIn.start();
        }
    }

    Rectangle{
        id:pill;
        Behavior on opacity {SmoothedAnimation{}}
        color: colour;
        MouseArea{
            z:1;
            width: parent.width+ 10;
            height: parent.height+15;
            onClicked:{
                panel.show();
            }
        }
        width: Screen.width/5;
        height: 19;
        radius: 40;
        anchors{
            bottom: parent.bottom;
            bottomMargin:panel.open? -height : -height/2;
            horizontalCenter: parent.horizontalCenter
        }
    }
}
