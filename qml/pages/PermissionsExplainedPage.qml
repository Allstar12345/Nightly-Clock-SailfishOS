/**
Copyright (C) 2021 Allstar Software (Paul Wallace)
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
Page {
    allowedOrientations: decideOrientation();
    id: permexplain
    Component.onCompleted: {var timer = createTimer(permexplain, (200));timer.triggered.connect(function() {flickable.opacity=1;})}
    QtObject {id: create; property Component com: null; function createComponent (qmlfile){com = Qt.createComponent(qmlfile);com.createObject(stationInfo)} }

    SilicaFlickable{
    opacity: 0;
    id:flickable;
    anchors.fill: parent;
    contentHeight: column.height;
    Behavior on opacity{FadeAnimation{}}

    Column{
        width:parent.width;
        id: column;
        bottomPadding: Theme.paddingSmall

        PageHeader {
            id: header;
            title: qsTr("Nightly Clock permissions")
        }

        DetailItem {
        label:qsTr("Internet");
        value:qsTr("This permission allows access to the internet through WLAN or mobile data for things like weather and internet radio");
        }

        DetailItem {
        label: qsTr("Play and record audio");
        value:qsTr("This allows audio to be played for the alarm sound, the record permission is not used but is bundled together by Jolla");
        }

        DetailItem {
        label:qsTr("User directories");
        value:qsTr("This permission allows access the Documents, Downloads, Music, Pictures, Public and Video folders for things like custom wallpapers, alarm sounds and clock faces");
        }

        DetailItem {
        label:qsTr("Location");
        value:qsTr("This permission allows the weather feature to find your location");
        }

        DetailItem {
        label:qsTr("User services");
        value:qsTr("This permission allows the weather press and hold feature to launch your chosen Application ");
        }
   }
}
}

