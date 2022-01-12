import QtQuick 2.0
import QtQuick.Controls 2.15

Button {
    id: button
    width: 80; height: width * 0.8
    checkable: true

    readonly property color checked__color: "#000000"
    readonly property color hover__color: "#404244"
    readonly property color unchecked__color: "#1F1F1F"

    property string buttonText: "" // Текст на кнопке
    property string imageSourceCheck: "" // Изображение на активной кнопке
    property string imageSourceUncheck: "" // Изображение на НЕ активной кнопке

    property int textHeigh: button.height / 4.7

    Rectangle {
        id: button_bg
        anchors.fill: parent
        color: {
            if (button.checked === true)
                return checked__color
            else if (mouse_area.containsMouse)
                return hover__color
            else
                return unchecked__color
        }

        Item {
            width: button.height / 2.5; height: button.height / 2.5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: - textHeigh / 2
        }

        Image {
            fillMode: Image.PreserveAspectFit
            source: button.checked ? imageSourceCheck : imageSourceUncheck
            width: button.height / 2.5; height: button.height / 2.5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: - textHeigh / 2
        }

        Text {
            text: buttonText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3

            color: "white"
            font.bold: true
            font.pixelSize: textHeigh
        }

        // Белая черточка при нажатии
        Rectangle {
            width: 3; height: parent.height
            color: "white"
            anchors.left: parent.left
            visible: button.checked
        }

        MouseArea {
            id: mouse_area
            anchors.fill: parent
            hoverEnabled: true
        }
    }

}
