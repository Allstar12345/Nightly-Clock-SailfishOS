/*
  Copyright (C) 207 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../"
import "../shoutcast.js" as Shoutcast

Page {
    id: genrePage
    objectName: "GenrePage"
    property bool showBusy: true

    allowedOrientations: decideOrientation();

    JSONListModel {
        id: genresModel
        source: Shoutcast.PrimaryGenreBase + "?" + Shoutcast.DevKeyPart + "&" + Shoutcast.QueryFormat
        query: "$..genre.*"
    }

    function reload() {
        showBusy = true
        genresModel.refresh()
    }



    Connections {
        target: genresModel
        onLoaded: {
            showBusy = false

        }
        onTimeout: {
            showBusy = false
            qmlUtils.showBanner("Nightly Clock", qsTr("SHOUTcast server did not respond"), 3000)
            console.log("SHOUTcast server did not respond")
        }
    }


    SilicaListView {
        id: genreView
        model: genresModel.model
        anchors.fill: parent
        anchors {
            topMargin: 0
            bottomMargin: 0
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: reload()
            }
        }



        header: Column {
            id: lvColumn
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                id: pHeader
                title: qsTr("Station Genres")
                BusyIndicator {
                    id: busyThingy
                    parent: pHeader.extraContent
                    anchors.left: parent.left
                    running: showBusy
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        delegate: ListItem {
            id: delegate
            width: parent.width - 2 * Theme.paddingMedium
            x: Theme.paddingMedium

            Label {
                id: nameLabel
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.primaryColor
                textFormat: Text.StyledText
                truncationMode: TruncationMode.Fade
                width: parent.width
                text: name ? name : qsTr("No Station Name")
            }

            onClicked: {
                var page
                if(model.haschildren) {
                    // has sub genres
                    page = pageStack.nextPage()
                    if(!page || page.objectName !== "SubGenrePage")
                        pageStack.pushAttached(Qt.resolvedUrl("ShoutcastSubGenre.qml"),
                                               {genreId: model.id, genreName: model.name})
                    else {
                        page.genreId = model.id
                        page.genreName = model.name
                    }
                } else {
                    // no sub genres
                    page = pageStack.nextPage()
                    if(!page || page.objectName !== "StationsPage")
                        pageStack.pushAttached(Qt.resolvedUrl("ShoutcastStations.qml"),
                                               {genreId: model.id, genreName: model.name})
                    else {
                       page.genreId = model.id
                       page.genreName = model.name
                    }
                }
                pageStack.navigateForward(PageStackAction.Animated)
            }
        }

    }


}

