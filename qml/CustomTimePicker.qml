/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "AlarmTimeFavourites.js" as AlarmTimeFavs
//import "private"

Dialog {

    id: timePickerDialog
    property int hour
    property int minute
    property int hourMode
    property date time: new Date(0,0,0, hour, minute)
    property string timeText: timePicker._formatTime()
    allowedOrientations: Orientation.All

        DialogHeader {id: header;}
        TimePicker {
            id: timePicker
            anchors{
                top:header.bottom;
                horizontalCenter:compactMode? parent.horizontalCenter : bmModel.count>0 ? undefined : parent.horizontalCenter;
            }

            ClockItem {
                anchors.centerIn: parent
                time: timePicker.time
            }
        }
       SectionHeader{
           visible: bmModel.count>0?true:false;
           id: headerr;
           text: qsTr("Favourites");
           anchors{
               top: compactMode? timePicker.bottom : header.bottom;
               topMargin: compactMode? Theme.paddingMedium : 0
           }
       }

        SilicaListView {
            Component.onCompleted: {
                AlarmTimeFavs.openDB();
                updateList();
            }
            function updateList(){
                AlarmTimeFavs.loadLimit = Screen.sizeCategory == Screen.Large? "10" : "4";
                AlarmTimeFavs.readFavouritesListLimit(bmModel);
            }
            id: bmView
            width: compactMode? timePickerDialog.width: timePickerDialog.width/2.2
           anchors{
               right:parent.right
               top:headerr.bottom;
               bottom: parent.bottom
               topMargin: Theme.paddingMedium
           }

            model: bmModel
            delegate: bmDelegate
        ListModel {id: bmModel}}
        Component {
          id: bmDelegate

          ListItem {
              property string myString
              property variant myData: model
              id: bmItem
              onClicked: {
                  myString = qmlUtils.convertTime(model.time, model.timeformat, "hh:mm");
                  timePicker.minute = parseInt(myString.substring(myString.length, 3));
                  timePicker.hour = parseInt(myString.substring(0, 2));
              }

              Label {
                  id: title
                  text: model.time
                  width: parent.width-30;
                  anchors{
                      left: parent.left;
                      leftMargin: Theme.paddingLarge
                  }
                  truncationMode: TruncationMode.Fade
                  color: highlighted ? Theme.highlightColor : Theme.primaryColor
                  anchors.verticalCenter: parent.verticalCenter
                  x: Theme.horizontalPageMargin
              }
          }
        }

    onOpened: {
        timePicker.hour = hour
        timePicker.minute = minute
      timePicker.hourMode = hourMode
    }

    onDone: {
        if (result == DialogResult.Accepted) {
            hour = timePicker.hour
            minute = timePicker.minute
        }
    }
}
