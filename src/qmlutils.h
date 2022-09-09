#ifndef QMLUTILS_H
#define QMLUTILS_H

#include <QtCore/QObject>
#include <QDesktopServices>
#include <QDir>
#include <QQmlContext>
#include <QQmlEngine>
#include <QtQml>
#include <QSysInfo>

class QClipboard;
class QDeclarativeItem;
class QDeclarativeView;

class QMLUtils : public QObject
{
    Q_OBJECT
public:
    explicit QMLUtils();
    Q_INVOKABLE static QString getOSVersion();
    Q_INVOKABLE void openURL(QString bob);
    Q_INVOKABLE void deleteFile(const QString file);
    Q_INVOKABLE int getFileSize(QString file);
    Q_INVOKABLE void outputFile(QString fileName);
    Q_INVOKABLE void contentsCheck(QString direc);
    Q_INVOKABLE QString homePath();
    Q_INVOKABLE QString tempPath();
    Q_INVOKABLE QString withoutExtensionn(const QString url);
    Q_INVOKABLE QString getExtension(const QString url);
    Q_INVOKABLE bool checkFileExists(QString path);
    Q_INVOKABLE void showBanner(QString title, QString text, int timeout);
    Q_INVOKABLE void restart() const;
    Q_INVOKABLE QString convertTime(QString time, QString timeFormat, QString convertFormatTo) const;
    Q_INVOKABLE void onOnlineStatusChanged(bool isOnline);
    Q_INVOKABLE QString subractTime(QString time, QString format);
    Q_INVOKABLE QString calcPreRadioBufferTime(QString time, QString format);
    Q_INVOKABLE QString returnArchitecture();
    Q_INVOKABLE void externalClockFaceIntCheck(QString fileURL);
    Q_INVOKABLE void findImagesInFolder(QString url, bool sub);
    Q_INVOKABLE void importPictureList(QString fileName);
    Q_INVOKABLE void generateImageList(QString name, QString value);
    Q_INVOKABLE void dirCheckOrCreate(QString path);
    Q_INVOKABLE void clockFaceValidationCheck(QString url);
    Q_INVOKABLE bool stringStartsWith(QString text, QString compare);
    Q_INVOKABLE QString getMimeType(QString path);
    Q_INVOKABLE bool dirCheck(QString path);
    Q_INVOKABLE bool removeDir(const QString & dirName);
    Q_INVOKABLE void startProcess(QString program);



Q_SIGNALS:
    void onlineStateChanged(bool isOnline);
    Q_INVOKABLE void onlineModeChanged(bool isOnline);
    Q_INVOKABLE void pictureImportItem(QString ico);
    Q_INVOKABLE void pictureImportFinished();
    Q_INVOKABLE void clockFaceRejected(QString message);
    Q_INVOKABLE void clockFaceAccepted();
    Q_INVOKABLE void finishedCheck(bool rejected, QString faceURL);
    Q_INVOKABLE void validationFileCount(int count);
    Q_INVOKABLE void validationCountUp();
    Q_INVOKABLE void missingVitalFile();
    Q_INVOKABLE void showBannerMessage(QString title, QString text,  int timeout);

private:

    QNetworkConfigurationManager* mConfig;


};

#endif // QMLUTILS_H
