/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../"
import "../shoutcast.js" as Shoutcast
import "../shoutcastFavorites.js" as ShoutcastFavorites

Page {

    id: stationsPage
    objectName: "StationsPage"
    property string genreName: ""
    property string genreId: ""
    property int currentItem: -1
    property bool canGoNext: currentItem < (stationsModel.count-1)
    property bool canGoPrevious: currentItem > 0
    property int navDirection: 0 // 0: none, -x: prev, +x: next
    property bool showBusy: false
    property var tuneinBase: ({})

    allowedOrientations: Orientation.All

    JSONListModel {
        id: stationsModel
        source: alarmServer.getStationByGenreURI(genreId)
        query: "$..station"
        keepQuery: "$..tunein"
        orderField: "lc"
    }

    onGenreIdChanged: {
        showBusy = true
        stationsModel.model.clear()}


    Component.onCompleted: {
        stationsModel.model.append(Shoutcast.EmptyStationRecord)
        stationsModel.model.clear(); ShoutcastFavorites.openDB();
    }

    function loadingDone() {
        if(stationsModel.model.count === 0) {
            alarmServer.showErrorDialog(qsTr("SHOUTcast server returned no Stations"))
            console.log("SHOUTcast server returned no Stations")
        }
        else currentItem = alarmServer.findStation(alarmServer.stationId, stationsModel.model)
    }

    Connections {
        target: stationsModel
        onLoaded: {
            showBusy = false
            currentItem = -1
            tuneinBase = {}

                var b = stationsModel.keepObject[0]["base"]
                if(b)
                    tuneinBase["base"] = b
                b = stationsModel.keepObject[0]["base-m3u"]
                if(b)
                    tuneinBase["base-m3u"] = b
                b = stationsModel.keepObject[0]["base-xspf"]
                if(b)
                    tuneinBase["base-xspf"] = b
                loadingDone()
            /*}*/
        }
        onTimeout: {
            alarmServer.showErrorDialog(qsTr("SHOUTcast server did not respond"))
            console.log("SHOUTcast server did not respond")
        }
    }

    function reload() {
        showBusy = true
        stationsModel.refresh()
    }


    Connections {
        target: alarmServer
        onStationChanged: {
            navDirection = 0
            currentItem = alarmServer.findStation(stationInfo.id, stationsModel.model)
        }
        onStationChangeFailed: {
            if(navDirection !== 0)
                navDirection = alarmServer.navToPrevNext(currentItem, navDirection, stationsModel.model, tuneinBase)
        }
    }

    SilicaListView {
        id: genreView
        model: stationsModel.model
        anchors.fill: parent


        PullDownMenu {
            MenuItem {
                text: qsTr("Reload");
                onClicked: reload();
            }
        }

        header: Column {
            id: lvColumn

            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge *1.5

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
            height: menuOpen?stationListItemView.height+cont.height: stationListItemView.height
            x: Theme.paddingMedium
            menu:cont
            contentHeight: childrenRect.height
            StationListItemView {id: stationListItemView }
            onClicked: alarmServer.loadStation(model.id, Shoutcast.createInfo(model), tuneinBase)

                       ContextMenu {
                           id: cont
                           MenuItem {
                               property string urlForFav;
                               property int retryAttempts

                               function getURL(stationId, info, tuneinBase){
                                   var m3uBase = tuneinBase["base-m3u"]

                                   if(!m3uBase) {
                                      console.log("Don't know how to retrieve playlist.: \n\m" + JSON.stringify(tuneinBase))
                                   }

                                   var xhr = new XMLHttpRequest
                                   var playlistUri = Shoutcast.TuneInBase
                                           + m3uBase
                                           + "?" + Shoutcast.getStationPart(stationId)
                                   xhr.open("GET", playlistUri)
                                   xhr.onreadystatechange = function() {
                                       if(xhr.readyState === XMLHttpRequest.DONE) {
                                           timer.destroy()
                                           var playlist = xhr.responseText;
                                           console.log("Playlist for stream: \n\n" + playlist)
                                           var streamURL
                                           streamURL = Shoutcast.extractURLFromM3U(playlist)
                                           console.log("URL: \n\n" + streamURL)
                                           if(streamURL.length > 0) {

                                               urlForFav = streamURL;
                                               var itemnew = ShoutcastFavorites.defaultItem();
                                               itemnew.title = name;
                                               itemnew.url =  urlForFav;ShoutcastFavorites.createFavorite(itemnew);
                                                qmlUtils.showBanner(qsTr("Added to favourites:"), name, 2000);
                                                retryAttempts=0;
                                           }

                                           else {
                                               // Retry load here in case server is returning 404, seems to happen randomly
                                              if(retryAttempts<2){
                                                  var rettimer = createTimer(window, 1500);
                                                  rettimer.triggered.connect(function() {
                                                      getURL(model.id, Shoutcast.createInfo(model), tuneinBase);
                                                      retryAttempts++; rettimer.destroy();
                                                  });
                                              }
                                              else{
                                                  retryAttempts=0;
                                                  qmlUtils.showBanner("Nightly Clock", qsTr("Failed to retrieve stream URL."), 4000);
                                                  console.log("Error could not find stream URL: \n\n" + playlistUri + "\n\n" + playlist + "\n\n")
                                              }
                                           }
                                       }
                                   }
                                   var timer = createTimer(alarmServer, 1000)
                                   timer.triggered.connect(function() {
                                       if(xhr.readyState === XMLHttpRequest.DONE)
                                           return
                                       xhr.abort()
                                       qmlUtils.showBanner("Nightly Clock", qsTr("Server did not respond while retrieving stream URL."), 4000)
                                       console.log("Error timeout while retrieving stream URL: \n\n")
                                       timer.destroy()
                                   });
                                   xhr.send();
                               }
                               function createTimer(root, interval) {
                                   return Qt.createQmlObject("import QtQuick 2.0; Timer {interval: " + interval + "; repeat: false; running: true;}", root, "TimeoutTimer");
                               }
                             text: qsTrId("Add to favourites")

                             onClicked: {
                                getURL(model.id, Shoutcast.createInfo(model), tuneinBase);

                             }
                           }
                       }

        }

        VerticalScrollDecorator {}

        Label {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeLarge
            visible: parent.count == 0
            text: qsTr("No stations found")
            color: Theme.secondaryColor
        }
    }

}
