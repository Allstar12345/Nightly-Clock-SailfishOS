import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../"

Item {
Connections{
    target: tabs
    onMovingChanged:{
        if(!tabs.moving)show();
    }
}

anchors.fill: parent;
visible:false;
id: customise;
property bool allowDeletion:true

function show(){
    var timer = createTimer(customise, (300));timer.triggered.connect(function() {
    customise.visible=true;
    flickable.opacity=1;}
)
}

Component.onCompleted: {
    if(tabs.moving === false)show();
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
        TextSwitch {
            id: boldSwitch
            text: qsTr("Bold Font")
            checked: boldFont
            onClicked: {
                if(boldFont === true){
                    boldFont=false;
                    appsettings.saveSystemSetting("boldFont", "")
                }
                else{
                    boldFont=true;
                    appsettings.saveSystemSetting("boldFont", true)
                }
            }
        }

        TextSwitch{
            id: snowSwitch
            RemorsePopup {
                id: remorseRestartSnow
                onCanceled: {
                    snowSwitch.checked=false;
                }
                onTriggered: {
                    appsettings.saveSystemSetting("snowEffect", "true");
                    qmlUtils.restart();
                }

          }
            text: qsTr("Snow Effect")
            description: qsTr("Celebrate winter time with snow!")
            checked: appsettings.getSystemSetting("snowEffect", "") === ""? false:true
            onClicked: {
                if(appsettings.getSystemSetting("snowEffect", "") === ""){
                    remorseRestartSnow.execute(qsTr("Snow enabled, restarting"), 10000)
                }
                else{
                    appsettings.saveSystemSetting("snowEffect", "");
                    killSnowEffect();
                }
            }

            function checkIfAllowed(){
         var month = Qt.formatDateTime (new Date(), "MM");
        if(month === "11"){return true;}
        else if(month === "12"){return true;}
        else if(month === "01"){return true;}
        else if(month === "02"){return true;}
        else{return false;}
            }

           visible:checkIfAllowed();

        }

        ComboBox{
            value:appsettings.getSystemSetting("wallpaperValue", "")
            label:qsTr("Wallpaper")
            Connections{
                target: main;
                onUpdateWallpaperLabel:{
                    wallpaperCombo.value = appsettings.getSystemSetting("wallpaperValue", "");
                }
            }

            BusyIndicator{
            running: downloadManager.isDownloading
            size: BusyIndicatorSize.Small
            anchors{
                right:parent.right;
                verticalCenter:parent.verticalCenter;
                rightMargin: Theme.paddingLarge
            }
            }
            onClicked: {
                pageStack.push(Qt.resolvedUrl("WallpaperPicker.qml"));
            }
            id: wallpaperCombo

        }


        ComboBox{
            Component.onCompleted: {
                if(appsettings.getSystemSetting("CustomFontLabel", "")==="")currentIndex=0
                else currentIndex= parseInt(appsettings.getSystemSetting("CustomFontLabel", ""))}
            onCurrentIndexChanged:{
                appsettings.saveSystemSetting("CustomFontLabel", currentIndex);
            }
            Component {
                            id: filePickerPage
                            FilePickerPage {
                                title: qsTr("Choose Font")
                                nameFilters: [ '*.otf', '*.ttf' ]
                                onSelectedContentPropertiesChanged: {
                                    console.log(selectedContentProperties.filePath)
                                     appsettings.saveSystemSetting("CustomFont", selectedContentProperties.filePath);
                                }
                            }
                        }
            label:qsTr("Digital Clock/Date Font")
            menu:ContextMenu{
                MenuItem{
                    text:qsTr("Default");
                    onClicked: {
                        appsettings.saveSystemSetting("CustomFont", "");
                    }
                }
                MenuItem{
                    text: qsTr("Font on your device");
                    onClicked: {
                        pageStack.push(filePickerPage)
                    }
                }
            }

        }

        Slider{
            label: qsTr("Clock font brightness")
            value:mainViewBrightness
            maximumValue: 1
            valueText: Math.round(value*100)+ "%"
            minimumValue: 0.4
            anchors{
                left:parent.left;
                right:parent.right
            }
            onValueChanged: {
                mainViewBrightness = value;
                appsettings.saveSystemSetting("mainViewBrightness", value)
            }
        }

        TextSwitch{
            checked:appsettings.getSystemSetting("loopThroughColours", "")===""?false:true
            text: qsTr("Loop through colours")
            enabled: ambianceForColour?false:true
            id: loopSwitch
            onClicked: {
                if(appsettings.getSystemSetting("loopThroughColours", "")===""){
                    ambianceForColour = false;
                    appsettings.saveSystemSetting("loopThroughColours", "true");
                    startColourLoop();
                    ambianceForColour = false;
                    appsettings.saveSystemSetting("ambienceForColour", "");
                }

                else{
                    letsstoplooping();
                    appsettings.saveSystemSetting("loopThroughColours", "")
                }
            }

        }
        TextSwitch{
            text:qsTr("Use Ambience for colour")
            enabled: looping? false:true
            checked:ambianceForColour
            onClicked: {
                if(ambianceForColour === true){
                    appsettings.saveSystemSetting("ambienceForColour", "");
                    ambianceForColour=false;
                }
            else{
                    appsettings.saveSystemSetting("ambienceForColour", "true");
                    ambianceForColour=true;
                }
            }
        }

        ListItem{
            GlassItem {
                enabled: looping? false: ambianceForColour? false : true
               id: colorIndicator
                color:  colour
                radius: 15
                cache: false
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

               Button {
                   enabled:looping? false:ambianceForColour?false:true
                   id: button
                   text:qsTr("Choose a UI colour")
                   anchors.centerIn: parent
                   onClicked: {
                       var page = pageStack.push("Sailfish.Silica.ColorPickerPage", {colors:  colourArray})
                       page.colorClicked.connect(function(color) {
                           colour= color
                           pageStack.pop()
                       })
                   }
               }
        }

        TextField{
            enabled:looping? false:ambianceForColour?false:true
            id: customColour
            text:colour
            width:parent.width
            onTextChanged: {colour=text}
            placeholderText: qsTr("Enter Your #html colour")

        }

}
}
}
