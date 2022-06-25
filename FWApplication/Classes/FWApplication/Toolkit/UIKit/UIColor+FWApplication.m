/**
 @header     UIColor+FWApplication.m
 @indexgroup FWApplication
      UIColor+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "UIColor+FWApplication.h"
#import "UIBezierPath+FWApplication.h"

@implementation UIColor (FWApplication)

#pragma mark - Color

- (UIColor *)fw_addColor:(UIColor *)color blendMode:(CGBlendMode)blendMode
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    uint8_t pixel[4] = { 0 };
    CGContextRef context = CGBitmapContextCreate(&pixel, 1, 1, 8, 4, colorSpace, bitmapInfo);
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextSetBlendMode(context, blendMode);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIColor colorWithRed:pixel[0] / 255.0f green:pixel[1] / 255.0f blue:pixel[2] / 255.0f alpha:pixel[3] / 255.0f];
}

- (UIColor *)fw_inverseColor
{
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if (![self getRed:&r green:&g blue:&b alpha:&a]) {
        if ([self getWhite:&r alpha:&a]) { g = r; b = r; }
    }
    
    UIColor *newColor = [[UIColor alloc] initWithRed:(1.0 - r) green:(1.0 - g) blue:(1.0 - b) alpha:a];
    return newColor;
}

- (BOOL)fw_isDarkColor
{
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    if (![self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        if ([self getWhite:&red alpha:&alpha]) { green = red; blue = red; }
    }
    
    float referenceValue = 0.411;
    float colorDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
    
    return 1.0 - colorDelta > referenceValue;
}

- (UIColor *)fw_brightnessColor:(CGFloat)ratio
{
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    return [UIColor colorWithHue:h saturation:s brightness:b * ratio alpha:a];
}

#pragma mark - Image

+ (UIColor *)fw_colorWithImage:(UIImage *)image
{
    return [UIColor colorWithPatternImage:image];
}

+ (UIColor *)fw_colorWithImage:(UIImage *)image point:(CGPoint)point
{
    // 检查点是否越界
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // 绘制目标像素到bitmap上下文
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // 转换颜色为float
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - Gradient

+ (UIColor *)fw_gradientColorWithSize:(CGSize)size
                              colors:(NSArray *)colors
                           locations:(const CGFloat *)locations
                           direction:(UISwipeGestureRecognizerDirection)direction
{
    NSArray<NSValue *> *linePoints = [UIBezierPath fw_linePointsWithRect:CGRectMake(0, 0, size.width, size.height) direction:direction];
    CGPoint startPoint = [linePoints.firstObject CGPointValue];
    CGPoint endPoint = [linePoints.lastObject CGPointValue];
    return [self fw_gradientColorWithSize:size colors:colors locations:locations startPoint:startPoint endPoint:endPoint];
}

+ (UIColor *)fw_gradientColorWithSize:(CGSize)size
                              colors:(NSArray *)colors
                           locations:(const CGFloat *)locations
                          startPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (__bridge CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    UIGraphicsEndImageContext();
    
    return [UIColor colorWithPatternImage:image];
}

@end
