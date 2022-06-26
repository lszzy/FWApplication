/**
 @header     NSNumber+FWApplication.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "NSNumber+FWApplication.h"

@implementation NSNumber (FWApplication)

- (CGFloat)fw_CGFloatValue
{
#if CGFLOAT_IS_DOUBLE
    return [self doubleValue];
#else
    return [self floatValue];
#endif
}

- (NSString *)fw_roundString:(NSInteger)digit
{
    return [self fw_formatString:digit roundingMode:NSNumberFormatterRoundHalfUp];
}

- (NSString *)fw_ceilString:(NSInteger)digit
{
    return [self fw_formatString:digit roundingMode:NSNumberFormatterRoundCeiling];
}

- (NSString *)fw_floorString:(NSInteger)digit
{
    return [self fw_formatString:digit roundingMode:NSNumberFormatterRoundFloor];
}

- (NSString *)fw_formatString:(NSInteger)digit
              roundingMode:(NSNumberFormatterRoundingMode)roundingMode
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterNoStyle;
    formatter.roundingMode = roundingMode;
    formatter.minimumIntegerDigits = 1;
    formatter.maximumFractionDigits = digit;
    formatter.decimalSeparator = @".";
    formatter.groupingSeparator = @"";
    formatter.usesGroupingSeparator = NO;
    formatter.currencyDecimalSeparator = @".";
    formatter.currencyGroupingSeparator = @"";
    NSString *result = [formatter stringFromNumber:self];
    return result ?: @"";
}

- (NSNumber *)fw_roundNumber:(NSUInteger)digit
{
    return [self fw_formatNumber:digit roundingMode:NSNumberFormatterRoundHalfUp];
}

- (NSNumber *)fw_ceilNumber:(NSUInteger)digit
{
    return [self fw_formatNumber:digit roundingMode:NSNumberFormatterRoundCeiling];
}

- (NSNumber *)fw_floorNumber:(NSUInteger)digit
{
    return [self fw_formatNumber:digit roundingMode:NSNumberFormatterRoundFloor];
}

- (NSNumber *)fw_formatNumber:(NSUInteger)digit
              roundingMode:(NSNumberFormatterRoundingMode)roundingMode
{
    NSString *string = [self fw_formatString:digit roundingMode:roundingMode];
    return [NSNumber numberWithDouble:[string doubleValue]];
}

@end
