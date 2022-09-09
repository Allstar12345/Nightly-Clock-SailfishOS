import QtQuick 2.6
import Sailfish.Silica 1.0

 Dialog {
     Column {
         width: parent.width
         DialogHeader {
             title:qsTr("Download sounds");
             defaultAcceptText: qsTr("Explore")
         }
         Label{
             x:Theme.horizontalPageMargin;
             width: parent.width/1.1;
             truncationMode: TruncationMode.Elide;
             wrapMode: Text.Wrap;
             text: qsTr("White Noise needs the inbuilt sounds to be downloaded, this is so Nightly Clock does not have a large file size when installing.\nTap explore above to download or pick a custom sound")
         }
     }
     onDone: {
         if (result == DialogResult.Accepted) {
             pageStack.replace("pages/WhiteNoiseSoundSettings.qml");
         }
     }
 }
