/**
 @header     NSNumber+FWApplication.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "NSNumber+FWApplication.h"

@implementation FWNumberWrapper (FWApplication)

- (CGFloat)CGFloatValue
{
#if CGFLOAT_IS_DOUBLE
    return [self.base doubleValue];
#else
    return [self.base floatValue];
#endif
}

- (NSString *)roundString:(NSInteger)digit
{
    return [self formatString:digit roundingMode:NSNumberFormatterRoundHalfUp];
}

- (NSString *)ceilString:(NSInteger)digit
{
    return [self formatString:digit roundingMode:NSNumberFormatterRoundCeiling];
}

- (NSString *)floorString:(NSInteger)digit
{
    return [self formatString:digit roundingMode:NSNumberFormatterRoundFloor];
}

- (NSString *)formatString:(NSInteger)digit
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
    NSString *result = [formatter stringFromNumber:self.base];
    return result ?: @"";
}

- (NSNumber *)roundNumber:(NSUInteger)digit
{
    return [self formatNumber:digit roundingMode:NSNumberFormatterRoundHalfUp];
}

- (NSNumber *)ceilNumber:(NSUInteger)digit
{
    return [self formatNumber:digit roundingMode:NSNumberFormatterRoundCeiling];
}

- (NSNumber *)floorNumber:(NSUInteger)digit
{
    return [self formatNumber:digit roundingMode:NSNumberFormatterRoundFloor];
}

- (NSNumber *)formatNumber:(NSUInteger)digit
              roundingMode:(NSNumberFormatterRoundingMode)roundingMode
{
    NSString *string = [self formatString:digit roundingMode:roundingMode];
    return [NSNumber numberWithDouble:[string doubleValue]];
}

@end
