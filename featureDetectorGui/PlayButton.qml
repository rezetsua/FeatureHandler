import QtQuick 2.0
import QtQuick.Controls 2.15

Button {
    id: button
    checkable: true
    width: 80; height: width * 0.75

    property string imageSource: ""
    property string buttonText: ""
    property color checked__color: "#000000"
    readonly property color hover__color: "#444444"
    property color text__color: "#DADADA"
    readonly property color unchecked__color: "#1F1F1F"

    Rectangle {
        id: button_bg
        anchors.fill: parent
        color: {
            if (button.checked == true)
                return checked__color
            else if (mouse_area.containsMouse)
                return hover__color
            else
                return unchecked__color
        }
//        border.color: checked__color
//        border.width: 1

        Image {
            anchors.fill: parent
            anchors.margins: 20
            fillMode: Image.PreserveAspectFit
            source: imageSource
        }
//        Text {
//            text: buttonText
//            anchors.verticalCenter: parent.verticalCenter
//            anchors.left: parent.left
//            anchors.leftMargin: 16

//            color: button.checked ? main_item.bgColor : text__color
//            font.weight: Font.DemiBold
//            font.pixelSize: 32 / 2.3
//        }

        MouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
