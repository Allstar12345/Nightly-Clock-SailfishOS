#ifndef Updater_H
#define Updater_H

#include <QObject>
#include <QNetworkReply>

class UpdaterPrivate;

class Updater : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
public:
    Updater(QObject *parent = 0);
    ~Updater();

    QString url() const;
    void setUrl(const QString &xUrl);

public slots:
    void checkForUpdates();

signals:
    void urlChanged();
    void resultFinished(const QJsonObject &xResult);
    void errorChecking();

private slots:
    void replyFinished(QNetworkReply *xNetworkReply);

private:
    UpdaterPrivate *m;
};

#endif // Updater_H
