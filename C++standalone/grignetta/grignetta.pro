QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    main.cpp \
    grignetta.cpp

HEADERS += \
    declipper.h \
    grignetta.h

FORMS += \
    grignetta.ui

TRANSLATIONS += \
    grignetta_it_IT.ts

#AudioFile library
INCLUDEPATH += D:\marco\Documents\librerieC++\AudioFile
#Eigen library
INCLUDEPATH += D:\marco\Documents\librerieC++\eigen-3.3.9

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
