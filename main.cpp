/*#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFontDatabase>
//#include <QGuiApplication>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //-- load icon fonts --//
    QFontDatabase::addApplicationFont(":/Content/font/materialdesignicons-webfont.ttf");

    //-- material design configuration --//
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    qputenv("QT_QUICK_CONTROLS_STYLE", "material");

    //-- QSetting configuration --//
    QCoreApplication::setOrganizationName("MediaSoft");
    QCoreApplication::setOrganizationDomain("MediaSoft.com");
    QCoreApplication::setApplicationName("kootwall");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}*/

#include <QtWidgets/QApplication>
#include <QtQml/QQmlContext>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>
#include <QQmlComponent>
#include <QtCore/QDir>
#include <QQmlEngine>
#include <QFontDatabase>
#include "datasource.h"
#include "imageuploader.h"

int main(int argc, char *argv[])
{
    // Qt Charts uses Qt Graphics View Framework for drawing, therefore QApplication must be used.
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    app.setApplicationName("Kootwall");

    QFontDatabase::addApplicationFont(":/Content/font/materialdesignicons-webfont.ttf");

    //-- QSetting configuration --//
    QCoreApplication::setOrganizationName("MediaSoft");
    QCoreApplication::setOrganizationDomain("MediaSoft.com");
    QCoreApplication::setApplicationName("kootwall");

    QQuickView viewer;

    // The following are needed to make examples run without having to install the module
    // in desktop environments.
#ifdef Q_OS_WIN
    QString extraImportPath(QStringLiteral("%1/../../../../%2"));
#else
    QString extraImportPath(QStringLiteral("%1/../../../%2"));
#endif
    viewer.engine()->addImportPath(extraImportPath.arg(QGuiApplication::applicationDirPath(),
                                                       QString::fromLatin1("qml")));

    DataSource dataSource(&viewer);
    viewer.rootContext()->setContextProperty("dataSource", &dataSource);

    ImageUploader imageUploader;
    viewer.rootContext()->setContextProperty("imageUploader", &imageUploader);

    //-- material design configuration --//
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    qputenv("QT_QUICK_CONTROLS_STYLE", "material");

    viewer.engine()->addImportPath(":/imports");
    QObject::connect(viewer.engine(), &QQmlEngine::quit, &viewer, &QWindow::close);

    viewer.setTitle(QStringLiteral("Kootwall"));

    QQmlComponent component(viewer.engine());
    QQuickWindow::setDefaultAlphaBuffer(true);
    component.loadUrl(QUrl("qrc:/main.qml"));
    if ( component.isReady()) {
        component.create();
    }
    else{
        qWarning() << component.errorString();
    }

    //-- windows icon --//
    app.setWindowIcon(QIcon(":/Content/Images/logo_icon.png"));

    return app.exec();
}
