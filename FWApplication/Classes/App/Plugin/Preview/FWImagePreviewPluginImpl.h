/*!
 @header     FWImagePreviewPluginImpl.h
 @indexgroup FWApplication
 @brief      FWImagePreviewPluginImpl
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "FWImagePreviewPlugin.h"
#import "FWImagePreviewController.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWImagePreviewPluginImpl

/// 默认图片预览插件
@interface FWImagePreviewPluginImpl : NSObject <FWImagePreviewPlugin>

/// 单例模式
@property (class, nonatomic, readonly) FWImagePreviewPluginImpl *sharedInstance;

/// 自定义图片预览控制器句柄，默认nil时使用自带控制器，显示分页，点击图片|视频时关闭，present样式为zoom
@property (nonatomic, copy, nullable) __kindof FWImagePreviewController * (^previewControllerBlock)(void);

/// 图片预览全局自定义句柄，show方法自动调用
@property (nonatomic, copy, nullable) void (^customBlock)(__kindof FWImagePreviewController *previewController);

@end

NS_ASSUME_NONNULL_END
