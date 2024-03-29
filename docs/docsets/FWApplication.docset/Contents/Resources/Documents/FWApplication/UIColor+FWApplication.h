/**
 @header     UIColor+FWApplication.h
 @indexgroup FWApplication
      UIColor+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (FWApplication)

#pragma mark - Color

// 以指定模式添加混合颜色
- (UIColor *)fw_addColor:(UIColor *)color blendMode:(CGBlendMode)blendMode NS_REFINED_FOR_SWIFT;

// 当前颜色的反色。http://stackoverflow.com/questions/5893261/how-to-get-inverse-color-from-uicolor
@property (nonatomic, strong, readonly) UIColor *fw_inverseColor NS_REFINED_FOR_SWIFT;

// 判断当前颜色是否为深色。http://stackoverflow.com/questions/19456288/text-color-based-on-background-image
@property (nonatomic, assign, readonly) BOOL fw_isDarkColor NS_REFINED_FOR_SWIFT;

// 当前颜色修改亮度比率的颜色
- (UIColor *)fw_brightnessColor:(CGFloat)ratio NS_REFINED_FOR_SWIFT;

#pragma mark - Image

// 从整个图像初始化UIColor
+ (UIColor *)fw_colorWithImage:(UIImage *)image NS_REFINED_FOR_SWIFT;

// 从图像的某个点初始化UIColor
+ (nullable UIColor *)fw_colorWithImage:(UIImage *)image point:(CGPoint)point NS_REFINED_FOR_SWIFT;

#pragma mark - Gradient

/**
 创建渐变颜色，支持四个方向，默认向下Down
 
 @param size 渐变尺寸，非渐变边可以设置为1。如CGSizeMake(1, 50)
 @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
 @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
 @param direction 渐变方向，自动计算startPoint和endPoint，支持四个方向，默认向下Down
 @return 渐变色
 */
+ (UIColor *)fw_gradientColorWithSize:(CGSize)size
                              colors:(NSArray *)colors
                           locations:(nullable const CGFloat *)locations
                           direction:(UISwipeGestureRecognizerDirection)direction NS_REFINED_FOR_SWIFT;

/**
 创建渐变颜色
 
 @param size 渐变尺寸，非渐变边可以设置为1。如CGSizeMake(1, 50)
 @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
 @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
 @param startPoint 渐变开始点，需要根据rect计算
 @param endPoint 渐变结束点，需要根据rect计算
 @return 渐变色
 */
+ (UIColor *)fw_gradientColorWithSize:(CGSize)size
                              colors:(NSArray *)colors
                           locations:(nullable const CGFloat *)locations
                          startPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
