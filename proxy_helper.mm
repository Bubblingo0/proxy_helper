
//ref
//https://raw.githubusercontent.com/qinyuhang/ShadowsocksX-NG-R/master/proxy_conf_helper/main.m
//https://github.com/zxzerster/zxzerster.github.io/blob/3ea047f875febe3b5b26dcc6b1239d1481983a57/_posts/2018-02-13-How-to-Set-Proxy-Programmatically.md

#include "proxy_helper.h"
#include <Foundation/Foundation.h>
#include <SystemConfiguration/SystemConfiguration.h>
#include <SystemConfiguration/SCPreferences.h>

int setProxy(const ProxyMode mode, const int socksPort, const int httpPort, const char* pacUrl)
{
    static AuthorizationRef authRef;
    static AuthorizationFlags authFlags;
    authFlags = kAuthorizationFlagDefaults
    | kAuthorizationFlagExtendRights
    | kAuthorizationFlagInteractionAllowed
    | kAuthorizationFlagPreAuthorize;
    OSStatus authErr = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment, authFlags, &authRef);
    if (authErr != noErr) {
        authRef = nil;
        //NSLog(@"Error when create authorization");
        return 1;
    }

    if (authRef == nil) {
        //NSLog(@"No authorization has been granted to modify network configuration");
        return 1;
    }
        
    SCPreferencesRef prefRef = SCPreferencesCreateWithAuthorization(nil, CFSTR("Trojan"), nil, authRef);

    NSDictionary *sets = (__bridge NSDictionary *)SCPreferencesGetValue(prefRef, kSCPrefNetworkServices);

    NSMutableDictionary *proxies = [[NSMutableDictionary alloc] init];
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPEnable];
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesHTTPSEnable];
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
    [proxies setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCFNetworkProxiesSOCKSEnable];
    [proxies setObject:@[] forKey:(NSString *)kCFNetworkProxiesExceptionsList];

    // 遍历系统中的网络设备列表，设置 AirPort 和 Ethernet 的代理
    for (NSString *key in [sets allKeys]) {
        NSMutableDictionary *dict = [sets objectForKey:key];
        NSString *hardware = [dict valueForKeyPath:@"Interface.Hardware"];

        //printf("key %s - %s \n", [key UTF8String], [hardware UTF8String]);

        if ([hardware isEqualToString:@"AirPort"] ||
                [hardware isEqualToString:@"Wi-Fi"] ||
                [hardware isEqualToString:@"Ethernet"]) {
            NSString* prefPath = [NSString stringWithFormat:@"/%@/%@/%@", kSCPrefNetworkServices, key, kSCEntNetProxies];

            if (PAC == mode) {
                if(pacUrl != nullptr)
                {
                    NSString* url = [NSString stringWithCString:pacUrl encoding:NSUTF8StringEncoding];

                    [proxies setObject:url forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigURLString];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCFNetworkProxiesProxyAutoConfigEnable];
                    SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)prefPath, (__bridge CFDictionaryRef)proxies);
                }

            } else if (GLOBAL == mode) {
                if (socksPort > 0) {
                    [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesSOCKSProxy];
                    [proxies setObject:[NSNumber numberWithInt:socksPort] forKey:(NSString*)kCFNetworkProxiesSOCKSPort];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString*)kCFNetworkProxiesSOCKSEnable];
                    [proxies setObject:@[@"127.0.0.1", @"localhost", @"192.168/16", @"10.0/16"] forKey:(NSString *)kCFNetworkProxiesExceptionsList];
                }

                //http & https proxy
                if (httpPort > 0) {
                    [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesHTTPProxy];
                    [proxies setObject:[NSNumber numberWithInteger:httpPort] forKey:(NSString*)kCFNetworkProxiesHTTPPort];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString*) kCFNetworkProxiesHTTPEnable];

                    [proxies setObject:@"127.0.0.1" forKey:(NSString *)kCFNetworkProxiesHTTPSProxy];
                    [proxies setObject:[NSNumber numberWithInteger:httpPort] forKey:(NSString*)kCFNetworkProxiesHTTPSPort];
                    [proxies setObject:[NSNumber numberWithInt:1] forKey:(NSString*)kCFNetworkProxiesHTTPSEnable];
                }

                SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)prefPath, (__bridge CFDictionaryRef)proxies);
            }
            else if (OFF == mode) {
                SCPreferencesPathSetValue(prefRef, (__bridge CFStringRef)prefPath, (__bridge CFDictionaryRef)proxies);
            }
        }
    }

    SCPreferencesCommitChanges(prefRef);
    SCPreferencesApplyChanges(prefRef);
    SCPreferencesSynchronize(prefRef);

    AuthorizationFree(authRef, kAuthorizationFlagDefaults);

    return 0;
}
