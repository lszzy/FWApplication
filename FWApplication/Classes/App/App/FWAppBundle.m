/*!
 @header     FWAppBundle.m
 @indexgroup FWApplication
 @brief      FWAppBundle
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/4/21
 */

#import "FWAppBundle.h"

#pragma mark - FWAppBundle

@implementation FWAppBundle

+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [[NSBundle fwBundleWithName:@"FWApplication"] fwLocalizedBundle];
        if (!bundle) {
            bundle = [[NSBundle fwBundleWithClass:[FWAppBundle class] name:@"FWApplication"] fwLocalizedBundle];
        }
    });
    return bundle;
}

@end
