import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../"

Item {
    Component {
      id: imagePickerPage
     ImagePickerPage {
         onSelectedContentPropertiesChanged: {
             selectedLocalWallpaper = selectedContentProperties.filePath;
             page.selectedIndex= listView.currentIndex;
             selected=true;
             }
     }
    }

    MouseArea{
        anchors.fill: parent;
        onClicked: {
            pageStack.push(imagePickerPage)
        }
    }
    height: parent.height;
    width:parent.width

    Image{
        opacity: 0.7;
        source:selectedLocalWallpaper === ""? Theme._homeBackgroundImage : selectedLocalWallpaper;
        anchors.centerIn: parent;
        height: parent.height;
        width:compactMode?parent.width/1.1 : parent.width/1.3;
        id: img
    }

    Rectangle{
        clip:true;
        anchors.fill: img;
        color:"Transparent";
        border.color:Qt.darker(Theme.secondaryHighlightColor);
        border.width: 0.5
        Image{
            visible: selectedLocalWallpaper === ""? true:false;
            opacity: combo._menuOpen?0:1;
            Behavior on opacity {OpacityAnimator{}}
            anchors.centerIn: parent;
            source:"image://theme/icon-l-image"
        }

        ComboBox{
            id: combo
            anchors{
                bottom:parent.bottom
            }
            Component.onCompleted: {
              combo.currentIndex= parseInt(appsettings.getSystemSetting("WallpaperAspectRatioLabel", "2"))
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
    Text{
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideMiddle
        fontSizeMode: Text.VerticalFit
        width: parent.width/1.05
        text:qsTr("Photo on device");
        id:txt;
        font.bold: true;
        font.pointSize: Theme.fontSizeMedium;
        color:lightTheme? Qt.darker(Theme.highlightColor) : Theme.highlightColor;
        anchors{
            bottom:combo.top;
            bottomMargin: Theme.paddingMedium;
            horizontalCenter: parent.horizontalCenter
        }
    }
    }
}
