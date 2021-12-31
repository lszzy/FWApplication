/**
 @header     UIDevice+FWApplication.m
 @indexgroup FWApplication
      UIDevice+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "UIDevice+FWApplication.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <net/if.h>
@import FWFramework;

static NSString *fwStaticDeviceUUID = nil;

@implementation UIDevice (FWApplication)

#pragma mark - UUID

+ (NSString *)fwDeviceUUID
{
    if (!fwStaticDeviceUUID) {
        @synchronized ([self class]) {
            NSString *deviceUUID = [[FWKeychainManager sharedInstance] passwordForService:@"FWDeviceUUID" account:NSBundle.mainBundle.bundleIdentifier];
            if (deviceUUID.length > 0) {
                fwStaticDeviceUUID = deviceUUID;
            } else {
                deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                if (deviceUUID.length < 1) {
                    deviceUUID = [[NSUUID UUID] UUIDString];
                }
                [self setFwDeviceUUID:deviceUUID];
            }
        }
    }
    
    return fwStaticDeviceUUID;
}

+ (void)setFwDeviceUUID:(NSString *)fwDeviceUUID
{
    fwStaticDeviceUUID = fwDeviceUUID;
    
    [[FWKeychainManager sharedInstance] setPassword:fwDeviceUUID forService:@"FWDeviceUUID" account:NSBundle.mainBundle.bundleIdentifier];
}

#pragma mark - Jailbroken

+ (BOOL)fwIsJailbroken
{
#if TARGET_OS_SIMULATOR
    return NO;
#else
    // 1
    NSArray *paths = @[@"/Applications/Cydia.app",
                       @"/private/var/lib/apt/",
                       @"/private/var/lib/cydia",
                       @"/private/var/stash"];
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
    
    // 2
    FILE *bash = fopen("/bin/bash", "r");
    if (bash != NULL) {
        fclose(bash);
        return YES;
    }
    
    // 3
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uuidString = (__bridge_transfer NSString *)string;
    NSString *path = [NSString stringWithFormat:@"/private/%@", uuidString];
    if ([@"test" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return YES;
    }
    
    return NO;
#endif
}

#pragma mark - Network

+ (NSString *)fwIpAddress
{
    NSString *ipAddr = nil;
    struct ifaddrs *addrs = NULL;
    
    int ret = getifaddrs(&addrs);
    if (0 == ret) {
        const struct ifaddrs * cursor = addrs;
        
        while (cursor) {
            if (AF_INET == cursor->ifa_addr->sa_family && 0 == (cursor->ifa_flags & IFF_LOOPBACK)) {
                ipAddr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
                break;
            }
            
            cursor = cursor->ifa_next;
        }
        
        freeifaddrs(addrs);
    }
    
    return ipAddr;
}

+ (NSString *)fwHostName
{
    char hostName[256];
    int success = gethostname(hostName, 255);
    if (success != 0) return nil;
    hostName[255] = '\0';
    
#if TARGET_OS_SIMULATOR
    return [NSString stringWithFormat:@"%s", hostName];
#else
    return [NSString stringWithFormat:@"%s.local", hostName];
#endif
}

+ (CTTelephonyNetworkInfo *)fwNetworkInfo
{
    static CTTelephonyNetworkInfo *networkInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    });
    return networkInfo;
}

+ (NSString *)fwCarrierName
{
    return [self fwNetworkInfo].subscriberCellularProvider.carrierName;
}

+ (NSString *)fwNetworkType
{
    NSString *networkType = nil;
    NSString *accessTechnology = [self fwNetworkInfo].currentRadioAccessTechnology;
    if (!accessTechnology) return networkType;
    
    NSArray *types2G = @[CTRadioAccessTechnologyGPRS,
                         CTRadioAccessTechnologyEdge,
                         CTRadioAccessTechnologyCDMA1x];
    NSArray *types3G = @[CTRadioAccessTechnologyWCDMA,
                         CTRadioAccessTechnologyHSDPA,
                         CTRadioAccessTechnologyHSUPA,
                         CTRadioAccessTechnologyCDMAEVDORev0,
                         CTRadioAccessTechnologyCDMAEVDORevA,
                         CTRadioAccessTechnologyCDMAEVDORevB,
                         CTRadioAccessTechnologyeHRPD];
    NSArray *types4G = @[CTRadioAccessTechnologyLTE];
    NSArray *types5G = nil;
    if (@available(iOS 14.1, *)) {
        types5G = @[CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR];
    }
    
    if ([types5G containsObject:accessTechnology]) {
        networkType = @"5G";
    } else if ([types4G containsObject:accessTechnology]) {
        networkType = @"4G";
    } else if ([types3G containsObject:accessTechnology]) {
        networkType = @"3G";
    } else if ([types2G containsObject:accessTechnology]) {
        networkType = @"2G";
    }
    return networkType;
}

@end
