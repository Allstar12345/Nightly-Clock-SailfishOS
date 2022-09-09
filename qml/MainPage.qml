import QtQuick 2.6
import QtQuick.Particles 2.0
import Sailfish.Silica 1.0
import org.nemomobile.mpris 1.0
import Sailfish.Media 1.0


Page {
function toggleDarkWallpaperr(){
    if(backgroundRect.visible === true){
        backgroundRect.visible = false
    }
    else backgroundRect.visible = true
}

id: page
    function startSunrise(){
        backgroundRect.visible = true;
        sunriseColour();
        sunriseColourDecider.start();
    }

    function stopSunrise(){
        sunriseColourDecider.stop();
        sunriseCurrentIndex = 0;

        if(appsettings.getSystemSetting("wallpaper", "")===""){
            backgroundRect.color = "black";
            backgroundRect.visible = false;
        }

       else if(appsettings.getSystemSetting("wallpaper", "") === "Black"){
            backgroundRect.color = "black";
        }

        else if(appsettings.getSystemSetting("wallpaper", "") === "bing"){
            backgroundRect.color = "black";
            backgroundRect.visible = false;
        }

        else{
            backgroundRect.visible = false;
            backgroundRect.color = "black";
        }
    }

 function sunriseColour(){
     console.log(sunriseColourArray.length)

     if(sunriseCurrentIndex === sunriseColourArray.length){
         sunriseCurrentIndex = 0;
     }

     sunriseColourString = sunriseColourArray[sunriseCurrentIndex];
     backgroundRect.color = sunriseColourString;
     sunriseCurrentIndex++;
 }

 property var sunriseColourArray:['#471e18', '#933e32', '#ba4e3f', '#ff1f00', '#ff4e05', '#ff5a07', '#ff6c05', '#ff7c06', '#ff8c05', '#fd9403', '#f99002', '#fea804', '#f6af07', '#fec705', '#ffc807', '#f9c611', '#f9cb25']
 property int sunriseCurrentIndex:0
 Timer {
     id: sunriseColourDecider;
     repeat:true;
     triggeredOnStart: false;
     running: false;
     interval:60000;
     onTriggered: {
         sunriseColour()
     }
 }

 FontLoader {
     id: clockFont;
     source:appsettings.getSystemSetting("CustomFont", "")
 }

 function resetStandbyTimer(){
    standbyMode=false;
    standbyTimer.start();
}

Connections{
    target: main;
    onToggleDarkWallpaper:{
        toggleDarkWallpaperr();
    }

    onKillSnowEffect:{
        emitter.destroy();
        imgpart.destroy();
        particleSys.destroy();
    }

    onStopSunrise:{
        stopSunrise();
    }

    onStartInteractiveTut:{
        creator.createComponent("pages/FirstRun/InteractiveTutorial.qml");
    }

    onRestartStandbyTimer:{
        standbyTimer.start();
    }
}

Timer{
    id: standbyTimer;
    interval:300000;
    onTriggered: {
        standbyMode = true;
    }
}

onOrientationChanged: {
oriChanged();
console.log(orientation);
if(orientation===0)compactMode=true;
else if(orientation===1)compactMode=true;
else if(orientation===2)compactMode=false;
else if(orientation===4)compactMode=true;
else if(orientation===8)compactMode=false;

else{
    compactMode=true;
}

if(usingCustomClockFace === true){

if(compactMode){
    clockFaceLoader.visible = true;
    mainClock.visible = false;
}
else{
    clockFaceLoader.visible = false;
    mainClock.visible = true;
}
}
}

Image{
    Rectangle{
        anchors.fill: parent;
        opacity: 0.4;
        color:"black"

        Image {
            id: glassTextureImage;
            fillMode: Image.Tile;
            horizontalAlignment: Image.AlignLeft;
            verticalAlignment: Image.AlignTop;
            opacity: 0.1;
            anchors.fill: parent;
            z:1;
            source: "image://theme/graphic-shader-texture"
        }
    }

    cache:false;
    asynchronous:true;
    fillMode: getFillMode();
    anchors.fill: parent;
    source: wallpaperSource === "Black" ? "" :
      mprisWallpaper? mediaArtWorkURI.length >0 ? mediaArtWorkURI
      : wallpaperSource: wallpaperSource
    id: wallpaper;

        function getFillMode(){
            if(appsettings.getSystemSetting("WallpaperAspectRatio", "")==="") return Image.PreserveAspectCrop
            else if(appsettings.getSystemSetting("WallpaperAspectRatio", "")==="Preserve Aspect Fit") return Image.PreserveAspectFit
            else if(appsettings.getSystemSetting("WallpaperAspectRatio", "")==="Stretch") return Image.Stretch
        }

Connections{
    target: main;
    onUpdateWallpaperRatio: wallpaper.fillMode= wallpaper.getFillMode();
}
}


Rectangle{
    Behavior on color {ColorAnimation{duration: 3000}}
    id: backgroundRect;
    anchors.fill: parent;
    visible: wallpaperSource === "Black"? true:false;
    color:"Black"
}
    Connections{
        target: main;
        onShowMainClock:{
            mainClock.show();
        }
        onFireIntervalPage:{
            pageStack.push(Qt.resolvedUrl("IntervalAlarmPopup.qml"))
        }
    }

    Component.onCompleted: {
        standbyTimer.start();
        if(appsettings.getSystemSetting("loopColours", "") === "true") startColourLoop();
    }

    allowedOrientations: decideOrientation();


    Timer{
         id: clockTimer;
         interval:1000;
         repeat:true;
         running: true;
         onTriggered: {
             if(usingCustomClockFace){
                 timeUpdated();
             }

             clockTime = Qt.formatDateTime (new Date(), timeFormat);
             mainDate.text=Qt.formatDateTime (new Date(), dateFormat);

             if(alarmEnabled === true){
                 if(alarmServer.alarmSounding === false){
                     if(alarmServer.shoutAsSoundSource){

                     if(alarmServer.preBufferTime === clockTime){
                         if(networkOnline){
                         console.log("Reached pre buffer time")
                         downloadManager.download(alarmSound, qmlUtils.tempPath() + "/internetRadioPrebuffer.mp3")
                         alarmSound = "file://" + qmlUtils.tempPath() + "/internetRadioPrebuffer.mp3"}
                         else {
                             alarmSound= "sounds/1.mp3";
                         }
                     }
                     }

                     if(sunriseMode){
                         if(sunriseTime === clockTime){
                             startSunrise();
                         }
                     }
                 }

              if(alarmTime === clockTime){
                  main.activate();
                  if(intervalAlarm == true){
                      if(alarmServer.alarmSounding === false){
                          alarmServer.soundInterval();
                      }
                  }
                  else{
                      if(alarmServer.alarmSounding === false){
                          sunriseColourDecider.stop();
                          alarmServer.soundAlarm();
                      }
                  }
              }
         }
             if(alarmServer.alarmSounding === false){
                 if(tickingSound == true) {
                     tickSound.play();
                 }
             }
     }
     }

     function enablePowerSaving(){
         powerSaving = true;
         qmlUtils.showBanner("Nightly Clock",qsTr("Power Saving Enabled"), 2000);
     }

     function disablePowerSaving(){
         powerSaving = false;
         qmlUtils.showBanner("Nightly Clock",qsTr("Power Saving Disabled"), 2000);
     }

     QtObject { id: creator; property Component com: null;function createComponent (qmlfile){com = Qt.createComponent(qmlfile);com.createObject(page)} }

    SilicaFlickable {
        id: flickable

        MouseArea{
            propagateComposedEvents: true;
            anchors.fill: parent;
            onPressed: {
                resetStandbyTimer();
            }
            onReleased: {
                resetStandbyTimer();
            }
        }

        ParticleSystem {
            id: particleSys
            Component.onCompleted: {
              checkIfAllowed();
          }

           function startSnow(){
               emitter.enabled = true;
               emitter.burst(emitter.emitRate)
           }

           function checkIfAllowed(){
           var month = Qt.formatDateTime (new Date(), "MM");
           if(appsettings.getSystemSetting("snowEffect", "") === "true"){

          if(month === "11"){
            startSnow();
        }

        else if(month === "12"){
            startSnow();
        }

        else if(month === "01"){
            startSnow();
        }

        else if(month === "02"){
            startSnow();
        }

        else{
            emitter.destroy();
            imgpart.destroy();
            particleSys.destroy();
        }
      }
            }
            }

        Emitter{
              id: emitter
              enabled: false
              anchors{
                  top:parent.top;
              }
              height:parent.height/1.5;
              width: parent.width
              system: particleSys
              emitRate: 15
              lifeSpan: 3000
              lifeSpanVariation: 300
              maximumEmitted: 800
              size: 4
              endSize: 30
              velocity: TargetDirection{
                  targetX: 0; targetY: 0
                  targetVariation: 360
                  magnitude: 150
                  targetItem: pillButton
              }
          }

          ImageParticle{
              id: imgpart
              color:lightTheme? "black": "white"
              source:"images/snowflake.png"
              system: particleSys
          }

        opacity:mainViewBrightness
        anchors.fill: parent
        onMovingChanged: {
            resetStandbyTimer();
        }
        PullDownMenu {
         visible: standbyMode? false : true

            MenuItem {
                text: qsTr("Settings")
                onClicked:{
                    standbyTimer.stop();
                    pageStack.push(Qt.resolvedUrl("pages/SettingsBasePage.qml"));
                }
            }
            MenuItem {
                text:  qsTr("Alarm settings")
                onClicked: {
                    standbyTimer.stop();
                    pageStack.push(Qt.resolvedUrl("pages/AlarmSettings.qml"));
                }
            }
             MenuLabel {
                 Connections{
                     target:main;
                     onTimeFormatChanged:{
                         dropDownAlarmTime.text = dropDownAlarmTime.calcTime();
                     }

                     onAlarmTimeChanged:{
                         dropDownAlarmTime.text= dropDownAlarmTime.calcTime();
                     }
                 }
                 function calcTime(){
                     if(timeFormat === "hh:mm:ss"){
                         return "Alarm: "+ qmlUtils.convertTime(alarmTime, timeFormat, "hh:mm")
                     }

                    else if(timeFormat === "h:mm:ss AP"){
                         return qsTr("Alarm") + ": "+ qmlUtils.convertTime(alarmTime, timeFormat, "h:mm AP");
                     }

                     else{
                         return qsTr("Alarm") + ": " + alarmTime;
                     }
                 }

                 visible: alarmEnabled;
                 id: dropDownAlarmTime;
                 text:calcTime();
             }
        }



        DockedPanel {
                id: panel
                animationDuration: 400
                width: parent.width
                height:lightTheme ? Theme.itemSizeExtraLarge + Theme.paddingLarge*2 :Theme.itemSizeExtraLarge + Theme.paddingLarge
                modal: true
                dock: Dock.Bottom
                Row {
                    anchors.centerIn: parent
                    Switch{
                        visible: whiteNoiseQuickToggle
                        checked: whiteNoise
                        icon.source: "image://theme/icon-m-browser-sound-template"
                        onClicked: {
                            if(whiteNoise){
                                whiteNoise = false;
                            }
                            else{
                                whiteNoise = true;
                            }
                        }

                    }

                    Switch {
                        enabled: sunriseMode?false:true;
                        icon.source: "image://theme/icon-m-clock";
                        checked: intervalAlarm;
                        onClicked: {
                            if(alarmTime === ""){
                                qmlUtils.showBanner("", qsTr("Set Alarm Time before turning Interval Alarm on"), 2000);
                                checked = false;
                                panel.hide();
                            }

                            else{
                                if(appsettings.getSystemSetting("intervalfirstruntut", "") === ""){
                                    panel.hide();
                                    appsettings.saveSystemSetting("intervalfirstruntut", "true");
                                    pageStack.push("pages/IntervalAlarmTutorial.qml");
                                }
                                else {
                                    if(intervalAlarm === true){
                                        intervalAlarm = false;
                                    }
                                    else{
                                        intervalAlarm = true;
                                    }
                                }
                            }
                        }
                    }

                    Switch {
                        icon.source: "image://theme/icon-m-alarm";
                        checked:alarmEnabled;
                        onClicked: {
                            if(alarmTime === ""){
                                flashAlarmTime = true;
                                pageStack.push(Qt.resolvedUrl("pages/AlarmSettings.qml"));
                                checked = false;
                                panel.hide();
                            }

                            else{
                                if(alarmEnabled === true){
                                    alarmEnabled = false;
                                    appsettings.saveSystemSetting("alarmEnabled", "")
                                }
                                else{
                                    alarmEnabled = true;
                                    appsettings.saveSystemSetting("alarmEnabled", "true")
                                }
                            }
                        }
                    }

                    Switch{
                        enabled:intervalAlarm? false:true;
                        icon.source: "image://theme/icon-m-day";
                        checked: sunriseMode;
                        onClicked: {
                            if(alarmTime === ""){
                                flashAlarmTime = true;
                                pageStack.push(Qt.resolvedUrl("pages/AlarmSettings.qml"));
                                checked = false;
                                panel.hide();
                            }
                            else{
                                if(appsettings.getSystemSetting("sunrisefirstruntut", "") === ""){
                                    panel.hide();
                                    appsettings.saveSystemSetting("sunrisefirstruntut", "true");
                                    pageStack.push("pages/SunriseModeTutorial.qml")
                                }
                                else{
                                    if(sunriseMode)sunriseMode = false;
                                    else sunriseMode = true
                                }
                            }
                        }
                    }
                }
            }


        Loader{
             onStatusChanged: if (clockFaceLoader.status == Loader.Error){
             qmlUtils.showBanner(qsTr("Unable to load clockface"), "", 5000);
             pageStack.push(Qt.resolvedUrl(largeScreen? "pages/ClockFacePickerTablet.qml" : "pages/ClockFacePicker.qml"));
                }
             asynchronous: true;
             active: Qt.application.active;
             visible: usingCustomClockFace? true:false;
             id: clockFaceLoader;
             source:customClockFaceURL;
             anchors{
                 top:parent.top;
                 horizontalCenter: parent.horizontalCenter
             }
            }

        Text {
            font.family: appsettings.getSystemSetting("CustomFont", "") === "" ? undefined : clockFont.name
            opacity:powerSaving?0.6:1
            color: colour
            function hide(){
                opacity = 0;
            }
            function show(){
                opacity = 1;
            }
            Behavior on opacity{NumberAnimation{}}
            anchors{
                top:parent.top;
                horizontalCenter: parent.horizontalCenter;
                topMargin:5
            }
            id: mainClock
            visible: usingCustomClockFace?false:true
            font.bold: boldFont
            Component.onCompleted: {console.log("CLOCK FONT SIZE: " + font.pointSize)}
            font.pointSize: decideClockSize();
            text:clockTime
            z: 1

            MouseArea{
                z: 5;
                enabled:true;
                anchors.fill: parent;
                id: clockMouse;
                onDoubleClicked: {
                    pageStack.push(Qt.resolvedUrl("pages/AlarmSettings.qml"))
                }


            }

            Timer{
                running:true;
                repeat: true;
                id: upMovementClock;
                interval: globalScreenSaverInterval

                onTriggered: {
                if(mainClock.anchors.horizontalCenterOffset>=0) {
                    mainClock.anchors.horizontalCenterOffset +=1;
                }
           if(mainClock.anchors.horizontalCenterOffset > 30){
               downMovementClock.start();
               upMovementClock.stop();
           }
            }
            }
            Timer{
                id: downMovementClock;
                repeat: true;
                interval: globalScreenSaverInterval;
                onTriggered: {
                    if(mainClock.anchors.horizontalCenterOffset === 0){
                        downMovementClock.stop
                        upMovementClock.start()
                }
                else{
                        mainClock.anchors.horizontalCenterOffset -=1;
                    }

                }
            }
        }




        Text {
            renderType: Text.NativeRendering
            font.family: appsettings.getSystemSetting("CustomFont", "") === "" ? undefined : clockFont.name

            Connections{
                target: main;
                onUpdateDateSize:{
                    mainClock.font.pointSize= decideClockSize();
                }
            }
            opacity: powerSaving? 0.6 : 1
            visible:if(dateVisible){
                        if(usingCustomClockFace){
                            if(customClockFaceWantsDate){
                                return true;
                            }
                            else{
                                return false;
                            }
                        }
                        else{
                            return true;
                        }
                       }
                    else{
                        return false;
                    }
            color: colour
            Behavior on color {ColorAnimation{}}
            anchors{
                horizontalCenter: parent.horizontalCenter;
                topMargin:clockFaceLoader.visible?Theme.paddingLarge+5:undefined;
                top:clockFaceLoader.visible? clockFaceLoader.bottom: mainClock.bottom;
            }
            id: mainDate
            font.bold: boldFont
            font.pointSize:mainClock.font.pointSize/3.5
            text: Qt.formatDateTime (new Date(), dateFormat)

            Timer{
                running:true;
                repeat: true;
                id: upMovementDate;
                interval: globalScreenSaverInterval

                onTriggered: {
            if(mainDate.anchors.horizontalCenterOffset>=0) {
                mainDate.anchors.horizontalCenterOffset+=1;
            }
            if(mainDate.anchors.horizontalCenterOffset>30){
                downMovementDate.start();
                upMovementDate.stop();
            }
            }
            }

            Timer{
                id: downMovementDate;
                repeat: true;
                interval: 1000;
                onTriggered: {
                    if(mainDate.anchors.horizontalCenterOffset === 0){
                        downMovementDate.stop();
                        upMovementDate.start();
                }
                else{
                  mainDate.anchors.horizontalCenterOffset -=1;
                    }
                }
            }
        }


            Component.onCompleted: {
      //Backwards compatability for MPRIS API changes in 4.4

          if(qmlUtils.getOSVersion() >= "4.4"){
           var newObjec = Qt.createQmlObject('
          import Sailfish.Silica 1.0
          import QtQuick 2.6
          MediaControls{
                      id: mediaControls;
                      anchors{
                          bottom: parent.bottom;
                          bottomMargin: largeScreen? batteryIcon.height + batteryIcon.anchors.bottomMargin + Theme.paddingLarge * 1.2 : batteryIcon.height + batteryIcon.anchors.bottomMargin + Theme.paddingLarge
                      }
          }', flickable, "mediacontrols");

      }

         else{
          var newObject = Qt.createQmlObject('
          import Sailfish.Silica 1.0
          import QtQuick 2.6
          MediaControlsLegacy{
                      id: mediaControls;
                      anchors{
                          bottom: parent.bottom;
                          bottomMargin: largeScreen? batteryIcon.height + batteryIcon.anchors.bottomMargin + Theme.paddingLarge * 1.2 : batteryIcon.height + batteryIcon.anchors.bottomMargin + Theme.paddingLarge
                      }
          }', flickable, "mediacontrols");

            }

            }

        WeatherItem{
            onPressAndHold:{
              launcher.launchApp(appsettings.getSystemSetting("weatherLongPressAction", "/usr/share/applications/sailfish-weather.desktop"));
            }

            onClicked:{
                pageStack.push("pages/SettingsBasePage.qml",  {selectedTab : 2})
            }
            id: weatherItem;
            anchors.horizontalCenterOffset: showWeatherLocation? -60:-40;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top:clockFaceLoader.visible? mainDate.visible? mainDate.bottom : clockFaceLoader.bottom : mainDate.visible? mainDate.bottom : mainClock.bottom;
            anchors.topMargin: mainDate.visible?Theme.paddingLarge:Theme.paddingMedium}

        AlarmBellIcon{
            function calcTime(){
                if(timeFormat === "hh:mm:ss"){
                    return qmlUtils.convertTime(alarmTime, timeFormat, "hh:mm");
                }

            else if(timeFormat === "h:mm:ss AP"){
                    return qmlUtils.convertTime(alarmTime, timeFormat, "h:mm AP");
                }

            else{
                    return alarmTime;
                }
            }
            opacity: panel.open? 0: powerSaving? 0.6 : 1;
            id: alarmBell;

            onLongPressed: {
                pageStack.push(Qt.resolvedUrl("pages/AlarmSettings.qml"));
            }
            onClicked:{
                alarmServer.snoozed? creator.createComponent("SnoozeOnOffDialog.qml"): qmlUtils.showBanner(qsTr("Alarm set for") + ": " + calcTime() ," ", 2000)
            }
        }

        Rectangle{
            width: Screen.width/5
            height: Screen.height/8
            color:"Transparent"
             MouseArea{
                 id: mousepill;
                 z:1;
                 width: parent.width;
                 height: parent.height;
                 onClicked:{
                     resetStandbyTimer();
                     panel.show();
                 }
             }

            anchors{
                bottom:parent.bottom;
                horizontalCenter: parent.horizontalCenter;
                bottomMargin: standbyMode? - height : panel.open ? -height : -height/2
            }
     }
        Rectangle{
            z: 1;
            opacity:powerSaving? 0.6 : 0.8;
            id:pillButton;
            Behavior on anchors.bottomMargin {SmoothedAnimation{}}
            Behavior on color {ColorAnimation{}}
            color: colour;
            width: Screen.width/5;
            height:19;
            radius: 40;
            anchors{
                bottom: parent.bottom;
                bottomMargin: standbyMode? - height : panel.open? - height : -height/2;
                horizontalCenter: parent.horizontalCenter
            }
        }

        BatteryIcon{
            opacity: panel.open? 0 : powerSaving? 0.6 : 1;
            id: batteryIcon;
        }
        Text {
            font.bold: boldFont
            anchors{
                left: batteryIcon.right;
                leftMargin: 4;
                verticalCenter: batteryIcon.verticalCenter
            }
            font.family: appsettings.getSystemSetting("CustomFont", "") === "" ? undefined : clockFont.name
            opacity: panel.open? 0 : powerSaving? 0.6 : 1;
            color: colour
            Behavior on color {ColorAnimation{}}
            id: batteryPercentage
            text:mceBatteryLevel.text
            font.pointSize: Theme.fontSizeSmall
        }
    }

}
