import QtQuick 2.0
import Sailfish.Silica 1.0

import "shoutcast.js" as Shoutcast

Row {
    id: stationListItemViewColumn
    width: parent.width
    spacing: Theme.paddingLarge + 10
    function createTimer(root, interval) {return Qt.createQmlObject("import QtQuick 2.0; Timer {interval: " + interval + "; repeat: false; running: true;}", root, "TimeoutTimer");}

    Image {
        id: image
        width: height
        height: column.height - Theme.paddingSmall
        anchors {
            verticalCenter: parent.verticalCenter
        }
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        onStatusChanged: if (image.status == Image.Error) {
         source= "Image://theme/icon-m-media-radio"
          }
             source: logo ? logo : "Image://theme/icon-m-media-radio"
    }

    Column {
        id: column
        width: parent.width - image.width - Theme.paddingMedium

        // name
        // lc, genre, mt/br
        // ct

        Label {
            id: nameLabel
            width: parent.width
            color: currentItem === index ? Theme.highlightColor : Theme.primaryColor
            textFormat: Text.StyledText
            truncationMode: TruncationMode.Fade
            text: name
        }

        Label {
            id: metaLabel
            width: parent.width
            color: currentItem === index ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeExtraSmall-1
            truncationMode: TruncationMode.Fade
            text: getMetaString(model)
        }



    }

    function getMetaString(model) {
        var mstr = ""
        if(model.lc)
            mstr += lc;
        var gstr = genreString(model)
        if(gstr.length > 0) {
            if(mstr.length > 0)
                mstr += ", "
            mstr += gstr
        }
        if(model.mt) {
            if(mstr.length > 0)
                mstr += ", "
            mstr += Shoutcast.getAudioType(model.mt)
        }
        if(model.br) {
            if(mstr.length > 0)
                mstr += "/"
            mstr += model.br
        }
        return mstr
    }

    function genreString(model) {
        //console.log(model.id + ": l=" + model.ct.length + ", text=" + model.ct)
        var str = ""
        if(model.genre)
            str += genre
        if(model.genre2)
            str += ", " + genre2
        if(model.genre3)
            str += ", " + genre3
        if(model.genre4)
            str += ", " + genre4
        if(model.genre5)
            str += ", " + genre5
        return str
    }
}

