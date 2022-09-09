import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../pages"

Rectangle{
    id: customFaceTile
    Component{
    id: customFace
    CustomClockFaceManager{
    onForceSelected:{
        selected=true;
    }
    }
    }
    anchors.centerIn: parent
    width: main.width-15;
    height: listView.height-10
    color:"Transparent"
    border.color: Qt.darker(Theme.secondaryHighlightColor);
    border.width: 0.5
    Image{
        opacity: 0.3;
        source:Theme._homeBackgroundImage;
        anchors.centerIn: parent;
        height: parent.height;
        width:parent.width;
        id: img
    }

    Text{
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        fontSizeMode: Text.VerticalFit
        width: parent.width/1.05
        text:"Custom Clock Style";
        id:txt;
        font.bold: true;
        font.pointSize: Theme.fontSizeMedium;
        color:lightTheme? Qt.darker(Theme.highlightColor):Theme.highlightColor;
        anchors{
            top:parent.top;
            topMargin: Theme.paddingMedium;
            horizontalCenter: parent.horizontalCenter
        }
    }

    Image{
        source:"image://theme/icon-l-clock";
        anchors.centerIn: parent
    }

    Button{
        text:"Choose Custom Style";
        onClicked:{
            pageStack.push(customFace);
        }
        anchors{
            horizontalCenter: parent.horizontalCenter;
            bottom:parent.bottom;
            bottomMargin: Theme.paddingMedium
        }
    }
}
