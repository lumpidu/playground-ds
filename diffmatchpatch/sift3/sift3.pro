#-------------------------------------------------
#
# Project created by QtCreator 2011-03-13T17:54:17
#
#-------------------------------------------------

QT       -= gui

TARGET = sift3
TEMPLATE = lib
CONFIG += staticlib

SOURCES += sift3.cpp

HEADERS += sift3.h
unix:!symbian {
    maemo5 {
        target.path = /opt/usr/lib
    } else {
        target.path = /usr/local/lib
    }
    INSTALLS += target
}
