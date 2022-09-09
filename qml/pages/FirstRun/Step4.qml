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
                title: qsTr("We're Nearly There")
            }
            Image{
                id: img
                anchors.centerIn: parent
                sourceSize.width: Screen.width/2.8
                sourceSize.height: sourceSize.width
                width: sourceSize.width
                height: sourceSize.height
                anchors.verticalCenterOffset: Screen.sizeCategory == Screen.Large? - Theme.paddingLarge : -Theme.paddingLarge
                source:"../../images/icon.svg"


            }

            Label{
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width-100
                anchors{
                    top:img.bottom;
                    topMargin: Theme.paddingLarge
                    horizontalCenter: parent.horizontalCenter;
                }

                text:qsTr("There will be a small non interactive tutorial showing the basics of using Nightly Clock")
            }

            Button{
                text:qsTr("Let's Get Started")
                anchors{
                    bottom:parent.bottom;
                    bottomMargin: Theme.paddingMedium;
                    horizontalCenter: parent.horizontalCenter
                }

                onClicked:{
                    pageStack.pop();
                    firstRun = true;
                    startInteractiveTut();
                }
            }
}
