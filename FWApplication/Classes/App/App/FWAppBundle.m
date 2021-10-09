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
                @"fwDone": @"完成",
                @"fwClose": @"关闭",
                @"fwConfirm": @"确定",
                @"fwCancel": @"取消",
                @"fwOriginal": @"原有",
            },
            @"zh-Hant": @{
                @"fwDone": @"完成",
                @"fwClose": @"關閉",
                @"fwConfirm": @"確定",
                @"fwCancel": @"取消",
                @"fwOriginal": @"原有",
            },
            @"en": @{
                @"fwDone": @"Done",
                @"fwClose": @"OK",
                @"fwConfirm": @"Yes",
                @"fwCancel": @"Cancel",
                @"fwOriginal": @"Original",
            },
            @"ja": @{
                @"fwDone": @"完了",
                @"fwClose": @"閉める",
                @"fwConfirm": @"確認",
                @"fwCancel": @"戻る",
                @"fwOriginal": @"オリジナル",
            },
            @"ms": @{
                @"fwDone": @"Selesai",
                @"fwClose": @"OK",
                @"fwConfirm": @"Ya",
                @"fwCancel": @"Batal",
                @"fwOriginal": @"Asal",
            },
        };
    });
    
    NSString *language = [NSBundle fwCurrentLanguage];
    return strings[language] ?: strings[@"en"];
}

#pragma mark - Public

+ (NSString *)cancelButton
{
    return [self localizedString:@"fwCancel"];
}

+ (NSString *)confirmButton
{
    return [self localizedString:@"fwConfirm"];
}

+ (NSString *)doneButton
{
    return [self localizedString:@"fwDone"];
}

+ (NSString *)closeButton
{
    return [self localizedString:@"fwClose"];
}

+ (NSString *)originalButton
{
    return [self localizedString:@"fwOriginal"];
}

@end
