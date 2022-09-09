import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../"
import "../AlarmTimeFavourites.js" as AlarmTimeFavs


Page {
    id: page
    allowedOrientations: decideOrientation();
    Component.onCompleted: {}
    Component.onDestruction: {}

    SilicaFlickable {
        contentHeight: column.height
        bottomMargin: 5
        anchors.fill: parent
        id: flickable
        Column {
            width: parent.width;
            id: column;
            spacing: largeScreen? Theme.paddingLarge : Theme.paddingMedium

            PageHeader {
                id: header
                title: qsTr("White Noise Settings")
            }

            TextSwitch {
                id: whiteNoiseSwitch
                text: qsTr("White Noise");
                description: whiteNoiseSource === "" ?  qsTr("You need to select a sound before you can use White Noise") : ""
                enabled: whiteNoiseSource === "" ? false : true
                checked: whiteNoise
                onClicked: {if(whiteNoise){whiteNoise=false;}
                    else{whiteNoise=true;}
                }
            }

        IconTextSwitch{
            text: qsTr("Show toggle in home")
            icon.source: "image://theme/icon-m-browser-sound-template"
            description: qsTr("Show white noise toggle in pill button popup")
            checked: whiteNoiseQuickToggle
            onClicked: {
                if(whiteNoiseQuickToggle){
                    whiteNoiseQuickToggle = false;
                    appsettings.saveSystemSetting("whiteNoiseQuickToggle", "")
                }

           else {
                whiteNoiseQuickToggle = true;
                appsettings.saveSystemSetting("whiteNoiseQuickToggle", "true");
                }
            }
          }

            ComboBox{
                id: soundcombo
                Component.onCompleted: {
                if(appsettings.getSystemSetting("wnsi", "") === "")currentIndex=0
                else currentIndex= parseInt(appsettings.getSystemSetting("wnsi", ""))
                }
                onCurrentIndexChanged:{
                    appsettings.saveSystemSetting("wnsi", currentIndex);
                }
                anchors.topMargin:10
                label:qsTr("White noise sound")
                description: qsTr("Choose from inbuilt or custom sounds")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("WhiteNoiseSoundSettings.qml"))
                }

       }




            Slider{
                label:qsTr("White noise volume")
                value:whiteNoiseVolume
                maximumValue: 1.0
                valueText: Math.round(value*100)+ "%"
                minimumValue: 0.05
                anchors{
                    left:parent.left;
                    right:parent.right
                }
                onValueChanged: {
                    whiteNoiseVolume = value;
                    appsettings.saveSystemSetting("whiteNoiseVolume", value)
                }
            }

        }
    }
}
