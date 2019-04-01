#ifndef PROXY_HELPER_H
#define PROXY_HELPER_H

enum ProxyMode
{
    GLOBAL,
    PAC,
    OFF
};

int setProxy(const ProxyMode mode, const int socksPort = 0, const int httpPort = 0, const char* pacUrl = nullptr);

#endif // PROXY_HELPER_H
