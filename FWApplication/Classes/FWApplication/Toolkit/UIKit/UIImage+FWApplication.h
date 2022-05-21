/**
 @header     UIImage+FWApplication.h
 @indexgroup FWApplication
      UIImage+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/19
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 注意CGContextDrawImage如果图片尺寸太大会导致内存不足闪退(如高斯模糊效果)，建议先压缩再调用
 */
@interface FWImageWrapper (FWApplication)

#pragma mark - Color

// 获取灰度图
@property (nonatomic, readonly, nullable) UIImage *grayImage;

// 取图片某一点的颜色
- (nullable UIColor *)colorAtPoint:(CGPoint)point;

// 取图片某一像素的颜色
- (nullable UIColor *)colorAtPixel:(CGPoint)point;

// 获取图片的平均颜色
@property (nonatomic, readonly) UIColor *averageColor;

#pragma mark - Effect

// 倒影图片
- (nullable UIImage *)imageWithReflectScale:(CGFloat)scale;

// 倒影图片
- (nullable UIImage *)imageWithReflectScale:(CGFloat)scale gap:(CGFloat)gap alpha:(CGFloat)alpha;

// 阴影图片
- (nullable UIImage *)imageWithShadowColor:(UIColor *)color offset:(CGSize)offset blur:(CGFloat)blur;

// 获取装饰图片
@property (nonatomic, readonly) UIImage *maskImage;

// 高斯模糊图片，默认模糊半径为10，饱和度为1
- (nullable UIImage *)imageWithBlurRadius:(CGFloat)blurRadius saturationDelta:(CGFloat)saturationDelta tintColor:(nullable UIColor *)tintColor maskImage:(nullable UIImage *)maskImage;

#pragma mark - Alpha

// 如果没有透明通道，增加透明通道
@property (nonatomic, readonly) UIImage *alphaImage;

#pragma mark - Album

// 保存图片到相册，保存成功时error为nil
- (void)saveImageWithCompletion:(nullable void (^)(NSError * _Nullable error))completion;

@end

@interface FWImageClassWrapper (FWApplication)

#pragma mark - View

// 截取View所有视图，包括旋转缩放效果
- (nullable UIImage *)imageWithView:(UIView *)view limitWidth:(CGFloat)limitWidth;

#pragma mark - Icon

// 获取AppIcon图片
- (nullable UIImage *)imageWithAppIcon;

// 获取AppIcon指定尺寸图片，名称格式：AppIcon60x60
- (nullable UIImage *)imageWithAppIcon:(CGSize)size;

#pragma mark - Pdf

// 从Pdf数据或者路径创建UIImage
- (nullable UIImage *)imageWithPdf:(id)path;

// 从Pdf数据或者路径创建指定大小UIImage
- (nullable UIImage *)imageWithPdf:(id)path size:(CGSize)size;

#pragma mark - Emoji

// 从Emoji字符串创建指定大小UIImage
- (nullable UIImage *)imageWithEmoji:(NSString *)emoji size:(CGFloat)size;

#pragma mark - Gradient

/**
 创建渐变颜色UIImage，支持四个方向，默认向下Down
 
 @param size 图片大小
 @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
 @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
 @param direction 渐变方向，自动计算startPoint和endPoint，支持四个方向，默认向下Down
 @return 渐变颜色UIImage
 */
- (nullable UIImage *)gradientImageWithSize:(CGSize)size
                                       colors:(NSArray *)colors
                                    locations:(nullable const CGFloat *)locations
                                    direction:(UISwipeGestureRecognizerDirection)direction;

/**
 创建渐变颜色UIImage
 
 @param size 图片大小
 @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
 @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
 @param startPoint 渐变开始点，需要根据rect计算
 @param endPoint 渐变结束点，需要根据rect计算
 @return 渐变颜色UIImage
 */
- (nullable UIImage *)gradientImageWithSize:(CGSize)size
                                       colors:(NSArray *)colors
                                    locations:(nullable const CGFloat *)locations
                                   startPoint:(CGPoint)startPoint
                                     endPoint:(CGPoint)endPoint;

#pragma mark - Album

// 保存视频到相册，保存成功时error为nil。如果视频地址为NSURL，需使用NSURL.path
- (void)saveVideo:(NSString *)videoPath withCompletion:(nullable void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
