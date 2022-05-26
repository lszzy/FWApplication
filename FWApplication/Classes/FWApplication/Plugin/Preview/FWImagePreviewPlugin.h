/**
 @header     FWImagePreviewPlugin.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWImagePreviewPlugin

/// 图片预览插件协议，应用可自定义图片预览插件实现
NS_SWIFT_NAME(ImagePreviewPlugin)
@protocol FWImagePreviewPlugin <NSObject>
@required

/// 显示图片预览方法
/// @param viewController 当前视图控制器
/// @param imageURLs 预览图片列表，支持NSString|UIImage|PHLivePhoto|AVPlayerItem类型
/// @param imageInfos 自定义图片信息数组
/// @param currentIndex 当前索引，默认0
/// @param sourceView 来源视图句柄，支持UIView|NSValue.CGRect，默认nil
/// @param placeholderImage 占位图或缩略图句柄，默认nil
/// @param renderBlock 自定义渲染句柄，默认nil
/// @param customBlock 自定义配置句柄，默认nil
- (void)viewController:(UIViewController *)viewController
        showImagePreview:(NSArray *)imageURLs
              imageInfos:(nullable NSArray *)imageInfos
            currentIndex:(NSInteger)currentIndex
              sourceView:(nullable id _Nullable (^)(NSInteger index))sourceView
        placeholderImage:(nullable UIImage * _Nullable (^)(NSInteger index))placeholderImage
             renderBlock:(nullable void (^)(__kindof UIView *view, NSInteger index))renderBlock
             customBlock:(nullable void (^)(id imagePreview))customBlock;

@end

#pragma mark - FWImagePreviewPluginController

/// 图片预览插件控制器协议，使用图片预览插件
NS_REFINED_FOR_SWIFT
@protocol FWImagePreviewPluginController <NSObject>
@required

/// 显示图片预览(简单版)
/// @param imageURLs 预览图片列表，支持NSString|UIImage|PHLivePhoto|AVPlayerItem类型
/// @param imageInfos 自定义图片信息数组
/// @param currentIndex 当前索引，默认0
/// @param sourceView 来源视图，可选，支持UIView|NSValue.CGRect，默认nil
- (void)showImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(nullable NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(nullable id _Nullable (^)(NSInteger index))sourceView;

/// 显示图片预览(详细版)
/// @param imageURLs 预览图片列表，支持NSString|UIImage|PHLivePhoto|AVPlayerItem类型
/// @param imageInfos 自定义图片信息数组
/// @param currentIndex 当前索引，默认0
/// @param sourceView 来源视图句柄，支持UIView|NSValue.CGRect，默认nil
/// @param placeholderImage 占位图或缩略图句柄，默认nil
/// @param renderBlock 自定义渲染句柄，默认nil
/// @param customBlock 自定义句柄，默认nil
- (void)showImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(nullable NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(nullable id _Nullable (^)(NSInteger index))sourceView
                       placeholderImage:(nullable UIImage * _Nullable (^)(NSInteger index))placeholderImage
                            renderBlock:(nullable void (^)(__kindof UIView *view, NSInteger index))renderBlock
                            customBlock:(nullable void (^)(id imagePreview))customBlock;

@end

/// UIViewController使用图片预览插件，全局可使用UIWindow.fw.topPresentedController
@interface FWViewControllerWrapper (FWImagePreviewPluginController) <FWImagePreviewPluginController>

/// 自定义图片预览插件，未设置时自动从插件池加载
@property (nonatomic, strong, nullable) id<FWImagePreviewPlugin> imagePreviewPlugin;

@end

/// UIView使用图片预览插件，内部使用UIView.fw.viewController
@interface FWViewWrapper (FWImagePreviewPluginController) <FWImagePreviewPluginController>

@end

NS_ASSUME_NONNULL_END
