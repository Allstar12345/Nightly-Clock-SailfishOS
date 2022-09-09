/*
  Copyright (C) 2017 Willem-Jan de Hoog
*/
import "../shoutcastFavorites.js" as ShoutcastFavorites
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import "../"
import "../shoutcast.js" as Shoutcast


Page {

    id: top500Page
    objectName: "TopStationsPage"
    property int currentItem: -1
    property bool showBusy: false
    property var tuneinBase: ({})
    property bool canGoNext: currentItem < (top500Model.count-1)
    property bool canGoPrevious: currentItem > 0
    property int navDirection: 0 // 0: none, -x: prev, +x: next
    allowedOrientations: Orientation.All
    ListModel {  id: stationsModel}

    Component.onCompleted: {
        ShoutcastFavorites.openDB();
        stationsModel.model.append(Shoutcast.EmptyStationRecord);
        stationsModel.model.clear();
    }

    XmlListModel {
        id: top500Model
        query: "/stationlist/station"
        XmlRole { name: "name"; query: "string(@name)" }
        XmlRole { name: "mt"; query: "string(@mt)" }
        XmlRole { name: "id"; query: "@id/number()" }
        XmlRole { name: "br"; query: "@br/number()" }
        XmlRole { name: "genre"; query: "string(@genre)" }
        XmlRole { name: "ct"; query: "string(@ct)" }
        XmlRole { name: "lc"; query: "@lc/number()" }
        XmlRole { name: "logo"; query: "string(@logo)" }
        onStatusChanged: {
            if(status === XmlListModel.Ready) {
                showBusy = false
                if(top500Model.count === 0)
                    qmlUtils.showBanner(qsTr("Nightly Clock", "SHOUTcast server returned no Stations", 4000))
                else
                    currentItem = alarmServer.findStation(alarmServer.stationId, top500Model)
            }
        }
    }

    XmlListModel {
        id: tuneinModel
        query: "/stationlist/tunein"
        XmlRole{ name: "base"; query: "@base/string()" }
        XmlRole{ name: "base-m3u"; query: "@base-m3u/string()" }
        XmlRole{ name: "base-xspf"; query: "@base-xspf/string()" }
        onStatusChanged: {
            if (status !== XmlListModel.Ready)
                return
            tuneinBase = {}
            if(tuneinModel.count > 0) {
                var b = tuneinModel.get(0)["base"]
                if(b)
                    tuneinBase["base"] = b
                b = tuneinModel.get(0)["base-m3u"]
                if(b)
                    tuneinBase["base-m3u"] = b
                b = tuneinModel.get(0)["base-xspf"]
                if(b)
                    tuneinBase["base-xspf"] = b
            }
        }
    }

    function reload() {
        showBusy = true
        currentItem = -1
        alarmServer.loadTop500(function(xml) {
            top500Model.xml = xml
            top500Model.reload()
            tuneinModel.xml = xml
            tuneinModel.reload()
        }, function() {
            // timeout
            showBusy = false
            qmlUtils.showBanner("Nightly Clock", qsTr("SHOUTcast server did not respond"), 4000)
            console.log("SHOUTcast server did not respond")
        })
    }

    onStatusChanged: {if(status === PageStatus.Active)reload()}

    Connections {
        target: alarmServer
        onStationChanged: {
            navDirection = 0
            currentItem = alarmServer.findStation(stationInfo.id, top500Model)
        }
        onStationChangeFailed: {
            if(navDirection !== 0)
                navDirection = alarmServer.navToPrevNext(currentItem, navDirection, top500Model, tuneinBase)
        }
    }

    SilicaListView {
        id: genreView
        model: top500Model
        anchors.fill: parent
        anchors.topMargin: 0


        PullDownMenu {

            MenuItem {
                text: qsTr("Refresh")
                onClicked: reload()
            }
        }


        header: Column {
            id: lvColumn
            width: parent.width - 2*  Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge *1.5

            PageHeader {
                id: pHeader
                title: qsTr("Top 500")
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
            width: parent.width - 2* Theme.paddingMedium
            height: menuOpen ? stationListItemView.height + cont.height: stationListItemView.height
            x: Theme.paddingMedium
            contentHeight: childrenRect.height
            menu: cont

            StationListItemView {
                id: stationListItemView
            }
            ContextMenu {


                id: cont
                MenuItem {
                    property string urlForFav;property int retryAttempts
                    function getURL(stationId, info, tuneinBase){
                        var m3uBase = tuneinBase["base-m3u"]

                        if(!m3uBase) {
                           // banner.showText(qsTr("Don't know how to retrieve playlist."))
                          //  console.log("Don't know how to retrieve playlist.: \n\m" + JSON.stringify(tuneinBase))
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
                                    itemnew.url =  urlForFav;
                                    ShoutcastFavorites.createFavorite(itemnew); qmlUtils.showBanner(qsTr("Added to favourites:") , name, 2000);
                                    retryAttempts=0
                                }
                                else {
                                    // Retry load here in case server is returning 404, seems to happen randomly
                                   if(retryAttempts<2){
                                       var rettimer = createTimer(window, 1500);
                                       rettimer.triggered.connect(function() {getURL(model.id, Shoutcast.createInfo(model), tuneinBase);
                                           retryAttempts++;
                                           rettimer.destroy();
                                       });
                                   }
                                   else{
                                       retryAttempts = 0;
                                       qmlUtils.showBanner("Nightly Clock", qsTr("Failed to retrieve stream URL."), 4000);
                                       console.log("Error could not find stream URL: \n\n" + playlistUri + "\n\n" + playlist + "\n\n")
                                   }
                                }
                            }
                        }
                        var timer = createTimer(alarmServer, 2000)
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

            onClicked: alarmServer.loadStation(model.id, Shoutcast.createInfo(model), tuneinBase)
        }

        VerticalScrollDecorator {}


    }

}

