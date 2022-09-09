import QtQuick 2.6
import Sailfish.Silica 1.0
import QMLUtils 1.0

ApplicationWindow {
QMLUtils{id:utils;}
Label{
anchors{
    top:parent.top;
    horizontalCenter:parent.horizontalCenter;
    topMargin: Theme.paddingLarge
   }

width: parent.width/1.1;
wrapMode: Text.Wrap;
color:Theme.highlightColor;
verticalAlignment: Text.AlignVCenter;
horizontalAlignment: Text.AlignHCenter;
font.pixelSize: Theme.fontSizeExtraLarge;
text: qsTr("Sorry your version of Sailfish ") + "("+ utils.getOSVersion() + ")" +qsTr("is no longer supported by Nightly Clock.\n\nPlease update your device if possible or download a supported version of Nightly Clock");
}

Button{
    anchors{
        bottom:parent.bottom;
        bottomMargin: Theme.paddingLarge;
        horizontalCenter: parent.horizontalCenter
    }
text:qsTr("Download ") + "v1.15 " + utils.returnArchitecture();
onClicked: {
    Qt.openUrlExternally("https://allstarsoftware.co.uk/NightlyClockSailfish/Updates/");
}
}
}
