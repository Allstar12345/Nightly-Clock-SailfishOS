/**
  Copyright (C) 2021 Allstar Software (Paul Wallace)
*/
import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "../"
Page {visible:false
    allowedOrientations: decideOrientation();
    id: settingsBase;
    signal closingBasePage
    property int selectedTab;

    QtObject { id: createSettings; property Component com: null;function createComponent (qmlfile){com = Qt.createComponent(qmlfile);com.createObject(settingsBase)} }

    onStatusChanged: {
        if(status == PageStatus.Inactive){
            closingBasePage();
            restartStandbyTimer();
        }
    }

    Component.onCompleted: {
        var timer = createTimer(settingsBase, (200));timer.triggered.connect(function() {
            settingsBase.visible = true;
            flickable.opacity = 1;
        })
    if(selectedTab > 0) {
        tabs.moveTo(selectedTab)
    }
    }

    SilicaFlickable{

        opacity: 0;
        id:flickable;
        width:parent.width;
        anchors{
            top:parent.top;
            bottom:parent.bottom;
        }

        Behavior on opacity{OpacityAnimator{}}
        PullDownMenu{
        MenuItem{
            text:qsTr("About Nightly Clock");
            onClicked: pageStack.push(Qt.resolvedUrl("AboutApp.qml"))
        }
        MenuItem{
            text:qsTr("Reset Nightly Clock");
            id:resetItem;
            onClicked:{
                createSettings.createComponent("../ResetAppPopup.qml");
                resetItem.enabled = false;
                resetEnabled.start();
            }
        Timer{
            id:resetEnabled;
            repeat:false;
            interval: 5000;
            onTriggered:{
                resetItem.enabled = true;
            }
        }
        }
        MenuItem{
            enabled: networkOnline;
            text:qsTr("Check for updates");
            onClicked: {
                manualUpdateCheck = true;
                createSettings.createComponent("../UpdateChecker.qml")
            }
        }
        }

    CustomTabView {
        slideableCacheExpiry:0
        id: tabs;
        anchors.fill: parent;
            header: Column {
                width: parent.width
                CustomTabButtonRow {
                   x:compactMode ? Theme.paddingSmall : Theme.paddingLarge
                    Repeater {
                       model: [qsTr("Settings"), qsTr("Customise"), qsTr("Weather")]
                        CustomTabButton {
                            onClicked:{
                                tabs.moveTo(model.index)
                            }
                            title: modelData
                            tabIndex: model.index
                        }
                    }
                }
            }

            model: [tab1View, tab2View, tab3View]
            Component {
                id: tab1View
                SettingsPage{}
            }
            Component {
                id: tab2View
               CustomiseSettings {}
            }
            Component {
                id: tab3View
                WeatherSettings {}
            }
        }
    }
}
