TEMPLATE = app
CONFIG += console c++11
CONFIG -= app_bundle
CONFIG -= qt
QMAKE_CXXFLAGS += -fobjc-arc
QMAKE_LFLAGS_RPATH=
QMAKE_LFLAGS += -framework Cocoa -framework Security -framework SystemConfiguration

SOURCES += \
        main.cpp \
        proxy_helper.mm


HEADERS += \
    helper_version.h \
    proxy_helper.h
