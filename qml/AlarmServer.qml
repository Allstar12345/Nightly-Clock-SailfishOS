import QtQuick 2.6
import QtMultimedia 5.6
import QtFeedback 5.0
import "shoutcast.js" as Shoutcast
import "jsUtils.js" as Util

Item{
    id: alarmServer
    function playy(){
        audio.play();
    }
    property string preBufferTime: appsettings.getSystemSetting("preBufferTime", "")
    property alias alarmSource: audio.source
    property bool shoutAsSoundSource:appsettings.getSystemSetting("usingShoutForAlarm", "")===""?false:true
    signal openIntervalPage
    signal closeIntervalPage
    signal closeIntervalPageFull
    property alias mediaStatus:audio.status
    property int intervalCount: parseInt(appsettings.getSystemSetting("intervalHowManyToSound", ""))
    property int intervalRestartTime: parseInt(appsettings.getSystemSetting("intervalTimeBetweenSounding", ""))
    property int counted:0
    property int soundingInterval: parseInt(appsettings.getSystemSetting("intervalAlarmTimeout", ""))
    property int audioBufferProgress
    property bool snoozed:false
    property bool intervalAlarmSounding:false
    property bool alarmSounding:false
    function forcePlay(){
        audio.play();
    }
    function stopSnooze(){
        snoozed=false;
        snoozeTimer.stop();
    }

    function snooze(){
        snoozed=true;
        vibra.stop();
        audio.stop();
        snoozeTimer.start();
        alarmEnabled=false;
    }

    function enableAlarm(){
        alarmEnabled = true;
        appsettings.saveSystemSetting("alarmEnabled", "true");
    }

    function disableAlarm(){
        alarmEnabled=false;
        appsettings.saveSystemSetting("alarmEnabled", "");
    }

    function disableIntervalAlarm(){
        intervalAlarm=false;
    }

    function enableIntervalAlarm(){
        intervalAlarm=true;
    }

    function pushIntervalPage(){
        fireIntervalPage();
    }

function soundAlarmWebBodge(){
    standbyMode = false;
    if(intervalAlarmSounding){
        main.activate();

        if(fadeInAlarm){

            fadeIn.start();
        }

        vibra.start();
    }

    else if(main.applicationActive === false){
        main.activate();
        alarmSounding = true;

        if(fadeInAlarm){
            fadeIn.start();
        }

        vibra.start();
        pageStack.push(Qt.resolvedUrl("pages/AlarmTriggerPage.qml"))
    }

        else{
        alarmSounding = true;

        if(fadeInAlarm){
            fadeIn.start();
        }

        vibra.start();
        pageStack.push(Qt.resolvedUrl("pages/AlarmTriggerPage.qml"))
    }
}


function soundAlarm(){
        standbyMode = false;
        if(intervalAlarmSounding){
            main.activate();

            if(fadeInAlarm){
                fadeIn.start();
            }

            audio.play();
            vibra.start();
        }

        else if(main.applicationActive===false){
            audio.autoLoad=true;
            main.activate();
            alarmSounding=true;
            if(fadeInAlarm){
                fadeIn.start();
            }
            audio.play();
            vibra.start();
            pageStack.push(Qt.resolvedUrl("pages/AlarmTriggerPage.qml"));
        }
            else{
            alarmSounding=true;
            if(fadeInAlarm){
                fadeIn.start();
            }
            audio.play();
            vibra.start();
            pageStack.push(Qt.resolvedUrl("pages/AlarmTriggerPage.qml"))
        }
    }

    function stopAlarm(){
        if(shoutAsSoundSource){
            if(networkOnline)
                downloadManager.cancel();
        }
        snoozed = false;
        alarmSounding = false
        intervalAlarmSounding = false;
        audio.stop();
        vibra.stop();
        alarmEnabled = false;
        lastStepTimer.stop();
        intervalSounder.stop();
        intervalRestart.stop();
        closeIntervalPageFull();

        if(shoutAsSoundSource){
            if(networkOnline)qmlUtils.deleteFile(qmlUtils.tempPath()+ "/internetRadioPrebuffer.mp3");
            alarmSound=appsettings.getSystemSetting("alarmSound", "");
        }
    }

    function soundInterval(){
        if(intervalCount==counted){
            intervalSounder.stop();
            closeIntervalPage();
            lastStepTimer.start();
        }

        else{
            pushIntervalPage();
            intervalAlarmSounding=true;
            soundAlarm();
            intervalSounder.start();
        }
 }

    property string logoURL: ""
    signal stationChanged(var stationInfo)
    signal stationChangeFailed(var stationInfo)
    property string shoutcastSource;
    property int retryAttempts

    onStationChanged: {
        alarmServer.stationId = stationInfo.id
        alarmServer.stationName = stationInfo.name
        alarmServer.genreName = stationInfo.genre
        alarmServer.streamMetaText1 = stationInfo.name + " - " + stationInfo.lc + " " + Shoutcast.getAudioType(stationInfo.mt) + " " + stationInfo.br
        alarmServer.streamMetaText2 = (stationInfo.genre ? (stationInfo.genre + " - ") : "") + stationInfo.ct
        alarmServer.logoURL = stationInfo.logo ? stationInfo.logo : ""
        alarmServer.shoutcastSource = stationInfo.stream
        var metaData = {}
        metaData['title'] = alarmServer.streamMetaText1
        metaData['artist'] = alarmServer.stationName
        pageStack.push("pages/ShoutcastStreamTest.qml");
        //stationInfo.stream is url
    }

    function loadStation(stationId, info, tuneinBase) {_loadStation(stationId, info, tuneinBase)}

    function _loadStation(stationId, info, tuneinBase) {
        var sid=stationId; var inf= info; var base=tuneinBase; var m3uBase = tuneinBase["base-m3u"]

        if(!m3uBase) { showErrorDialog(qsTr("Don't know how to retrieve playlist."));console.log("Don't know how to retrieve playlist.: \n\m" + JSON.stringify(tuneinBase));}

        var xhr = new XMLHttpRequest
        var playlistUri = Shoutcast.TuneInBase
                + m3uBase
                + "?" + Shoutcast.getStationPart(stationId)
        xhr.open("GET", playlistUri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                timer.destroy()
                var playlist = xhr.responseText;
                console.log("Playlist for stream: \n\n" + playlist)
                var streamURL
                streamURL = Shoutcast.extractURLFromM3U(playlist)
                console.log("URL: \n\n" + streamURL)
                if(streamURL.length > 0) {
                        info.stream = streamURL
                        stationChanged(info)
                }   else {
                    // Retry load here in case server is returning 404, seems to happen randomly
                    if(retryAttempts<1){
                        var rettimer = createTimer(alarmServer, 2000);
                        rettimer.triggered.connect(function() {
                            loadStation(sid, inf, base);
                            retryAttempts++;
                            rettimer.destroy();});
                   }
                    else{console.log("Error could not find stream URL: \n\n" + playlistUri + "\n\n" + playlist + "\n\n");showErrorDialog(qsTr("Failed to retrieve stream URL."));stationChangeFailed(info)}

                }
            }
        }
        var timer = createTimer(alarmServer, 2000)
        timer.triggered.connect(function() {
            if(xhr.readyState === XMLHttpRequest.DONE)
                return
            xhr.abort()
            showErrorDialog(qsTr("Server did not respond while retrieving stream URL."))
            console.log("Error timeout while retrieving stream URL: \n\n")
            stationChangeFailed(info)
            timer.destroy()
        });
        xhr.send();
    }

    function loadKeywordSearch(keywordQuery, onDone, onTimeout) {
        var xhr = new XMLHttpRequest
        var uri = Shoutcast.KeywordSearchBase
            + "?" + Shoutcast.DevKeyPart
        uri += "&" + Shoutcast.getSearchPart(keywordQuery)
        //console.log("loadKeywordSearch: " + uri)
        xhr.open("GET", uri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                timer.destroy()
                onDone(xhr.responseText)
            }
        }
        var timer = createTimer(alarmServer, 5000)
        timer.triggered.connect(function() {
            if(xhr.readyState === XMLHttpRequest.DONE)
                return
            xhr.abort()
            onTimeout()
            timer.destroy()
        });
        xhr.send();
    }

    function loadRandomStation(){
          var xhr = new XMLHttpRequest
        var uri = Shoutcast.RandomBase + "?" + Shoutcast.DevKeyPart+ "&f=xml"
        xhr.open("GET", uri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                timer.destroy()
                console.log(xhr.responseText)
            }
        }
        var timer = createTimer(alarmServer, 5000)
        timer.triggered.connect(function() {
            if(xhr.readyState === XMLHttpRequest.DONE)
                return
            xhr.abort()
            onTimeout()
            timer.destroy()
        });
        xhr.send();
    }

    function loadTop500(onDone, onTimeout) {
        var xhr = new XMLHttpRequest
        var uri = Shoutcast.Top500Base
                + "?" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.QueryFormat
        xhr.open("GET", uri)
        xhr.onreadystatechange = function() {
            if(xhr.readyState === XMLHttpRequest.DONE) {
                timer.destroy()
                onDone(xhr.responseText)
            }
        }
        var timer = createTimer(alarmServer, 5000)
        timer.triggered.connect(function() {
            if(xhr.readyState === XMLHttpRequest.DONE)
                return
            xhr.abort()
            onTimeout()
            timer.destroy()
        });
        xhr.send();
    }

    function createTimer(root, interval) {
        return Qt.createQmlObject("import QtQuick 2.0; Timer {interval: " + interval + "; repeat: false; running: true;}", root, "TimeoutTimer");
    }



    function getStationByGenreURI(genreId) {
      var uri = Shoutcast.StationSearchBase
                    + "?" + Shoutcast.getGenrePart(genreId)
                    + "&" + Shoutcast.DevKeyPart
                    + "&" + Shoutcast.QueryFormat

        return uri
    }

    // when loading prev/next failed try the following one in the same direction
   function navToPrevNext(currentItem, navDirection, model, tuneinBase) {
        var item
        if(navDirection === -1 || navDirection === 1) {
            if(navDirection > 0 // next?
               && (currentItem + navDirection) < (model.count-1))
                navDirection++
            else if(navDirection < 0 // prev?
                      && (currentItem - navDirection) > 0)
                navDirection--
            else // reached the end
                navDirection = 0

            if(navDirection !== 0) {
                item = model.get(currentItem + navDirection)
                if(item)
                    alarmServer.loadStation(item.id, Shoutcast.createInfo(item), tuneinBase)
            }
        }
        return navDirection
    }

    function findStation(id, model) {
        for(var i=0;i<model.count;i++) {
            if(model.get(i).id === id)
                return i
        }
        return -1
    }
    function showMessageDialog(title, text) {
         qmlUtils.showBanner(title, text, 2000)
    }
    function showErrorDialog(text) {
       qmlUtils.showBanner("Nightly Clock", text, 2000)
    }

    property int stationId: -1
    property string stationName: ""
    property string genreName: ""
    property string metaText: genreName
    property string streamMetaText1: stationName
    property string streamMetaText2: ""

     Timer{
         id: intervalSounder
         interval: soundingInterval
         onTriggered: {
             counted+=1
             console.log("Interval Count " + intervalCount)
             console.log("COUNTED " + counted)
             if(intervalCount == counted){
                 intervalSounder.stop();
                 stopAlarm();
                 lastStepTimer.start(); }

             else{
                 stopAlarm();
                 intervalSounder.stop();
                 intervalRestart.start();
             }

         }

}
     Timer {
         id: intervalRestart
         interval:intervalRestartTime
         onTriggered: {
           intervalRestart.stop()
           soundInterval();
       }
     }
    Timer {
         id: lastStepTimer
         interval: intervalRestartTime
         onTriggered: {
             lastStepTimer.stop()
                 soundAlarm()
                 counted = 0;
                 if(main.applicationActive === true) main.activate();
                 else{
                    pageStack.push("pages/AlarmTriggerPage.qml")}
         }

}
    Timer {
    interval:alarmSnoozeTimeout
    id: snoozeTimer
    onTriggered: {
        soundAlarm();
        snoozeTimer.stop();
    }
}


NumberAnimation{
    id: fadeIn;
    duration: 9000;
    target:audio;
    property: "volume";
    from:0;
    to:alarmVolume
}

    Audio{
        id: audio
        autoLoad: false
        source:alarmSound
        loops: MediaPlayer.Infinite
        volume: alarmVolume
        onError:{
            if( Audio.error === Audio.NetworkError){source="sounds/1.mp3"; }
            else if( Audio.error === Audio.ResourceError){source="sounds/1.mp3"}
            else if( Audio.error === Audio.FormatError){source="sounds/1.mp3"}
            else if( Audio.error === Audio.AccessDeniedError){source="sounds/1.mp3"}
            else if( Audio.error === Audio.ServiceMissing){source="sounds/1.mp3"}
            console.log("Alarm Audio Error: " +errorString + "\nAlarm Sound: "+ alarmSound);
        }

    }
HapticsEffect{
    id: vibra
    intensity: vibrationIntensity
    duration: vibrationDuration === "infinity"? HapticsEffect.Infinite : vibrationDuration

}
}
