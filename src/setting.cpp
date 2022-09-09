#include "setting.h"
#include <QSettings>
#include <QString>
#include <QDebug>
#include <QStandardPaths>

Setting::Setting(QObject *parent):
 QObject(parent)
{
}


QString Setting::getSystemSetting(QString name, QString defaultValue){
    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/AllstarSoftware/harbour-NightlyClockSailfish/settings.conf", QSettings::NativeFormat);
    return settings.value(name, defaultValue).toString();
}

void Setting::saveSystemSetting(QString name,QString data){
     QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/AllstarSoftware/harbour-NightlyClockSailfish/settings.conf", QSettings::NativeFormat);
     settings.setValue(name, data);
}

void Setting::dropSettings(){
    QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/AllstarSoftware/harbour-NightlyClockSailfish/settings.conf", QSettings::NativeFormat);
    settings.remove("");
}




