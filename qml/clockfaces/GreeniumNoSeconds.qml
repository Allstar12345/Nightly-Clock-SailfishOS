/*
 * Copyright (C) 2018 - Timo Könnecke <el-t-mo@arcor.de>
 *               2016 - Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 - Florent Revest <revestflo@gmail.com>
 *               2012 - Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
 *                      Aleksey Mikhailichenko <a.v.mich@gmail.com>
 *                      Arto Jalkanen <ajalkane@gmail.com>
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1
import Sailfish.Silica 1.0


Item {
    opacity:powerSaving?0.6:1.0
    id: wallClock
    width:Screen.sizeCategory== Screen.Large? Screen.width/1.3: Screen.width/1.2
    Connections{
        target:main;
        onRepaintClockFace:{
            minDisplay.requestPaint();
            canvas.requestPaint()
        }
    }


   property bool showDateOnMain:true
       height: width
       anchors{
           top:parent.top;
           topMargin: Theme.paddingLarge
           horizontalCenter: parent.horizontalCenter
       }

       Timer{
           running:true;
           repeat: true;
           id: upMovement;
           interval: globalScreenSaverInterval

       onTriggered: {
           if(wallClock.anchors.horizontalCenterOffset>=0){
               wallClock.anchors.horizontalCenterOffset+=1;
           }
       if(wallClock.anchors.horizontalCenterOffset>20){
           downMovement.start();
           upMovement.stop();
       }
       }
       }

       Timer{
           id: downMovement;
           repeat: true;
           interval: globalScreenSaverInterval;
           onTriggered: {
               if(wallClock.anchors.horizontalCenterOffset===0){
                   downMovement.stop();
                   upMovement.start();
               }
           else{
                   wallClock.anchors.horizontalCenterOffset-=1;
               }
           }
       }
    // date
    function getHours() {
        var date = new Date
        return date.getHours()
    }

    function getMinutes(){
        var date = Qt.formatDateTime (new Date(), "mm")
        return date;
    }

    property int hours: getHours()
    property int minutes: getMinutes()
    property int milliseconds


    function timeChanged() {
        var min = wallClock.getMinutes()
        if(minDisplay.min != min) {
            minDisplay.min = min
            minDisplay.requestPaint()
        }
        hourDisplay.text=getHours();
    }
    property bool running: true
    Connections{
        target:running? main:null;
        onTimeUpdated:{wallClock.timeChanged()}
    }

    Canvas {
        z: 3
        id: canvas
        anchors.fill: parent
        smooth: true
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = parent.height/48
            ctx.lineCap="round"
            ctx.strokeStyle = Qt.rgba(0.1, 0.1, 0.1, 0.95)

            ctx.translate(parent.width/2, parent.height/2)
            for (var i=0; i < 60; i++) {
                // do not paint a minute stroke when there is an hour stroke
              // if ((i%5) != 0) {
                    ctx.beginPath()
                    ctx.moveTo(0, height*0.365)
                    ctx.lineTo(0, height*0.405)
                    ctx.stroke()
              // }
                ctx.rotate(Math.PI/30)
            }
        }
    }

    Canvas {
        z: 6
        id: minDisplay
        property var min: 0
        anchors.fill: parent
        smooth: true
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.shadowColor = Qt.rgba(0.541, 0.796, 0.243, 0.85)
            ctx.shadowOffsetX = 0
            ctx.shadowOffsetY = 0
            ctx.shadowBlur = 5
            ctx.lineWidth = parent.height/58
            ctx.lineCap="round"
            ctx.strokeStyle = Qt.rgba(0.541, 0.796, 0.243, 1)
            ctx.translate(parent.width/2, parent.height/2)
            ctx.rotate(Math.PI)
            for (var i=0; i <= wallClock.getMinutes(); i++) {
                ctx.beginPath()
                ctx.moveTo(0, height*0.367)
                ctx.lineTo(0, height*0.402)
                ctx.stroke()
                ctx.rotate(Math.PI/30)
            }
        }
    }

    Text {
        z: 6
        id: hourDisplay
        renderType: Text.NativeRendering
        font.pixelSize: parent.height*0.3
        font.family: "Titillium"
        font.styleName:"Bold"
        color: "white"
        style: Text.Outline;
        styleColor: Qt.rgba(0.1, 0.1, 0.1, 0.95)
        opacity: 0.98
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent
        text: getHours()
    }

     Component.onCompleted: {
        var min = wallClock.getMinutes()
        minDisplay.min = min
        minDisplay.requestPaint()

     }

}
