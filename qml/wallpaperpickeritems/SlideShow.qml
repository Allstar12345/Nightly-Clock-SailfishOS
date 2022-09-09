import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../"

Item {
    Connections{
        target: main;
        onForceSelectedChange:{
            if(selected) selected = false;
            else selected=true;page.selectedIndex = listView.currentIndex;
        }
    }
    Component.onCompleted: {
        qmlUtils.importPictureList(StandardPaths.data + "/wallpaperslideshow.list");
    }
    MouseArea{
        anchors.fill: parent;
     onClicked: {
         if(slideshowManagerModel.count===0){
             qmlUtils.showBanner("Pick some photos first", "", 1500)
         }
        else{

           if(selected){
               selected=false;
               page.selectedIndex= -1;
           }

             else {
               selected = true;
               page.selectedIndex = listView.currentIndex;
           }
         }
    }
    }
    height: parent.height;
    width:parent.width
    SilicaGridView {
        id: listVieww

        interactive: false
        cellHeight: cellWidth;
        cellWidth: listVieww.width/3
        anchors.fill: img
        model: slideshowManagerModel
        currentIndex: -1

        delegate:
        Rectangle {
           color: "Transparent"
           id: delg
           width:  listVieww.cellWidth
           height: listVieww.cellHeight
        Image{
        asynchronous: true
     source: model.url
     fillMode: Image.PreserveAspectCrop
     sourceSize.width: listVieww.cellWidth
     sourceSize.height: listVieww.cellHeight
     height:sourceSize.height;
     width: sourceSize.width
     opacity: status == Image.Ready?1:0
     Behavior on opacity{OpacityAnimator{}}
     anchors.centerIn: parent
        }
    }
    }
    Image{
        opacity: slideshowManagerModel.count> 0 ? 0.3 : 0.6;
        source:selectedLocalWallpaper === "" ? Theme._homeBackgroundImage : selectedLocalWallpaper;
        anchors.centerIn: parent;
        height: parent.height;
        width:compactMode ?parent.width/1.1 : parent.width/1.3;
        id: img
    }
    Rectangle{
        clip:true;
        anchors.fill: img;
        color:"Transparent";
        border.color:Qt.darker(Theme.secondaryHighlightColor);
        border.width: 0.5

        Image{visible: selectedLocalWallpaper === ""? true : false;
        Behavior on opacity {OpacityAnimator{}}
        anchors.centerIn: parent;
        source:"image://theme/icon-l-image"
        }

        Button{
            onClicked:{
                inslideshowmanager = true;
                pageStack.push(Qt.resolvedUrl("../pages/WallpaperSlideshowManager.qml"));
            }
            id: chooseBut;
            text:"Choose Photos";
            anchors{
                horizontalCenter: parent.horizontalCenter;
                bottom: parent.bottom;
                bottomMargin: Theme.paddingMedium
            }
        }

    Text{
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        fontSizeMode: Text.VerticalFit
        width: parent.width/1.05
        text:"Slideshow";
        id:txt;
        font.bold: true;
        font.pointSize: Theme.fontSizeMedium;
        color:lightTheme? Qt.darker(Theme.highlightColor) : Theme.highlightColor;
        anchors{
            bottom:chooseBut.top;
            bottomMargin: Theme.paddingMedium;
            horizontalCenter: parent.horizontalCenter
        }
    }
    }
}
