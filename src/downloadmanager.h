#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QFile>


class DownloadManager : public QObject
{
    Q_OBJECT
public:
    explicit DownloadManager(QObject *parent = 0);

signals:
    Q_INVOKABLE void downloadComplete();
    Q_INVOKABLE void progressPercentage( int percentage);
    Q_INVOKABLE void downloadStatus(float currentStatus);
    Q_INVOKABLE void downloadStarted();
    Q_INVOKABLE void downloadPaused();
    Q_INVOKABLE void downloadResumed();
    Q_INVOKABLE void downloadedBytes(qint64 bytesReceived);
    Q_INVOKABLE void downloadCancelled();
    Q_INVOKABLE void downloadError(QNetworkReply::NetworkError code);
    Q_INVOKABLE void internalDownloadError();



public slots:

     Q_INVOKABLE void cancel();
     Q_INVOKABLE void download(QUrl url, QString fileName);
     Q_INVOKABLE void pause();
     Q_INVOKABLE void resume();
     Q_INVOKABLE void finished();


private slots:


     void download( QNetworkRequest& request );
     Q_INVOKABLE void downloadProgress ( qint64 bytesReceived, qint64 bytesTotal );
     Q_INVOKABLE void error ( QNetworkReply::NetworkError code );


private:

    QNetworkAccessManager* mManager;
    QNetworkRequest mCurrentRequest;
    QNetworkReply* mCurrentReply;
    QFile* mFile;
    int mDownloadSizeAtPause;
    QString defaultFileName;
    QString fileName;

};

#endif // DOWNLOADMANAGER_H
