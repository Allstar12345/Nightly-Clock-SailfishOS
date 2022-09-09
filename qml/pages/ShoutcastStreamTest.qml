import QtQuick 2.2
import Sailfish.Silica 1.0
import QtMultimedia 5.2
import "../"
import "../ShoutcastStationHistory.js" as ShoutcastHistory
Page {
id:page
property double bufferThres:0.12

Timer{
    id: closer;
    interval: 1000;
    onTriggered:{
        pageStack.pop();
    }
}

    allowedOrientations: decideOrientation();
    function saveHistory(){
        var itemnew = ShoutcastHistory.defaultItem();
        itemnew.title = alarmServer.stationName;
        itemnew.url = alarmServer.shoutcastSource;
       ShoutcastHistory.createhistory(itemnew);
    }
Audio{
    id: media;
    volume:0.5
    property bool restart: true
}
Column {
    id: content
    width: parent.width
    spacing: 5

    PageHeader {
        id: header
        title: alarmServer.stationName
    }

TextField{
    id: texter
    text: alarmServer.shoutcastSource
    width:parent.width
    enabled: false
}

ButtonLayout{
Button{
    text:qsTr("Test");
    onClicked: {
        media.source = texter.text;
        media.play();
    }
}

Button{
    text:qsTr("Save");
    onClicked: {
        appsettings.saveSystemSetting("alarmSound", alarmServer.shoutcastSource);
        alarmSound = alarmServer.shoutcastSource;
        media.stop();
        ShoutcastHistory.openDB();
        saveHistory();
        qmlUtils.showBanner("Alarm sound set:",alarmServer.stationName, 2000);
        appsettings.saveSystemSetting("usingShoutForAlarm", true);
        appsettings.saveSystemSetting("alarmSoundsPickerSelected", 1);
        closer.start();
        console.log("Setting Set : " +appsettings.getSystemSetting("alarmSound", ""))
    }
}
}

}
Image{
    id: logoIMG
    source:"../images/Logo_shoutcast.png"
    anchors{
        bottom:parent.bottom;
        left:parent.left;
        leftMargin: Theme.paddingSmall;
        bottomMargin: Theme.paddingSmall
    }
}

Label{
    anchors{
        verticalCenter: logoIMG.verticalCenter;
        left:logoIMG.right;
        leftMargin: Theme.paddingMedium
    }
    text:qsTr("Powered by SHOUTcast");
}
}

