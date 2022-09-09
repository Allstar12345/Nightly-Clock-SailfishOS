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
    MouseArea{
        anchors.fill: parent;
        onClicked: {
            listView.currentIndex = index;
            if(selected)selected=false;
            else clearSelected();
            selected=true
        }
    }

    id: wallClock
    width:tutorialMode?main.compactMode? Screen.sizeCategory== Screen.Large? Screen.width/1.5:Screen.width/1.2 : Screen.sizeCategory== Screen.Large?Screen.width/1.5:Screen.width/1.7 :main.largeScreen? listView.cellWidth/1.25:main.compactMode? Screen.sizeCategory== Screen.Large? Screen.width/1.5:Screen.width/1.2 : Screen.sizeCategory== Screen.Large?Screen.width/1.5:Screen.width/1.7
    height: width
    anchors{centerIn: parent}
    // date
    function getHours() {
        var date = new Date
        return date.getHours()
    }

    function getMinutes(){
        var date = Qt.formatDateTime (new Date(), "mm")
        return date;
    }

    function getSeconds(){
        var date = new Date
        return date.getSeconds()
    }

    function getDate(){
        var date = new Date
        return date.getDate()
    }

    property int hours: getHours()
    property int minutes: getMinutes()
    property int seconds: getSeconds()
    property int milliseconds


    Canvas {
        z: 1
        id: secondCanvas
        property var second: 0
        anchors.fill: parent
        smooth: true
        renderTarget: Canvas.FramebufferObject
        onPaint: {
            var ctx = getContext("2d")
            var date = wallClock.getDate()
            var rot = (wallClock.getSeconds() - 15)*6
            ctx.reset()
            ctx.beginPath()
            ctx.lineWidth = parent.width/42
            ctx.fillStyle = Qt.rgba(1, 0.549, 0.149, 0.7)
            ctx.arc(parent.width/2, parent.height/2, width / 2.1, -90*0.01745329252, rot*0.01745329252, false);
            ctx.lineTo(parent.width/2, parent.height/2)
            ctx.fill()
        }
    }

    Rectangle {
        z: 2
        anchors.centerIn: parent
        color: Qt.rgba(0.184, 0.184, 0.184, 0.7)
        width: parent.width*0.565
        height: parent.height*0.565
        radius: width*0.5
    }

    Text {
        z: 3
        id: hourDisplay
        font.pixelSize: parent.height*0.16
        font.family: "Raleway"
        font.styleName:"Regular"
        color: "white"
        opacity: 1.0
        style: Text.Outline; styleColor: "#80000000"
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text:wallClock.getHours()+ ":"+ wallClock.getMinutes()
    }


    Component.onCompleted: {
        var second = wallClock.getSeconds()
        secondCanvas.second = second
        secondCanvas.requestPaint()
    }
}
