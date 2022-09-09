import QtQuick 2.6
import Sailfish.Silica 1.0
import QtMultimedia 5.2
import Sailfish.Pickers 1.0
import DownloadManager 1.0
import "../"

Page {
    id: page
    signal killPlayers
    signal clearSwitch
    signal refreshEnabled
    allowedOrientations: decideOrientation();
    Component.onDestruction: {
        if( whiteNoiseSource === ""){
            whiteNoiseSource = "";
    appsettings.saveSystemSetting("whiteNoiseSource",  whiteNoiseSource);
    appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 3);
    selected = 3;
        }
    }

    DownloadManager{
        id: downloader;
        property bool isDownloading: false;
        onDownloadStarted: {
            isDownloading = true;
        }

        onDownloadCancelled: {
            isDownloading = false;
        }

        onDownloadError: {
            isDownloading = false;
        }

        onDownloadComplete:{
            isDownloading = false;
            refreshEnabled();
        }
    }

    property int selected: parseInt(appsettings.getSystemSetting("whiteNoiseSourcesPickerSelected", 3))
    Component {
        id: musicPickerPage
        MusicPickerPage {
            onSelectedContentPropertiesChanged: {
                whiteNoiseSource = "file://" + selectedContentProperties.filePath;
                appsettings.saveSystemSetting("whiteNoiseSource", "file://" + selectedContentProperties.filePath);
                appsettings.saveSystemSetting("whiteNoiseSourcePicker", 0);
                selected = 0;
            }
        }
    }
    MediaPlayer{
        id: media;
        volume:0.5;
        property bool isPlayingMedia;
        onPlaying: {
            isPlayingMedia = true;
        }

         onPaused:{
        isPlayingMedia = false;
        }

         onStopped: {
        isPlayingMedia = false;
    }
    }

    SilicaFlickable {
        id: flickable1
        contentHeight: content.height
        anchors.fill: parent
        anchors.bottomMargin: Theme.paddingMedium
        ScrollDecorator{flickable: flickable1}

        PullDownMenu{

      MenuItem{
          text: qsTr("In-App sounds repository")
      onClicked: {
          Qt.openUrlExternally("https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds");
      }
      }
     }


    Column{
        id: content
        width: parent.width;
        spacing: Theme.paddingLarge
        PageHeader {
            id: header;
            title: qsTr("White noise sound")
        }

    ExpandingSection{
        Rectangle{
            z:1;
            Behavior on opacity{OpacityAnimator{}}
            opacity: selected === 0 ? 0.4:0;
            anchors.fill: parent;
            color:Theme.secondaryHighlightColor;}
            title:qsTr("Sound on your device");
            content.sourceComponent:SilicaControl{
            height: 150

        Connections{
            target: page;
            onKillPlayers:{
                media.stop();
            }
        }

        Button{
            onClicked:{
                pageStack.push(musicPickerPage)
            }
            text:"Choose Song";
            anchors{
                left:parent.left;
                leftMargin: Theme.paddingLarge;
                verticalCenter: parent.verticalCenter
            }
        }

        IconButton{
            visible: whiteNoiseSource.indexOf("file://")? false : true
            icon.source: media.isPlayingMedia?"image://theme/icon-m-pause?" + (pressed? Theme.highlightColor : Theme.primaryColor) : "image://theme/icon-m-play?" + (pressed ? Theme.highlightColor : Theme.primaryColor)
            onClicked: {
                if(media.isPlayingMedia){
                    media.pause();
                }

                else{
                    page.killPlayers();
                    media.source =  whiteNoiseSource;
                    media.play()
                }
            }
            anchors{
                right:parent.right;
                rightMargin: Theme.paddingLarge;
                verticalCenter: parent.verticalCenter
            }
        }
    }
    }
   ExpandingSection{

       Rectangle{
           z:1;
           Behavior on opacity{OpacityAnimator{}}
           opacity: selected >=1 ? 0.4 : 0;
           anchors.fill: parent;
           color:Theme.secondaryHighlightColor;
       }
       title: qsTr("In-app sounds");
       content.sourceComponent:SilicaControl{
       height: column.height

       Column{
       width: parent.width
       id: column

       SoundListItem{
           text: qsTr("Wind")
           itemEnabled: playButtonEnabled
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/wind.mp3"
           value: StandardPaths.data + "/assets/wind.mp3"
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
              showBusy = true;
              qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
              downloader.download(downloadSource, value)
           }

           onClicked: {
               if(itemEnabled)if(whiteNoiseSource === ""){
                       selected = 1;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 1);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource = "";
                   }
           }
       }

       SoundListItem{
           itemEnabled: playButtonEnabled
           text: qsTr("Underwater")
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/underwater.mp3"
           value: StandardPaths.data + "/assets/underwater.mp3"
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
              showBusy = true;
              qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
              downloader.download(downloadSource, value)
           }
           onClicked: {
               if(itemEnabled)if(whiteNoiseSource === ""){
                       selected = 2;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 2);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource= "";
                   }
           }

       }

       SoundListItem{
           itemEnabled: playButtonEnabled
           text: qsTr("Rain downpour 1")
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/Rain_Downpour_1.mp3"
           value: StandardPaths.data + "/assets/Rain_Downpour_1.mp3"
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
              showBusy = true;
              qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
              downloader.download(downloadSource, value)
           }
           onClicked: {
               if(itemEnabled)
                   if(whiteNoiseSource === ""){
                       selected = 3;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 3);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource = "";
                   }
           }
       }

       SoundListItem{
           itemEnabled: playButtonEnabled
           text: qsTr("Rain downpour 2")
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/Rain_Downpour_2.mp3"
           value: StandardPaths.data + "/assets/Rain_Downpour_2.mp3"
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
              showBusy = true;
              qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
              downloader.download(downloadSource, value)
           }
           onClicked: {
               if(itemEnabled)if(whiteNoiseSource === ""){
                       selected = 4;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 4);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource= "";
                   }
           }
       }

       SoundListItem{
           itemEnabled: playButtonEnabled
           text: qsTr("Rain downpour 3")
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/Rain_Downpour_3.mp3"
           value: StandardPaths.data + "/assets/Rain_Downpour_3.mp3"
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
              showBusy = true;
              qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
              downloader.download(downloadSource, value)
           }
           onClicked: {
               if(itemEnabled)if(whiteNoiseSource === ""){
                       selected = 5;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 5);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource= "";
                   }
           }

       }

       SoundListItem{
           itemEnabled: playButtonEnabled
           text: qsTr("Rain light")
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/Rain_Light.mp3"
           value: StandardPaths.data + "/assets/Rain_Light.mp3"
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
               showBusy = true;
               qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
               downloader.download(downloadSource, value)
           }
           onClicked: {
               if(itemEnabled)if(whiteNoiseSource === ""){
                       selected = 6;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 6);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource= "";
                   }
           }
       }

       SoundListItem{
           itemEnabled: playButtonEnabled
           text: qsTr("Hum 1")
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/hum.mp3"
           value: StandardPaths.data + "/assets/hum.mp3"
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
              showBusy = true;
              qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
              downloader.download(downloadSource, value)
           }
           onClicked: {if(itemEnabled)if(whiteNoiseSource === ""){
                       selected = 7;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 7);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource= "";
                   }
           }
       }

       SoundListItem{
           itemEnabled: playButtonEnabled
           text: qsTr("Hum 2")
           downloadButtonEnabled: networkOnline ? !downloader.isDownloading : false
           playButtonEnabled: qmlUtils.checkFileExists(value)
           downloadSource: "https://allstarsoftware.co.uk/NightlyClockSailfish/assets/white_noise_sounds/hum_2.mp3"
           value: StandardPaths.data + "/assets/hum_2.mp3";
           onRefresh: {
               playButtonEnabled = qmlUtils.checkFileExists(value);
               showBusy = false;
           }
           onDownloadClicked:{
              showBusy = true;
              qmlUtils.dirCheckOrCreate(StandardPaths.data + "/assets")
              downloader.download(downloadSource, value)
           }
           onClicked: { if(itemEnabled)if(whiteNoiseSource === ""){
                       selected = 8;
                       whiteNoiseSource=value;
                       appsettings.saveSystemSetting("whiteNoiseSource", value);
                       appsettings.saveSystemSetting("whiteNoiseSourcesPickerSelected", 8);
                       qmlUtils.showBanner("", "Sound changed", 2000);
                   }
                   else{
                       whiteNoiseSource= "";
                   }
           }
       }

   }
   }
   }
}
}
}
