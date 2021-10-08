/*!
 @header     FWAppBundle.m
 @indexgroup FWApplication
 @brief      FWAppBundle
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/4/21
 */

#import "FWAppBundle.h"

@implementation FWAppBundle

+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [[NSBundle fwBundleWithName:@"FWApplication"] fwLocalizedBundle];
        if (!bundle) bundle = [NSBundle mainBundle];
    });
    return bundle;
}

+ (NSDictionary<NSString *,NSString *> *)localizedStrings:(NSString *)table
{
    if (table) return nil;
    
    static NSDictionary *strings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strings = @{
            @"zh-Hans": @{
                @"完成": @"完成",
                @"关闭": @"关闭",
                @"确定": @"确定",
                @"取消": @"取消",
                @"原有": @"原有",
            },
            @"zh-Hant": @{
                @"完成": @"完成",
                @"关闭": @"關閉",
                @"确定": @"確定",
                @"取消": @"取消",
                @"原有": @"原有",
            },
            @"en": @{
                @"完成": @"Done",
                @"关闭": @"OK",
                @"确定": @"Yes",
                @"取消": @"Cancel",
                @"原有": @"Original",
            },
            @"ja": @{
                @"完成": @"完了",
                @"关闭": @"閉める",
                @"确定": @"確認",
                @"取消": @"戻る",
                @"原有": @"オリジナル",
            },
            @"ms": @{
                @"完成": @"Selesai",
                @"关闭": @"OK",
                @"确定": @"Ya",
                @"取消": @"Batal",
                @"原有": @"Asal",
            },
        };
    });
    
    NSString *language = [NSBundle fwCurrentLanguage];
    return strings[language] ?: strings[@"en"];
}

#pragma mark - Public

+ (NSString *)cancelButton
{
    return [self localizedString:@"取消"];
}

+ (NSString *)confirmButton
{
    return [self localizedString:@"确定"];
}

+ (NSString *)doneButton
{
    return [self localizedString:@"完成"];
}

+ (NSString *)closeButton
{
    return [self localizedString:@"关闭"];
}

+ (NSString *)originalButton
{
    return [self localizedString:@"原有"];
}

@end
