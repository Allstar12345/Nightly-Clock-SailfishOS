import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../"
import "../AlarmTimeFavourites.js" as AlarmTimeFavs


Page {
    id: page
    allowedOrientations: decideOrientation();
    onStatusChanged: {
        if(status == PageStatus.Inactive){
            restartStandbyTimer();
        }
    }

   Component.onDestruction: {
       appsettings.saveSystemSetting("alarmVolume", alarmVolume);
       appsettings.saveSystemSetting("flashLightSpeed", flashSpeed)
   }

    SilicaFlickable {
        contentHeight: content.height
        bottomMargin: 5
        anchors.fill: parent
        id: flickable
        Column {
            id: content
            width: parent.width
            spacing: 2

            PageHeader {
                id: header
                title: qsTr("Alarm Settings")
            }

            TextSwitch {
                id: boldSwitch
                text: qsTr("Alarm turned on")
                checked: alarmEnabled
                onClicked: {
                    if(alarmEnabled === true){
                        alarmEnabled = false;
                        appsettings.saveSystemSetting("alarmEnabled", "")
                    }

                    else{
                        alarmEnabled=true;
                        appsettings.saveSystemSetting("alarmEnabled", "true")
                    }
                }
            }

            TextSwitch{
                text:qsTr("Sunrise alarm")
                enabled: intervalAlarm?false:true
                checked: sunriseMode
                description: intervalAlarm? qsTr("Turn off Interval Alarm to use Sunrise"): ""
                id: sunriseSwitch
                onClicked: {
                    if(appsettings.getSystemSetting("sunrisefirstruntut", "") === ""){
                        appsettings.saveSystemSetting("sunrisefirstruntut", "true");
                        pageStack.push("SunriseModeTutorial.qml")
                    }
                    else{
                        if(sunriseMode)sunriseMode = false;
                        else sunriseMode = true
                    }
                }
            }

            ComboBox{
                Connections{
                    target: main;

                    onUpdateAlarmTimeBox:{
                    alarmTimeBox.updateDescription();
                    AlarmTimeFavs.loadLimit = "1";
                    AlarmTimeFavs.readFavouritesListLimit(mod);
                }
                }

            id:alarmTimeBox
            Behavior on opacity {NumberAnimation{}}

            function updateDescription(){
                description = appsettings.getSystemSetting("alarmTime", "")
            }

            label:qsTr("Alarm Time")
            description:alarmTime
            ListModel{id: mod;}

            IconButton{
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AlarmTimeFavourites.qml"))
                }

                Timer{
                    interval: 700;
                    id: inter;
                    onTriggered: {
                        AlarmTimeFavs.openDB();
                        AlarmTimeFavs.loadLimit = "1";
                        AlarmTimeFavs.readFavouritesListLimit(mod);
                    }
                }

                Component.onCompleted: {
                    inter.start();
                }
                visible:mod.count>0 ? true : false
                icon.source: "image://theme/icon-m-edit";

            anchors{
                right:addFavButton.left;
                rightMargin: Theme.paddingMedium;
                verticalCenter: parent.verticalCenter
            }
            }

            IconButton{
                visible: alarmTime === ""?false:true
                id: addFavButton
                onClicked: {
                    var itemnew = AlarmTimeFavs.defaultItem();
                    itemnew.time = alarmTime;
                    itemnew.timeformat = timeFormat;
                    AlarmTimeFavs.createFavorite(itemnew);
                    AlarmTimeFavs.loadLimit = "1";
                    AlarmTimeFavs.readFavouritesListLimit(mod);
                    qmlUtils.showBanner("", qsTr("Added to favourites"), 1000)
                }

              anchors{
                  right:parent.right;
                  verticalCenter: parent.verticalCenter
              }

             icon.source: "image://theme/icon-m-add"}
              onClicked: {
                flashAlarmTime = false;
                flashTimer.stop();
                flashReturn.stop();
                alarmTimeBox.highlighted = false;
                pageStack.push(Qt.resolvedUrl("SetAlarmTime.qml"))
            }

            Timer{
                id: flashTimer;
                interval:850;
                running: flashAlarmTime;
                onTriggered: {
                    alarmTimeBox.highlighted = true;
                    flashReturn.start();
                }
            }
            Timer{
                id: flashReturn;
                interval: 850;
                onTriggered: {
                    alarmTimeBox.highlighted = false;
                    flashTimer.start();
                }
            }
            }


            ComboBox{
                Component.onCompleted: {
                    if(appsettings.getSystemSetting("snoozeTimeoutLabel", "")==="")currentIndex=0
                   else currentIndex = parseInt(appsettings.getSystemSetting("snoozeTimeoutLabel", ""))
                }
                onCurrentIndexChanged:{
                    appsettings.saveSystemSetting("snoozeTimeoutLabel", currentIndex);
                }
                label:qsTr("Snooze Length")
                menu:ContextMenu{
                    MenuItem{
                        text:qsTr("1 Minute");
                        value:"60000";
                        onClicked:{
                            alarmSnoozeTimeout = value;
                            appsettings.saveSystemSetting("alarmSnoozeTimeout", value);
                            appsettings.saveSystemSetting("snoozeTimeoutLabel", text);
                        }
                    }



                    MenuItem{
                        text:qsTr("5 Minutes");
                        value:"300000";
                        onClicked:{
                            alarmSnoozeTimeout = value;
                            appsettings.saveSystemSetting("alarmSnoozeTimeout", value);
                            appsettings.saveSystemSetting("snoozeTimeoutLabel", text);
                        }
                    }

                    MenuItem{
                        text:qsTr("10 Minutes");
                        value:"600000";
                        onClicked:{
                            alarmSnoozeTimeout = value;
                            appsettings.saveSystemSetting("alarmSnoozeTimeout", value);
                            appsettings.saveSystemSetting("snoozeTimeoutLabel", text);
                        }
                    }

                    MenuItem{
                        text:qsTr("15 Minutes");
                        value:"900000";
                        onClicked:{
                            alarmSnoozeTimeout = value;
                            appsettings.saveSystemSetting("alarmSnoozeTimeout", value);
                            appsettings.saveSystemSetting("snoozeTimeoutLabel", text);
                        }
                    }

                    MenuItem{
                        text:qsTr("20 Minutes");
                        value:"1200000";
                        onClicked:{
                            alarmSnoozeTimeout = value;
                            appsettings.saveSystemSetting("alarmSnoozeTimeout", value);
                            appsettings.saveSystemSetting("snoozeTimeoutLabel", text);
                        }
                    }

                    MenuItem{
                        text:qsTr("30 Minutes");
                        value:"1800000";
                        onClicked:{
                            alarmSnoozeTimeoute = value;
                            appsettings.saveSystemSetting("alarmSnoozeTimeout", value);
                            appsettings.saveSystemSetting("snoozeTimeoutLabel", text);
                        }
                    }
                }
            }
            TextField{
                id: alarmMessageField
                text: appsettings.getSystemSetting("alarmCompletedMessage", "")
                width: parent.width
                maximumLength: 20
                onTextChanged: {
                    appsettings.saveSystemSetting("alarmCompletedMessage", text)
                }
                placeholderText: qsTr("Alarm Message")
            }


          SectionHeader{
              text:qsTr("Alarm Notification")
          }

          Slider{
              label:qsTr( "Alarm Volume")
              value:alarmVolume
              maximumValue: 0.99
              valueText:value*100>=99 ? qsTr("Full") : Math.round(value*100)+ "%"
              minimumValue:0.05
              anchors{
                  left:parent.left;
                  right:parent.right
              }
              stepSize: 0.01
              onValueChanged: {
                  alarmVolume=value;
              }
          }
          TextSwitch{
              // Need to hide this for Tablet/non ARM devices..
              visible: qmlUtils.returnArchitecture() === "i386"? false : true
               text:qsTr("Flash camera light")
               checked: flashCameraLight;
               onClicked: {
                   if(flashCameraLight){
                       flashCameraLight = false;
                       appsettings.saveSystemSetting("flashCameraLight", "");
                   }

               else{
                flashCameraLight = true;
                appsettings.saveSystemSetting("flashCameraLight", "true");
                   }
               }
           }

          Slider{
              visible: flashCameraLight
              id: flashSpeedTimer
              width: parent.width
              value: flashSpeed
              label:qsTr("Flash Speed")
              valueText: valueTexte();
              function valueTexte(){
                   if(value<=500)return qsTr("Very Fast")
                   if(value<2000) return qsTr("Fast")
                   if(value<=3500) return qsTr("Medium")
                   if(value<5000) return qsTr("Slow")
                   if(value<=10000) return qsTr("Very Slow")
                  else return qsTr("Error")
              }
              stepSize: 500
              minimumValue: 500
              maximumValue: 10000
              onValueChanged: {
                  flashSpeed=value;
              }

          }

            // hardware seems to dislike anything below 500-1000 so let's use 500 as base


          TextSwitch{
          text: qsTr("Increasing volume")
          checked: fadeInAlarm
          onClicked: {
              if(fadeInAlarm){
                  fadeInAlarm = false;
                  appsettings.saveSystemSetting("fadeInAlarmVolume", "");
              }
              else{
                  fadeInAlarm = true;
                  appsettings.saveSystemSetting("fadeInAlarmVolume", "true")
              }
          }
          description: qsTr("Alarm Volume increases gradually")
          }

            ComboBox{
                id: soundCombo
                label:qsTr("Alarm Sound")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AlarmSoundsPicker.qml"))
                }
            }

            ComboBox{
                visible: qmlUtils.returnArchitecture() === "i386"?false:true
                Component.onCompleted: {
                    if(appsettings.getSystemSetting("vibrationLabel", "") === "") currentIndex = 0
                    else currentIndex = parseInt(appsettings.getSystemSetting("vibrationLabel", ""))
                }
                onCurrentIndexChanged:{
                    appsettings.saveSystemSetting("vibrationLabel", currentIndex);
                }

                id: soundBox
                label:qsTr("Vibration")
                menu:ContextMenu{

                    MenuItem{
                        text:qsTr("Vibration Disabled");
                        value: "0";
                        onClicked:{
                            vibrationDuration = value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("1 Second");
                        value:"1000";
                        onClicked:{
                            vibrationDuration = value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("2 Seconds");
                        value:"2000";
                        onClicked:{
                            vibrationDuration = value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("3 Seconds");
                        value:"3000";
                        onClicked:{
                            vibrationDuration = value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("4 Seconds");
                        value:"4000";
                        onClicked:{
                            vibrationDuration = value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("5 Seconds");
                        value:"5000";
                        onClicked:{
                            vibrationDuration = value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("6 Seconds");
                        value:"6000";
                        onClicked:{
                            vibrationDuration = value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("7 Seconds");
                        value:"7000";
                        onClicked:{
                            vibrationDuration=value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("8 Seconds");
                        value:"8000";
                        onClicked:{
                            vibrationDuration=value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("9 Seconds");
                        value:"9000";
                        onClicked:{
                            vibrationDuration=value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }

                    MenuItem{
                        text:qsTr("10 Seconds");
                        value:"10000";
                        onClicked:{
                            vibrationDuration=value;
                            appsettings.saveSystemSetting("VibrationDuration", value);
                        }
                    }
                }
            }

            Slider{
               visible: soundBox.currentIndex === 0?false:true
               label: qsTr("Vibration Intensity")
               stepSize: 0.25
               minimumValue: 0.25
               maximumValue: 1.0
               value:vibrationIntensity
               anchors{
                   left:parent.left;
                   right:parent.right
               }
               valueText: Math.round(value*100)+ "%"
               onValueChanged: {
                   console.log(value);
                   vibrationIntensity = value;
                   appsettings.saveSystemSetting("vibrationIntensity", vibrationIntensity);
               }
            }

                    ExpandingSection {
                        id: section
                        title:qsTr( "Interval Alarm")
                        content.sourceComponent: Column {
                            width: section.width
                            TextSwitch {
                                id: intervalSwitch
                                enabled: sunriseMode?false:true
                                text: intervalAlarm? qsTr("Disable Interval Alarm"): qsTr("Enable Interval Alarm")
                                description: sunriseMode? qsTr("Turn off Sunrise mode to use Interval Alarm"): ""
                                checked: intervalAlarm
                                onClicked: {
                                    if(intervalAlarm === true){
                                        intervalAlarm=false;
                                    }
                                    else{
                                        if(appsettings.getSystemSetting("intervalfirstruntut", "") === ""){
                                            appsettings.saveSystemSetting("intervalfirstruntut", "true");
                                            pageStack.push("IntervalAlarmTutorial.qml")
                                        }
                                        else{
                                        intervalAlarm = true;
                                        flickable.scrollToBottom();
                                        }
                                    }
                                }

                            }


                             ComboBox{
                                 id: timeout
                                 opacity: intervalAlarm?1:0
                                 visible: intervalAlarm?true:false
                                 Component.onCompleted: {
                                     if(appsettings.getSystemSetting("intervalAlarmLabel", "")==="")currentIndex = 0
                                    else currentIndex = parseInt(appsettings.getSystemSetting("intervalAlarmLabel", ""))
                                 }
                                 onCurrentIndexChanged:{
                                     appsettings.saveSystemSetting("intervalAlarmLabel", currentIndex)
                                 }
                                 label:qsTr("Time to sound for")
                                menu:ContextMenu{

                                    MenuItem{
                                        text:qsTr("10 Seconds");
                                        value:"10000";
                                        onClicked:{
                                            alarmServer.soundingInterval = value;
                                            appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                            appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                        }
                                    }

                                     MenuItem{
                                         text:qsTr("15 Seconds");
                                         value:"15000";
                                         onClicked:{
                                             alarmServer.soundingInterval = value;
                                             appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                             appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("20 Seconds");
                                         value:"20000";
                                         onClicked:{
                                             alarmServer.soundingInterval=value;
                                             appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                             appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("25 Seconds");
                                         value:"25000";
                                         onClicked:{
                                             alarmServer.soundingInterval=value;
                                             appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                             appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("30 Seconds");
                                         value:"30000";
                                         onClicked:{
                                             alarmServer.soundingInterval=value;
                                             appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                             appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("40 Seconds");
                                         value:"40000";
                                         onClicked:{
                                             alarmServer.soundingInterval=value;
                                             appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                             appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("50 Seconds");
                                         value:"50000";
                                         onClicked:{
                                             alarmServer.soundingInterval=value;
                                             appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                             appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("1 Minute");
                                         value:"60000";
                                         onClicked:{
                                             alarmServer.soundingInterval=value;
                                             appsettings.saveSystemSetting("intervalAlarmTimeout", value);
                                             appsettings.saveSystemSetting("intervalTimeOutLabel", text);
                                         }
                                     }

                                 }
                             }
                             ComboBox{
                                 id: times
                                 opacity: intervalAlarm?1:0
                                 visible: intervalAlarm?true:false
                                 Component.onCompleted: {
                                     if(appsettings.getSystemSetting("intervalTimesLabel", "") === "")currentIndex=0
                                    else currentIndex= parseInt(appsettings.getSystemSetting("intervalTimesLabel", ""))
                                 }
                                 onCurrentIndexChanged:{
                                     appsettings.saveSystemSetting("intervalTimesLabel", currentIndex);
                                 }
                                 label:qsTr("How many times to sound")
                                menu:ContextMenu{

                                    MenuItem{
                                        text:qsTr("1 Time");
                                        value:"1";
                                        onClicked:{
                                            alarmServer.intervalCount = value;
                                            appsettings.saveSystemSetting("intervalHowManyToSound", value);
                                            appsettings.saveSystemSetting("intervalTimesLabel", text);
                                        }
                                    }

                                     MenuItem{
                                         text:qsTr("2 Times");
                                         value:"2";
                                         onClicked:{
                                             alarmServer.intervalCount = value;
                                             appsettings.saveSystemSetting("intervalHowManyToSound", value);
                                             appsettings.saveSystemSetting("intervalTimesLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("3 Times");
                                         value:"3";
                                         onClicked:{
                                             alarmServer.intervalCount=value;
                                             appsettings.saveSystemSetting("intervalHowManyToSound", value);
                                             appsettings.saveSystemSetting("intervalTimesLabel", text);
                                         }
                                     }

                                     MenuItem{
                                         text:qsTr("4 Times");
                                         value:"4";
                                         onClicked:{
                                             alarmServer.intervalCount=value;
                                             appsettings.saveSystemSetting("intervalHowManyToSound", value);
                                             appsettings.saveSystemSetting("intervalTimesLabel", text);
                                         }
                                     }

                                 }}
                             ComboBox{
                                 id:timesbetween
                                 opacity: intervalAlarm?1:0
                                 visible: intervalAlarm?true:false
                                 Component.onCompleted: {
                                     if(appsettings.getSystemSetting("intervalTimesBetweenLabel", "") === "")currentIndex=0
                                     else currentIndex= parseInt(appsettings.getSystemSetting("intervalTimesBetweenLabel", ""))
                                 }
                                 onCurrentIndexChanged:{
                                     appsettings.saveSystemSetting("intervalTimesBetweenLabel", currentIndex);
                                 }
                                 label:qsTr("Time between sounding")
                                menu:ContextMenu{

                                    MenuItem{
                                        text:qsTr("1 Minute");
                                        value:"60000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("2 Minutes");
                                        value:"120000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("3 Minutes");
                                        value:"180000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("4 Minutes");
                                        value:"240000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("5 Minutes");
                                        value:"300000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("10 Minutes");
                                        value:"600000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("15 Minutes");
                                        value:"900000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("20 Minutes");
                                        value:"1200000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("25 Minutes");
                                        value:"1500000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("30 Minutes");
                                        value:"1800000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                    MenuItem{
                                        text:qsTr("40 Minutes");
                                        value:"2400000";
                                        onClicked:{
                                            alarmServer.intervalRestartTime=value;
                                            appsettings.saveSystemSetting("intervalTimeBetweenSounding", value);
                                            appsettings.saveSystemSetting("intervalTimesBetweenLabel", text);
                                        }
                                    }

                                 }
                             }
                        }
            }
          }
    }
}
