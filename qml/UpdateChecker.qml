/**
  Copyright (C) 2021 Allstar Software (Paul Wallace)
*/
import QtQuick 2.6
import Updater 1.0
    Updater{
        id: up;
        property string currentBuild:"1.029"
         onResultFinished: {
            if(qmlUtils.getOSVersion() >= xResult["required_os"]){
            if(xResult["version"]>currentBuild){
                pageStack.push("pages/NewUpdatePage.qml", {
                updaterNewVersionNumber:xResult["version"],
                updaterNewAppVersionNumber : xResult["app_version"],
                updaterNewVersionURLARM : xResult["url_arm"],
                updaterNewVersionURLARM64 : xResult["url_arm64"],
                updaterNewVersionURLi386 : xResult["url_i386"] ,
                updaterNewVersionFileNameARM: xResult ["fileName_arm"],
                updaterNewVersionFileNameARM64: xResult ["fileName_arm64"],
                updaterNewVersionFileNamei386 : xResult["fileName_i386"] ,
                updaterNewVersionFileSize: xResult["fileSize"] ,
                updaterNewVersionDate:xResult["datereleased"],
                updaterNewVersionChangelog:xResult["changelog"],
                updaterNewVersionImage1Url:xResult["image1"],
                updaterNewVersionImage2Url:xResult["image2"],
                updaterNewVersionImage3Url:xResult["image3"] ,
                updaterNewVersionImage4Url:xResult["image4"],
                updaterNewVersionImage5Url:xResult["image5"],
                updaterNewVersionImage6Url:xResult["image6"]});
            }

            else{
                if(manualUpdateCheck){
                    qmlUtils.showBanner("", qsTr("You're up to date"), 3000);
                    manualUpdateCheck = false;
                }
            }
            }
         }
         onErrorChecking: {
             if(manualUpdateCheck) qmlUtils.showBanner("", qsTr("Unable to check for updates"), 5000);
         }

       Component.onCompleted:{
           if(manualUpdateCheck){
               qmlUtils.showBanner("", qsTr("Checking for updates"), 2000);
           }
             checkForUpdates();
       }
    }
