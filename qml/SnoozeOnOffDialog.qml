import QtQuick 2.0
import Sailfish.Silica 1.0

RemorsePopup {
    id: remorse
    onTriggered: {
        alarmServer.stopSnooze();
    }

Component.onCompleted: {
    remorse.execute(qsTr("Snooze switched off"))
}
}

