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
                title: qsTr("Sunrise Alarm")
            }
            Image{
                id: img
                visible: compactMode
                anchors{
                    horizontalCenter: parent.horizontalCenter;
                    top:header.bottom;
                    topMargin: 5
                }
                source: "image://theme/icon-m-day"
            }
            LinkedLabel{
                wrapMode: Text.Wrap
                shortenUrl: true
                linkColor: Theme.highlightColor
                horizontalAlignment: Text.AlignHCenter
                anchors{
                    top:compactMode? img.bottom : header.bottom;
                    topMargin: compactMode? 10 : 5;
                    horizontalCenter: parent.horizontalCenter
                }

                width: parent.width-100
                font.pixelSize: compactMode? Theme.fontSizeSmall: Theme.fontSizeMedium
                plainText:qsTr("Sunrise Alarm is a feature inspired by the Google Pixel phone dock which has been recreated for Nightly Clock: http://yt.vu/wpQUEAXnbtA \n\n15 minutes before the alarm is due to sound Nightly Clock will begin to change the background colour and project bright morning colours from the screen.\n\nSunrise Alarm is not a persistent setting and needs to be turned on before you go to sleep from Alarm Settings or via the Quick Settings toggle on the clock screen.")
            }

            Button{
                anchors{
                    horizontalCenter: parent.horizontalCenter;
                    bottom:parent.bottom;
                    bottomMargin: 5
                }
                text:qsTr("Get Started")
                onClicked:{
                    pageStack.pop();
                    sunriseMode = true;
                }
            }
}
