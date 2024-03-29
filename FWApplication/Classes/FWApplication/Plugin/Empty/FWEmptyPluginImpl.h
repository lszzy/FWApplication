/**
 @header     FWEmptyPluginImpl.h
 @indexgroup FWApplication
      FWEmptyPluginImpl
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/3
 */

#import "FWEmptyPlugin.h"
#import "FWEmptyView.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWEmptyPluginImpl

/// 默认空界面插件
NS_SWIFT_NAME(EmptyPluginImpl)
@interface FWEmptyPluginImpl : NSObject <FWEmptyPlugin>

/// 单例模式
@property (class, nonatomic, readonly) FWEmptyPluginImpl *sharedInstance;

/// 显示空界面时是否执行淡入动画，默认YES
@property (nonatomic, assign) BOOL fadeAnimated;
/// 空界面自定义句柄，show方法自动调用
@property (nonatomic, copy, nullable) void (^customBlock)(FWEmptyView *emptyView);

/// 默认空界面文本句柄，非loading时才触发
@property (nonatomic, copy, nullable) NSString * _Nullable (^defaultText)(void);
/// 默认空界面详细文本句柄，非loading时才触发
@property (nonatomic, copy, nullable) NSString * _Nullable (^defaultDetail)(void);
/// 默认空界面图片句柄，非loading时才触发
@property (nonatomic, copy, nullable) UIImage * _Nullable (^defaultImage)(void);
/// 默认空界面动作按钮句柄，非loading时才触发
@property (nonatomic, copy, nullable) NSString * _Nullable (^defaultAction)(void);

@end

NS_ASSUME_NONNULL_END
