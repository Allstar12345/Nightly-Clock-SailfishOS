import QtQuick 2.0
import Sailfish.Silica 1.0
import "shoutcastFavorites.js" as Favs
import "ShoutcastStationHistory.js" as History
import "AlarmTimeFavourites.js" as AlarmTimeFavs


RemorsePopup {
    id: remorse
    onTriggered: {
        appsettings.dropSettings();
        AlarmTimeFavs.openDB();
        Favs.openDB();
        History.openDB();
        Favs.dropTable();
        History.dropTable();
        AlarmTimeFavs.dropTable();
        qmlUtils.deleteFile(StandardPaths.data + "/photoftheday.jpg");
        qmlUtils.deleteFile(StandardPaths.data + "/wallpaperslideshow.list");
        qmlUtils.removeDir(StandardPaths.data + "/assets");
        qmlUtils.restart();
    }

Component.onCompleted: {
    remorse.execute(qsTr("Reset Nightly Clock"))
}
}

