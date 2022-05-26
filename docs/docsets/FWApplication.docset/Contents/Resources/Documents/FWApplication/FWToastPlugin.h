/**
 @header     FWToastPlugin.h
 @indexgroup FWApplication
      FWToastPlugin
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWToastPlugin

/// 消息吐司样式枚举，可扩展
typedef NSInteger FWToastStyle NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(ToastStyle);
/// 默认消息样式
static const FWToastStyle FWToastStyleDefault = 0;
/// 成功消息样式
static const FWToastStyle FWToastStyleSuccess = 1;
/// 失败消息样式
static const FWToastStyle FWToastStyleFailure = 2;

/// 吐司插件协议，应用可自定义吐司插件实现
NS_SWIFT_NAME(ToastPlugin)
@protocol FWToastPlugin <NSObject>

@optional

/// 显示加载吐司，需手工隐藏
- (void)showLoadingWithAttributedText:(nullable NSAttributedString *)attributedText inView:(UIView *)view;

/// 隐藏加载吐司
- (void)hideLoading:(UIView *)view;

/// 显示进度条吐司，需手工隐藏
- (void)showProgressWithAttributedText:(nullable NSAttributedString *)attributedText progress:(CGFloat)progress inView:(UIView *)view;

/// 隐藏进度条吐司
- (void)hideProgress:(UIView *)view;

/// 显示指定样式消息吐司，可设置自动隐藏，自动隐藏完成后回调
- (void)showMessageWithAttributedText:(nullable NSAttributedString *)attributedText style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(nullable void (^)(void))completion inView:(UIView *)view;

/// 隐藏消息吐司
- (void)hideMessage:(UIView *)view;

@end

#pragma mark - FWToastPluginView

/// 吐司插件视图协议，使用吐司插件
NS_REFINED_FOR_SWIFT
@protocol FWToastPluginView <NSObject>
@required

/// 设置吐司外间距，默认zero
@property (nonatomic, assign) UIEdgeInsets toastInsets;

/// 显示加载吐司，需手工隐藏，默认文本
- (void)showLoading;

/// 显示加载吐司，需手工隐藏，支持String和AttributedString
- (void)showLoadingWithText:(nullable id)text;

/// 隐藏加载吐司
- (void)hideLoading;

/// 显示进度条吐司，需手工隐藏，支持String和AttributedString
- (void)showProgressWithText:(nullable id)text progress:(CGFloat)progress;

/// 隐藏进度条吐司
- (void)hideProgress;

/// 显示默认样式消息吐司，自动隐藏，支持String和AttributedString
- (void)showMessageWithText:(nullable id)text;

/// 显示指定样式消息吐司，自动隐藏，支持String和AttributedString
- (void)showMessageWithText:(nullable id)text style:(FWToastStyle)style;

/// 显示指定样式消息吐司，自动隐藏，自动隐藏完成后回调，支持String和AttributedString
- (void)showMessageWithText:(nullable id)text style:(FWToastStyle)style completion:(nullable void (^)(void))completion;

/// 显示指定样式消息吐司，可设置自动隐藏，自动隐藏完成后回调，支持String和AttributedString
- (void)showMessageWithText:(nullable id)text style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(nullable void (^)(void))completion;

/// 隐藏消息吐司
- (void)hideMessage;

@end

/// UIView使用吐司插件，全局可使用UIWindow.fw.mainWindow
@interface FWViewWrapper (FWToastPluginView) <FWToastPluginView>

/// 自定义吐司插件，未设置时自动从插件池加载
@property (nonatomic, strong, nullable) id<FWToastPlugin> toastPlugin;

@end

/// UIViewController使用吐司插件，内部使用UIViewController.view
@interface FWViewControllerWrapper (FWToastPluginView) <FWToastPluginView>

@end

/// UIWindow全局使用吐司插件，内部使用UIWindow.fw.mainWindow
@interface FWWindowClassWrapper (FWToastPluginView) <FWToastPluginView>

@end

NS_ASSUME_NONNULL_END
