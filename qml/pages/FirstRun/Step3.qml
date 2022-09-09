import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../"



Page {
    id: page
    signal clearSelected
    allowedOrientations: Orientation.All
    property int selectedIndex:-1
    property string selectedLocalWallpaper
    backNavigation: false

    function setWallpaper(){

    if(listView.currentIndex === 0){
        appsettings.saveSystemSetting("wallpaperValue", "Ambience");
    }

    if(listView.currentIndex === 1){
        appsettings.saveSystemSetting("wallpaper", "Black");
        wallpaperSource = "Black";
        appsettings.saveSystemSetting("wallpaperValue", "Black");
    }

    else if(listView.currentIndex ===2 ){
        wallpaperSource = "bing";
        bingWallpaper.requestWallpaper("http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1");
        appsettings.saveSystemSetting("wallpaperValue", "Photo of the day");
    }

    else if(listView.currentIndex === 3){
        wallpaperSource = selectedLocalWallpaper;
        appsettings.saveSystemSetting("wallpaperValue", "Photo on device");
    }

    pageStack.replace(Qt.resolvedUrl("Step4.qml"))
    }

    ListModel{id: listModel}

    Timer{
        interval: 20;
        id: launchTimer;
        onTriggered: {
            listModel.append({"url":"../../wallpaperpickeritems/Ambience.qml"});
            listModel.append({"url":"../../wallpaperpickeritems/AllBlack.qml"});
            listModel.append({"url":"../../wallpaperpickeritems/BingPicOfDay.qml"});
            listModel.append({"url":"../../wallpaperpickeritems/PickFile.qml"});
        }
    }

    Component.onCompleted: {
        launchTimer.start();
    }
            PageHeader {
                id: header
                title: qsTr("Choose a wallpaper")
            }

            Label{
                id: text
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width-100
                anchors{
                    top:header.bottom;
                    topMargin: Theme.paddingMedium;
                    horizontalCenter: parent.horizontalCenter;
                }

                text: qsTr("Swipe left for different wallpaper choices\n(tap to select)")
            }

            SilicaListView{
            id: listView;
            orientation: Qt.Horizontal
            width:parent.width
            contentWidth: listView.count * Screen.width
            anchors{
                top:text.bottom;
                bottom:button.top;
                bottomMargin: Theme.paddingLarge;
                topMargin: Theme.paddingLarge
            }
            snapMode: ListView.SnapOneItem;
            boundsBehavior: Flickable.StopAtBounds;
            highlightRangeMode: ListView.StrictlyEnforceRange;
            model: listModel
            cacheBuffer: 1

            delegate: Rectangle {
                property bool selected
                Connections{
                    target: page;
                    onClearSelected:{
                        selected = false;
                    }
                }

                onSelectedChanged: {
                    if(selected) selectedIndex = listView.currentIndex;
                    else selectedIndex= -1;
                }
                color: "Transparent"
                width:  page.width
                height: listView.height


                Image{
                    Behavior on opacity{OpacityAnimator{}}
                    opacity: selected?0.95:0;
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
                 source:"../../images/clockface_picker_selected.svg"}

                Rectangle{
                    Behavior on opacity{OpacityAnimator{}}
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

            Button{
                text:qsTr("Next")
                id: button
                enabled: selectedIndex === -1? false:true
                anchors{
                    bottom:parent.bottom;
                    bottomMargin: Theme.paddingMedium;
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: setWallpaper();

            }
}
