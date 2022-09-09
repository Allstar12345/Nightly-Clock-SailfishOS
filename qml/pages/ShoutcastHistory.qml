import QtQuick 2.0
import "../ShoutcastStationHistory.js" as ShoutcastHistory
import "../shoutcastFavorites.js" as ShoutcastFavorites
import Sailfish.Silica 1.0
import "../"
Page {
    id: histPage
    property string searchString
    property bool keepSearchFieldFocus:true
    allowedOrientations: decideOrientation();

    Component.onCompleted: {
        ShoutcastHistory.openDB();
        updateList();
        ShoutcastFavorites.openDB();
    }

    RemorsePopup {
        id: deleteAllFavs;
        onTriggered: {
            ShoutcastHistory.dropTable();
            ShoutcastHistory.openDB();
            updateList();
        }
    }

    function updateList()
    {
        bmView.model = 0;
        ShoutcastHistory.readHistoryList(bmModel);
        bmView.model = bmModel;
        console.log(bmView.count);
    }

    function updateSearch(){
   ShoutcastHistory.search(bmModel);
    }

    Label {
        anchors.fill: parent
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible:bmView.count>0?false:true
        text:  qsTr("No history")
        color: Theme.secondaryColor
    }

    Column {
        id: headerContainer

        width: histPage.width

        PageHeader {
            title: qsTr("Station History")
        }

        SearchField {
              id: searchField
              width: parent.width
              EnterKey.enabled:true
              EnterKey.iconSource: "image://theme/icon-m-search"
              EnterKey.onClicked:{
                  ShoutcastHistory.searchcriteria=text;
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
         // menu: contextMenuComponent
          property variant myData: model
          id: bmItem
          menu: contextMenuComponent
          onClicked: {
              appsettings.saveSystemSetting("alarmSound", model.url);
              alarmSound=model.url;
              qmlUtils.showBanner(qsTr("Alarm sound set:"), model.title, 2000);
          }

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
                           text: qsTr("Add to favourites")
                           onClicked: {
                               var itemnew = ShoutcastFavorites.defaultItem();
                               itemnew.title = model.title;
                               itemnew.url =  model.url;
                               ShoutcastFavorites.createFavorite(itemnew);
                               qmlUtils.showBanner(qsTr("Added to favourites:"), model.title, 2000);
                           }
                         }
                         MenuItem{
                             text:qsTr("Remove station from history")
                             onClicked: {
                                ShoutcastHistory.deletehistory(model.id);
                                qmlUtils.showBanner("", qsTr("Station removed from history"), 2000);
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

        ListModel {id: bmModel}
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
                   text:qsTr("Clear History")
                   onClicked: {
                       deleteAllFavs.execute(qsTr("Clearing histoy"))
                   }
               }
           }

            VerticalScrollDecorator {}
        }
}
