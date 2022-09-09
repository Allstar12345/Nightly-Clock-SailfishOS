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
    property var radian: 0.01745
    id: wallClock
    property bool showDateOnMain:true
    width: Screen.sizeCategory== Screen.Large? Screen.width/1.3:Screen.width/1.2
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
        var date = new Date
        return date.getMinutes()
    }

    function getSeconds(){
        var date = new Date
        return date.getSeconds()
    }

    property int hours: getHours()
    property int minutes: getMinutes()
    property int seconds: getSeconds()
    property int milliseconds


    function timeChanged() {
        minuteCircle.requestPaint()
        minuteArc.requestPaint()
        hourCircle.requestPaint()
        hourArc.requestPaint()
    }

    property bool running: true
    Connections{
        target:running? main:null;
        onTimeUpdated:{wallClock.timeChanged()}
    }

    Image {
        id: logoAsteroid
        source: "asteroid_logo.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width/5.7
        height: parent.height/5.7
    }

    Canvas {
        id: minuteArc
        anchors.fill: parent
        smooth: true
        renderTarget: Canvas.FramebufferObject
        onPaint: {
            var ctx = getContext("2d")
            var rot = (wallClock.getMinutes() -15 )*6
            ctx.reset()
            ctx.lineCap="round"
            ctx.beginPath()
            ctx.arc(parent.width/2, parent.height/2, width / 2.75, -90* radian, 450* radian, false);
            ctx.lineWidth = parent.width/80
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.5)
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(parent.width/2, parent.height/2, width / 2.75, -90* radian, rot* radian, false);
            ctx.lineWidth = parent.width/20
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.7)
            ctx.stroke()
        }
    }

    Canvas {
        id: minuteCircle
        property var rotM: (wallClock.getMinutes() - 15)/60
        property var centerX: parent.width/2
        property var centerY: parent.height/2
        property var minuteX: centerX+Math.cos(rotM * 2 * Math.PI)*width*0.36
        property var minuteY: centerY+Math.sin(rotM * 2 * Math.PI)*width*0.36
        anchors.fill: parent
        smooth: true
        renderTarget: Canvas.FramebufferObject
        onPaint: {
            var ctx = getContext("2d")
            var rot1 = (0 -15 )*6 * radian
            var rot2 = (60 -15 )*6 * radian
            ctx.reset()
            ctx.lineWidth = 3
            ctx.fillStyle = Qt.rgba(0.184, 0.184, 0.184, 0.9)
            ctx.beginPath()
            ctx.moveTo(minuteX, minuteY)
            ctx.arc(minuteX, minuteY, width / 11.5, rot1, rot2, false);
            ctx.lineTo(minuteX, minuteY);
            ctx.fill();
        }
    }

    Canvas {
        id: hourArc
        anchors.fill: parent
        smooth: true
        renderTarget: Canvas.FramebufferObject
        onPaint: {
            var ctx = getContext("2d")
            var rot = 0.5 * (60 * (wallClock.getHours()-3) + wallClock.getMinutes())
            ctx.reset()
            ctx.lineCap="round"
            ctx.beginPath()
            ctx.arc(parent.width/2, parent.height/2, width / 5.3, 270* radian, 630* radian, false);
            ctx.lineWidth = parent.width/80
            ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.5)
            ctx.stroke()
            ctx.beginPath()
            ctx.arc(parent.width/2, parent.height/2, width / 5.3, 270* radian, rot* radian, false);
            ctx.lineWidth = parent.width/20
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.7)
            ctx.stroke()
        }
    }

    Canvas {
        id: hourCircle
        property var rotH: (wallClock.getHours()-3 + wallClock.getMinutes()/60) / 12
        property var centerX: parent.width/2
        property var centerY: parent.height/2
        property var hourX: (centerX+Math.cos(rotH * 2 * Math.PI)*width*0.185)
        property var hourY: (centerY+Math.sin(rotH * 2 * Math.PI)*width*0.185)
        anchors.fill: parent
        smooth: true
        renderTarget: Canvas.FramebufferObject
        onPaint: {
            var ctx = getContext("2d")
            var rot1 = (0 -15 )*6 * radian
            var rot2 = (60 -15 )*6 * radian
            ctx.reset()
            ctx.lineWidth = 3
            ctx.fillStyle = Qt.rgba(0.184, 0.184, 0.184, 0.9)
            ctx.beginPath()
            ctx.moveTo(hourX, hourY)
            ctx.arc(hourX, hourY, width / 11.5, rot1, rot2, false);
            ctx.lineTo(hourX, hourY);
            ctx.fill();
        }
    }

    Text {
        id: hourDisplay
        property var rotH: (wallClock.getHours()-3 + wallClock.getMinutes()/60) / 12
        property var hoffset: parent.height*0.0015
        property var voffset: parent.height*0.005
        property var centerX: parent.width/2-width/2-hoffset
        property var centerY: parent.height/2-height/2+voffset
        font.pixelSize: parent.height/8
        font.family: "SlimSans"
        color: "white"
        opacity: 1.0
        style: Text.Outline; styleColor: "#80000000"
        horizontalAlignment: Text.AlignHCenter
        x: centerX+Math.cos(rotH * 2 * Math.PI)*height*1.32
        y: centerY+Math.sin(rotH * 2 * Math.PI)*height*1.32
        text: wallClock.toLocaleString(Qt.locale(), "<b>HH</b>")
    }

    Text {
        id: minuteDisplay
        property var rotM: (wallClock.getMinutes() - 15)/60
        property var hoffset: parent.height*0.0015
        property var voffset: parent.height*0.0015
        property var centerX: parent.width/2-width/2-hoffset
        property var centerY: parent.height/2-height/2+voffset
        font.pixelSize: parent.height/8
        font.family: "SlimSans"
        color: "white"
        opacity: 1.00
        style: Text.Outline; styleColor: "#80000000"
        x: centerX+Math.cos(rotM * 2 * Math.PI)*height*2.535
        y: centerY+Math.sin(rotM * 2 * Math.PI)*height*2.535
        text: wallClock.toLocaleString(Qt.locale(), "mm")
    }


    Component.onCompleted: {
        minuteCircle.requestPaint()
        minuteArc.requestPaint()
        hourCircle.requestPaint()
        hourArc.requestPaint()
        customClockFaceWantsDate=showDateOnMain;
    }
}
