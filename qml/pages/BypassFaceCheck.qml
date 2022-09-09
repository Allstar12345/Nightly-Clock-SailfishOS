import QtQuick 2.6
import Sailfish.Silica 1.0

 Dialog {
     Column {
         width: parent.width
         DialogHeader {
             title: qsTr("Bypass Check");
             id: header;
             defaultAcceptText: qsTr("Confirm")
         }

         Label{
             x:Theme.horizontalPageMargin;
             width: parent.width/1.1;
             truncationMode: TruncationMode.Elide;
             wrapMode: Text.Wrap;
             text: qsTr("This will disable the security check for custom clock faces, do NOT use this unless you trust the face creator or are using self created clock faces!")
         }
     }
     onDone: {if (result == DialogResult.Accepted) {
             appsettings.saveSystemSetting("bcs", "true")
         }
     }
 }
