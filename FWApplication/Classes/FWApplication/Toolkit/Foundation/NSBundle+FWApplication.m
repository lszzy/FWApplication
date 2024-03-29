/**
 @header     NSBundle+FWApplication.m
 @indexgroup FWApplication
      NSBundle分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-09-17
 */

#import "NSBundle+FWApplication.h"
#import <objc/runtime.h>

@implementation NSBundle (FWApplication)

+ (void)fw_setGoogleMapsLanguage:(NSString *)language
{
    static NSString *customLanguage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleMethod(objc_getClass("GMSDASHClientDescription"), NSSelectorFromString(@"firstLanguage"), nil, FWSwizzleType(id), FWSwizzleReturn(id), FWSwizzleArgs(), FWSwizzleCode({
            id result = FWSwizzleOriginal();
            
            if (customLanguage) {
                return customLanguage;
            }
            
            return result;
        }));
    });
    
    customLanguage = language;
}

+ (void)fw_setGooglePlacesLanguage:(NSString *)language
{
    static NSString *customLanguage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleMethod(objc_getClass("GMSPabloClient"), NSSelectorFromString(@"URLComponentsForPath:sessionToken:"), nil, FWSwizzleType(id), FWSwizzleReturn(id), FWSwizzleArgs(id path, id token), FWSwizzleCode({
            id result = FWSwizzleOriginal(path, token);
            
            if (customLanguage && [result isKindOfClass:[NSURLComponents class]]) {
                NSURLComponents *components = (NSURLComponents *)result;
                NSMutableArray<NSURLQueryItem *> *queryItems = [components.queryItems mutableCopy];
                [queryItems addObject:[NSURLQueryItem queryItemWithName:@"language" value:customLanguage]];
                components.queryItems = queryItems;
            }
            
            return result;
        }));
    });
    
    customLanguage = language;
}

@end
