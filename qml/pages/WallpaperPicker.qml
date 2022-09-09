import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../"



Page {
    QtObject { id: creator; property Component com: null;function createComponent (qmlfile){com = Qt.createComponent(qmlfile);com.createObject(page)} }
    id: page
    signal clearSelected
    property int currentSaveIndex
    allowedOrientations: decideOrientation();
    property int selectedIndex:-1
    property int savedSelectedIndex: parseInt(appsettings.getSystemSetting("wallpaperLabel", "0"))
    property string selectedLocalWallpaper
    function createNewSlideshowList(){
        next();
    }

    function next(){
        if(currentSaveIndex === slideshowManagerModel.count){
        }

        else{
            qmlUtils.generateImageList(StandardPaths.data + "/wallpaperslideshow.list", slideshowManagerModel.get(currentSaveIndex).url);
            currentSaveIndex++;
            next();
        }
    }
    onStatusChanged: {
        if(status==PageStatus.Deactivating){
    if(inslideshowmanager){}
    else{
        setWallpaper();
    }
     }
    }

    function setWallpaper(){
      if(page.selectedIndex>-1){

    if(listView.currentIndex===0){
        wallpaperSource="";
        appsettings.saveSystemSetting("wallpaper", "");
        appsettings.saveSystemSetting("imageofthedaylasturlll", "");
        qmlUtils.deleteFile(StandardPaths.data + "/photoftheday.jpg");
        appsettings.saveSystemSetting("wallpaperValue", "Ambience");
        appsettings.saveSystemSetting("wallpaperSlideshow", "");
        stopWallpaperSlideshow();
        qmlUtils.showBanner("Wallpaper changed", "", 1000);
    }

    if(listView.currentIndex===1){
        appsettings.saveSystemSetting("wallpaper", "Black");
        wallpaperSource="Black";
        appsettings.saveSystemSetting("imageofthedaylasturlll", "");
        standbyBlackWallpaper=false;
        appsettings.saveSystemSetting("standbyBlackWallpaper", "");
        qmlUtils.deleteFile(StandardPaths.data + "/photoftheday.jpg");
        appsettings.saveSystemSetting("wallpaperValue", "Black");
        appsettings.saveSystemSetting("wallpaperSlideshow", "");
        stopWallpaperSlideshow();
        qmlUtils.showBanner("Wallpaper changed", "", 1000);
    }

    else if(listView.currentIndex===2){
        wallpaperSource = "bing";
        bingWallpaper.requestWallpaper("http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1");
        appsettings.saveSystemSetting("wallpaperValue", "Photo of the day");
        appsettings.saveSystemSetting("wallpaperSlideshow", "");
        stopWallpaperSlideshow();
        qmlUtils.showBanner("Wallpaper changed", "", 1000);
        }

    else if(listView.currentIndex===3){
        wallpaperSource = selectedLocalWallpaper;
        appsettings.saveSystemSetting("wallpaperValue", "Photo on device");
    }

    else if(listView.currentIndex===4){
    wallpaperSlideshowModel.clear();
        qmlUtils.deleteFile(StandardPaths.data + "/wallpaperslideshow.list");
        stopWallpaperSlideshow();
        createNewSlideshowList();
        main.slideshowCurrentIndex=0;
        wallpaperSlideshow=true;
        appsettings.saveSystemSetting("wallpaperSlideshow", "true");
        wallpaperSource="";
        appsettings.saveSystemSetting("wallpaper", "");
        qmlUtils.deleteFile(StandardPaths.data + "/photoftheday.jpg");
        appsettings.saveSystemSetting("imageofthedaylasturlll", "");
        main.startWallpaperSlideshow();
        appsettings.saveSystemSetting("wallpaperValue", "Photo Slideshow");
    }
    updateWallpaperLabel();
      }
    }

    Timer{
        id: fr;
        interval: 300;
        onTriggered: {
            if(appsettings.getSystemSetting("wallpaperfirstRun", "")===""){
                creator.createComponent("../WallpaperPickerTutorial.qml");
            }
        }
    }
    ListModel{id: listModel}

    Timer{
        interval: 500;
        id: launchTimer;
        onTriggered: {
            listModel.append({"url":"../wallpaperpickeritems/Ambience.qml"});
            listModel.append({"url":"../wallpaperpickeritems/AllBlack.qml"});
            listModel.append({"url":"../wallpaperpickeritems/BingPicOfDay.qml"});
            listModel.append({"url":"../wallpaperpickeritems/PickFile.qml"});
            listModel.append({"url":"../wallpaperpickeritems/SlideShow.qml"});
        }
    }

    Component.onCompleted: {
        if(wallpaperSource.indexOf("file://")){
            selectedLocalWallpaper=wallpaperSource;
        }
        launchTimer.start();
        fr.start();
    }
            PageHeader {
                id: header
                title: qsTr("Choose a wallpaper")
            }
            BusyIndicator{
                running: true
                id: busy
            size: BusyIndicatorSize.Large
            anchors{centerIn:parent}
            }

            SilicaListView{
            id: listView;
            clip:true;
            orientation: Qt.Horizontal
            width:parent.width
            visible: false; opacity: 0
            contentWidth: listView.count * Screen.width

            anchors{
                top:header.bottom;
                bottom:pageIndi.top;
                bottomMargin: Theme.paddingMedium;
                topMargin: Theme.paddingLarge
            }

            snapMode: ListView.SnapOneItem;
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds;
            highlightRangeMode: ListView.StrictlyEnforceRange;
            model: listModel
            onCurrentIndexChanged:{
                appsettings.saveSystemSetting("wallpaperLabel", listView.currentIndex);
            }

            cacheBuffer:1
            Timer{
                id: fadeInDelay;
                interval: 900;
                onTriggered:{
                    busy.visible=false;
                    busy.running=false;
                    listView.visible=true;
                    listView.opacity=1;
                    pageIndi.visible=true;
                }
            }
            Timer{
                id: timer;
                interval: 600;
                onTriggered:{
                    listView.currentIndex = page.savedSelectedIndex
                }
            }

            Component.onCompleted: {
                timer.start();
                fadeInDelay.start();
            }

            delegate: Rectangle {
                property bool selected
                Connections{
                target: page;
                onClearSelected:{
                    selected=false;
                }
                }
                onSelectedChanged: {
                    if(selected) page.selectedIndex = listView.currentIndex;
                    else page.selectedIndex= -1;
                }
                color: "Transparent"
                width:  page.width
                height: listView.height

                Image{
                    Behavior on opacity{OpacityAnimator{}}
                    opacity: selected ?0.95 : 0;
                    z:1;
                    sourceSize.height: Theme.iconSizeLarge;
                    sourceSize.width: Theme.iconSizeLarge;
                    width: sourceSize.width;
                    height: sourceSize.height

                 anchors{
                     top:parent.top;
                     topMargin: Theme.paddingMedium;
                     horizontalCenter: parent.horizontalCenter
                 }
                 source:"../images/clockface_picker_selected.svg"
                }
                Rectangle{Behavior on opacity{OpacityAnimator{}}
                    opacity:selected? 0.1 : 0;
                    anchors.fill: parent;
                    color:Theme.secondaryHighlightColor;
                }
                Loader{
                 asynchronous: true
                 source: model.url
                 height: parent.height;
                 width: parent.width
                 visible: status == Loader.Ready
                 anchors.centerIn: parent
                }
            }
            }

            Item{
                id: pageIndi;
                visible: false;
                anchors{
                    bottom:parent.bottom;
                    right:parent.right;
                    left:parent.left;
                    rightMargin: Theme.paddingSmall/2;
                    leftMargin: Theme.paddingSmall/2
                }
                height:Theme.itemSizeExtraSmall/11

                Rectangle{
                    onXChanged:{
                        opacity = 0.6;
                        if(opaTimer.running)opaTimer.restart();
                        else opaTimer.start();
                    }

                    Timer{
                        id: opaTimer;
                        interval: 1500;
                        onTriggered: {
                            parent.opacity=0;
                        }
                    }
                        Behavior on opacity {OpacityAnimator{duration: 150;}}
                        Behavior on x{NumberAnimation{}}
                        color: lightTheme?Theme.darkPrimaryColor: Theme.lightPrimaryColor;
                        opacity:0;
                        x:listView.currentIndex * width;
                        width: page.width / listView.count;
                        height: Theme.itemSizeExtraSmall/12;
                        anchors{
                            verticalCenter: parent.verticalCenter
                        }
                        }
                }
}
