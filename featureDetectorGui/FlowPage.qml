import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {

    Connections{
        target: liveImageProviderIn
        function onImageChanged() {
            sourceImage.reload()
        }
    }

    Connections{
        target: liveImageProviderOut
        function onImageChanged() {
            outputImage.reload()
        }
    }

    Connections {
        target: core_module_
        function onFlowSourcePathChanged() {
            inputStack.currentIndex = 1
        }
    }

    Rectangle {
        anchors.fill: parent
        color: main_item.bgColor

        Column {
            anchors.bottom: parent.bottom
            anchors.right: parent.left

            Rectangle {
                height: 1
                width: 80
                color: borderColor
            }

            // Кнопка запуска алгоритма
            PlayButton {
                enabled: (inputStack.currentIndex === 0) ? false : true
                imageSource: checked ? "qrc:icon/play_check.png" : "qrc:icon/play.png"
                MouseArea {
                    property bool isFLowActive: false
                    anchors.fill: parent
                    onPressed: {
                        parent.checked = true
                    }
                    onReleased: {
                        parent.checked = false
                        if (!isFLowActive) {
                            isFLowActive = true
                            core_module_.playFlag = true
                            inputStack.currentIndex = 2
                            outputStack.currentIndex = 1
                            core_module_.createOpticalFlow(comboBox.currentIndex)
                        }
                        else {
                            isFLowActive = false
                            core_module_.playFlag = false
                        }
                    }
                }
            }

            // Кнопка обновления источника
            PlayButton {
                imageSource: checked ? "qrc:icon/refresh_check.png" : "qrc:icon/refresh.png"
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        parent.checked = true
                    }
                    onReleased: {
                        parent.checked = false
                        core_module_.playFlag = false
                        inputStack.currentIndex = 0
                        outputStack.currentIndex = 0
                    }
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 0

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 720

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Исходное изображение
                    Rectangle {
                        Layout.preferredHeight: 480
                        Layout.fillWidth: true

                        color: main_item.bgColor
                        border.width: (inputStack.currentIndex === 2) ? 0 : 1
                        border.color: main_item.borderColor

                        StackLayout {
                            id: inputStack
                            anchors.fill: parent
                            currentIndex: 0

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"

                                Button {
                                    anchors.centerIn: parent
                                    text: "Выбрать исходное\nвидео"
                                    onClicked: {
                                        fileDialog.index = 3
                                        fileDialog.open()
                                    }
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment:  Text.AlignVCenter
                                    wrapMode: Text.WordWrap
                                    text: "Кадр исходного\nвидео"
                                    font.pixelSize: 24
                                    color: borderColor
                                }
                            }

                            Image{
                                id: sourceImage
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                property bool counter: false
                                source: "image://liveIn/image"
                                asynchronous: false
                                cache: false

                                function reload()
                                {
                                    counter = !counter
                                    source = "image://liveIn/image?id=" + counter
                                }

                            }
                        }
                    }

                    // Выбор детектора
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.topMargin: 40

                        Rectangle {
                            height: parent.height
                            width: 260
                            anchors.centerIn: parent

                            color: main_item.comboBoxColor

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 20

                                text: "Метод: "
                                font.pointSize: 12
                                color: main_item.bgColor
                            }

                            ComboBox {
                                id: comboBox
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                model: ["LK Sparse",
                                        "LK Dense",
                                        "Farneback",
                                        "RLOF"]
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: 720

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Результат детектирования
                    Rectangle {
                        Layout.preferredHeight: 480
                        Layout.fillWidth: true

                        color: main_item.bgColor
                        border.width: (outputStack.currentIndex === 0) ? 1 : 0
                        border.color: main_item.borderColor

                        StackLayout {
                            id: outputStack
                            anchors.fill: parent
                            currentIndex: 0

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment:  Text.AlignVCenter
                                    wrapMode: Text.WordWrap
                                    text: "Результат работы\nалгоритма"
                                    font.pixelSize: 24
                                    color: borderColor
                                }
                            }

                            Image{
                                id: outputImage
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                property bool counter: false
                                source: "image://liveOut/image"
                                asynchronous: false
                                cache: false

                                function reload()
                                {
                                    counter = !counter
                                    source = "image://liveOut/image?id=" + counter
                                }

                            }
                        }
                    }

                    // Информация о производительности
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.topMargin: 40

                        Rectangle {
                            height: parent.height
                            width: /*pointText.contentWidth +*/ timeText.contentWidth + 80
                            anchors.centerIn: parent

                            color: main_item.comboBoxColor

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    Text {
                                        id: timeText
                                        anchors.centerIn: parent

                                        text: "FPS: " + core_module_.flowFPS.toFixed(0)
                                        font.pointSize: 12
                                        color: main_item.bgColor
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
