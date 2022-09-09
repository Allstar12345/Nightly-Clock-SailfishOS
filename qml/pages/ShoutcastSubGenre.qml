/*
  Copyright (C) 207 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../"
import "../shoutcast.js" as Shoutcast

Page {
    id: subGenrePage
    objectName: "SubGenrePage"
    property string genreName: ""
    property string genreId: ""
    property bool showBusy: false
    allowedOrientations: decideOrientation();

    JSONListModel {
        id: genresModel
        source: Shoutcast.SecondaryGenreBase
                + "?" + Shoutcast.getParentGenrePart(genreId)
                + "&" + Shoutcast.DevKeyPart
                + "&" + Shoutcast.QueryFormat
        query: "$..genre.*"
    }

    onGenreIdChanged: {
        showBusy = true
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
            qmlUtils.showBanner("Nightly Clock", qsTr("SHOUTcast server did not respond"), 4000)
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
                title: genreName
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
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium

            Label {
                id: nameLabel
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.primaryColor
                textFormat: Text.StyledText
                truncationMode: TruncationMode.Fade
                width: parent.width
                text: name
            }

            onClicked: {
                var page = pageStack.nextPage()
                if(!page)
                    pageStack.pushAttached(Qt.resolvedUrl("ShoutcastStations.qml"),
                                           {genreId: model.id, genreName: model.name})
                else {
                   page.genreId = model.id
                   page. genreName = model.name
                }
                pageStack.navigateForward(PageStackAction.Animated)
            }
        }

    }

}

