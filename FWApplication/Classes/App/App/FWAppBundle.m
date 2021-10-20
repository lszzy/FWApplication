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

+ (UIImage *)imageNamed:(NSString *)name
{
    UIImage *image = [super imageNamed:name];
    if (image) return image;
    
    if ([name isEqualToString:@"fwNavBack"]) {
        CGSize size = CGSizeMake(12, 20);
        return [UIImage fwImageWithSize:size block:^(CGContextRef contextRef) {
            UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75];
            CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
            CGFloat lineWidth = 2;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(size.width - lineWidth / 2, lineWidth / 2)];
            [path addLineToPoint:CGPointMake(0 + lineWidth / 2, size.height / 2.0)];
            [path addLineToPoint:CGPointMake(size.width - lineWidth / 2, size.height - lineWidth / 2)];
            [path setLineWidth:lineWidth];
            [path stroke];
        }];
    } else if ([name isEqualToString:@"fwNavClose"]) {
        CGSize size = CGSizeMake(16, 16);
        return [UIImage fwImageWithSize:size block:^(CGContextRef contextRef) {
            UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75];
            CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
            CGFloat lineWidth = 2;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0, 0)];
            [path addLineToPoint:CGPointMake(size.width, size.height)];
            [path closePath];
            [path moveToPoint:CGPointMake(size.width, 0)];
            [path addLineToPoint:CGPointMake(0, size.height)];
            [path closePath];
            [path setLineWidth:lineWidth];
            [path setLineCapStyle:kCGLineCapRound];
            [path stroke];
        }];
    } else if ([name isEqualToString:@"fwVideoPlay"]) {
        CGSize size = CGSizeMake(60, 60);
        return [UIImage fwImageWithSize:size block:^(CGContextRef contextRef) {
            UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75];
            CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
            CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:0 green:0 blue:0 alpha:.25].CGColor);
            CGFloat lineWidth = 1;
            UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(lineWidth / 2, lineWidth / 2, size.width - lineWidth, size.width - lineWidth)];
            [circle setLineWidth:lineWidth];
            [circle stroke];
            [circle fill];
            
            CGContextSetFillColorWithColor(contextRef, color.CGColor);
            CGFloat triangleLength = size.width / 2.5;
            UIBezierPath *triangle = [UIBezierPath bezierPath];
            [triangle moveToPoint:CGPointZero];
            [triangle addLineToPoint:CGPointMake(triangleLength * cos(M_PI / 6), triangleLength / 2)];
            [triangle addLineToPoint:CGPointMake(0, triangleLength)];
            [triangle closePath];
            UIOffset offset = UIOffsetMake(size.width / 2 - triangleLength * tan(M_PI / 6) / 2, size.width / 2 - triangleLength / 2);
            [triangle applyTransform:CGAffineTransformMakeTranslation(offset.horizontal, offset.vertical)];
            [triangle fill];
        }];
    } else if ([name isEqualToString:@"fwVideoPause"]) {
        CGSize size = CGSizeMake(12, 18);
        return [UIImage fwImageWithSize:size block:^(CGContextRef contextRef) {
            UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75];
            CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
            CGFloat lineWidth = 2;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(lineWidth / 2, size.height)];
            [path moveToPoint:CGPointMake(size.width - lineWidth / 2, 0)];
            [path addLineToPoint:CGPointMake(size.width - lineWidth / 2, size.height)];
            [path setLineWidth:lineWidth];
            [path stroke];
        }];
    } else if ([name isEqualToString:@"fwVideoStart"]) {
        CGSize size = CGSizeMake(17, 17);
        return [UIImage fwImageWithSize:size block:^(CGContextRef contextRef) {
            UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75];
            CGContextSetFillColorWithColor(contextRef, color.CGColor);
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointZero];
            [path addLineToPoint:CGPointMake(size.width * cos(M_PI / 6), size.width / 2)];
            [path addLineToPoint:CGPointMake(0, size.width)];
            [path closePath];
            [path fill];
        }];
    } else if ([name isEqualToString:@"fwPickerCheck"]) {
        CGSize size = CGSizeMake(20, 20);
        return [UIImage fwImageWithSize:size block:^(CGContextRef contextRef) {
            UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75];
            CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
            CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:0 green:0 blue:0 alpha:.25].CGColor);
            CGFloat lineWidth = 1;
            UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(lineWidth / 2, lineWidth / 2, size.width - lineWidth, size.width - lineWidth)];
            [circle setLineWidth:lineWidth];
            [circle stroke];
            [circle fill];
        }];
    } else if ([name isEqualToString:@"fwPickerChecked"]) {
        CGSize size = CGSizeMake(20, 20);
        return [UIImage fwImageWithSize:size block:^(CGContextRef contextRef) {
            UIColor *color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75];
            CGContextSetStrokeColorWithColor(contextRef, color.CGColor);
            CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:0 green:0 blue:0 alpha:.75].CGColor);
            CGFloat lineWidth = 1;
            UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(lineWidth / 2, lineWidth / 2, size.width - lineWidth, size.width - lineWidth)];
            [circle setLineWidth:lineWidth];
            [circle stroke];
            [circle fill];
            
            CGSize checkSize = CGSizeMake(9, 7);
            CGPoint checkOrigin = CGPointMake((size.width - checkSize.width) / 2.0, (size.height - checkSize.height) / 2.0);
            CGFloat lineAngle = M_PI_4;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(checkOrigin.x, checkOrigin.y + checkSize.height / 2)];
            [path addLineToPoint:CGPointMake(checkOrigin.x + checkSize.width / 3, checkOrigin.y + checkSize.height)];
            [path addLineToPoint:CGPointMake(checkOrigin.x + checkSize.width, checkOrigin.y + lineWidth * sin(lineAngle))];
            [path addLineToPoint:CGPointMake(checkOrigin.x + checkSize.width - lineWidth * cos(lineAngle), checkOrigin.y + 0)];
            [path addLineToPoint:CGPointMake(checkOrigin.x + checkSize.width / 3, checkOrigin.y + checkSize.height - lineWidth / sin(lineAngle))];
            [path addLineToPoint:CGPointMake(checkOrigin.x + lineWidth * sin(lineAngle), checkOrigin.y + checkSize.height / 2 - lineWidth * sin(lineAngle))];
            [path closePath];
            [path setLineWidth:lineWidth];
            [path stroke];
        }];
    }
    return nil;
}

+ (NSString *)localizedString:(NSString *)key table:(NSString *)table
{
    if (table) return [super localizedString:key table:table];
    NSString *localized = [[self bundle] localizedStringForKey:key value:@" " table:table];
    if (![localized isEqualToString:@" "]) return localized;
    
    static NSDictionary *localizedStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localizedStrings = @{
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
    NSDictionary *strings = localizedStrings[language] ?: localizedStrings[@"en"];
    return strings[key] ?: key;
}

#pragma mark - Image

+ (UIImage *)navBackImage
{
    return [self imageNamed:@"fwNavBack"];
}

+ (UIImage *)navCloseImage
{
    return [self imageNamed:@"fwNavClose"];
}

+ (UIImage *)videoPlayImage
{
    return [self imageNamed:@"fwVideoPlay"];
}

+ (UIImage *)videoPauseImage
{
    return [self imageNamed:@"fwVideoPause"];
}

+ (UIImage *)videoStartImage
{
    return [self imageNamed:@"fwVideoStart"];
}

+ (UIImage *)pickerCheckImage
{
    return [self imageNamed:@"fwPickerCheck"];
}

+ (UIImage *)pickerCheckedImage
{
    return [self imageNamed:@"fwPickerChecked"];
}

#pragma mark - String

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
