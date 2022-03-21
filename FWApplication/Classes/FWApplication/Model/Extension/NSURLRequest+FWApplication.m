/**
 @header     NSURLRequest+FWApplication.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2022/03/21
 */

#import "NSURLRequest+FWApplication.h"

@implementation NSURLRequest (FWApplication)

- (NSString *)fwCurlCommand {
    __block NSMutableString *curlCommand = [NSMutableString stringWithFormat:@"curl -v -X %@ ", self.HTTPMethod];

    [curlCommand appendFormat:@"\'%@\' ", self.URL.absoluteString];

    [self.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *val, BOOL *stop) {
        [curlCommand appendFormat:@"-H \'%@: %@\' ", key, val];
    }];

    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:self.URL];
    if (cookies) {
        [curlCommand appendFormat:@"-H \'Cookie:"];
        for (NSHTTPCookie *cookie in cookies) {
            [curlCommand appendFormat:@" %@=%@;", cookie.name, cookie.value];
        }
        [curlCommand appendFormat:@"\' "];
    }

    if (self.HTTPBody) {
        NSString *body = [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
        [curlCommand appendFormat:@"-d \'%@\'", body];
    }

    return curlCommand;
}

@end
