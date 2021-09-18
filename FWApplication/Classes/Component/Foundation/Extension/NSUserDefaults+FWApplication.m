/*!
 @header     NSUserDefaults+FWApplication.m
 @indexgroup FWApplication
 @brief      NSUserDefaults+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "NSUserDefaults+FWApplication.h"

@implementation NSUserDefaults (FWApplication)

+ (id)fwObjectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)fwSetObject:(id)object forKey:(NSString *)key
{
    if (object == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)fwObjectForKey:(NSString *)key
{
    return [self objectForKey:key];
}

- (void)fwSetObject:(id)object forKey:(NSString *)key
{
    if (object == nil) {
        [self removeObjectForKey:key];
    } else {
        [self setObject:object forKey:key];
    }
    [self synchronize];
}

@end
