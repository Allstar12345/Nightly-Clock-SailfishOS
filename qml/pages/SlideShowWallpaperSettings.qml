import QtQuick 2.6
import Sailfish.Silica 1.0

Page {
Column {
    id: content
    width: parent.width
    spacing: 5

    PageHeader {
        id: header
        title: qsTr("Slideshow Settings")
    }

    ComboBox{
        id: combo
        Component.onCompleted: {
          combo.currentIndex = parseInt(appsettings.getSystemSetting("WallpaperAspectRatioLabel", "2"))
        }

        onCurrentIndexChanged:{
            appsettings.saveSystemSetting("WallpaperAspectRatioLabel", currentIndex);
            updateWallpaperRatio();
        }

        label:qsTr("Wallpaper Aspect Ratio")
        menu:ContextMenu{
           MenuItem{
               text:qsTr("Stretch");
               onClicked: {
                   appsettings.saveSystemSetting("WallpaperAspectRatio", "Stretch")
               }
           }

           MenuItem{
               text:qsTr("Preserve Aspect Fit");
               onClicked: {
                   appsettings.saveSystemSetting("WallpaperAspectRatio", "Preserve Aspect Fit")
               }
           }

           MenuItem{
               text:qsTr("Preserve Aspect Crop  (default)");
               onClicked: {
                   appsettings.saveSystemSetting("WallpaperAspectRatio", "")
               }
           }
        }
    }

    Slider{
      label: qsTr("Slideshow interval")
      value:slideShowInterval
      maximumValue: 18000000
      valueText:timeConversion(value)
          function timeConversion(value) {
              var millisec=value;
          var seconds = (millisec / 1000).toFixed(1);

          var minutes = (millisec / (1000 * 60)).toFixed(1);

          var hours = (millisec / (1000 * 60 * 60)).toFixed(1);

         var days = (millisec / (1000 * 60 * 60 * 24)).toFixed(1);

         if (seconds < 60) {
             return seconds + " " +  qsTr("Sec");
         }
          else if (minutes < 60) {
              return minutes + " " + qsTr("Minutes");
          } else if (hours < 24) {
              return hours + " " +  qsTr("Hours");
          }

      }
        minimumValue: 300000
        anchors{
            left:parent.left;
            right:parent.right
        }
        onValueChanged: {
            slideShowInterval = value;
            valueText = timeConversion(value);
        }
    }

}

}

