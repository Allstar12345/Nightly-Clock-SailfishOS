import QtQuick 2.6
import Sailfish.Silica 1.0
import QtMultimedia 5.6

ListItem {
    property alias text: label.text
    property string downloadSource
    signal downloadClicked
    signal refresh
    property alias playButtonEnabled: playButton.enabled
    property alias downloadButtonEnabled: downloadButton.enabled
    property alias showBusy: busy.running
    property bool itemEnabled
    highlighted: value ===  whiteNoiseSource

    MediaPlayer{
        id: media;
        source : "file://" + value;
        volume: 0.5;
        property bool isPlayingMedia;
        onPlaying: {
            isPlayingMedia=true;
        }
        onPaused: {
            isPlayingMedia=false;
        }
        onStopped: {
            isPlayingMedia=false;
        }
    }
    width: parent.width

    Connections{
        target: page;
        onRefreshEnabled:{
            refresh();
        }
        onKillPlayers:{
            media.stop();
        }
    }

    IconButton{
        id: downloadButton
        visible: !playButton.enabled
        opacity: showBusy ? 0 : 1
        Behavior on opacity {FadeAnimation{}}
        icon.source: "image://theme/icon-m-cloud-download?" + (pressed? Theme.highlightColor : Theme.primaryColor)
        onClicked: {
            downloadClicked()
        }
        down: true
        anchors{
            right:playButton.left;
            rightMargin: Theme.paddingLarge;
            verticalCenter: parent.verticalCenter
            }
    }

    BusyIndicator{
    anchors.centerIn:downloadButton;
    id: busy;
    size: BusyIndicatorSize.Medium;
    opacity: running? 1 : 0;
    Behavior on opacity {FadeAnimation{}}
    }

    IconButton{
        id: playButton
        icon.source: media.isPlayingMedia?"image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
        onClicked: {
            if(media.isPlayingMedia){
                media.pause();
            }
            else{
                page.killPlayers();
                switchh.value;
                media.play()
            }
        }
        anchors{
            right:parent.right;
            rightMargin: Theme.paddingLarge;
            verticalCenter: parent.verticalCenter
        }
    }

    property string value
    id: switchh
    Label {
        id: label;
        width: parent.width/2
        opacity: playButtonEnabled ? 1.0 : 0.3
        wrapMode: Text.Wrap
        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: lineCount > 1 ? (lineCount-1) * height / lineCount / 2 : 0
            left: parent.left
            leftMargin: Theme.paddingLarge
        }
    }
}
