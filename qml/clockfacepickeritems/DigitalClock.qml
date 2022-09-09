import QtQuick 2.0
import Sailfish.Silica 1.0
import "../"


Item {
    height: parent.height;
    width:parent.width


    Text {
        MouseArea{
            anchors.fill: parent;
            onClicked: {
                listView.currentIndex = index;
                if(selected)selected=false;
                else clearSelected();
                selected=true
            }
        }

        color: colour
        anchors.centerIn: parent
        anchors.verticalCenterOffset: compactMode?undefined:- Theme.paddingLarge
        font.pointSize:tutorialMode? Theme.fontSizeHuge*2.2: largeScreen?Theme.fontSizeHuge: Theme.fontSizeHuge*2.2
        text: Qt.formatDateTime (new Date(), "hh:mm");

    }

}
