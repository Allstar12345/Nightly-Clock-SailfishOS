import QtQuick 2.0
import Sailfish.Silica 1.0
import "../AlarmTimeFavourites.js" as AlarmTimeFavs
import "../"

Page {
    id: favsPage
    allowedOrientations: decideOrientation();
    Component.onCompleted: {
        AlarmTimeFavs.openDB();
        updateList();
    }
    RemorsePopup {id: deleteAllFavs;
        onTriggered: {
            AlarmTimeFavs.dropTable();
            AlarmTimeFavs.openDB();
            updateAlarmTimeBox();
            updateList();
        }
    }

    function updateList()
    {
        bmView.model = 0;
        AlarmTimeFavs.readFavoriteList(bmModel);
        bmView.model = bmModel;
        console.log(bmView.count);
    }

    Label {
        anchors.fill: parent
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible:bmView.count>0?false:true
        text:  qsTr("No favourites")
        color: Theme.secondaryColor
    }

    Column {
        id: headerContainer
        width: favsPage.width
        PageHeader {title: qsTr("Favourite Alarms")}
    }

    Component {
      id: bmDelegate

      ListItem {
          property variant myData: model
          id: bmItem
          onClicked: {
              pushingFromFavsPage = true;
              pushingFromFavsTime = model.time;
              pushingFromFavsFormat = model.timeformat;
              pageStack.replace(Qt.resolvedUrl("SetAlarmTime.qml"));
          }

          menu: contextMenuComponent
          Image {
              id: image
              width: height
              height: parent.height - Theme.paddingLarge
              anchors {
                  verticalCenter: parent.verticalCenter;
                  left:parent.left;
                  leftMargin: Theme.paddingMedium
              }
              asynchronous: true
              source:"Image://theme/icon-m-alarm"
          }

          Label {
              id: title
              text: model.time
              width: parent.width-30;
              anchors{
                  left: image.right;
                  rightMargin: Theme.paddingLarge
              }
              truncationMode: TruncationMode.Fade
              color: highlighted ? Theme.highlightColor : Theme.primaryColor
              anchors.verticalCenter: parent.verticalCenter
              x: Theme.horizontalPageMargin
          }

          Component {
                     id: contextMenuComponent
                     ContextMenu {
                         MenuItem {
                           text: qsTrId("Remove")
                           onClicked: {
                               AlarmTimeFavs.deleteFavorite(model.id)
                               qmlUtils.showBanner("",qsTr("Removed"), 2000);
                               updateList();
                           }
                         }
                     }
         }
      }
    }
        SilicaListView {
            id: bmView
            anchors.fill: parent
            model: bmModel
            delegate: bmDelegate

        ListModel {id: bmModel }
            currentIndex: -1 // otherwise currentItem will steal focus
            header:  Item {
                id: header
                width: headerContainer.width
                height: headerContainer.height
                Component.onCompleted: headerContainer.parent = header
            }

            PullDownMenu{
                visible: bmView.count>0?true:false
               MenuItem{
                   text:qsTr("Delete All")
                   onClicked: {
                       deleteAllFavs.execute(qsTr("Deleting all"));
                   }
               }
           }
            VerticalScrollDecorator {}

        }
}
