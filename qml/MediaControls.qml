import QtQuick 2.5
import Sailfish.Silica 1.0
import Amber.Mpris 1.0

// For 4.4 +

Rectangle {
    id: root
    visible: showMediaControls? compactMode? mprisManager.currentService : largeScreen? mprisManager.currentService: false : false
    function createTimer(root, interval) {return Qt.createQmlObject("import QtQuick 2.0; Timer {interval: " + interval + "; repeat: false; running: true;}", root, "TimeoutTimer");}

    function nextTrack(){
        if (mprisManager.canGoNext) mprisManager.next()
    }

    function playPause(){
        if (mprisManager.playbackStatus == Mpris.Playing && mprisManager.canPause) {
            mprisManager.playPause();
        }
        else if (mprisManager.playbackStatus != Mpris.Playing && mprisManager.canPlay) {
            mprisManager.playPause();
        }
    }

    function previousTrack(){
        if (mprisManager.canGoPrevious) mprisManager.previous()
    }

    property string trackTitle
    property string trackArtist
    property string artWorkURI
    property string isPlayingMedia: mprisManager.currentService && mprisManager.playbackStatus == Mpris.Playing

    MprisManager {
    id: mprisManager
    onMetadataChanged: {
        updateMetaData();
    }
    onCurrentServiceChanged: {
        updateMetaData();
    }

    function updateMetaData(){
    var titleTag = Mpris.metadataToString(Mpris.Title);
    var artistTag = Mpris.metadataToString(Mpris.Artist);
    var artWork = Mpris.metadataToString(Mpris.ArtUrl);
    trackArtist= (artistTag in mprisManager.metadata) ? mprisManager.metadata[artistTag].toString() : ""
    trackTitle = (titleTag in mprisManager.metadata) ? mprisManager.metadata[titleTag].toString() : ""
    artWorkURI = (artWork in mprisManager.metadata) ? mprisManager.metadata[artWork].toString() : ""
    }
    }

    Component.onCompleted: {
        var timer = createTimer(root, parseInt(Math.random(1000)));
        timer.triggered.connect(function() {
            mprisManager.updateMetaData();
        })
    }

    onIsPlayingMediaChanged: {
        mprisManager.updateMetaData();
    }

    Connections{
        target: main;
        onForcePauseMPRIS:{
            if (mprisManager.playbackStatus == Mpris.Playing && mprisManager.canPause) {
                mprisManager.playPause();
            }
        }
    }



    color:"Transparent"
    anchors{
        left:parent.left;
        right:parent.right
    }

    height: title.height*2+ buttonRow.height
    Label{
        width: parent.width/1.2;
        visible: largeScreen? true: compactMode;
        id: title;
        maximumLineCount: 1;
        horizontalAlignment: Text.AlignHCenter;
        wrapMode: Text.NoWrap;
        fontSizeMode: Text.VerticalFit;
        elide: Text.ElideRight;
        anchors{
            top:parent.top;
            horizontalCenter: parent.horizontalCenter
        }
        color:colour;
        font.pixelSize: Theme.fontSizeMedium;
        text:trackTitle;
    }

    Row{
        id: buttonRow;
        spacing: parent.width/4
        anchors{
            bottom:parent.bottom;
            horizontalCenter: parent.horizontalCenter
        }

    IconButton{
        onClicked:{
            previousTrack();
        }
        enabled: mprisManager.canGoPrevious;
        icon.source:  "image://theme/icon-m-previous?"+ (pressed? Qt.lighter(colour): colour)
    }

    IconButton{
        onClicked:{
            playPause();
        }
        icon.source: mprisManager.currentService && mprisManager.playbackStatus == Mpris.Playing? "image://theme/icon-l-pause?"+ (pressed? Qt.lighter(colour): colour): "image://theme/icon-l-play?"+ (pressed? Qt.lighter(colour): colour)
    }

    IconButton{
        onClicked:{
            nextTrack();
        }
        enabled: mprisManager.canGoNext;
        icon.source: "image://theme/icon-m-next?"+ (pressed? Qt.lighter(colour): colour)
    }
    }
}
