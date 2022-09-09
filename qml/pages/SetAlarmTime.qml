import QtQuick 2.0
import Sailfish.Silica 1.0
import "../"

CustomTimePicker{
    id: dio
    property string myString
    property string bob
    property string newHour
    property string newMin
   hourMode:clock12Hour? DateTime.TwelveHours : DateTime.TwentyFourHours
   Component.onCompleted: {
      if(pushingFromFavsPage){
          myString = qmlUtils.convertTime(pushingFromFavsTime, pushingFromFavsFormat, "hh:mm");
          minute = myString.substring(myString.length, 3);
          hour = myString.substring(0, 2);
      }
else{
      if(alarmTime === ""){}
      else{
          bob = qmlUtils.convertTime(alarmTime, timeFormat, "hh:mm");
          minute = parseInt(bob.substring(bob.length, 3));
          hour = parseInt(bob.substring(0, 2));
      }
      }
  }


onRejected: {
    pushingFromFavsPage=false;
}

onCanceled: {
    pushingFromFavsPage=false;
}

onAccepted: {
    pushingFromFavsPage = false;
    var newTime;
    newHour = hour;
    newMin = minute;

    console.log(newHour.length)
    console.log(newMin.length)

    if(newHour.length === 1){
      newHour= "0"+hour
  }

  if(newMin.length === 1){
      newMin= "0" + minute
  }
    console.log("hour " + newHour)
    console.log("min: "+ newMin)
    var initialTime = newHour+":"+ newMin
    console.log("Initial Time: " + initialTime)
    newTime = qmlUtils.convertTime(initialTime, "hh:mm", timeFormat);
    main.alarmTime = newTime;
    appsettings.saveSystemSetting("alarmTime", alarmTime);
    console.log("Alarm Time Main String: " + alarmTime);
    updateAlarmTimeBox();
    alarmEnabled = true;
}

}
