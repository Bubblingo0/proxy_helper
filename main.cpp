
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "proxy_helper.h"
#include "helper_version.h"

void usage()
{
    printf("usage:\n");
    printf("proxy_helper global -socks 10xx -http 10xx \n");
    printf("proxy_helper pac \"https://xxx/xx.pac\" \n");
    printf("proxy_helper off \n");
    printf("proxy_helper version \n");
}

int main(int argc, const char * argv[]) {

    if(argc < 2){
        usage();
        return 0;
    }

    if(0 == strcasecmp("version", argv[1]))
    {
        printf(HELPER_VERSION);
        return 0;
    }
    else if (0 == strcasecmp("global", argv[1]))
    {
        int socksPort = 0;
        int httport = 0;
        if(argc >= 4)
        {
            if(0 == strcasecmp("-socks", argv[2]))
            {
                socksPort = atoi(argv[3]);
            }
            else if(0 == strcasecmp("-http", argv[2]))
            {
                httport = atoi(argv[3]);
            }
        }

        if(argc >= 6)
        {
            if(0 == strcasecmp("-socks", argv[4]))
            {
                socksPort = atoi(argv[5]);
            }
            else if(0 == strcasecmp("-http", argv[4]))
            {
                httport = atoi(argv[5]);
            }
        }

        setProxy(GLOBAL, socksPort, httport);
        printf("socksPort %d, httpPort %d \n", socksPort, httport);
        printf("set proxy to %s \n", argv[1]);
    }
    else if(0 == strcasecmp("pac", argv[1]))
    {
        if(argc < 3){
            usage();
            return 0;
        }

        setProxy(PAC, 0, 0, argv[2]);
        printf("set proxy to %s \n", argv[1]);
    }
    else if(0 == strcasecmp("off", argv[1]))
    {
        setProxy(OFF);
        printf("set proxy to %s \n", argv[1]);
    }
    else
    {
        usage();
    }

    return 0;
}
