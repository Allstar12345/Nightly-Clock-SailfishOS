#ifndef WEATHERAPI_H
#define WEATHERAPI_H

#include <QObject>
#include <QNetworkReply>

class WeatherAPIPrivate;

class WeatherAPI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString url READ url WRITE setUrl NOTIFY urlChanged)
public:
    WeatherAPI(QObject *parent = 0);
    ~WeatherAPI();

    QString url() const;
    void setUrl(const QString &xUrl);

public slots:
    void requestWeather(const QString &xSearchString);

signals:
    void urlChanged();
    void resultFinished(const QJsonObject &xResult);

private slots:
    void replyFinished(QNetworkReply *xNetworkReply);

private:
    WeatherAPIPrivate *m;
};

#endif // WEATHERAPI_H
