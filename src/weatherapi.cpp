#include "weatherapi.h"

#include <QNetworkAccessManager>
#include <QJsonObject>
#include <QJsonDocument>

class WeatherAPIPrivate
{
    public:
        QString mUrl;
        QNetworkAccessManager *mNetworkAccessManager;
};

WeatherAPI::WeatherAPI(QObject *parent) : QObject(parent)
{
    m = new WeatherAPIPrivate;
    m->mNetworkAccessManager = new QNetworkAccessManager(this);
    connect(m->mNetworkAccessManager, &QNetworkAccessManager::finished, this, &WeatherAPI::replyFinished);
}

WeatherAPI::~WeatherAPI()
{
    delete m;
}

QString WeatherAPI::url() const
{
    return m->mUrl;
}

void WeatherAPI::setUrl(const QString &xUrl)
{
    if(m->mUrl != xUrl)
    {
        m->mUrl = xUrl;
        emit urlChanged();
    }
}

void WeatherAPI::requestWeather(const QString &xSearchString)
{
    m->mNetworkAccessManager->get(QNetworkRequest(QUrl(m->mUrl + xSearchString + "&APPID=73f034b126d0a3ac5cf7c373862e8058")));
}

void WeatherAPI::replyFinished(QNetworkReply *xNetworkReply)
{
    if(xNetworkReply->error() == QNetworkReply::NoError)
    {
        QJsonObject tJsonObject = QJsonDocument::fromJson(xNetworkReply->readAll()).object();
        emit resultFinished(tJsonObject);
    }
    delete xNetworkReply;
}
