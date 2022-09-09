#include "qmlutils.h"
#include <QtGui/QClipboard>
#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtGui/QDesktopServices>
#include <QDesktopServices>
#include <QProcess>
#include <QUrl>
#include <QDir>
#include <QFile>
#include <QQmlContext>
#include <QQmlEngine>
#include <QtQml>
#include <QtQuick>
#include <QStandardPaths>
#include <QSysInfo>
#include <QtMultimedia>
#include "setting.h"

int clockValidationChecked;

QMLUtils::QMLUtils()
{
    mConfig = new QNetworkConfigurationManager();
    bool res = QObject::connect(mConfig, SIGNAL(onlineStateChanged(bool)), this,
            SLOT(onOnlineStatusChanged(bool)));
    Q_ASSERT(res);
}


void QMLUtils::startProcess(QString program){
    QObject *parent;
    QStringList arguments;
    QProcess *myProcess = new QProcess(parent);
    myProcess->start(program, arguments);
}


bool QMLUtils::removeDir(const QString & dirName)
{
    bool result = true;
    QDir dir(dirName);
    if (dir.exists(dirName)) {
        Q_FOREACH(QFileInfo info, dir.entryInfoList(QDir::NoDotAndDotDot | QDir::System | QDir::Hidden | QDir::AllDirs | QDir::Files, QDir::DirsFirst)) {
            if (info.isDir()) {result = removeDir(info.absoluteFilePath()); }
            else { result = QFile::remove(info.absoluteFilePath()); }
            if (!result) { return result; }
        }
        result = dir.rmdir(dirName);
    }
    return result;
}

bool QMLUtils::dirCheck(QString path)
{
    QDir dir(path);
    if (dir.exists()) {
        return true;
    }
    else{
        return false;
    }
}

QString QMLUtils::getOSVersion(){
    QString str = QSysInfo::productVersion().remove(3, 8);return str;
}

QString QMLUtils::getMimeType(QString path){
        QMimeDatabase db;
        QMimeType type = db.mimeTypeForFile(path);
        qDebug() << "Mime type:" << type.name() << "url: " << path;
    return type.name();
}

bool QMLUtils::stringStartsWith(QString text, QString compare){
    if(text.startsWith(compare)){return true;}
    else{return false;}
}

void QMLUtils::clockFaceValidationCheck(QString url){
    QString cutUrl = url.mid(7,url.length());
    QDir source(cutUrl);
       if (!source.exists())
           return;
       QStringList files = source.entryList(QStringList() << "*.qml", QDir::Files);
      if(checkFileExists(cutUrl+"/face.qml")){
       emit validationFileCount(files.count());

    QStringList bob;
    bob << "*.qml" << "*.QML";
    QDirIterator it(cutUrl, bob, QDir::NoFilter, QDirIterator::Subdirectories);
    while (it.hasNext()) {
       it.next();
       emit validationCountUp();
       externalClockFaceIntCheck(it.filePath());
    }
    if (it.hasNext() == false) {
      // finished looking
    }
      }

      else{
          showBanner("Error Occurred", "face.qml is missing from style", 5000);
          emit missingVitalFile();
      }
}

void QMLUtils::externalClockFaceIntCheck(QString fileURL){
    Setting * setting = new Setting();

    if(setting->getSystemSetting("bcs", "") == "true")
    {
        finishedCheck(false, fileURL);
    }

    else {

    QString s1("main.");
    QString s2("import AppSettings 1.0");
    QString s3("import QMLUtils 1.0");
    QString s4("import org.nemomobile.systemsettings 1.0");
    QString s5("import QtPositioning");
    QString s6("import BingWallpaper 1.0");
    QString s7("import Nemo.KeepAlive 1.2");
    QString s8("import DownloadManager 1.0");
    QString s10 ("alarmServer.");
    QString s11 ("downloadManager.");
    QString s12 ("positioning.");
    QString s13 ("appsettings.saveSystemSetting");
    QString s14 ("appsettings.dropSettings");
    QString s15 ("import Updater 1.0");
    QString s16 ("XMLHttpRequest");
    QString s17 ("DBusInterface");
    QString s18 ("qmlUtils.");

    QFile MyFile(fileURL);
    MyFile.open(QIODevice::ReadWrite);
    QTextStream in (&MyFile);
    bool rejected = false;
    QString line;
    do {
        line = in.readLine();
       // qDebug() << line;
        if (line.contains(s1, Qt::CaseInsensitive)) {
         emit clockFaceRejected(s1);
            rejected = true;
        }

      else if (line.contains(s2, Qt::CaseInsensitive)) {
         emit clockFaceRejected(s2);
            rejected = true;
        }

        else if (line.contains(s3, Qt::CaseInsensitive)) {
         emit clockFaceRejected(s3);
            rejected = true;
        }

     else if (line.contains(s4, Qt::CaseInsensitive)) {
         emit clockFaceRejected(s4);
            rejected = true;
        }

    else if (line.contains(s5, Qt::CaseInsensitive)) {
         emit clockFaceRejected(s5);
            rejected = true;
        }

      else if (line.contains(s6, Qt::CaseInsensitive)) {
         emit clockFaceRejected(s6);
            rejected = true;
        }

        else if (line.contains(s7, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s7);
              rejected = true;
          }

        else if (line.contains(s8, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s8);
              rejected = true;
          }

        else if (line.contains(s10, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s10);
              rejected = true;
          }

        else if (line.contains(s11, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s11);
              rejected = true;
          }

        else if (line.contains(s12, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s12);
              rejected = true;
          }

        else if (line.contains(s13, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s13);
              rejected = true;
          }

        else if (line.contains(s14, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s14);
              rejected = true;
          }

        else if (line.contains(s15, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s15);
              rejected = true;
          }

        else if (line.contains(s16, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s16);
              rejected = true;
          }

        else if (line.contains(s17, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s17);
              rejected = true;
          }

        else if (line.contains(s18, Qt::CaseInsensitive)) {
           emit clockFaceRejected(s18);
              rejected = true;
          }

        if(in.atEnd()){
            emit finishedCheck(rejected, fileURL);
           // clockValidationChecked=0;
        }

    } while (!line.isNull());

    }
}

void QMLUtils::dirCheckOrCreate(QString path)
{
    QDir dir(path);
    if (!dir.exists()) {
        dir.mkpath(path);
    }
}

void QMLUtils::importPictureList(QString fileName)
{
qDebug() << fileName;
    QFile inputFile(fileName);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            QString line = in.readLine();
            qDebug() << "Output: " << line;
                  emit pictureImportItem(line);
                  line="";
        }

               inputFile.close();
                emit pictureImportFinished();
                qDebug() << "Finished";
    }

}

void QMLUtils::generateImageList(QString name, QString value){
QString newName = name;
QFile file(newName);
qDebug() << "List Name: " << newName;
  if (!file.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text))
return;
  QTextStream out(&file);
 out <<  value  << endl;

  file.close();
  file.deleteLater();
}

void QMLUtils::findImagesInFolder(QString url, bool sub){
    QStringList bob;
    bob << "*.png" << "*.PNG" << "*.jpg" << "*.JPG" << "*.jpeg" << "*.JPEG" << "*.bmp" << "*.BMP" << "*.gif" << "*.GIF" << "*.pbm" <<"*.PBM";
    QDirIterator it(url, bob, QDir::NoFilter,
             sub ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags);


    while (it.hasNext()) {
        it.next();
        qDebug() << it.filePath();
        emit pictureImportItem("file:///"+it.filePath());
        bob.clear();

    }

    if (it.hasNext() == false) {
        bob.clear();
       // delete play;
        emit pictureImportFinished();
        qDebug() << "Finished";

    }
}

QString QMLUtils::returnArchitecture(){
    return QSysInfo::buildCpuArchitecture();
}

void QMLUtils::showBanner(QString title, QString text, int timeout) {
    showBannerMessage(title, text, timeout);
}

QString QMLUtils::getExtension(const QString url){

    QFileInfo fi(url);
   return "."+fi.suffix();
}

QString QMLUtils::withoutExtensionn(const QString url){
    QString filename(url);
    return filename.left(filename.lastIndexOf("."));
    }

QString QMLUtils::subractTime(QString time, QString format){
    QTime alarmtime = QTime::fromString(time, format);
    QTime before = alarmtime.addSecs(-15 * 60);
    qDebug() << before;
    return before.toString(format);
}

QString QMLUtils::calcPreRadioBufferTime(QString time, QString format){
    QTime alarmtime = QTime::fromString(time, format);
    QTime before = alarmtime.addSecs(-0.09 * 60);
    qDebug() << before;
    return before.toString(format);


}
void QMLUtils::onOnlineStatusChanged(bool isOnline)
{
QString onlineStatus = isOnline ? "Online" : "Offline";
qDebug() << onlineStatus;
emit onlineModeChanged(isOnline);
}

void QMLUtils::outputFile(QString fileName)
{

    QFile inputFile(fileName);
    if (inputFile.open(QIODevice::ReadOnly)) {
        QTextStream in(&inputFile);
        while (!in.atEnd()) {
            QString line = in.readLine();
            qDebug() << "Output: " << line;

        }
        inputFile.close();

    }

}
void QMLUtils::contentsCheck(QString direc)
{
    QDir dir(direc);

    QFileInfoList files = dir.entryInfoList();
foreach (QFileInfo file, files) {
    if (file.isDir()) {
        qDebug() << "DIR: " << file.fileName();
    } else {
        qDebug() << "FILE: " << file.fileName();
    }
}

}

int QMLUtils::getFileSize(QString file)
{
int size = 0;
QFile myFile(file);
if (myFile.open(QIODevice::ReadOnly)) {
size = myFile.size(); //when file does open.
myFile.close();
return size;
}
else return 0;
}

void QMLUtils::openURL(QString bob){

    QDesktopServices::openUrl(bob);
}

QString QMLUtils::homePath()
{

return QDir::homePath();

}

QString QMLUtils::tempPath()
{

return QDir::tempPath();

}

void QMLUtils::restart() const
{
         QProcess::startDetached(QGuiApplication::applicationFilePath());
    exit(12);
}

QString QMLUtils::convertTime(QString time, QString timeFormat, QString convertFormatTo) const{
    QString strValue = time;
    QString format = timeFormat;
    QDateTime dt = QDateTime::fromString (strValue, format);

    //qDebug() << dt;
   // qDebug() << dt.toString();
    qDebug() << dt.toString(convertFormatTo);
   // qDebug() << dt.toString("h:mm a");
    return dt.toString(convertFormatTo);
}

void QMLUtils::deleteFile(const QString file)
{
QFile filer(file);

if (!filer.open(QIODevice::ReadWrite)) {
qDebug() << "couldn't open file ReadWrite";
// return false;
} else {
filer.remove(file);
qDebug() << "Removed";

}
}

bool QMLUtils::checkFileExists(QString path)
{
    QFileInfo checkFile(path);
    if (checkFile.exists() && checkFile.isFile()) {
        return true;
    } else {
        return false;
    }
}
