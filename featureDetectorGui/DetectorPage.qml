import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    Connections {
        target: core_module_
        function onDetectedOutputReady() {
            outputImage.scale = 1
            outputImage.source = "file:" + core_module_.detectorOutputPath
        }
        function onDetectorSourcePathChanged() {
            sourceImage1.source = "file:" + core_module_.detectorSourcePath
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
                enabled: (inputStack.currentIndex === 1) ? true : false
                imageSource: checked ? "qrc:icon/play_check.png" : "qrc:icon/play.png"
                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        parent.checked = true
                        outputImage.scale = 0.2
                        outputImage.source = "qrc:icon/sync.png"
                    }
                    onReleased: {
                        parent.checked = false
                        core_module_.detectKeyPoint(comboBox.currentIndex)
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
                        inputStack.currentIndex = 0
                        outputImage.source = ""
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
                        border.width: (inputStack.currentIndex === 0) ? 1 : 0
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
                                    text: "Выбрать исходное\nизображение"
                                    onClicked: {
                                        fileDialog.index = 0
                                        fileDialog.open()
                                    }
                                }
                            }

                            Image {
                                id: sourceImage1
                                visible: false
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectFit
                                source: ""
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

                                text: "Детектор: "
                                font.pointSize: 12
                                color: main_item.bgColor
                            }

                            ComboBox {
                                id: comboBox
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                model: ["Shi-Tomasi",
                                    "FAST",
                                    "AGAST",
                                    "SimpleBlob",
                                    "SIFT",
                                    "MSER",
                                    "KAZE",
                                    "AKAZE"]
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
                        border.width: (outputImage.source == "") ? 1 : 0
                        border.color: main_item.borderColor

                        Image {
                            id: outputImage
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: ""
                        }
                    }

                    // Информация о производительности
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.topMargin: 40

                        Rectangle {
                            height: parent.height
                            width: pointText.contentWidth + timeText.contentWidth + 80
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

                                        text: "Время работы: " + (core_module_.detectorTimeCost*1000).toFixed(0) + " мс"
                                        font.pointSize: 12
                                        color: main_item.bgColor
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1

                                    color: main_item.bgColor
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    Text {
                                        id: pointText
                                        anchors.centerIn: parent

                                        text: "Количество точек: " + core_module_.detectorKeyPointAmount
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
