QT += quick widgets

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

INCLUDEPATH +="/usr/local/opencv2/include/opencv4"
LIBS += -L"/usr/local/opencv2/lib/"
LIBS += \
   -lopencv_core \
   -lopencv_features2d \
   -lopencv_highgui \
   -lopencv_imgcodecs \
   -lopencv_imgproc \
   -lopencv_video \
   -lopencv_videoio \
   -lopencv_optflow

SOURCES += \
        core_module.cpp \
        main.cpp \
        opencvimageprovider.cpp \
        videostreamer.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    core_module.h \
    opencvimageprovider.h \
    videostreamer.h
