import QtQuick 2.0
import Sailfish.Silica 1.0
import "../shoutcastFavorites.js" as ShoutcastFavorites
import "../"

Page {
    id: favsPage
    property string searchString
    property bool keepSearchFieldFocus:true
    allowedOrientations: decideOrientation();
    Component.onCompleted: {
        ShoutcastFavorites.openDB();
        updateList();
    }
    RemorsePopup {
        id: deleteAllFavs;
        onTriggered: {
            ShoutcastFavorites.dropTable();
            ShoutcastFavorites.openDB();
            updateList();
        }
    }

    function updateList()
    {
        bmView.model = 0;
        ShoutcastFavorites.readFavoriteList(bmModel);
        bmView.model = bmModel;
        console.log(bmView.count);
    }

    function updateSearch(){
        ShoutcastFavorites.search(bmModel);
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
        PageHeader {title: qsTr("Favourite Stations")}

        SearchField {
             id: searchField
             width: parent.width
             EnterKey.enabled:true
             EnterKey.iconSource: "image://theme/icon-m-search"
             EnterKey.onClicked:{
                 ShoutcastFavorites.searchcriteria = text;
                 updateSearch();
             }
             onTextChanged: {if(text === ""){
                     updateList();
                 }
             }
         //Just search when enter pressed since it keeps loosing focus everytime a key is pressed -_-
        }
    }

    Component {
      id: bmDelegate

      ListItem {
          property variant myData: model
          id: bmItem
          onClicked: {
              appsettings.saveSystemSetting("alarmSound", model.url);
              alarmSound=model.url;
              qmlUtils.showBanner("", qsTr("Alarm sound set") + ": " + model.title, 3000);
          }
          menu: contextMenuComponent

          Image {
              id: image
              width: height
              height: parent.height - Theme.paddingSmall
              anchors {
                  verticalCenter: parent.verticalCenter
              }
              asynchronous: true
              source:"Image://theme/icon-m-media-radio"
          }

          Label {
              id: title
              text: model.title
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
                           text: qsTrId("Remove Favourite")
                           onClicked: {
                              ShoutcastFavorites.deleteFavorite(model.id)
                              qmlUtils.showBanner("",qsTr("Favourite Removed"), 2000);
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
                   text:qsTr("Delete All Favourites")
                   onClicked: {
                       deleteAllFavs.execute(qsTr("Deleting all favourites"))
                   }
               }
           }
            VerticalScrollDecorator {}

        }
}
