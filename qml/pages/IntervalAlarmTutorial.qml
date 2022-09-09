import QtQuick 2.0
import Sailfish.Silica 1.0
import "../"


Page {
    id: page
    property string titleString
    backNavigation: false
    allowedOrientations: decideOrientation();


            PageHeader {
                id: header
                title: qsTr("Interval Alarm")
            }
            Image{
                id: img
                visible: compactMode
                anchors{
                    horizontalCenter: parent.horizontalCenter;
                    top:header.bottom;
                    topMargin: 5
                }
                source: "image://theme/icon-l-clock"
            }
            Label{
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                anchors{
                    top:compactMode? img.bottom : header.bottom;
                    topMargin: compactMode?10:5;
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width-100
                font.pixelSize:compactMode? Theme.fontSizeSmall: Theme.fontSizeMedium
                text:qsTr("Interval Alarm is a feature exlusive to Nightly Clock, designed as an advanced snooze type function.\nThe Alarm can be programmed to sound a set amount of times with a user set delay between those soundings.\n\nFor example:\n\n Alarm set for 12:20, will sound twice for 30 seconds each before stopping with 5 minutes between those soundings. The App will then sound once more after 5 minutes which requires user input to turn off.")}

            Button{
                anchors{
                    horizontalCenter: parent.horizontalCenter;
                    bottom:parent.bottom;
                    bottomMargin: 5
                }
                text:qsTr("Get Started")
                onClicked:{
                    pageStack.pop();
                    intervalAlarm=true;
                }
            }

}
