import QtQuick 2.6
import Sailfish.Silica 1.0
import "../../"



Page {
    signal clearSelected
    id: clockFacePicker
    property bool tutorialMode:true
    property int selectedIndex:-1
    property string a
   allowedOrientations: Orientation.All

function setClockFace(){
    if(listView.currentIndex === 0){
        pageStack.replace(Qt.resolvedUrl("Step3.qml"));
    }

    else{
        a = listModel.get(listView.currentIndex).url;
        a = "clockfaces/"+a.substring(27, a.length);
        usingCustomClockFace = true;
        customClockFaceURL = a;
        appsettings.saveSystemSetting("clockFacePickerIndex", listView.currentIndex);
        pageStack.replace(Qt.resolvedUrl("Step3.qml"))
    }
    }

    backNavigation: false
    ListModel{id: listModel}
    Timer{
        interval: 20;
        id: launchTimer;
        onTriggered: {
            listModel.append({"url":"../../clockfacepickeritems/DigitalClock.qml"});
            listModel.append({"url":"../../clockfacepickeritems/AnalogDefault.qml"});
            listModel.append({"url":"../../clockfacepickeritems/AnalogDefaultDateWindow.qml"});
            listModel.append({"url":"../../clockfacepickeritems/AnalogBasic.qml"});
            listModel.append({"url":"../../clockfacepickeritems/AnalogPrecision.qml"});
            listModel.append({"url":"../../clockfacepickeritems/AnalogRailway.qml"});
            listModel.append({"url":"../../clockfacepickeritems/AnalogTactical.qml"});
            listModel.append({"url":"../../clockfacepickeritems/Prominent.qml"});
            listModel.append({"url":"../../clockfacepickeritems/ProminentColour.qml"});
            listModel.append({"url":"../../clockfacepickeritems/Greenium.qml"});
            listModel.append({"url":"../../clockfacepickeritems/GreeniumColour.qml"});
            listModel.append({"url":"../../clockfacepickeritems/GreeniumNoSeconds.qml"});
            listModel.append({"url":"../../clockfacepickeritems/GreeniumNoSecondsColour.qml"});
        }
    }

    Component.onCompleted: {
        launchTimer.start();
    }
            PageHeader {
                id: header
                title: qsTr("Choose a clock style")
            }

            Label{
                id: text
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width-100
                anchors{
                    top:header.bottom;
                    topMargin: Theme.paddingMedium;
                    horizontalCenter: parent.horizontalCenter;
                }
                text: qsTr("Swipe left for different clock styles\n(tap to select)")
            }

            SilicaListView{
            id: listView;
            orientation: Qt.Horizontal
            width:parent.width
            contentWidth: listView.count * Screen.width
            anchors{
                top:text.bottom;
                bottom:button.top;
                bottomMargin: Theme.paddingLarge;
                topMargin: Theme.paddingLarge
            }

            snapMode: ListView.SnapOneItem;
            boundsBehavior: Flickable.StopAtBounds;
            highlightRangeMode: ListView.StrictlyEnforceRange;
            model: listModel
            cacheBuffer:1
            Component.onCompleted: {
                swipeGest.opacity = 0.7;
                hint.start();
            }

            Rectangle{
                color:Theme.overlayBackgroundColor;
                anchors.fill: parent;
                id: swipeGest;
                opacity: 0;
                Behavior on opacity {OpacityAnimator{}}

                MouseArea {
                z:5
                id: globalMouseArea
                anchors.fill: parent
                enabled:false
                preventStealing: true
                property real velocity: 0.0
                property int xStart: 0
                property int xPrev: 0
                property bool tracing: false
                onPressed: {
                xStart = mouse.x
                xPrev = mouse.x
                velocity = 0
                tracing = true
                }
                onPositionChanged: {
                if ( !tracing ) return
                var currVel = (mouse.x-xPrev)
                velocity = (velocity + currVel)/2.0
                xPrev = mouse.x
                if ( velocity < 15 && mouse.x < parent.width*0.2 ) {
                    hint.stop();
                    swipeGest.opacity = 0;
                    globalMouseArea.enabled = false;
                }
                }
                onReleased: {
                tracing = false
                if ( velocity > 15 && mouse.x < parent.width*0.2 ) {
                }
                }
                }

                Timer{
                    id: gestTimer;
                    interval: 1000;
                    onTriggered: {
                        hint.stop();
                        swipeGest.opacity = 0;
                        globalMouseArea.enabled = false;
                    }
                }

                TouchInteractionHint {
                    z:5
                    id: hint
                    loops: 2
                    onRunningChanged: {
                        if(running === false) swipeGest.opacity = 0
                    }
                    interactionMode: TouchInteraction.Swipe
                    direction: TouchInteraction.Left
                }

            }

            delegate: Rectangle {
                Connections{
                    target: clockFacePicker;
                    onClearSelected:{
                        selected = false;
                    }
                }


                property bool selected
                onSelectedChanged: {
                    if(selected) selectedIndex = listView.currentIndex;
                    else selectedIndex = -1;
                }
                color: "Transparent"
                width: clockFacePicker.width
                height: listView.height

                ComboBox{
                    id: fontSizeCombo
                    opacity: listView.currentIndex === 0?1:0;
                    Behavior on opacity {OpacityAnimator{}}

                    Component.onCompleted: {
                        if(appsettings.getSystemSetting("clocksizeLabel", "") === "")currentIndex = 0
                        else currentIndex = parseInt(appsettings.getSystemSetting("clocksizeLabel", ""))
                    }

                    anchors{
                        bottom:parent.bottom;
                        bottomMargin: Theme.paddingSmall
                    }

                    onCurrentIndexChanged:{appsettings.saveSystemSetting("clocksizeLabel", currentIndex);}
                    label: qsTr("Digital Clock Size")

                    menu:ContextMenu{
                        MenuItem{
                            text:qsTr("Large");
                            value:"Large";
                            onClicked:{
                                appsettings.saveSystemSetting("fontSize", value);
                                appsettings.saveSystemSetting("fontSizeLabel", text);
                                updateDateSize();
                            }
                        }

                        MenuItem{
                            text:qsTr("Medium");
                            value:"Medium";
                            onClicked:{
                                appsettings.saveSystemSetting("fontSize", value);
                                appsettings.saveSystemSetting("fontSizeLabel", text);
                                updateDateSize();
                            }
                        }

                        MenuItem{
                            text:qsTr("Small");
                            value:"Small";
                            onClicked:{
                                appsettings.saveSystemSetting("fontSize", value);
                                appsettings.saveSystemSetting("fontSizeLabel", text);
                                updateDateSize();
                            }
                        }

                        MenuItem{
                            text:qsTr("Very Small");
                            value:"XSmall";
                            onClicked:{
                                appsettings.saveSystemSetting("fontSize", value);
                                appsettings.saveSystemSetting("fontSizeLabel", text);
                                updateDateSize();
                            }
                        }
                    }
                }

                Image{
                    visible:compactMode
                    Behavior on opacity{OpacityAnimator{}}
                    opacity: selected? 0.95 : 0;
                    z:1;
                    sourceSize.height: Theme.iconSizeLarge;
                    sourceSize.width: Theme.iconSizeLarge;
                    width: sourceSize.width;
                    height: sourceSize.height

                 anchors{
                     top:parent.top;
                     topMargin: Theme.paddingMedium;
                     horizontalCenter: parent.horizontalCenter
                 }
                 source:"../../images/clockface_picker_selected.svg"}

                Rectangle{
                    Behavior on opacity{OpacityAnimator{}}
                    opacity:selected?0.1:0;
                    anchors.fill: parent;
                    color:Theme.secondaryHighlightColor;
                }

                Loader{
                asynchronous: true
                source: model.url
                Behavior on opacity{OpacityAnimator{}}
                visible: status == Loader.Ready
                opacity:status == Loader.Ready? fontSizeCombo._menuOpen?0:1:0
                anchors.centerIn: parent
                }
            }
            }

            Button{
                text:qsTr("Next")
                id: button
                enabled: selectedIndex === -1? false:true
                anchors{
                    bottom:parent.bottom;
                    bottomMargin: Theme.paddingMedium;
                    horizontalCenter: parent.horizontalCenter
                }
                onClicked: setClockFace();

            }
}
