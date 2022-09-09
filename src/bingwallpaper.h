#ifndef BingWallpaper_H
#define BingWallpaper_H

#include <QObject>
#include <QNetworkReply>

class BingWallpaperPrivate;

class BingWallpaper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
public:
    BingWallpaper(QObject *parent = 0);
    ~BingWallpaper();

    QString url() const;
    void setUrl(const QString &xUrl);

public slots:
    void requestWallpaper(const QString &xSearchString);

signals:
    void urlChanged();
    void resultFinished(const QJsonObject &xResult);

private slots:
    void replyFinished(QNetworkReply *xNetworkReply);

private:
    BingWallpaperPrivate *m;
};

#endif // BingWallpaper_H
