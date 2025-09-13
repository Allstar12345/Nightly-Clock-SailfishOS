import QtQuick 2.5
import Sailfish.Silica 1.0
import "pages"
import AppSettings 1.0
import QtMultimedia 5.6
import WeatherAPI 1.0
import QtPositioning 5.2
import BingWallpaper 1.0
import DownloadManager 1.0
import QMLUtils 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.Connectivity 1.0
import MeeGo.Connman 0.2
import Nemo.KeepAlive 1.2
import Nemo.Mce 1.0
import org.nemomobile.lipstick 0.1
import Nemo.Notifications 1.0


ApplicationWindow
{
    LauncherItem {
        id: launcher;
        function launchApp(url){
            launcher.filePath = url;
            launcher.launchApplication();
        }
    }

    KeepAlive {
        id: keepAlive;
        enabled: alarmEnabled
    }

onApplicationActiveChanged: {
    console.log("Active : "+ applicationActive);
    if(usingCustomClockFace)repaintClockFace();
}

   BingWallpaper{
       id: bingWallpaper;
        onResultFinished: {
            var file_path = StandardPaths.data + "/photoftheday.jpg";
            if(qmlUtils.checkFileExists(file_path) && xResult["images"][0]["url"] === appsettings.getSystemSetting("imageofthedaylasturlll", "")){
                wallpaperSource = "file://" + file_path;
            }
            else{
            console.log(xResult["images"][0]["url"])
            qmlUtils.deleteFile(StandardPaths.data + "/photoftheday.jpg");
            downloadManager.download("http://www.bing.com"+ xResult["images"][0]["url"], StandardPaths.data + "/photoftheday.jpg");
            appsettings.saveSystemSetting("imageofthedaylasturlll", xResult["images"][0]["url"]);

            }
        }
    }

    QMLUtils{id: qmlUtils}
    PositionSource {
        id: positioning
        updateInterval: 3600000
        active: weatherLocationEnabled
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        onSourceErrorChanged: {
            console.log("Positioning Error: " + sourceError );
            findingLocation = false;
        }
        onPositionChanged: {
            var coord = positioning.position.coordinate;
            findingLocation = false;
            weatherAPI.requestWeather("lat" + "="+ coord.latitude + "&lon" + "="+ coord.longitude);
        }
    }

 Timer{
     id: weatherRefreshTimer;
     running:showWeather;
     interval: weatherRefreshInterval;
     onTriggered: {
         if(weatherLocationEnabled){
             positioning.start();
         }
         else{
             weatherAPI.requestWeather(appsettings.getSystemSetting("weatherlocation", ""))
         }
     }
 }

 WeatherAPI {
        id: weatherAPI
        property string weatherIconId
        property string weatherTemp
        property string weatherDescription
        property string weatherCityName
        property string weatherHumidity
        signal updateWeather
        url: "http://api.openweathermap.org/data/2.5/weather?"
        function cToF(celsius){
            var cTemp = celsius;
          var cToFahr = cTemp * 9 / 5 + 32;
            return cToFahr;
        }

        onResultFinished: {
            weatherDescription = xResult["weather"][0]["description"];
            weatherCityName = xResult["name"];
            weatherTemp = appsettings.getSystemSetting("weatherTempUnit", "") === ""? Math.round(xResult["main"]["temp"] - 273.15) + " °C": appsettings.getSystemSetting("weatherTempUnit", "")==="kelvin"? xResult["main"]["temp"] +"°K":  cToF(Math.round(xResult["main"]["temp"] - 273.15)) + "°F"
            weatherHumidity = xResult["main"]["humidity"] + " %";
            weatherIconId = xResult["weather"][0]["icon"];
            console.log(weatherCityName + weatherDescription + weatherTemp + weatherHumidity + weatherIconId);
            updateWeather();
        }
    }

    DownloadManager{
        id: downloadManager;
        property bool isDownloading
    }
    Connections{
        target: downloadManager;
        onDownloadStarted:{
            downloadManager.isDownloading = true;
        }
        onDownloadError:{
            downloadManager.isDownloading = false;
        }
        onDownloadComplete:{
            downloadManager.isDownloading = false;
            if(!alarmServer.alarmSounding){
                wallpaperSource = "file://" + StandardPaths.data + "/photoftheday.jpg";
                console.log("FileSize:  " + qmlUtils.getFileSize(StandardPaths.data + "/photoftheday.jpg") )
            }
    }
    }

    Connections{
        target: qmlUtils;
        onShowBannerMessage:{
            Notices.show(title + " " + text, timeout, Notice.Center);
        }

        onOnlineModeChanged:{
            networkOnline = isOnline;
        }
    }


    function validRepr(valid) {return valid ? "" : "[invalid]"}
    MceBatteryLevel {
          id: mceBatteryLevel
          readonly property string validRepr: main.validRepr(valid)
          readonly property string text: validRepr + percent + "%"
          onTextChanged: {
              if(percent<=20)
                  powerSaving = true;
              else powerSaving = false
          }
      }
    MceChargerState {
        id: mceChargerState
        readonly property string validRepr: main.validRepr(valid)
    }

   ConnectionHelper {
         id: connectionHelper
         onNetworkConnectivityEstablished: {
             networkOnline = true;
         }
         onNetworkConnectivityUnavailable: {
             networkOnline = false;
         }
    }
   property bool inslideshowmanager

   Connections{
       target: inslideshowmanager? null : qmlUtils;

       onPictureImportItem:{
           wallpaperSlideshowModel.append({"url":ico});
       }

       onPictureImportFinished:{
           console.log("Finished")
       }
   }

ListModel{id:wallpaperSlideshowModel;}

ListModel {id: slideshowManagerModel; }

Connections{
    target: qmlUtils;
    onPictureImportItem:{
        slideshowManagerModel.append({"url":ico});
    }
}

Timer {
    id: randomColourDecider;
    repeat:true;
    triggeredOnStart: false;
    running: false;
    interval:300000;
    onTriggered: {
        colourLoop();
    }
}

Timer {
    id: slideShowLooper;
    repeat:true;
    triggeredOnStart: false;
    running: false;
    interval:slideShowInterval;
    onTriggered: {
        slideShowLoop();
    }
}

function slideShowLoop(){
    if(slideshowCurrentIndex === wallpaperSlideshowModel.count){
        slideshowCurrentIndex = 0;
    }

    console.log("slideshowCurrentIndex: "+ slideshowCurrentIndex + " Value: " + wallpaperSlideshowModel.get(slideshowCurrentIndex).url)
    wallpaperSource = wallpaperSlideshowModel.get(slideshowCurrentIndex).url
    slideshowCurrentIndex++;
}

 function stopWallpaperSlideshow(){
     slideShowLooper.stop();
 }

 function startWallpaperSlideshow(){
     qmlUtils.importPictureList(StandardPaths.data + "/wallpaperslideshow.list");
     wallpaperSource= wallpaperSlideshowModel.get(0).url;slideshowCurrentIndex++;
     slideShowLooper.start();
 }

    property var colourArray:[ '#0092cc', '#FF6633', '#FFB399', '#FF33FF', '#FFFF99', '#00B3E6',
        '#E6B333', '#3366E6', '#999966', '#99FF99', '#B34D4D',
        '#80B300', '#809900', '#E6B3B3', '#6680B3', '7FDBFF', '#39CCCC', '#66991A',
        '#FF99E6', '#CCFF1A', '#FF1A66', '#E6331A', '#33FFCC',
        '#66994D', '#B366CC', '#4D8000', '#B33300', '#01FF70', '#CC80CC',
        '#66664D', '#991AFF', '#E666FF', '#4DB3FF', '#F012BE', '#1AB399',
        '#E666B3', '#33991A', '#CC9999', '#B3B31A', '#00E680',
        '#4D8066', '#809980', '#E6FF80', '#B10DC9' ,'#1AFF33', '#999933',
        '#FF3380', '#CCCC00', '#66E64D', '#4D80CC', '#9900B3',
'#E64D66', '#4DB380', '#FF4D4D', '#DDDDDD', '#99E6E6', '#6666FF', '#ffffff']

function startColourLoop(){
    randomColourDecider.start();
    looping = true;
}

function intSunriseMode(){
    inter = qmlUtils.subractTime(alarmTime, timeFormat)
    sunriseTime=inter.substring(0, inter.length)
}

property string inter

function letsstoplooping(){
    randomColourDecider.stop();
    looping=false;
}

function colourLoop(){
    if(currentIndex === colourArray.length){
        currentIndex=0;
    }
    colour=colourArray[currentIndex]; //function
    currentIndex++;
}

property bool flashAlarmTime
property bool lightTheme: {
        try {
            if (Theme.colorScheme !== Theme.LightOnDark)
                return true
        } catch (e) {}
        return false
    }
function createTimer(root, interval) {return Qt.createQmlObject("import QtQuick 2.0; Timer {interval: " + interval + "; repeat: false; running: true;}", root, "TimeoutTimer");}
signal forcePauseMPRIS
property bool mprisWallpaper
property int slideShowInterval
property int slideshowCurrentIndex
property bool wallpaperSlideshow
property bool largeScreen: Screen.sizeCategory == Screen.Large
signal updateWallpaperLabel
signal forceSelectedChange
signal colourUpdated
signal timeUpdated
signal repaintClockFace
property bool usingExternal: appsettings.getSystemSetting("usingExternalClockFace", "")===""? false : true
property bool usingCustomClockFace:appsettings.getSystemSetting("usingCustomClockFace", "")===""? false : true
onUsingCustomClockFaceChanged: {
    if(usingCustomClockFace){
        appsettings.saveSystemSetting("usingCustomClockFace", "true");
    }
    else{
        appsettings.saveSystemSetting("usingCustomClockFace", "");
    }
}
signal killSnowEffect
property bool customClockFaceWantsDate
property bool customClockFaceWantsWeather:true
signal weatherVisibleForce
onCustomClockFaceWantsWeatherChanged: {weatherVisibleForce();}
property bool pushingFromFavsPage
property string pushingFromFavsTime
property string pushingFromFavsFormat
property string sunriseTime
property bool standbyBlackWallpaper
property string customClockFaceURL: appsettings.getSystemSetting("customClockFaceURL", "")
onCustomClockFaceURLChanged: {
    appsettings.saveSystemSetting("customClockFaceURL", customClockFaceURL);
}
property bool manualUpdateCheck
signal startSunriseTimer
property bool findingLocation
property int weatherRefreshInterval
property bool showWeather:true
property bool showWeatherTemp
property bool standbyMode:false
signal toggleDarkWallpaper
property double lastScreenBrightness
property string clockTime
property bool sunriseMode
property bool firstRun:false
property bool networkOnline
signal startInteractiveTut
property bool showWeatherLocation
property bool flashCameraLight
property string mediaArtWorkURI
property string wallpaperSource: appsettings.getSystemSetting("wallpaper", "")
property real alarmVolume
property bool fadeInAlarm
property bool ambianceForColour:if(appsettings.getSystemSetting("ambienceForColour", "")=== ""){return false;} else return true;
property double tickVolume
property int globalScreenSaverInterval: applicationActive ? powerSaving? 8000 : 4000 :0
property bool alarmEnabled :appsettings.getSystemSetting("alarmEnabled", "") === ""? false: true
property string alarmTime:appsettings.getSystemSetting("alarmTime", "") === ""? "": appsettings.getSystemSetting("alarmTime", "")
property double vibrationIntensity: appsettings.getSystemSetting("vibrationIntensity", "") === "" ?  "0.75":appsettings.getSystemSetting("vibrationIntensity", "");
property int vibrationDuration
property string alarmSound: appsettings.getSystemSetting("alarmSound", "")=== "" ? "sounds/1.mp3": appsettings.getSystemSetting("alarmSound", "")
property string colour:ambianceForColour? Theme.highlightColor: appsettings.getSystemSetting("clockColour", "#0092cc")
property string lighterColour: Qt.lighter(colour)
property string alarmSnoozeTimeout
property int flashSpeed:parseInt(appsettings.getSystemSetting("flashLightSpeed", "")) ? parseInt(appsettings.getSystemSetting("flashLightSpeed", "")): 3500
property bool powerSaving: false
property string dateFormat: appsettings.getSystemSetting("dateFormat", "")===""? "dd/MM/yyyy": appsettings.getSystemSetting("dateFormat", "")
property bool boldFont: appsettings.getSystemSetting("boldFont", "")===""?false:true
property bool intervalAlarm: appsettings.getSystemSetting("intervalAlarmMode", "")===""? false:true
property string timeFormat: appsettings.getSystemSetting("timeFormat", "")===""? ("hh:mm:ss"): appsettings.getSystemSetting("timeFormat", "")
property bool clock12Hour: appsettings.saveSystemSetting("clock12Hours", false)=== ""? true:false
property bool dateVisible:appsettings.getSystemSetting("dateVisible", "")===""? true:false
property real mainViewBrightness
property bool tickingSound
property bool tickingSoundWhenLocked
property bool showMediaControls
property bool whiteNoise
property bool whiteNoiseWithAlarm: appsettings.getSystemSetting("whiteNoiseWithAlarm", "") === "" ? false : true
property real whiteNoiseVolume: appsettings.getSystemSetting("whiteNoiseVolume", "0.3")
property string whiteNoiseSource: appsettings.getSystemSetting("whiteNoiseSource", "")
property bool  whiteNoiseQuickToggle: appsettings.getSystemSetting("whiteNoiseQuickToggle", "") === "" ? false : true

onStandbyModeChanged: {
    if(standbyMode){

        if(standbyBlackWallpaper){
            toggleDarkWallpaper();
        }

        if(appsettings.getSystemSetting("standbyBrightnessChange", "")==="true"){
            if(applicationActive){
                lastScreenBrightness = displaySettings.brightness;
                setScreenBrightness(1.05);
                console.log("Last brightness: " +lastScreenBrightness)
            }
        }
    }
    else{
        if(standbyBlackWallpaper){
            toggleDarkWallpaper();
        }
        if(appsettings.getSystemSetting("standbyBrightnessChange", "")==="true"){
        if(lastScreenBrightness == 0){
            setScreenBrightness(1.50)}

        else displaySettings.brightness= _calcDelta (lastScreenBrightness);
        }
        }
}
property int currentIndex:0
property bool looping
property string sunriseColourString
signal stopSunrise
signal oriChanged

property bool weatherLocationEnabled
    property string highlightColor:Theme.highlightColor
    onHighlightColorChanged: {
        if(ambianceForColour) colour=Theme.highlightColor;
    }
    signal restartStandbyTimer
    signal  batteryChargingChanged
    property bool compactMode:true
    property bool customFont:false
    allowedOrientations: decideOrientation();
    initialPage: Component { MainPage { id: mainPage} }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    signal updateAlarmBell
    signal updateColourBoxText
    signal updateAlarmTimeBox
    signal fireIntervalPage
    signal showMainClock();
    signal updateDateSize
    signal updateWallpaperRatio

    function setScreenBrightness (value) {
        if (value <= 1) setMinimumBrightness()
        else if (value >= displaySettings.maximumBrightness) setMaximumBrightness ();
        else displaySettings.brightness = value;
    }

    function setMinimumScreenBrightness () {
        displaySettings.brightness = 1
    }

    function setMaximumScreenBrightness () {
        displaySettings.brightness = displaySettings.maximumBrightness
    }

    function _calcDelta (percents) {
        return Math.round (displaySettings.maximumBrightness / 100 * percents)
    }

    DisplaySettings {id: displaySettings}

function decideBaseClockSize(){
    if(timeFormat === "hh:mm:ss"){
 if(Screen.sizeCategory== Screen.Large){
return compactMode? Theme.fontSizeHuge*2.8: Theme.fontSizeHuge*3.1}
else{
     return compactMode? Theme.fontSizeHuge*1.65: Theme.fontSizeHuge*2.65
 }
}

else if(timeFormat === "hh:mm"){
 if(Screen.sizeCategory== Screen.Large){
return compactMode? Theme.fontSizeHuge*3: Theme.fontSizeHuge*3.3}
else{
     return compactMode? Theme.fontSizeHuge*2.2: Theme.fontSizeHuge*2.7
 }
}
else if(timeFormat === "h:mm:ss AP"){
 if(Screen.sizeCategory== Screen.Large){
return compactMode? Theme.fontSizeHuge*2.25: Theme.fontSizeHuge*3.0}
else{
     return compactMode? Theme.fontSizeHuge*1.23: Theme.fontSizeHuge*2.25
 }
}
 else  if(timeFormat === "h:mm AP"){
if(Screen.sizeCategory== Screen.Large){
return compactMode? Theme.fontSizeHuge*2.5: Theme.fontSizeHuge*3.2}
else{return compactMode? Theme.fontSizeHuge*1.6: Theme.fontSizeHuge*2.5
}
 }
}

   function decideClockSize(){
       if(appsettings.getSystemSetting("fontSize", "")===""){
           console.log("fontSize Setting Empty, going default");
           return decideBaseClockSize();
      }
       else{
           var size= appsettings.getSystemSetting("fontSize", "");
           console.log(size)
           if(size === "Large"){
               return decideBaseClockSize();
           }

           else if(size === "Medium"){
               console.log("Triggered Medium Code")
               return decideBaseClockSize()/1.2;
           }

           else if(size === "Small"){
               console.log("Triggered Small Code")
               return decideBaseClockSize()/1.4;
           }

           else if(size === "XSmall"){
               console.log("Triggered XSmall Code")
               return decideBaseClockSize()/1.6;
           }

           else{
               console.log("Something cocked up: " + Theme.pixelRatio + " " +Screen.width +" " + Screen.height)
           }

       }
    }
    Component.onCompleted: {
        console.log("12 Hour? " + clock12Hour)
        if(appsettings.getSystemSetting("loopThroughColours", "")==="true")startColourLoop();
        alarmVolume =  appsettings.getSystemSetting("alarmVolume", "")==="" ? 0.99 : appsettings.getSystemSetting("alarmVolume", "");
        showWeatherTemp = appsettings.getSystemSetting("weatherTemp", "")===""? true:false
        showWeather = appsettings.getSystemSetting("showWeather", "")===""? false:true
        weatherLocationEnabled = appsettings.getSystemSetting("weatherLocationGPS", "")===""? false:true
        weatherRefreshInterval = appsettings.getSystemSetting("weatherRefreshInterval", "3600000");
        if(wallpaperSource === "bing"){
            console.log("Bing Wallpaper active");
            bingWallpaper.requestWallpaper("http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1")
        }
        flashCameraLight = appsettings.getSystemSetting("flashCameraLight", "")===""?false:true
        tickVolume = appsettings.getSystemSetting("tickVolume", "")=== "" ?0.8 :appsettings.getSystemSetting("tickVolume", "");
        vibrationDuration =  parseInt(appsettings.getSystemSetting("VibrationDuration", ""))? parseInt(appsettings.getSystemSetting("VibrationDuration", "")): "0";
        mainViewBrightness =  appsettings.getSystemSetting("mainViewBrightness", "") === ""?1:appsettings.getSystemSetting("mainViewBrightness", "");
        tickingSound = appsettings.getSystemSetting("tickingSound", "")===""? false:true;
        tickingSoundWhenLocked = appsettings.getSystemSetting("tickingSoundWhenLocked", "") === ""? false:true;
        alarmSnoozeTimeout = appsettings.getSystemSetting("alarmSnoozeTimeout", "") === ""?300000: appsettings.getSystemSetting("alarmSnoozeTimeout", "");
        showWeatherLocation = appsettings.getSystemSetting("showWeatherLocation", "") === ""?false:true
        sunriseMode = appsettings.getSystemSetting("sunriseMode", "")===""?false : true
        fadeInAlarm = appsettings.getSystemSetting("fadeInAlarmVolume", "") === ""?false:true
        showMediaControls = appsettings.getSystemSetting("mediaControls", "") === ""? true:false
        standbyBlackWallpaper =appsettings.getSystemSetting("standbyBlackWallpaper", "") === ""?false:true
        slideShowInterval = appsettings.getSystemSetting("slideshowInterval", 300000);
        wallpaperSlideshow = appsettings.getSystemSetting("wallpaperSlideshow", "") === ""?false:true
        mprisWallpaper = appsettings.getSystemSetting("mprisWallpaper", "") === ""?true:false
        if(wallpaperSlideshow){startWallpaperSlideshow();}
        if(appsettings.getSystemSetting("firstRun", "") === ""){
            firstRun = true;
            firstRunDelay.start();
        }
        if(firstRun === false){
            updateChecker.start();
        }
    }

    onSunriseModeChanged: {
        intSunriseMode();
    }

    Timer{
        id: firstRunDelay;
        interval: 200;
        onTriggered: {
            pageStack.push(Qt.resolvedUrl("pages/FirstRun/FirstRun.qml"));
        }
    }

    Timer{
        id: updateChecker;
        interval: 900;
        onTriggered: {if(appsettings.getSystemSetting("autoUpdateCheck", "")===""){
                create.createComponent(Qt.resolvedUrl("UpdateChecker.qml"))
            }
        }
    }

    property string allowedOri: appsettings.getSystemSetting("applicationOrientation", "") === ""? "All":  appsettings.getSystemSetting("applicationOrientation", "")
    AppSettings{ id:appsettings}
    AlarmServer{id: alarmServer}

    id: main

    function decideOrientation(){
        if(allowedOri === "All"){
            return Orientation.All
        }
        else if(allowedOri === "Landscape"){
            return Orientation.Landscape
        }
        else if (allowedOri === "Portrait"){
            return Orientation.Portrait
        }

    }
    onAllowedOriChanged: {
        appsettings.saveSystemSetting("applicationOrientation", allowedOri);
    }

    QtObject { id: create; property Component com: null;function createComponent (qmlfile){com = Qt.createComponent(qmlfile);com.createObject(main)} }


    onColourChanged: {
        colourUpdated();
        if(ambianceForColour === false)appsettings.saveSystemSetting("clockColour", colour)
    }

    onAlarmEnabledChanged: {
        if(alarmEnabled === true){
            appsettings.saveSystemSetting("alarmEnabled", "true");
            if(sunriseMode){
                intSunriseMode();
            }
        }
        else{
            appsettings.saveSystemSetting("alarmEnabled", "")
        }
    }

    onIntervalAlarmChanged: {
        if(intervalAlarm === true)appsettings.saveSystemSetting("intervalAlarmMode", "true")
        else{
            appsettings.saveSystemSetting("intervalAlarmMode", "")
        }
    }

    onWallpaperSourceChanged:{
        if(appsettings.getSystemSetting("wallpaper", "") === "bing"){}
        else appsettings.saveSystemSetting("wallpaper", wallpaperSource)
    }

    onAlarmTimeChanged: {
        if(sunriseMode){
            intSunriseMode();
        }
        if(appsettings.getSystemSetting("usingShoutForAlarm", "")===""){
            alarmServer.shoutAsSoundSource = false
        }
        else{
            alarmServer.shoutAsSoundSource = true;
            alarmServer.preBufferTime = qmlUtils.calcPreRadioBufferTime(alarmTime, timeFormat);
            appsettings.saveSystemSetting("preBufferTime", alarmServer.preBufferTime);
        }
    }


    onTimeFormatChanged: {
        if(appsettings.getSystemSetting("usingShoutForAlarm", "") === ""){
            alarmServer.shoutAsSoundSource=false
        }

    else{
            alarmServer.shoutAsSoundSource = true;
            alarmServer.preBufferTime = qmlUtils.calcPreRadioBufferTime(alarmTime, timeFormat);
            appsettings.saveSystemSetting("preBufferTime", alarmServer.preBufferTime);
        }
    }


    onAlarmSoundChanged: {
      console.log(alarmSound)
    if(appsettings.getSystemSetting("usingShoutForAlarm", "")===""){
        alarmServer.shoutAsSoundSource = false
    }
    else{
        alarmServer.shoutAsSoundSource = true;
        alarmServer.preBufferTime = qmlUtils.calcPreRadioBufferTime(alarmTime, timeFormat);
        appsettings.saveSystemSetting("preBufferTime", alarmServer.preBufferTime);
    }
    }

    MediaPlayer{
       id: tickSound
       source:"sounds/tick.mp3"
       volume: if(tickingSoundWhenLocked == true){
                   tickVolume
               }
      else{
        applicationActive == false? 0: tickVolume
        }
    }

    NumberAnimation{
        id: fadeOutw;
        duration: 4000;
        target:whiteNoiseAudio;
        property: "volume";
        from:1;
    }

    NumberAnimation{
        id: fadeInw;
        duration: 4000;
        target:whiteNoiseAudio;
        property: "volume";
        from:0;
    }

    MediaPlayer{
    id: whiteNoiseAudio
    onVolumeChanged: console.log(volume)
    function dropVolume(value){
        fadeOutw.to=value;
        fadeOutw.start();
    }
    function raiseVolume(value, duration){
        fadeInw.to=value;
        fadeInw.duration=duration;
        fadeInw.start();
    }

    source: "file://" + whiteNoiseSource
    volume: alarmServer.alarmSounding ? 0 : whiteNoiseVolume
    loops: MediaPlayer.Infinite
    autoLoad: false
    // force pause any media playback from outside Nightly Clock to avoid conflicts
    onPlaybackStateChanged: {
    if(Audio.playbackState === Audio.PlayingState){
        forcePauseMPRIS();
    }
    }
     onError:{
        if( Audio.error=== Audio.NetworkError){}
        else if( Audio.error=== Audio.ResourceError){}
        else if( Audio.error=== Audio.FormatError){}
        else if( Audio.error=== Audio.AccessDeniedError){}
        else if( Audio.error=== Audio.ServiceMissing){}
        console.log("White Noise Audio Error: "  +errorString + "\nSource: "+ whiteNoiseSource);
    }
    }

    onClock12HourChanged:{
        appsettings.saveSystemSetting("clock12Hours", clock12Hour)
    }

    onAmbianceForColourChanged: {
        if(ambianceForColour === false){
            colour=appsettings.getSystemSetting("clockColour", "")
        }
        else colour= Theme.highlightColor
    }



    onWhiteNoiseChanged: {
       if(whiteNoise){
         if(qmlUtils.dirCheck(StandardPaths.data + "/assets")) {
             whiteNoiseAudio.play();
             whiteNoiseAudio.raiseVolume(whiteNoiseVolume, 3000);
         }
         else{
             if(whiteNoiseSource=== "") {
             pageStack.push("NoWhiteNoisesDialog.qml");
             whiteNoise = false;
             }
         }
         }

       else whiteNoiseAudio.stop();
    }

}
