/**
 * Donnie. Copyright (C) 2017 Willem-Jan de Hoog
 *
 * License: MIT
 */

import "../shoutcastFavorites.js" as ShoutcastFavorites
import QtQuick 2.6
import QtQuick.XmlListModel 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "../"
import "../shoutcast.js" as Shoutcast

 // See sRadio to see how this all works better

Page {
    id: searchPage
    objectName: "SearchPage"
    property bool keepSearchFieldFocus: true
    property bool showBusy: false;
    property string searchString: ""
    property int startIndex: 0
    property int totalCount
    property var searchResults
    property var searchCapabilities: []
    property var scMap: []
    property string groupByField: ""
    property var tuneinBase: ({})
    property int currentItem: -1
    property bool canGoNext: currentItem < (searchModel.count-1)
    property bool canGoPrevious: currentItem > 0
    property int navDirection: 0 // 0: none, -x: prev, +x: next
    allowedOrientations: decideOrientation();

    onSearchStringChanged: {
        typeDelay.restart()
    }

    Timer {
        id: typeDelay
        interval: 500
        running: false
        repeat: false
        onTriggered: refresh()
    }



    function refresh() {
        if(searchString.length >= 1) {
                performKeywordSearch(searchString)
        }
    }

    property string _prevSearchString: ""
    function performNowPlayingSearch(searchString) {
        if(searchString === "")
            return
        showBusy = true
        searchModel.clear()
        if(searchString === _prevSearchString)
            nowPlayingModel.refresh()
        else {
            nowPlayingModel.source = alarmServer.getSearchNowPlayingURI(searchString)
            _prevSearchString = searchString
        }
    }

    JSONListModel {
        id: nowPlayingModel
        source: ""
        query: "$..station"
        keepQuery: "$..tunein"
    }

    Component.onCompleted: {
        ShoutcastFavorites.openDB();
        nowPlayingModel.model.append(Shoutcast.EmptyStationRecord)
        nowPlayingModel.model.clear()
    }

    Connections {
        target: nowPlayingModel
        onLoaded: {
            console.log("new results: "+nowPlayingModel.model.count)
            var i
            currentItem = -1
            for(i=0;
                i<nowPlayingModel.model.count;i++)
                searchModel.append(nowPlayingModel.model.get(i))
            tuneinBase = {}
            if(nowPlayingModel.keepObject.length > 0) {
                var b = nowPlayingModel.keepObject[0]["base"]
                if(b)
                    tuneinBase["base"] = b
                b = nowPlayingModel.keepObject[0]["base-m3u"]
                if(b)
                    tuneinBase["base-m3u"] = b
                b = nowPlayingModel.keepObject[0]["base-xspf"]
                if(b)
                    tuneinBase["base-xspf"] = b
            }
            showBusy = false
            if(searchModel.count > 0)
                currentItem = alarmServer.findStation(alarmServer.stationId, searchModel)
        }
        onTimeout: {
            showBusy = false
            qmlUtils.showBanner("Nightly Clock", qsTr("SHOUTcast server did not respond"), 4000)
            console.log("SHOUTcast server did not respond")
        }
    }

    function performKeywordSearch(searchString) {
        if(searchString.length === 0)
            return
        showBusy = true
        searchModel.clear()
        alarmServer.loadKeywordSearch(searchString, function(xml) {
            if(keywordModel.xml === xml) {
                keywordModel.reload()
                tuneinModel.reload()
            } else {
                keywordModel.xml = xml
                tuneinModel.xml = xml
            }
        }, function() {
            // timeout
            showBusy = false
            qmlUtils.showBanner("Nightly Clock", qsTr("SHOUTcast server did not respond"), 4000)
            console.log("SHOUTcast server did not respond")
        })
    }

    XmlListModel {
        id: keywordModel
        query: "/stationlist/station"
        XmlRole { name: "name"; query: "string(@name)" }
        XmlRole { name: "mt"; query: "string(@mt)" }
        XmlRole { name: "id"; query: "@id/number()" }
        XmlRole { name: "br"; query: "@br/number()" }
        XmlRole { name: "genre"; query: "string(@genre)" }
        XmlRole { name: "ct"; query: "string(@ct)" }
        XmlRole { name: "lc"; query: "@lc/number()" }
        XmlRole { name: "logo"; query: "string(@logo)" }
        XmlRole { name: "genre2"; query: "string(@genre2)" }

        onStatusChanged: {
            if (status !== XmlListModel.Ready)
                return
            var i
            currentItem = -1
            for(i=0;i<count;i++)
                searchModel.append(get(i))
            showBusy = false
            if(searchModel.count > 0)
                currentItem = alarmServer.findStation(alarmServer.stationId, searchModel)
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

    ListModel {
        id: searchModel
    }


    Connections {
        target: alarmServer
        onStationChanged: {
            navDirection = 0
            // station has changed look for the new current one
            currentItem = alarmServer.findStation(stationInfo.id, searchModel)
        }
        onStationChangeFailed: {
            if(navDirection !== 0)
                navDirection = alarmServer.navToPrevNext(currentItem, navDirection, searchModel, tuneinBase)
        }
    }

    SilicaListView {
        id: listView
        model: searchModel
        anchors.fill: parent
        anchors.topMargin: 0

        header: Column {
            id: lvColumn
            width: parent.width - 2*Theme.paddingMedium
            x: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                id: pHeader
                width: parent.width
                title: qsTr("Search")
                BusyIndicator {
                    id: busyThingy
                    parent: pHeader.extraContent
                    anchors.left: parent.left
                    running: showBusy;
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }


            SearchField {
                id: searchField
                width: parent.width
                placeholderText: qsTr("Search text")
                Binding {
                    target: searchPage
                    property: "searchString"
                    value: searchField.text.toLowerCase().trim()
                }
                EnterKey.onClicked: refresh()
            }

        }

        delegate: ListItem {
            id: delegate
            width: parent.width - 2* Theme.paddingMedium
            height: menuOpen? stationListItemView.height + cont.height : stationListItemView.height
            x: Theme.paddingMedium
            contentHeight: childrenRect.height
            menu:cont

            StationListItemView {
                id: stationListItemView
            }
            ContextMenu {
                id: cont
                MenuItem {
                    property int retryAttempts
                    function getURL(stationId, info, tuneinBase){
                        var m3uBase = tuneinBase["base-m3u"]

                        if(!m3uBase) {
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

                                    var itemnew = ShoutcastFavorites.defaultItem();
                                    itemnew.title = name;
                                    itemnew.url = streamURL;
                                    ShoutcastFavorites.createFavorite(itemnew);
                                    qmlUtils.showBanner("Added to favourites:", name, 2000);
                                    retryAttempts=0

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

        Label {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: parent.count == 0
            text: searchString.length==0?qsTr(""): qsTr("No stations found")
            color: Theme.secondaryColor
        }

    }
}
