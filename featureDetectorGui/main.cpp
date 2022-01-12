#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "core_module.h"
#include "opencvimageprovider.h"
#include "videostreamer.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    CoreModule core_module_(QCoreApplication::applicationDirPath());
    engine.rootContext()->setContextProperty("core_module_", &core_module_);

    OpencvImageProvider *liveImageProviderOut(new OpencvImageProvider);
    engine.rootContext()->setContextProperty("liveImageProviderOut",liveImageProviderOut);
    engine.addImageProvider("liveOut",liveImageProviderOut);
    QObject::connect(&core_module_,&CoreModule::newImageOut,liveImageProviderOut,&OpencvImageProvider::updateImage);

    OpencvImageProvider *liveImageProviderIn(new OpencvImageProvider);
    engine.rootContext()->setContextProperty("liveImageProviderIn",liveImageProviderIn);
    engine.addImageProvider("liveIn",liveImageProviderIn);
    QObject::connect(&core_module_,&CoreModule::newImageIn,liveImageProviderIn,&OpencvImageProvider::updateImage);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
