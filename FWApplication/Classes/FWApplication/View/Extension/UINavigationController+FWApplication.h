/**
 @header     UINavigationController+FWApplication.h
 @indexgroup FWApplication
      UINavigationController+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

/**
 修复iOS14.0如果pop到一个hidesBottomBarWhenPushed=NO的vc，tabBar无法正确显示出来的bug
 @note present带导航栏webview，如果存在input[type=file]，会dismiss两次，无法选择照片。解决方法：1.使用push 2.重写dismiss方法仅当presentedViewController存在时才调用dismiss
 
 @see https://github.com/Tencent/QMUI_iOS
 */
@interface FWNavigationControllerWrapper (FWApplication)

@end

@interface FWNavigationBarWrapper (FWApplication)

/// 导航栏内容视图，iOS11+才存在，显示item和titleView等
@property (nonatomic, readonly, nullable) UIView *contentView;

/// 导航栏大标题视图，显示时才有值。如果要设置背景色，可使用fwBackgroundView.backgroundColor
@property (nonatomic, readonly, nullable) UIView *largeTitleView;

@end

@interface FWNavigationBarClassWrapper (FWApplication)

/// 导航栏大标题高度，与是否隐藏无关
@property (nonatomic, readonly, assign) CGFloat largeTitleHeight;

@end

@interface FWToolbarWrapper (FWApplication)

/// 工具栏内容视图，iOS11+才存在，显示item等
@property (nonatomic, readonly, nullable) UIView *contentView;

/// 工具栏背景视图，显示背景色和背景图片等。如果标签栏同时显示，背景视图高度也会包含标签栏高度
@property (nonatomic, readonly, nullable) UIView *backgroundView;

@end
