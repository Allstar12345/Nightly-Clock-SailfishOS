import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"

Item {
    anchors.fill: parent;
    visible:false;
    id: settings;
    property bool allowDeletion: true

Connections{
    target: tabs;
    onMovingChanged:{
        if(!tabs.moving)show();
    }
}

function show(){var timer = createTimer(settings, (300));timer.triggered.connect(function() {settings.visible=true;flickable.opacity=1;})}

Component.onCompleted: {
    if(tabs.moving===false)show();
}

SilicaFlickable{
    opacity:0;
    id:flickable;
    width:parent.width;
    anchors{
        top:parent.top;
        bottom:parent.bottom;
        bottomMargin: Theme.paddingMedium
    }
    contentHeight: column.height;
    Behavior on opacity{OpacityAnimator{}}

    Column{
        width:parent.width;
        id: column;
        spacing: largeScreen? Theme.paddingLarge : Theme.paddingMedium

        TextSwitch{
            text:qsTr("Dim display in standby")
            description: qsTr("Dim display when app goes into standby mode (after 5 minutes of inactivity on the clock screen)")
            checked: appsettings.getSystemSetting("standbyBrightnessChange", "") === ""? false:true
            onClicked: {
                if(appsettings.getSystemSetting("standbyBrightnessChange", "") === ""){
                    appsettings.saveSystemSetting("standbyBrightnessChange", "true");
                }
                else{
                    appsettings.saveSystemSetting("standbyBrightnessChange", "");
                }
            }
        }
        TextSwitch {
             enabled: wallpaperSource === "Black"?false:true
             text: qsTr("Black wallpaper in standby")
             description: wallpaperSource === "Black"? qsTr("Wallpaper is already set to black") : qsTr("Automatically change wallpaper to black when app goes into standby mode")
             checked: standbyBlackWallpaper
             onClicked: {
                 if(standbyBlackWallpaper){
                     standbyBlackWallpaper=false;
                     appsettings.saveSystemSetting("standbyBlackWallpaper", "")
                 }
             else{
                     standbyBlackWallpaper=true;
                     appsettings.saveSystemSetting("standbyBlackWallpaper", "true")
                 }
             }
         }

        TextSwitch{
        text:qsTr("Show media controls");
        description: largeScreen? qsTr("Control your media from the clock screen"): ""
        checked: showMediaControls
        onClicked: {
            if(appsettings.getSystemSetting("mediaControls", "") === ""){
                showMediaControls=false;
                appsettings.saveSystemSetting("mediaControls", "false")
            }
            else{
                showMediaControls=true;
                appsettings.saveSystemSetting("mediaControls", "");
            }
        }
        }

        TextSwitch{
            checked:mprisWallpaper;
            visible: showMediaControls;
            text:qsTr("Show media artwork");
            description: qsTr("Set wallpaper as media artwork if available")
            onClicked: {
                if(mprisWallpaper){
                    mprisWallpaper=false;
                    appsettings.saveSystemSetting("mprisWallpaper", "false")
                }
                else{
                    mprisWallpaper=true;
                    appsettings.saveSystemSetting("mprisWallpaper", "");
                }
            }
        }

        TextSwitch {
            id:updateSwitch
            text: qsTr("Auto check for updates")
            checked: appsettings.getSystemSetting("autoUpdateCheck", "") === ""? true:false
            onClicked: {
                if(appsettings.getSystemSetting("autoUpdateCheck", "") === ""){
                    appsettings.saveSystemSetting("autoUpdateCheck", "false");
                }
                else{
                    appsettings.saveSystemSetting("autoUpdateCheck", "");
                }
            }
        }

        TextSwitch {
            id: tickSwitch
            text: qsTr("Clock ticking sound")
            checked: tickingSound
            onClicked: {
                if(tickingSound){
                    tickingSound=false;
                    appsettings.saveSystemSetting("tickingSound", "")
                }
                else{
                    tickingSound=true;
                    appsettings.saveSystemSetting("tickingSound", true)
                }
                console.log(main.tickingSound)
            }
        }

        TextSwitch {
            id: tickwhenhiddenSwitch
            opacity: tickingSound? 1:0
            visible: tickingSound? true:false
            text: qsTr("Tick when locked/minimised")
            checked: tickingSoundWhenLocked
            onClicked: {
                if(tickingSoundWhenLocked === true){
                    tickingSoundWhenLocked=false;
                    appsettings.saveSystemSetting("tickingSoundWhenLocked", "")
                }
                else{
                    tickingSoundWhenLocked=true;
                    appsettings.saveSystemSetting("tickingSoundWhenLocked", true)
                }
                console.log(tickingSoundWhenLocked)
            }
        }

        Slider{
            label:qsTr("Tick volume")
            value:tickVolume
            opacity: tickingSound? 1:0
            visible: tickingSound? true:false
            maximumValue: 1.0
            valueText: Math.round(value*100)+ "%"
            minimumValue: 0.05
            anchors{
                left:parent.left;
                right:parent.right
            }
            onValueChanged: {
                tickVolume=value;
                appsettings.saveSystemSetting("tickVolume", value);
            }
        }

        TextSwitch {
            id:byp
            text: qsTr("Bypass custom clock check");
            description: qsTr("This will disable the security check for custom clock faces")
            checked: appsettings.getSystemSetting("bcs", "")=== ""? false : true
            onClicked: {
            if(appsettings.getSystemSetting("bcs", "") === "true"){
                appsettings.saveSystemSetting("bcs", "");
            }
            else{
                var dialog = pageStack.push(Qt.resolvedUrl("BypassFaceCheck.qml"), {})
             dialog.rejected.connect(function() {byp.checked = false;})
            }
            }
        }

        ComboBox{
        label: qsTr("White noise")
        description: qsTr("Turn on and tweak white noise sound effects")
        onClicked: {
            pageStack.push(Qt.resolvedUrl("WhiteNoiseSettings.qml"))
        }
        }

        ComboBox{
           label:qsTr("Clock style")
           description: qsTr("Tap here for clock styles")
           onClicked: {
               Screen.sizeCategory == Screen.Large? pageStack.push(Qt.resolvedUrl("ClockFacePickerTablet.qml")):pageStack.push(Qt.resolvedUrl("ClockFacePicker.qml"));
           }

           onCurrentIndexChanged:{
               appsettings.saveSystemSetting("analogClockLabel", currentIndex);
           }
        }

        ComboBox{
            id: datef
            Component.onCompleted: {
                if(appsettings.getSystemSetting("dateformatLabel", "")==="")currentIndex=0
                else currentIndex= parseInt(appsettings.getSystemSetting("dateformatLabel", ""))}

            onCurrentIndexChanged:{appsettings.saveSystemSetting("dateformatLabel", currentIndex);}
            anchors.topMargin:10
            label:qsTr("Date format")
            menu:ContextMenu{
                MenuItem{text:Qt.formatDateTime (new Date(), "dd/MM/yyyy");value:"dd/MM/yyyy"; onClicked:{dateFormat=value; appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);dateVisible=true;appsettings.saveSystemSetting("dateVisible", "")}}
                MenuItem{text:Qt.formatDateTime (new Date(), "MM/dd/yyyy");value:"MM/dd/yyyy"; onClicked:{dateFormat=value; appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);dateVisible=true;appsettings.saveSystemSetting("dateVisible", "")}}
                MenuItem{text:Qt.formatDateTime (new Date(), "yyyy/MM/dd");value:"yyyy/MM/dd"; onClicked:{dateFormat=value; appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);dateVisible=true;appsettings.saveSystemSetting("dateVisible", "")}}
                MenuItem{text:Qt.formatDateTime (new Date(), "yyyy/dd/MM"); value:"yyyy/dd/MM";onClicked:{dateFormat=value; appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);dateVisible=true;appsettings.saveSystemSetting("dateVisible", "")}}
                MenuItem{text:Qt.formatDateTime (new Date(), "dd/MM/yy"); value:"dd/MM/yy";onClicked:{dateFormat=value; appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);dateVisible=true;appsettings.saveSystemSetting("dateVisible", "")}}
                MenuItem{text:Qt.formatDateTime (new Date(), "yy/dd/MM"); value:"yy/dd/MM";onClicked:{dateFormat=value; appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);dateVisible=true;appsettings.saveSystemSetting("dateVisible", "")}}
                MenuItem{text:Qt.formatDateTime (new Date(), "yy/MM/dd");onClicked:{dateFormat=value; appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);dateVisible=true; appsettings.saveSystemSetting("dateVisible", "")}}
                MenuItem{text:qsTr("Date Hidden"); value:"dd/MM/yyyy"; onClicked: {dateFormat=value; dateVisible=false;appsettings.saveSystemSetting("dateFormat", value);appsettings.saveSystemSetting("dateFormatLabel", text);appsettings.saveSystemSetting("dateVisible", "d")} }
            }
   }


        ComboBox{
            Component.onCompleted: {
                if(appsettings.getSystemSetting("timeformatLabel", "")==="")currentIndex=0
               else currentIndex= parseInt(appsettings.getSystemSetting("timeformatLabel", ""))
            }
            onCurrentIndexChanged:{
                appsettings.saveSystemSetting("timeformatLabel", currentIndex);
            }
            label:"Time format"
            menu: ContextMenu{
                MenuItem{
                    text:qsTr("24 Hour with Seconds");
                    value:"hh:mm:ss";
                    onClicked:{
                        clock12Hour=false;
                        alarmTime = qmlUtils.convertTime(alarmTime, timeFormat, value);
                        appsettings.saveSystemSetting("timeFormat", value);
                        appsettings.saveSystemSetting("alarmTime", "");
                        appsettings.saveSystemSetting("alarmTime", alarmTime);
                        timeFormat=value;
                    }
                }

                MenuItem{
                    text:qsTr("24 Hour without Seconds");
                    value:"hh:mm";
                    onClicked:{
                        clock12Hour=false;
                        alarmTime= qmlUtils.convertTime(alarmTime, timeFormat, value);
                        appsettings.saveSystemSetting("timeFormat", value);
                        appsettings.saveSystemSetting("alarmTime", "");
                        appsettings.saveSystemSetting("alarmTime", alarmTime);
                        timeFormat=value;
                    }
                }

                MenuItem{
                    text:qsTr("12 Hour with Seconds");
                    value:"h:mm:ss AP";
                    onClicked:{
                        clock12Hour=true;
                        alarmTime=qmlUtils.convertTime(alarmTime, timeFormat, value);
                        appsettings.saveSystemSetting("timeFormat", value);
                        appsettings.saveSystemSetting("alarmTime", "");
                        appsettings.saveSystemSetting("alarmTime", alarmTime);
                        timeFormat=value;
                    }
                }

                MenuItem{
                    text:qsTr("12 Hour without Seconds");
                    value:"h:mm AP";
                    onClicked:{
                        clock12Hour=true;
                        alarmTime=qmlUtils.convertTime(alarmTime, timeFormat, value);
                        appsettings.saveSystemSetting("timeFormat", value);
                        appsettings.saveSystemSetting("alarmTime", "");
                        appsettings.saveSystemSetting("alarmTime", alarmTime);
                        timeFormat=value;
                    }
                }
            }
        }

        ComboBox{
            label:qsTr("Orientation")
            Component.onCompleted: {
                if(appsettings.getSystemSetting("orientationLabel", "")==="")currentIndex=0
                else currentIndex= parseInt(appsettings.getSystemSetting("orientationLabel", ""))
            }
            onCurrentIndexChanged:{
                appsettings.saveSystemSetting("orientationLabel", currentIndex);
            }

            menu:ContextMenu{
                 MenuItem{
                    text:qsTr("Automatic")
                    onClicked: {allowedOri="All"; }
                 }
                 MenuItem{
                    text:qsTr("Portrait")
                    onClicked: {allowedOri="Portrait"}

                 }
                 MenuItem{
                    text:qsTr("Landscape")
                    onClicked: {allowedOri="Landscape"}

                 }
             }
        }

        /*Button{
            width: parent.width/1.1;
            anchors.horizontalCenter: parent.horizontalCenter;
            text:qsTr("App permissions explained");
            onClicked: {pageStack.push("PermissionsExplainedPage.qml")}
        }*/

        //See BUG#6 15/11/2021 for above


}
}
}
