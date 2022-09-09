import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: 8;
    height: face.height/1.5

    Rectangle{
        radius: 40
        height: parent.height/2
        width: parent.width
        id: vsible
        smooth: true
        color:Qt.lighter(colour)
        anchors{
            top:parent.top
        }
    }
Rectangle{
    height: parent.height/2
    width: parent.width
    id: hidden
    color:"Transparent"
    anchors{
        top:vsible.bottom
    }
}

}
