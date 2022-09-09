#include "bingwallpaper.h"
#include <QNetworkAccessManager>
#include <QJsonObject>
#include <QJsonDocument>

class BingWallpaperPrivate
{
    public:
        QString mUrl;
        QNetworkAccessManager *mNetworkAccessManager;
};

BingWallpaper::BingWallpaper(QObject *parent) : QObject(parent)
{
    m = new BingWallpaperPrivate;
    m->mNetworkAccessManager = new QNetworkAccessManager(this);
    connect(m->mNetworkAccessManager, &QNetworkAccessManager::finished, this, &BingWallpaper::replyFinished);
}

BingWallpaper::~BingWallpaper()
{
    delete m;
}

QString BingWallpaper::url() const
{
    return m->mUrl;
}

void BingWallpaper::setUrl(const QString &xUrl)
{
    if(m->mUrl != xUrl)
    {
        m->mUrl = xUrl;
        emit urlChanged();
    }
}

void BingWallpaper::requestWallpaper(const QString &xSearchString)
{
    m->mNetworkAccessManager->get(QNetworkRequest(QUrl(m->mUrl + xSearchString)));
}

void BingWallpaper::replyFinished(QNetworkReply *xNetworkReply)
{
    if(xNetworkReply->error() == QNetworkReply::NoError)
    {
        QJsonObject tJsonObject = QJsonDocument::fromJson(xNetworkReply->readAll()).object();
        emit resultFinished(tJsonObject);
    }
    delete xNetworkReply;
}
