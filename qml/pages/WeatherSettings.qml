import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"

Item {
Connections{
    target: tabs;
    onMovingChanged:{
        if(!tabs.moving)show();
         else{saveStuff();
        }
    }
}
Connections{
    target:settingsBase;
    onClosingBasePage:{
        saveStuff();
    }
}


anchors.fill: parent;
visible:false;
id: weather;

property bool allowDeletion:true
function show(){var timer = createTimer(weather, (300));timer.triggered.connect(function() {
    weather.visible = true;
    flickable.opacity = 1;
})
}

Component.onCompleted: {
    if(tabs.moving === false)show();
}

function saveStuff(){
    console.log("saved stuff")
    appsettings.saveSystemSetting("weatherRefreshInterval", weatherRefreshInterval);
    if(weatherLocationEnabled){}
    else if(textField.text === 0){}

    else{
        appsettings.saveSystemSetting("weatherlocation", ("q=" + textField.text));
        if(textField.text.length>0){
        weatherAPI.requestWeather("q=" + textField.text)
    }
    }
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
        spacing: largeScreen? Theme.paddingLarge: Theme.paddingMedium
        TextSwitch{
            text:qsTr("Show Weather")
            checked: showWeather
            onClicked: {
                if(showWeather === true){
                    showWeather = false;
                    appsettings.saveSystemSetting("showWeather", "");
                    weatherVisibleForce();
                }
                else{
                    showWeather = true;
                    appsettings.saveSystemSetting("showWeather", "true");
                    weatherVisibleForce();
                }
            }
        }

        TextSwitch{
            text:qsTr("Use Meecast events widget")
            checked: weatherMeeCast
            enabled: showWeather
            onClicked: {
                if(weatherMeeCast === true){
                    weatherMeeCast = false;
                    appsettings.saveSystemSetting("weatherMeeCast", "");
                    weatherVisibleForce();
                }
                else{
                    weatherMeeCast = true;
                    appsettings.saveSystemSetting("weatherMeeCast", "true");
                    weatherVisibleForce();
                }
            }
        }

        SectionHeader{text: qsTr("Location")}

        IconTextSwitch{
        icon.source: "image://theme/icon-m-location"
        visible: positioning.valid
        checked: weatherLocationEnabled
        text: qsTr("Use current location")
        busy: findingLocation
        description: positioning.position.coordinate.latitude + ", " + positioning.position.coordinate.longitude
        onClicked: {
            if(weatherLocationEnabled === false){
                weatherLocationEnabled=true;
                appsettings.saveSystemSetting("weatherLocationGPS", "true");
                positioning.start();
                findingLocation=true;
            }
            else weatherLocationEnabled = false;
            appsettings.saveSystemSetting("weatherLocationGPS", "")
        }
}
        TextField{
            enabled: showWeather && !weatherMeeCast
            id: textField
            property string bob: appsettings.getSystemSetting("weatherlocation", "")

            Component.onCompleted: {
                text= bob.substring(2, bob.length);
            }

            width: parent.width;
            placeholderText: qsTr("Type City followed by Country Code here"); }

        Label{
            x: Theme.horizontalPageMargin
            wrapMode: Text.Wrap
            fontSizeMode: Text.VerticalFit
            elide: Text.ElideMiddle
            width: parent.width/1.05
            text:qsTr("Type your city in the following formats (CITY, Country Code) for example: Hull, UK or (ZIP, Country Code)")}


        SectionHeader{
           text: qsTr("Customise")
        }

        TextSwitch{
            enabled: showWeather && !weatherMeeCast
            text:qsTr("Show temperature")
            checked: showWeatherTemp
            onClicked: {
                if(showWeatherTemp === true){
                    showWeatherTemp=false;
                    appsettings.saveSystemSetting("weatherTemp", "false")
                }
                else{
                    showWeatherTemp=true;
                    appsettings.saveSystemSetting("weatherTemp", "")
                }
            }
        }
        TextSwitch{
            enabled: showWeather && !weatherMeeCast
            text:qsTr("Show location")
            checked: showWeatherLocation
            onClicked: {
                if(showWeatherLocation === true){
                    showWeatherLocation=false;
                    appsettings.saveSystemSetting("showWeatherLocation", "")
                }
                else{
                    showWeatherLocation=true;
                    appsettings.saveSystemSetting("showWeatherLocation", "true")
                }
            }
        }

        ComboBox{
            enabled: showWeather && !weatherMeeCast
            label:qsTr("Temperature unit")
            id: tempSel
            Component.onCompleted: {
                if(appsettings.getSystemSetting("weatherTempUnitLabel", "") === "")currentIndex=0
                else currentIndex= parseInt(appsettings.getSystemSetting("weatherTempUnitLabel", ""))
            }
            onCurrentIndexChanged:{
                appsettings.saveSystemSetting("weatherTempUnitLabel", currentIndex);
            }
            menu:
                ContextMenu{
                MenuItem{
                    text:qsTr("Celsius");
                    onClicked: {
                        appsettings.saveSystemSetting("weatherTempUnit", "");
                    }
                }
                MenuItem{
                    text:qsTr("Fahrenheit");
                    onClicked: appsettings.saveSystemSetting("weatherTempUnit", "f");
                }
                MenuItem{
                    text:qsTr("Kelvin")
                    onClicked: appsettings.saveSystemSetting("weatherTempUnit", "kelvin");
                }
        }
        }

        ComboBox{
        enabled: showWeather
        label: qsTr("Long press action")
        Component.onCompleted: {
            if(appsettings.getSystemSetting("weatherLongPressActionLabel", "") === "")currentIndex=0
            else currentIndex= parseInt(appsettings.getSystemSetting("weatherLongPressActionLabel", ""))
        }
        onCurrentIndexChanged:{
            appsettings.saveSystemSetting("weatherLongPressActionLabel", currentIndex);
        }
        menu: ContextMenu {
            MenuItem{
                text:qsTr("Do Nothing");
                onClicked: {
                    appsettings.saveSystemSetting("weatherLongPressAction", value);
                }
                value: ""
            }
            MenuItem{
                enabled: qmlUtils.checkFileExists(value);
                text:qsTr("Open Jolla Weather");
                onClicked: {
                    appsettings.saveSystemSetting("weatherLongPressAction", value);
                }
                value:"/usr/share/applications/sailfish-weather.desktop"
            }
            MenuItem{
                enabled:qmlUtils.checkFileExists(value);
                text:qsTr("Open Meecast");
                onClicked: {
                    appsettings.saveSystemSetting("weatherLongPressAction", value);
                }
                value:"/usr/share/applications/harbour-meecast.desktop"
            }
            }
        }

        Slider{
            enabled: showWeather && !weatherMeeCast
            label:qsTr("Weather Refresh Time")
            minimumValue: 1800000
            maximumValue: 18000000
            stepSize: 1800000
            width:parent.width
            value: weatherRefreshInterval
            onValueChanged: {
                weatherRefreshInterval = value;
                valueText = timeConversion(value);
            }
           valueText:timeConversion(value)
            function timeConversion(value) {
                var millisec=value;
            var seconds = (millisec / 1000).toFixed(1);

            var minutes = (millisec / (1000 * 60)).toFixed(1);

            var hours = (millisec / (1000 * 60 * 60)).toFixed(1);

           var days = (millisec / (1000 * 60 * 60 * 24)).toFixed(1);

           if (seconds < 60) {
               return seconds + " " +qsTr("Sec");
           }
            else if (minutes < 60) {
                return minutes + " " + qsTr("Minutes");
            } else if (hours < 24) {
                return hours + " " + qsTr("Hours");
            }

        }
        }

}
}
}
