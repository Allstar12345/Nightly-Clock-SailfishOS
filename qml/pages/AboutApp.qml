import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: about
    allowedOrientations: decideOrientation();
SilicaFlickable{
    PullDownMenu{
        MenuItem{
            text:appsettings.getSystemSetting("logToFile", "") === ""? qsTr("Debug mode (for bug reporting only)") : qsTr("Disable debug mode");
            onClicked:{
                if(appsettings.getSystemSetting("logToFile", "") === ""){
                    label.text=(qsTr("Log Output will be saved to: \n") + StandardPaths.data + "/AllstarSoftware/harbour-NightlyClockSailfish");
                    remorse.execute(qsTr("Debug mode enabled, restarting"), 10000) }
                else{
                    remorse.execute(qsTr("Debug mode disabled, restarting"), 10000)
                }
            }
        }
    }

    anchors.fill: parent
            PageHeader {
                id: header;
                title: qsTr("About Nightly Clock")
            }
            ComboBox{
                id: aboute
                anchors{
                    horizontalCenter:parent.horizontalCenter;
                    top:header.bottom;
                    topMargin: Theme.paddingSmall
                }
                label:qsTr("Contact/Social Media")
               menu:ContextMenu{
                   MenuItem{text:qsTr("Contact Email"); onClicked:{Qt.openUrlExternally("mailto:contact@allstarsoftware.co.uk?subject=Nightly Clock For Sailfish")}}
                    MenuItem{text:qsTr("Buy me a beer"); onClicked:{Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PZZP6QDKVSN9A")}}
                    MenuItem{text:qsTr("Youtube"); onClicked: {Qt.openUrlExternally("https://www.youtube.com/channel/UCPzRDBnfgvQVRslv48fmehw")}}
                    MenuItem{text:qsTr("Twitter"); onClicked:{Qt.openUrlExternally("https://twitter.com/paulwallace1234")}}
                    MenuItem{text:qsTr("Facebook"); onClicked:{Qt.openUrlExternally("http://facebook.com/AllstarSoftware")}}
                    MenuItem{text:qsTr("Jolla Pioneer Fans Group"); onClicked: {Qt.openUrlExternally("https://www.facebook.com/groups/jollapioneer/")}}
                    MenuItem{text:qsTr("Selected clockfaces from unofficial AsteroidOS repo"); onClicked:{Qt.openUrlExternally("https://github.com/AsteroidOS/unofficial-watchfaces")}}
                    MenuItem{text:qsTr("Contributions from Shoutcast Sailfish"); onClicked:{Qt.openUrlExternally("https://github.com/wdehoog/shoutcast-sailfish")}}
                    MenuItem{text:qsTr("Special thanks to Marko Suominen"); onClicked: {Qt.openUrlExternally("https://fi.linkedin.com/in/marko-suominen-15ab6b39")}}
                    MenuItem{text:qsTr("Special thanks Jörg (ziellos)"); onClicked: {Qt.openUrlExternally("https://forum.sailfishos.org/u/ziellos/")}}
                    MenuItem{text:qsTr("Some audio from Epidemic Sound"); onClicked:{Qt.openUrlExternally("https://www.epidemicsound.com/")}}

               }
       }
        Image{
            opacity: aboute._menuOpen? 0:1
            id: icon
            Behavior on opacity{NumberAnimation{}}
            anchors.centerIn: parent
            source:"../images/icon.svg"
            sourceSize.width: Screen.width/2.7
            sourceSize.height: Screen.width/2.7
            width: sourceSize.width
            height: sourceSize.height
        }
        Label{
            id: label
            opacity: aboute._menuOpen? 0:1
            Behavior on opacity{NumberAnimation{}}
            anchors{
                horizontalCenter: parent.horizontalCenter;
                top:icon.bottom;
                topMargin:Theme.paddingLarge
            }
            text:"v1.20"
        }
        RemorsePopup {
            id: remorse
            onCanceled: {}
            onTriggered: {
                if(appsettings.getSystemSetting("logToFile", "")===""){
                    appsettings.saveSystemSetting("logToFile", "true");
                }
                else{
                    appsettings.saveSystemSetting("logToFile", "");
                }

                qmlUtils.restart();
            }
      }
}
}
