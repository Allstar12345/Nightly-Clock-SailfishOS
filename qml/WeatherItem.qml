import QtQuick 2.6
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import Sailfish.Weather 1.0

Item{
id: root
width: weatherMeeCast? weatherData.width : img.width + tempText.width*2.5
height: weatherMeeCast? weatherData.height :img.height
signal pressAndHold
signal clicked
visible: false
opacity:powerSaving?0.6: 1
Behavior on scale{ScaleAnimator{}}

function createTimer(root, interval) {return Qt.createQmlObject("import QtQuick 2.0; Timer {interval: " + interval + "; repeat: false; running: true;}", root, "TimeoutTimer");}

function jump(){
 root.scale = 1.05;
 var timer = createTimer(root, 300)
 timer.triggered.connect(function() {
     root.scale = 1.0;
 })
}

function checkVisiblee(){
    if(networkOnline === true){
        if(customClockFaceWantsWeather === true){
        if(showWeather === true){
            root.visible = true;
        }
        }
    }
    else{
        root.visible = false;
    }
}

Connections{
    target: weatherAPI;
    onUpdateWeather:{
        updateWeatherInfo();
    }
}
Connections{
    target: main;

    onWeatherVisibleForce:{
       root.checkVisiblee();
    }
    onNetworkOnlineChanged:{
        if(showWeather) if(networkOnline) weatherDelay.start();
    }
}

Timer{
    id: completedDelay;
    interval:500;
    onTriggered: {
        root.checkVisiblee();
    }
}
Component.onCompleted: {
    console.log("Weather completed")
    completedDelay.start();
    if(showWeather === true){
       weatherDelay.start();
    }
}

//Doesn't like showing the location name if triggered straight after onComplete, so add small delay
Timer{
    id: weatherDelay;
    interval: 500;
    onTriggered:{
        weatherAPI.requestWeather(appsettings.getSystemSetting("weatherlocation", ""));
   }
}
function updateWeatherInfo(){
    img.decideSource(weatherAPI.weatherIconId);
}

Timer{
    running:true;
    repeat: true;
    id: upMovement;
    interval: globalScreenSaverInterval

onTriggered: {
    if(root.anchors.topMargin>=50) {
        root.anchors.topMargin+=1;
    }
    if(root.anchors.topMargin>70){
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
        if(root.anchors.topMargin === 50){
            downMovement.stop();
            upMovement.start();
        }
        else{
            root.anchors.topMargin-=1;
        }
    }
}

MouseArea{
    id: mouse;
    enabled:true;
    anchors.fill: parent;
    onClicked: {
        root.clicked();
        resetStandbyTimer();
    }

    onPressAndHold: {
        resetStandbyTimer();
        root.pressAndHold();
        root.jump();
    }
}

Image{
   opacity: powerSaving?0.6: 1;
   visible: !weatherMeeCast
   id: img;
   sourceSize.width: Theme.itemSizeSmall - 10;
   sourceSize.height: Theme.itemSizeSmall - 10;
   width: sourceSize.width;
   height: sourceSize.height;
   source: decideSource(weatherAPI.weatherIconId);
   onSourceChanged: console.log("Weather icon: " + source)
   function decideSource(type){
       console.log(type)
       switch (type) {
       case "01d": {
           return "image://theme/icon-l-weather-d000-light?"+ colour ;
           break;
           }
       case "01n": {
           return "image://theme/icon-l-weather-n000-dark?"+ colour;
               break;
           }
       case "02d": {
      return "image://theme/icon-l-weather-d400-light?"+colour;
               break;
           }
       case "02n": {
           return "image://theme/icon-l-weather-d400-dark?"+colour;
           break;
           }
       case "03d": {
           return "image://theme/icon-l-weather-d400-light?"+colour;
               break;
           }
       case "03n": {
           return "image://theme/icon-l-weather-d400-dark?"+colour;
               break;
           }
       case "04d": {
           return "image://theme/icon-l-weather-d400-light?"+colour;
               break;
           }
       case "04n": {
           return "image://theme/icon-l-weather-d400-dark?"+colour;
               break;
           }
       case "09d": {
           return "image://theme/icon-l-weather-d420-light?"+colour;
               break;
           }
       case "09n": {
           return "image://theme/icon-l-weather-d420-dark?"+ colour;
               break;
           }
       case "10d": {
           return "image://theme/icon-l-weather-d430-light?"+colour;
               break;
           }
       case "10n": {
           return "image://theme/icon-l-weather-d430-dark?"+ colour;
               break;
           }
       case "11d": {
           return "image://theme/icon-l-weather-n440-light?"+ colour;
               break;
           }
       case "11n": {
           return "image://theme/icon-l-weather-n440-dark?"+ colour;
               break;
           }
       case "13d": {
           return "image://theme/icon-l-weather-n432-light?"+ colour;

               break;
           }
       case "13n": {
           return "image://theme/icon-l-weather-n432-dark?"+ colour;

               break;
           }
       case "50d": {
           return "image://theme/icon-l-weather-n600-light?"+ colour;

               break;
           }
       case "50n": {
           return "image://theme/icon-l-weather-n600-dark?" + colour;
               break;
           }
       default: {
               break;
           }
       }
   }
   anchors{
       horizontalCenter: parent.horizontalCenter;
       horizontalCenterOffset: tempText.text.length>= 13 ? -40 : -20
   }
}
Text{
    id: tempText;
    visible: showWeatherTemp && !weatherMeeCast;
    font.bold: boldFont;
    font.pointSize:Theme.fontSizeSmall;
    color: colour;
    Behavior on color {ColorAnimation{}}
    text: showWeatherLocation? weatherAPI.weatherCityName + ", " + weatherAPI.weatherTemp : weatherAPI.weatherTemp
    anchors{
        left: img.right;
        leftMargin: 25;
        verticalCenter:  img.verticalCenter
    }
}
WeatherBanner{
    id: weatherData
    visible: weatherMeeCast
    expanded: true
   }
}
