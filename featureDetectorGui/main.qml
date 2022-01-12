import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.0

ApplicationWindow {
    id: main_item

    width: 1800
    height: 640
    visible: true
    title: qsTr("Feature Detector")

    property color bgColor: "#262728"
    property color bgDarkColor: "#1F1F1F"
    property color borderColor: "#B2B2B2"
    property color hoverColor: "#404244"
    property color comboBoxColor: "#E0E0E0"

    onClosing: core_module_.playFlag = false

    FileDialog {
        id: fileDialog
        property int index: 0
        title: "Please choose a file"
        folder: shortcuts.home
        nameFilters: ["Image files (*.jpg *.png)"]
        onAccepted: {
            getPath(index)
        }
        onRejected: {
        }
    }

    Rectangle {
        anchors.fill: parent
        color: bgColor

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                id: leftButtonColumn
                Layout.fillHeight: true
                Layout.preferredWidth: 80
                color:bgDarkColor

                Column {
                    LeftButton {
                        id: b1
                        buttonText: "Поиск"
                        checked: true
                        imageSourceCheck: "qrc:icon/find.png"
                        imageSourceUncheck: "qrc:icon/find.png"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stack.currentIndex = 0
                            }
                        }
                    }
                    LeftButton {
                        id: b2
                        buttonText: "Сверка"
                        imageSourceCheck: "qrc:icon/puzzle.png"
                        imageSourceUncheck: "qrc:icon/puzzle.png"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stack.currentIndex = 1
                            }
                        }
                    }
                    LeftButton {
                        id: b3
                        buttonText: "Поток"
                        imageSourceCheck: "qrc:icon/route.png"
                        imageSourceUncheck: "qrc:icon/route.png"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                stack.currentIndex = 2
                            }
                        }
                    }
                }

                // Черная полоса
                Rectangle {
                    width: 1; height: parent.height
                    color: "black"
                    anchors.right: parent.right
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                StackLayout {
                    id: stack
                    anchors.fill: parent
                    currentIndex: 0

                    onCurrentIndexChanged: {
                        if (currentIndex == 0) {
                            fileDialog.nameFilters = ["Image files (*.jpg *.png)"]
                            b1.checked = true
                            b2.checked = false
                            b3.checked = false
                        }
                        else if (currentIndex == 1){
                            fileDialog.nameFilters = ["Image files (*.jpg *.png)"]
                            b1.checked = false
                            b2.checked = true
                            b3.checked = false
                        }
                        else if (currentIndex == 2){
                            fileDialog.nameFilters = ["Video files (*.avi *.mp4)"]
                            b1.checked = false
                            b2.checked = false
                            b3.checked = true
                        }
                    }

                    DetectorPage {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: true
                    }

                    DescriptorPage {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: false
                    }

                    FlowPage {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: false
                    }
                }
            }
        }
    }
    function getPath(index) {
        if (index === 0) {
            core_module_.setDetectorSourcePath(fileDialog.fileUrl)
        }
        else if (index === 1) {
            core_module_.setDescriptorSourcePath1(fileDialog.fileUrl)
        }
        else if (index === 2) {
            core_module_.setDescriptorSourcePath2(fileDialog.fileUrl)
        }
        else if (index === 3) {
            core_module_.setFlowSourcePath(fileDialog.fileUrl)
        }
    }
}
