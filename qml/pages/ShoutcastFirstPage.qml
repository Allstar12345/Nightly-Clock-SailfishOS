import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: about
    allowedOrientations: decideOrientation();

    SilicaFlickable{
    anchors.fill: parent

            PageHeader {
                id: header
                title: qsTr("Internet Radio")
            }

            Item {
                width: parent.width
                height: parent.height-logoIMG.height


                Column {
                    id: appTitleColumn
                    spacing: Theme.paddingLarge

                    anchors {
                       centerIn: parent
                    }

                    Button{
                        text:qsTr("Search Stations");
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("ShoutcastSearch.qml"));
                        }
                    }

                    Button{
                        text:qsTr("Top 500 Stations");
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("ShoutcastTopStations.qml"));
                        }
                    }

                    Button{
                        id: genreButton;
                        text:qsTr("Browse by Genre");
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("ShoutcastGenre.qml"));
                        }
                    }

                    Row{
                        spacing: genreButton.width-favButton.width*2
                        IconButton{
                            id: favButton;
                            icon.source: "image://theme/icon-m-favorite";
                            onClicked:{
                                pageStack.push(Qt.resolvedUrl("ShoutcastFavourites.qml"))
                            }
                        }

                        IconButton{
                            id: historyButton;
                            icon.source: "image://theme/icon-m-file-document";
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("ShoutcastHistory.qml"))
                            }
                        }
                    }


            }

}


            Image{
                id: logoIMG
                source:"../images/Logo_shoutcast.png"
                anchors{
                    bottom:parent.bottom;
                    left:parent.left;
                    leftMargin: Theme.paddingSmall;
                    bottomMargin: Theme.paddingSmall
                }
            }

            Label{
                anchors{
                    verticalCenter: logoIMG.verticalCenter;
                    left:logoIMG.right;
                    leftMargin: Theme.paddingMedium
                }
                text:qsTr("Powered by SHOUTcast");
            }


}
}
