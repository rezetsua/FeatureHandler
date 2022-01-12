import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Page {
    id: root

    Connections {
        target: core_module_
        function onDescriptorOutputReady() {
            imageStack.currentIndex = 1
            outputImage.scale = 1
            outputImage.source = "file:" + core_module_.descriptorOutputPath
        }
        function onDescriptorSourcePath1Changed() {
            sourceImage1.source = "file:" + core_module_.descriptorSourcePath1
            inputStack1.currentIndex = 1
        }
        function onDescriptorSourcePath2Changed() {
            sourceImage2.source = "file:" + core_module_.descriptorSourcePath2
            inputStack2.currentIndex = 1
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
                enabled: ((inputStack1.currentIndex === 1) && (inputStack2.currentIndex === 1)) ? true : false
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
                        core_module_.descriptKeyPoint(comboBox.currentIndex)
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
                        inputStack1.currentIndex = 0
                        inputStack2.currentIndex = 0
                        imageStack.currentIndex = 0
                        outputImage.source = ""
                    }
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 0

            Item {
                Layout.preferredHeight: 480
                Layout.fillWidth: true

                StackLayout {
                    id: imageStack
                    anchors.fill: parent
                    currentIndex: 0

                    // Исходные изображения
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            // Исходное изображение 1
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 720

                                color: main_item.bgColor
                                border.width: (inputStack1.currentIndex === 0) ? 1 : 0
                                border.color: main_item.borderColor

                                StackLayout {
                                    id: inputStack1
                                    anchors.fill: parent
                                    currentIndex: 0

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "transparent"

                                        Button {
                                            anchors.centerIn: parent
                                            text: "Выбрать первое\nизображение"
                                            onClicked: {
                                                fileDialog.index = 1
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

                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                            }

                            // Исходное изображение 2
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 720

                                color: main_item.bgColor
                                border.width: (inputStack2.currentIndex === 0) ? 1 : 0
                                border.color: main_item.borderColor

                                StackLayout {
                                    id: inputStack2
                                    anchors.fill: parent
                                    currentIndex: 0

                                    Rectangle {
                                        anchors.fill: parent
                                        color: "transparent"

                                        Button {
                                            anchors.centerIn: parent
                                            text: "Выбрать второе\nизображение"
                                            onClicked: {
                                                fileDialog.index = 2
                                                fileDialog.open()
                                            }
                                        }
                                    }

                                    Image {
                                        id: sourceImage2
                                        visible: false
                                        anchors.fill: parent
                                        fillMode: Image.PreserveAspectFit
                                        source: ""
                                    }
                                }
                            }
                        }
                    }

                    // Результат работы алгоритма
                    Rectangle {
                        Layout.preferredHeight: 480
                        Layout.fillWidth: true

                        color: main_item.bgColor
                        border.width: (outputImage.source === "") ? 1 : 0
                        border.color: main_item.borderColor

                        Image {
                            id: outputImage
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: ""
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

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

                            text: "Дескриптор: "
                            font.pointSize: 12
                            color: main_item.bgColor
                        }

                        ComboBox {
                            id: comboBox
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            model: ["SIFT",
                                    "ORB",
                                    "KAZE",
                                    "AKAZE",
                                    "BRISK"]
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 190
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

                                    text: "Время работы: " + (core_module_.descriptorTimeCost*1000).toFixed(0) + " мс"
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

                                    text: "Количество точек: " + core_module_.descriptorKeyPointAmount
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
