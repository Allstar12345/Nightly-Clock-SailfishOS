import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"

Item {
    MouseArea{
        anchors.fill: parent;
        onClicked: {
            if(selected)selected=false;
            else clearSelected();
            selected=true
        }
    }
    height: parent.height;
    width:parent.width

Wallpaper{
    smooth:false;
    opacity: 0.9;
    source:Theme._homeBackgroundImage;
    anchors.centerIn: parent;
    height: parent.height;
    width:compactMode?parent.width/1.1 : parent.width/1.3;
    id: img
}
    Rectangle{
        anchors.fill: img;
        color:"Transparent";
        border.color:Qt.darker(Theme.secondaryHighlightColor);
        border.width: 0.5

    Text{
        fontSizeMode: Text.VerticalFit;
        text:qsTr("Ambience");
        font.bold: true;
        font.pointSize: Theme.fontSizeMedium;
        color:Theme.highlightColor;

    anchors{
        bottom:parent.bottom;
        bottomMargin: Theme.paddingMedium;
        horizontalCenter: parent.horizontalCenter
        }
    }
    }


}
