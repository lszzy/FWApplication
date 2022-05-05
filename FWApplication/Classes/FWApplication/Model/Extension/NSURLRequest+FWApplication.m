/**
 @header     NSURLRequest+FWApplication.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2022/03/21
 */

#import "NSURLRequest+FWApplication.h"

@implementation FWURLRequestWrapper (FWApplication)

- (NSString *)curlCommand {
    __block NSMutableString *curlCommand = [NSMutableString stringWithFormat:@"curl -v -X %@ ", self.base.HTTPMethod];

    [curlCommand appendFormat:@"\'%@\' ", self.base.URL.absoluteString];

    [self.base.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *val, BOOL *stop) {
        [curlCommand appendFormat:@"-H \'%@: %@\' ", key, val];
    }];

    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:self.base.URL];
    if (cookies) {
        [curlCommand appendFormat:@"-H \'Cookie:"];
        for (NSHTTPCookie *cookie in cookies) {
            [curlCommand appendFormat:@" %@=%@;", cookie.name, cookie.value];
        }
        [curlCommand appendFormat:@"\' "];
    }

    if (self.base.HTTPBody) {
        NSString *body = [[NSString alloc] initWithData:self.base.HTTPBody encoding:NSUTF8StringEncoding];
        [curlCommand appendFormat:@"-d \'%@\'", body];
    }

    return curlCommand;
}

@end
