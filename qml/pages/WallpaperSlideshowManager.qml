import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Page{
    canNavigateForward: true
    allowedOrientations: decideOrientation();
    onStatusChanged: {
        if(status == PageStatus.Inactive){
            if(slideshowManagerModel.count>0){
                main.forceSelectedChange();
            }
            inslideshowmanager = false;
        }
    }
    Component.onCompleted: {
        inslideshowmanager=true;
    }
    property string selectedFiles
    id: wallpaperSlideshowmgr
    property string listURL:StandardPaths.data + "/wallpaperslideshow.list"

    Column {
        id: headerContainer
        width: wallpaperSlideshowmgr.width
        PageHeader {
            title: qsTr("Wallpaper Slideshow")
        }
    }
    Component {
      id: imagePickerPage
     MultiImagePickerDialog {

     onAccepted:{
         selectedFiles = ""
         for (var i = 0; i < selectedContent.count; ++i) {
             var url = selectedContent.get(i).url
             slideshowManagerModel.append({"url":url});
         }
     }
     }
    }

    Label {
        anchors.fill: parent
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible:slideshowManagerModel.count>0?false:true
        text:  qsTr("No photos")
        color: Theme.secondaryColor
    }

    SilicaGridView {
        id: listView
        cellHeight: cellWidth;
        cellWidth: listView.width/3
        anchors.fill: parent
        model: slideshowManagerModel
        delegate:
        Rectangle {
           color: "Transparent"
           id: delg
           width:  listView.cellWidth
           height: listView.cellHeight

           BusyIndicator{
           size: BusyIndicatorSize.Medium
           anchors.centerIn: parent;
           running: imge.status == Image.Loading? true : false
           }

        Image{
     id: imge
     asynchronous: true
     source: model.url
     fillMode: Image.PreserveAspectCrop
     sourceSize.width: listView.cellWidth
     sourceSize.height: listView.cellHeight
     height:sourceSize.height;
     width: sourceSize.width
     opacity: status == Image.Ready?1:0
     Behavior on opacity{OpacityAnimator{}}
    anchors.centerIn: parent
    MouseArea{
        anchors.fill: parent;
        property string ab
       z:1;
       propagateComposedEvents: true
       onPressAndHold: { }
    }
        }

    }

        currentIndex: -1 // otherwise currentItem will steal focus
        header:  Item {
            id: header
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = header
        }

        PullDownMenu{
            MenuItem{
                text: qsTr("Settings");
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("SlideShowWallpaperSettings.qml"));
                }
            }

            MenuItem{
            enabled: slideshowManagerModel.count === 0? false : true;
            text: qsTr("Clear Photos")
            onClicked:{
                slideshowManagerModel.clear();
                qmlUtils.deleteFile(listURL);
            }
            }
           MenuItem{
               text:qsTr("Add Photos")
               onClicked: {
                   pageStack.push(imagePickerPage)
               }
           }
       }
        VerticalScrollDecorator {}

    }

}
