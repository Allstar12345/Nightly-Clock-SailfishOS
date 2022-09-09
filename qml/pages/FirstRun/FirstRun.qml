import QtQuick 2.0
import Sailfish.Silica 1.0
import "../"


Page {
    id: page
    allowedOrientations: Orientation.All
    backNavigation: false

    function manualCompactMode(){
        if(orientation===0) compactMode = true;
        else if(orientation===1) compactMode = true;
        else if(orientation===2) compactMode = false;
        else if(orientation===4) compactMode = true;
        else if(orientation===8) compactMode = false;
        else{
            compactMode = true;
        }
    }

    Component.onCompleted: {
        manualCompactMode();
    }

            PageHeader {
                id: header
                title: qsTr("Welcome to Nightly Clock")
                property int tapped;
                MouseArea{
                    anchors.fill: parent;
                    z:5;
                    onClicked:if(parent.tapped === 3){
                                  appsettings.saveSystemSetting("firstRun", "true");
                                  pageStack.pop();
                              }
                              else{
                                  parent.tapped++
                              }
                }
            }

            Image{
                anchors.centerIn: parent
                source: "../../images/icon.svg"
                sourceSize.width: Screen.width/2.8
                sourceSize.height:Screen.width/2.8
                width: sourceSize.width
                height: sourceSize.height

            }

            Button{
                text:qsTr("Next")
                anchors{
                    bottom:parent.bottom;
                    bottomMargin: Theme.paddingMedium;
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: pageStack.replace(Qt.resolvedUrl("Step2.qml"))
            }
}
