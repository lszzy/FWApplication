/**
 @header     NSURL+FWApplication.m
 @indexgroup FWApplication
      NSURL+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/12/3
 */

#import "NSURL+FWApplication.h"
#import "NSString+FWApplication.h"

@implementation FWURLClassWrapper (FWApplication)

#pragma mark - Map

- (NSURL *)mapsURLWithString:(NSString *)string params:(NSDictionary *)params
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:string];
    [urlString appendString:@"?"];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *valueStr = [[[NSString stringWithFormat:@"%@", value] stringByReplacingOccurrencesOfString:@" " withString:@"+"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [urlString appendFormat:@"%@=%@&", key, valueStr];
    }];
    return [NSURL URLWithString:[urlString substringToIndex:urlString.length - 1]];
}

- (NSURL *)appleMapsURLWithAddr:(NSString *)addr options:(NSDictionary *)options
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:options];
    if (addr.length > 0) {
        [params setObject:addr forKey:@"q"];
    }
    return [self mapsURLWithString:@"http://maps.apple.com/" params:params];
}

- (NSURL *)appleMapsURLWithSaddr:(NSString *)saddr daddr:(NSString *)daddr options:(NSDictionary *)options
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:options];
    if (saddr.length > 0) {
        [params setObject:saddr forKey:@"saddr"];
    }
    if (daddr.length > 0) {
        [params setObject:daddr forKey:@"daddr"];
    }
    return [self mapsURLWithString:@"http://maps.apple.com/" params:params];
}

- (NSURL *)googleMapsURLWithAddr:(NSString *)addr options:(NSDictionary *)options
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:options];
    if (addr.length > 0) {
        [params setObject:addr forKey:@"q"];
    }
    return [self mapsURLWithString:@"comgooglemaps://" params:params];
}

- (NSURL *)googleMapsURLWithSaddr:(NSString *)saddr daddr:(NSString *)daddr mode:(NSString *)mode options:(NSDictionary *)options
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:options];
    if (saddr.length > 0) {
        [params setObject:saddr forKey:@"saddr"];
    }
    if (daddr.length > 0) {
        [params setObject:daddr forKey:@"daddr"];
    }
    [params setObject:(mode.length > 0 ? mode : @"driving") forKey:@"directionsmode"];
    return [self mapsURLWithString:@"comgooglemaps://" params:params];
}

- (NSURL *)baiduMapsURLWithAddr:(NSString *)addr options:(NSDictionary *)options
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:options];
    if (addr.length > 0) {
        if ([addr.fw isFormatCoordinate]) {
            [params setObject:addr forKey:@"location"];
        } else {
            [params setObject:addr forKey:@"address"];
        }
    }
    if (![params objectForKey:@"coord_type"]) {
        [params setObject:@"gcj02" forKey:@"coord_type"];
    }
    if (![params objectForKey:@"src"]) {
        [params setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"src"];
    }
    return [self mapsURLWithString:@"baidumap://map/geocoder" params:params];
}

- (NSURL *)baiduMapsURLWithSaddr:(NSString *)saddr daddr:(NSString *)daddr mode:(NSString *)mode options:(NSDictionary *)options
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:options];
    if (saddr.length > 0) {
        [params setObject:saddr forKey:@"origin"];
    }
    if (daddr.length > 0) {
        [params setObject:daddr forKey:@"destination"];
    }
    [params setObject:(mode.length > 0 ? mode : @"driving") forKey:@"mode"];
    if (![params objectForKey:@"coord_type"]) {
        [params setObject:@"gcj02" forKey:@"coord_type"];
    }
    if (![params objectForKey:@"src"]) {
        [params setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"src"];
    }
    return [self mapsURLWithString:@"baidumap://map/direction" params:params];
}

@end
