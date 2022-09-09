TARGET = harbour-NightlyClockSailfish

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

#CONFIG(release, debug|release):DEFINES += QT_NO_DEBUG_OUTPUT \
#QT_NO_WARNING_OUTPUT


#CONFIG += sailfishapp_no_deploy_qml

CONFIG += link_pkgconfig sailfishapp
PKGCONFIG += keepalive

QT        += dbus
PKGCONFIG += mlite5
#PKGCONFIG += nemonotifications-qt5
QT += multimedia
QT += core gui quick qml network
QT += location
QT+= svg
CONFIG+= NO_SSL

SOURCES += src/harbour-NightlyClockSailfish.cpp \
    src/customnetworkaccessfactory.cpp \
    src/setting.cpp \
    src/qmlutils.cpp \
    src/weatherapi.cpp \
    src/bingwallpaper.cpp \
    src/downloadmanager.cpp \
    src/updater.cpp

OTHER_FILES += \
    rpm/harbour-NightlyClockSailfish.spec \
    harbour-NightlyClockSailfish.desktop\
    qml/cover/CoverPage.qml \
    qml/MainPage.qml \
    qml/images/alarm_pulldown.png \
    qml/images/ic_info.png \
    qml/images/ic_pause.png \
    qml/images/ic_play.png \
    qml/images/ic_share.png \
    qml/images/icon.svg\
    qml/images/intervalTriggerImage.svg \
    qml/images/cloud.svg\
    qml/sounds/1.aac \
    qml/sounds/2.aac \
    qml/sounds/3.aac \
    qml/sounds/4.mp3 \
    qml/sounds/5.mp3 \
    qml/AlarmBellIcon.qml \
    qml/AlarmServer.qml \
    qml/pages/AboutApp.qml \
    qml/pages/AlarmTriggerPage.qml \
    qml/pages/AlarmSettings.qml \
    qml/pages/SetAlarmTime.qml \
    qml/pages/FirstRun.qml \
    qml/pages/FirstRun/FirstRun.qml \
    qml/pages/FirstRun/Step2.qml \
    qml/SnoozeOnOffDialog.qml \
    qml/IntervalAlarmPopup.qml \
    qml/ResetAppPopup.qml




CONFIG += sailfishapp_i18n
CONFIG += QtDocGallery





HEADERS += \
    src/customnetworkaccessfactory.h \
    src/setting.h \
    src/displayblanking.h \
    src/qmlutils.h \
    src/weatherapi.h \
    src/bingwallpaper.h \
    src/downloadmanager.h \
    src/updater.h

RESOURCES +=

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

DISTFILES += \
    qml/AlarmTimeFavourites.js \
    qml/ClockFacePickerTutorial.qml \
    qml/ClockItem.qml \
    qml/ComboBoxer.qml \
    qml/CustomTabButton.qml \
    qml/CustomTabButtonRow.qml \
    qml/CustomTabView.qml \
    qml/CustomTimePicker.qml \
    qml/MediaControls.qml \
    qml/MediaControlsLegacy.qml \
    qml/NoWhiteNoisesDialog.qml \
    qml/SoundListItem.qml \
    qml/TestFace.qml \
    qml/UnsupportedOS.qml \
    qml/Utils.js \
    qml/Wallpaper.qml \
    qml/WallpaperPickerTutorial.qml \
    qml/WallpaperSlideshow.js \
    qml/clockfacepickeritems/AnalogBasic.qml \
    qml/clockfacepickeritems/AnalogDefault.qml \
    qml/clockfacepickeritems/AnalogDefaultDateWindow.qml \
    qml/clockfacepickeritems/AnalogPrecision.qml \
    qml/clockfacepickeritems/AnalogRailway.qml \
    qml/clockfacepickeritems/AnalogScientific.qml \
    qml/clockfacepickeritems/AnalogTactical.qml \
    qml/clockfacepickeritems/DigitalClock.qml \
    qml/clockfacepickeritems/ExternalClockFacePicker.qml \
    qml/clockfacepickeritems/ExternalClockFacePickerLargeScreen.qml \
    qml/clockfacepickeritems/Greenium.qml \
    qml/clockfacepickeritems/GreeniumColour.qml \
    qml/clockfacepickeritems/GreeniumNoSeconds.qml \
    qml/clockfacepickeritems/GreeniumNoSecondsColour.qml \
    qml/clockfacepickeritems/Prominent.qml \
    qml/clockfacepickeritems/ProminentColour.qml \
    qml/clockfaces/AnalogBasic.qml \
    qml/clockfaces/AnalogDefault.qml \
    qml/clockfaces/AnalogDefaultDateWindow.qml \
    qml/clockfaces/AnalogRailway.qml \
    qml/clockfaces/AnalogScientific.qml \
    qml/clockfaces/AnalogTactical.qml \
    qml/clockfaces/BoldHour.qml \
    qml/clockfaces/Greenium.qml \
    qml/clockfaces/GreeniumColour.qml \
    qml/clockfaces/GreeniumNoSeconds.qml \
    qml/clockfaces/GreeniumNoSecondsColour.qml \
    qml/clockfaces/HourArc.qml \
    qml/clockfaces/Prominent.qml \
    qml/clockfaces/ProminentColour.qml \
    qml/pages/AlarmSoundsPicker.qml \
    qml/pages/AlarmTimeFavourites.qml \
    qml/pages/BypassFaceCheck.qml \
    qml/pages/ClockFacePicker.qml \
    qml/pages/ClockFacePickerTablet.qml \
    qml/pages/CustomClockFaceManager.qml \
    qml/pages/CustomiseSettings.qml \
    qml/pages/FirstRun/Step3.qml \
    qml/pages/FirstRun/Step4.qml \
    qml/pages/FolderPicker.qml \
    qml/pages/PermissionsExplainedPage.qml \
    qml/pages/SettingsBasePage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/SlideShowWallpaperSettings.qml \
    qml/pages/WallpaperPicker.qml \
    qml/pages/WallpaperSlideshowManager.qml \
    qml/pages/WeatherSettings.qml \
    qml/pages/WhiteNoiseSettings.qml \
    qml/pages/WhiteNoiseSoundSettings.qml \
    qml/wallpaperpickeritems/SlideShow.qml

