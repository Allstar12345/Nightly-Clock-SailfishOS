import QtQuick 2.6
import Sailfish.Silica 1.0
import "../"
import Sailfish.Pickers 1.0


Page {
    id: page
    property string chosenClockFace: customClockFaceURL
    property int fileCount
    property int newCount
    property bool validationRejected
    property string folderr
    property string bob: customClockFaceURL
    signal forceSelected

    Component.onCompleted: {
        if(usingExternal === true){
        var a = bob.substring(7, bob.length);
        if(qmlUtils.checkFileExists(a) === false){
        chosenClockFace = "";
        qmlUtils.showBanner (qsTr("Unable to find Style"), qsTr("It may have been deleted"), 5000);
        }
        }
    }
    ListModel{id: reasonModel;}
    Component {
                    id: filePickerPage
                    FolderPicker {
                       onFolderSelected:{
                           folderr = folder;
                           busy.running = true;
                           qmlUtils.clockFaceValidationCheck(folder);
                       }
                    }
                }

Connections{
    target: qmlUtils;
    onMissingVitalFile:{
        busy.running = false;
    }

    onValidationFileCount:{
        fileCount = count;
        console.log("Files count qml " + fileCount)
    }

    onValidationCountUp:{
        newCount++;
        console.log("New count qml " + newCount)
    }

    onClockFaceAccepted:{
        console.log("accepted");
    }

    onFinishedCheck:{
        console.log("Finished Check, rejected? " + rejected);
        busy.running=false;
        if(newCount === fileCount){
        if(rejected)
        {
            validationRejected = true;
            qmlUtils.showBanner(qsTr("Clock Style validation failed"), qsTr("See below for details"), 5000);
        }

        else{
            chosenClockFace = folderr+ "/face.qml";
            usingExternal = true
        }
        }
    }
    onClockFaceRejected:{
        reasonModel.append({"rejectedReason": message});
        console.log( "Model count " + reasonModel.count)
    }

}

Loader{
    asynchronous: true;
    id: loader;
    source: usingExternal? chosenClockFace : ""
    anchors{
        top:headerr.bottom;
        topMargin: Theme.paddingLarge;
        left:parent.left;
        right:parent.right
}
}

BusyIndicator{
  running: false
  id: busy
  size: BusyIndicatorSize.Large
  anchors{centerIn:parent}
}

Component {
    id: delegatee

    ListItem {
        property variant myData: model
        id: item
        Label {
            id: title
            text: model.rejectedReason
            width: parent.width-30;
            anchors{
                left: parent.left;
                leftMargin: Theme.paddingLarge
            }
            truncationMode: TruncationMode.Fade
            color: Theme.primaryColor
            anchors.verticalCenter: parent.verticalCenter
            x: Theme.horizontalPageMargin
        }

    }
  }

Label{
    color:Theme.primaryColor;
    anchors.centerIn: parent;
    text: qsTr("No Clock Selected");
    visible: usingExternal ?false:true
}
PageHeader {
    id: headerr
    title:qsTr("Custom Clock Style")
}

   ListView {
            id: view
            visible: validationRejected?true:false
            anchors{
                top:headerr.bottom;
                bottom:row.top
            }
            width:parent.width
            model: reasonModel
            delegate: delegatee
            currentIndex: -1
            header: SectionHeader{
                text:qsTr("The following are not allowed:")
            }
}
        Row{
            id: row;
            spacing:Theme.paddingSmall;
            anchors{
                bottom:parent.bottom;
                bottomMargin: Theme.paddingMedium;
                horizontalCenter: parent.horizontalCenter
            }

        Button{
            id: button;
            text:qsTr("Choose Style");
            onClicked: {
                pageStack.push(filePickerPage)
            }
        }
        Button{
            property string a;
            visible:usingExternal;
            id: button1;
            text:qsTr("Use Style");
            onClicked: {
                customClockFaceURL = chosenClockFace;
                selected = true;
                listView.currentIndex = 13;
                clockFacePicker.selectedIndex = 13;
                forceSelected();
                pageStack.pop();
            }
        }
}
}
