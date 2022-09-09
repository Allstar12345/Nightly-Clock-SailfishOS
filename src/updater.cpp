#include "updater.h"
#include <QNetworkAccessManager>
#include <QJsonObject>
#include <QJsonDocument>

class UpdaterPrivate
{
    public:
        QString mUrl = "https://allstarsoftware.co.uk/NightlyClockSailfish/Updates/checker.json";
        QNetworkAccessManager *mNetworkAccessManager;
};

Updater::Updater(QObject *parent) : QObject(parent)
{
    m = new UpdaterPrivate;
    m->mNetworkAccessManager = new QNetworkAccessManager(this);
    connect(m->mNetworkAccessManager, &QNetworkAccessManager::finished, this, &Updater::replyFinished);
}

Updater::~Updater()
{
    delete m;
}

QString Updater::url() const
{
    return m->mUrl;
}

void Updater::setUrl(const QString &xUrl)
{
    if(m->mUrl != xUrl)
    {
        m->mUrl = xUrl;
        emit urlChanged();
    }
}

void Updater::checkForUpdates()
{
    m->mNetworkAccessManager->get(QNetworkRequest(QUrl(m->mUrl)));
}

void Updater::replyFinished(QNetworkReply *xNetworkReply)
{
    if(xNetworkReply->error() == QNetworkReply::NoError)
    {
        QJsonObject tJsonObject = QJsonDocument::fromJson(xNetworkReply->readAll()).object();
        emit resultFinished(tJsonObject);
    }

    else{
        emit errorChecking();
    }

    delete xNetworkReply;
}
