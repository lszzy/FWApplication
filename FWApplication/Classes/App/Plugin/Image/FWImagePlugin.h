/*!
 @header     FWImagePlugin.h
 @indexgroup FWApplication
 @brief      FWImagePlugin
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/11/30
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWImagePlugin

/// 本地图片解码编码选项，默认兼容SDWebImage
typedef NSString * FWImageCoderOptions NS_EXTENSIBLE_STRING_ENUM;
/// 图片解码scale选项，默认未指定时为1
FOUNDATION_EXPORT FWImageCoderOptions const FWImageCoderOptionScaleFactor;

/// 网络图片加载选项，默认兼容SDWebImage
typedef NS_OPTIONS(NSUInteger, FWWebImageOptions) {
    /// 空选项，默认值
    FWWebImageOptionNone = 0,
    /// 是否图片缓存存在时仍重新请求(依赖NSURLCache)
    FWWebImageOptionRefreshCached = 1 << 3,
    /// 禁止调用imageView.setImage:显示图片
    FWWebImageOptionAvoidSetImage = 1 << 10,
};

/// 图片插件协议，应用可自定义图片插件
@protocol FWImagePlugin <NSObject>

@optional

/// 获取imageView正在加载的URL插件方法
- (nullable NSURL *)fwImageURL:(UIImageView *)imageView;

/// imageView加载网络图片插件方法
- (void)fwImageView:(UIImageView *)imageView
        setImageURL:(nullable NSURL *)imageURL
        placeholder:(nullable UIImage *)placeholder
            options:(FWWebImageOptions)options
         completion:(nullable void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion
           progress:(nullable void (^)(double progress))progress;

/// imageView取消加载网络图片请求插件方法
- (void)fwCancelImageRequest:(UIImageView *)imageView;

/// image下载网络图片插件方法，返回下载凭据
- (nullable id)fwDownloadImage:(nullable NSURL *)imageURL
                       options:(FWWebImageOptions)options
                    completion:(void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion
                      progress:(nullable void (^)(double progress))progress;

/// image取消下载网络图片插件方法，指定下载凭据
- (void)fwCancelImageDownload:(nullable id)receipt;

/// imageView动画视图类插件方法，默认使用UIImageView
- (Class)fwImageViewAnimatedClass;

/// image本地解码插件方法，默认使用系统方法
- (nullable UIImage *)fwImageDecode:(NSData *)data scale:(CGFloat)scale options:(nullable NSDictionary<FWImageCoderOptions, id> *)options;

/// image本地编码插件方法，默认使用系统方法
- (nullable NSData *)fwImageEncode:(UIImage *)image options:(nullable NSDictionary<FWImageCoderOptions, id> *)options;

@end

#pragma mark - UIImage+FWImagePlugin

/// 根据名称加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)
FOUNDATION_EXPORT UIImage * _Nullable FWImageNamed(NSString *name);

/*!
 @brief UIImage+FWImagePlugin
 */
@interface UIImage (FWImagePlugin)

/// 根据名称加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)
+ (nullable UIImage *)fwImageNamed:(NSString *)name;

/// 根据名称从指定bundle加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)
+ (nullable UIImage *)fwImageNamed:(NSString *)name bundle:(nullable NSBundle *)bundle;

/// 根据名称从指定bundle加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)。支持设置图片解码选项
+ (nullable UIImage *)fwImageNamed:(NSString *)name bundle:(nullable NSBundle *)bundle options:(nullable NSDictionary<FWImageCoderOptions, id> *)options;

/// 从图片文件路径解码创建UIImage，自动识别scale，支持动图
+ (nullable UIImage *)fwImageWithContentsOfFile:(NSString *)path;

/// 从图片数据解码创建UIImage，scale为1，支持动图
+ (nullable UIImage *)fwImageWithData:(nullable NSData *)data;

/// 从图片数据解码创建UIImage，指定scale，支持动图
+ (nullable UIImage *)fwImageWithData:(nullable NSData *)data scale:(CGFloat)scale;

/// 从图片数据解码创建UIImage，指定scale，支持动图。支持设置图片解码选项
+ (nullable UIImage *)fwImageWithData:(nullable NSData *)data scale:(CGFloat)scale options:(nullable NSDictionary<FWImageCoderOptions, id> *)options;

/// 从UIImage编码创建图片数据，支持动图
+ (nullable NSData *)fwDataWithImage:(nullable UIImage *)image;

/// 从UIImage编码创建图片数据，支持动图。支持设置图片编码选项
+ (nullable NSData *)fwDataWithImage:(nullable UIImage *)image options:(nullable NSDictionary<FWImageCoderOptions, id> *)options;

/// 下载网络图片并返回下载凭据
+ (nullable id)fwDownloadImage:(nullable id)url
                    completion:(void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion
                      progress:(nullable void (^)(double progress))progress;

/// 下载网络图片并返回下载凭据，指定option
+ (nullable id)fwDownloadImage:(nullable id)url
                       options:(FWWebImageOptions)options
                    completion:(void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion
                      progress:(nullable void (^)(double progress))progress;

/// 指定下载凭据取消网络图片下载
+ (void)fwCancelImageDownload:(nullable id)receipt;

@end

#pragma mark - UIImageView+FWImagePlugin

/*!
 @brief UIImageView+FWImagePlugin
 */
@interface UIImageView (FWImagePlugin)

/// 动画ImageView视图类，优先加载插件，默认UIImageView
@property (class, nonatomic, unsafe_unretained) Class fwImageViewAnimatedClass;

/// 当前正在加载的网络图片URL
@property (nonatomic, copy, readonly, nullable) NSURL *fwImageURL;

/// 加载网络图片，优先加载插件，默认使用框架网络库
- (void)fwSetImageWithURL:(nullable id)url;

/// 加载网络图片，支持占位，优先加载插件，默认使用框架网络库
- (void)fwSetImageWithURL:(nullable id)url
         placeholderImage:(nullable UIImage *)placeholderImage;

/// 加载网络图片，支持占位和回调，优先加载插件，默认使用框架网络库
- (void)fwSetImageWithURL:(nullable id)url
         placeholderImage:(nullable UIImage *)placeholderImage
               completion:(nullable void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion;

/// 加载网络图片，支持占位、选项、回调和进度，优先加载插件，默认使用框架网络库
- (void)fwSetImageWithURL:(nullable id)url
         placeholderImage:(nullable UIImage *)placeholderImage
                  options:(FWWebImageOptions)options
               completion:(nullable void (^)(UIImage * _Nullable image, NSError * _Nullable error))completion
                 progress:(nullable void (^)(double progress))progress;

/// 取消加载网络图片请求
- (void)fwCancelImageRequest;

@end

NS_ASSUME_NONNULL_END
