import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.2
Page {
    allowedOrientations: decideOrientation();

MediaPlayer{
    id: media;
    volume:0.5
}

Column {
    id: content
    width: parent.width
    spacing: 5

    PageHeader {
        id: header
        title: qsTr("Internet Alarm Sound")
    }
TextField{
    id: texter
    text:appsettings.getSystemSetting("alarmSound", "")
    placeholderText: qsTr("Type your direct link here")
    width:parent.width
}

ButtonLayout{
Button{
    text:qsTr("Test");
    onClicked: {
        media.source=texter.text;
        media.play();
    }
}

Button{
    text:qsTr("Save");
    onClicked: {
        media.stop();
        appsettings.saveSystemSetting("alarmSound", texter.text);
        alarmSound = texter.text;
        qmlUtils.showBanner("Alarm Sound Set:", texter.text,3000);
        appsettings.saveSystemSetting("alarmSoundsPickerSelected", 4);
        pageStack.pop();
    }
}
}

}
}

