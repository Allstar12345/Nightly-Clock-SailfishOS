import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"
import BingWallpaper 1.0

Item {
    Component.onCompleted: {
if(networkOnline)bing.requestWallpaper("http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1")
    }
    BingWallpaper{
        id: bing;
         onResultFinished: {
             console.log(xResult["images"][0]["url"])
            img.source= "http://www.bing.com"+ xResult["images"][0]["url"];
         }
     }
    MouseArea{
        anchors.fill: parent;
        onClicked: {
            if(selected)selected=false;
            else{
                clearSelected();
                selected=true
            }
        }
}
    height: parent.height;
    width:parent.width

Image{
    fillMode: Image.PreserveAspectCrop;
    opacity: 0.8;
    source:Theme._homeBackgroundImage;
    anchors.centerIn: parent;
    height: parent.height;
    width:compactMode? parent.width/1.1 : parent.width/1.3;
    id: img
}
    Rectangle{
        anchors.fill: img;
        color:"Transparent";
        border.color:Qt.darker(Theme.secondaryHighlightColor);
        border.width: 0.5

        BusyIndicator{
        running:img.status == Image.Ready?false:true
        id: busy
        size: compactMode?BusyIndicatorSize.Large: BusyIndicatorSize.Small
        anchors{
            centerIn:parent
        }
        }

    Text{
      wrapMode: Text.Wrap
      horizontalAlignment: Text.AlignHCenter
      elide: Text.ElideMiddle
      fontSizeMode: Text.VerticalFit
      width: parent.width/1.05
      text:qsTr("Photo of the day");
      font.bold: true;
      font.pointSize: Theme.fontSizeMedium;
      color:lightTheme? Qt.darker(Theme.highlightColor) : Theme.highlightColor;
     anchors{
         bottom:parent.bottom;
         bottomMargin: Theme.paddingMedium;
         horizontalCenter: parent.horizontalCenter
     }
    }
    }


}
