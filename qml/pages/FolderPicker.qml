import QtQuick 2.6
import Sailfish.Silica 1.0
import Qt.labs.folderlistmodel 2.1


Page {
    id: page
    property string globalHeader: qsTr("Choose Folder")
    property string currentFolder
    signal folderSelected (string folder)
    FolderListModel {
           id: folderModel
           rootFolder:StandardPaths.home
           showFiles:false
           showDotAndDotDot: true
       }
    allowedOrientations: decideOrientation();
    Label{
        color:Theme.primaryColor;
        anchors.centerIn: parent;
        text: qsTr("Pull down to select folder");
        visible:folderModel.count<=2?true:false
    }

    SilicaListView {
        id: flickable1
        anchors.fill: parent
        header: PageHeader {
            id: header;
            title: globalHeader
        }
        PullDownMenu {
                        MenuItem {
                            text: qsTr("Use this folder")
                            onClicked:{
                                folderSelected(folderModel.folder);
                                pageStack.pop();
                            }
                        }

                    }
        Component {
          id: delegatee
          ListItem {
              Component.onCompleted: {}
              highlighted: title.text === ".."?true:false
              height: title.text === "."? 0:Theme.itemSizeSmall
              visible: title.text === "."? false:true
              property variant myData: model
              id: item
              onClicked: {
                  if (folderModel.isFolder(index)) {
                      if(folderModel.get(index, "fileName") === ".."){globalHeader="Choose Folder";
                      }
                      else{globalHeader = folderModel.get(index, "fileName")}
                       page.currentFolder = folderModel.get(index, "fileURL")
                      folderModel.folder = folderModel.get(index, "fileURL")
              }

              }
              Label {
                  id: title
                  text: fileName
                  width: parent.width-30;
                  anchors{
                      left: parent.left;
                      leftMargin: Theme.paddingLarge
                  }
                  truncationMode: TruncationMode.Fade
                  color: Theme.primaryColor
                  anchors.verticalCenter: parent.verticalCenter
                  x: Theme.horizontalPageMargin
              }

          }
        }

        model: folderModel
        delegate: delegatee

    }

}
