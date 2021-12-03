/*!
 @header     FWImagePluginImpl.h
 @indexgroup FWApplication
 @brief      FWImagePluginImpl
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/11/30
 */

#import "FWImagePlugin.h"

NS_ASSUME_NONNULL_BEGIN

/// SDWebImage图片插件，启用Component_SDWebImage组件后生效
@interface FWSDWebImagePlugin : NSObject <FWImagePlugin>

/// 单例模式
@property (class, nonatomic, readonly) FWSDWebImagePlugin *sharedInstance;

/// 图片加载完成是否显示渐变动画，默认NO
@property (nonatomic, assign) BOOL fadeAnimated;

/// 图片自定义句柄，setImageURL开始时调用
@property (nonatomic, copy, nullable) void (^customBlock)(UIImageView *imageView);

@end

NS_ASSUME_NONNULL_END
