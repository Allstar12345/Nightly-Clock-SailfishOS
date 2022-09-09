import QtQuick 2.0
import Sailfish.Silica 1.0
import QtGraphicalEffects 1.0

Page{
   MouseArea{
       anchors.fill: parent;
       onClicked:{
           alarmServer.stopAlarm();
       }
   }
    PageHeader {
        id: header
        title: qsTr("Touch To Stop Interval Alarm")

    }
    Connections{
        target:alarmServer;
        onCloseIntervalPage:{
            alarmServer.stopAlarm();
        }
        onCloseIntervalPageFull:{
            pageStack.pop();
        }
    }
    Image{
        id: img
        opacity: 0.9
        anchors{
            horizontalCenter: parent.horizontalCenter;
            verticalCenter: parent.verticalCenter;
            verticalCenterOffset: 30
        }
        sourceSize.width: Screen.width/1.8
        sourceSize.height: Screen.width/1.8
        width: sourceSize.width
        height: sourceSize.height
        source:"images/interval.svg"
    }
    ColorOverlay {
        anchors.fill: img
        source: img
        color: Qt.darker(colour, 1.5)
    }
    BusyIndicator{
       anchors{
           verticalCenter: parent.verticalCenter;
           right:parent.right;
           rightMargin:50;
       }
       running:alarmServer.mediaStatus==="Buffering"? true:false
       visible:alarmServer.mediaStatus==="Buffering"? true:false
    }
}
