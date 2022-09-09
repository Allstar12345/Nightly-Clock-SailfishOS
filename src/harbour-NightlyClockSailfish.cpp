#include <QtQuick>
#include <sailfishapp.h>
#include "setting.h"
#include <QQmlContext>
#include <QQmlEngine>
#include <QtQml>
#include <QFile>
#include <QTextStream>
#include "displayblanking.h"
#include <QTimer>
#include "qmlutils.h"
#include "weatherapi.h"
#include "bingwallpaper.h"
#include "downloadmanager.h"
#include "updater.h"
#include <QObject>


 DisplayBlanking *displayBlanking;
 QString minimumOS = "4.0";
 QTextStream *out = 0;

void logOutput(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QByteArray localMsg = msg.toLocal8Bit();
    QString debugdate = QDateTime::currentDateTime().toString("yyyy.MM.dd hh:mm:ss");

    switch (type) {
    case QtDebugMsg:
        fprintf(stderr, "Debug: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtInfoMsg:
        fprintf(stderr, "Info: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtWarningMsg:
        fprintf(stderr, "Warning: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtCriticalMsg:
        fprintf(stderr, "Critical: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    case QtFatalMsg:
        fprintf(stderr, "Fatal: %s (%s:%u, %s)\n", localMsg.constData(), context.file, context.line, context.function);
        break;
    }
     QFile outFile(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)+ "/debug.txt");
     outFile.open(QIODevice::WriteOnly | QIODevice::Append);
     QTextStream ts(&outFile);
     ts  << debugdate << "\n" <<  "\n"  <<localMsg << endl;

}


int main(int argc, char *argv[])
{  

    QGuiApplication *app = SailfishApp::application(argc, argv);
    Setting* set = new Setting;

    if(set->getSystemSetting("logToFile", "") == "true"){
        qInstallMessageHandler(logOutput);
    }

    displayBlanking = new DisplayBlanking();
    displayBlanking->setPreventBlanking(true);
    app->setApplicationVersion(QString(APP_VERSION));
    QQuickView *view = SailfishApp::createView();
    QCoreApplication::setOrganizationName(QStringLiteral("AllstarSoftware"));
    QCoreApplication::setApplicationName(QStringLiteral("harbour-NightlyClockSailfish"));
    qmlRegisterType<Setting> ("AppSettings", 1, 0, "AppSettings");
    qmlRegisterType<QMLUtils> ("QMLUtils", 1, 0, "QMLUtils");
    qmlRegisterType<WeatherAPI>("WeatherAPI", 1, 0, "WeatherAPI");
    qmlRegisterType<BingWallpaper>("BingWallpaper", 1, 0, "BingWallpaper");
    qmlRegisterType<DownloadManager>("DownloadManager", 1, 0, "DownloadManager");
    qmlRegisterType<Updater>("Updater", 1, 0, "Updater");

    if(QMLUtils::getOSVersion()<minimumOS){
        view->setSource(SailfishApp::pathTo("qml/UnsupportedOS.qml"));
    }

    else{
    view->setSource(SailfishApp::pathTo("qml/harbour-NightlyClockSailfish.qml"));
    }

    view->showFullScreen();
    return app->exec();
}

QString homePath(){
    return QDir::homePath();
}
