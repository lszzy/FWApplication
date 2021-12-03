/**
 @header     FWNavigationStyle.h
 @indexgroup FWApplication
      FWNavigationStyle
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/12/5
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWNavigationBarAppearance

/// 导航栏全局样式可扩展枚举
typedef NSInteger FWNavigationBarStyle NS_TYPED_EXTENSIBLE_ENUM;
/// 默认样式，应用可配置并扩展
static const FWNavigationBarStyle FWNavigationBarStyleDefault = 0;

/// 导航栏样式配置
@interface FWNavigationBarAppearance : NSObject

/// 是否半透明(磨砂)，需edgesForExtendedLayout为Top|All，默认NO
@property (nonatomic, assign) BOOL isTranslucent;
/// 前景色，包含标题和按钮，默认nil
@property (nullable, nonatomic, strong) UIColor *foregroundColor;
/// 标题颜色，默认nil同前景色
@property (nullable, nonatomic, strong) UIColor *titleColor;
/// 背景色，后设置生效，默认nil
@property (nullable, nonatomic, strong) UIColor *backgroundColor;
/// 背景图片，后设置生效，默认nil
@property (nullable, nonatomic, strong) UIImage *backgroundImage;
/// 背景透明，需edgesForExtendedLayout为Top|All，后设置生效，默认NO
@property (nonatomic, assign) BOOL backgroundTransparent;
/// 阴影颜色，后设置生效，默认nil
@property (nullable, nonatomic, strong) UIColor *shadowColor;
/// 阴影图片，后设置生效，默认nil
@property (nullable, nonatomic, strong) UIImage *shadowImage;

/// 自定义句柄，最后调用，可自定义样式，默认nil
@property (nullable, nonatomic, copy) void (^appearanceBlock)(UINavigationBar *navigationBar);

/// 根据style获取全局appearance对象
+ (nullable FWNavigationBarAppearance *)appearanceForStyle:(FWNavigationBarStyle)style;
/// 设置style对应全局appearance对象
+ (void)setAppearance:(nullable FWNavigationBarAppearance *)appearance forStyle:(FWNavigationBarStyle)style;

@end

#pragma mark - UIViewController+FWStyle

/**
 视图控制器样式分类，兼容系统导航栏和自定义导航栏(default和custom样式)
 @note 需要设置UIViewControllerBasedStatusBarAppearance为YES，视图控制器修改状态栏样式才会生效
 */
@interface UIViewController (FWStyle)

#pragma mark - Bar

/// 状态栏样式，默认UIStatusBarStyleDefault，设置后才会生效
@property (nonatomic, assign) UIStatusBarStyle fwStatusBarStyle;

/// 状态栏是否隐藏，默认NO，设置后才会生效
@property (nonatomic, assign) BOOL fwStatusBarHidden;

/// 当前导航栏设置，优先级高于style，设置后会在viewWillAppear:自动应用生效
@property (nullable, nonatomic, strong) FWNavigationBarAppearance *fwNavigationBarAppearance;

/// 当前导航栏样式，默认Default，设置后才会在viewWillAppear:自动应用生效
@property (nonatomic, assign) FWNavigationBarStyle fwNavigationBarStyle;

/// 导航栏是否隐藏，默认NO，设置后才会在viewWillAppear:自动应用生效
@property (nonatomic, assign) BOOL fwNavigationBarHidden;

/// 动态隐藏导航栏，如果当前已经viewWillAppear:时立即执行
- (void)fwSetNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

/// 标签栏是否隐藏，默认为NO，立即生效。如果tabBar一直存在，则用tabBar包裹navBar；如果tabBar只存在主界面，则用navBar包裹tabBar
@property (nonatomic, assign) BOOL fwTabBarHidden;

/// 工具栏是否隐藏，默认为YES。需设置toolbarItems，立即生效
@property (nonatomic, assign) BOOL fwToolBarHidden;

/// 动态隐藏工具栏。需设置toolbarItems，立即生效
- (void)fwSetToolBarHidden:(BOOL)hidden animated:(BOOL)animated;

/// 设置视图布局Bar延伸类型，None为不延伸(Bar不覆盖视图)，Top|Bottom为顶部|底部延伸，All为全部延伸
@property (nonatomic, assign) UIRectEdge fwExtendedLayoutEdge;

#pragma mark - Item

/// 快捷设置导航栏标题文字或视图
@property (nonatomic, strong, nullable) id fwBarTitle;

/// 设置导航栏左侧按钮，支持UIBarButtonItem|UIImage等，默认事件为关闭当前页面，下个页面生效
@property (nonatomic, strong, nullable) id fwLeftBarItem;

/// 设置导航栏右侧按钮，支持UIBarButtonItem|UIImage等，默认事件为关闭当前页面，下个页面生效
@property (nonatomic, strong, nullable) id fwRightBarItem;

/// 快捷设置导航栏左侧按钮。注意自定义left按钮之后，系统返回手势失效
- (void)fwSetLeftBarItem:(nullable id)object target:(id)target action:(SEL)action;

/// 快捷设置导航栏左侧按钮，block事件。注意自定义left按钮之后，系统返回手势失效
- (void)fwSetLeftBarItem:(nullable id)object block:(void (^)(id sender))block;

/// 快捷设置导航栏右侧按钮
- (void)fwSetRightBarItem:(nullable id)object target:(id)target action:(SEL)action;

/// 快捷设置导航栏右侧按钮，block事件
- (void)fwSetRightBarItem:(nullable id)object block:(void (^)(id sender))block;

/// 快捷添加导航栏左侧按钮。注意自定义left按钮之后，系统返回手势失效
- (void)fwAddLeftBarItem:(nullable id)object target:(id)target action:(SEL)action;

/// 快捷添加导航栏左侧按钮，block事件。注意自定义left按钮之后，系统返回手势失效
- (void)fwAddLeftBarItem:(nullable id)object block:(void (^)(id sender))block;

/// 快捷添加导航栏右侧按钮
- (void)fwAddRightBarItem:(nullable id)object target:(id)target action:(SEL)action;

/// 快捷添加导航栏右侧按钮，block事件
- (void)fwAddRightBarItem:(nullable id)object block:(void (^)(id sender))block;

#pragma mark - Back

/// 设置导航栏返回按钮，支持UIBarButtonItem|NSString|UIImage等，nil时显示系统箭头，下个页面生效
@property (nonatomic, strong, nullable) id fwBackBarItem;

/// 导航栏返回按钮点击事件(pop不会触发)，当前页面生效。返回YES关闭页面，NO不关闭，子类可重写。默认调用已设置的block事件
- (BOOL)fwPopBackBarItem;

/// 设置导航栏返回按钮点击block事件，默认fwPopBackBarItem自动调用。逻辑同上
@property (nonatomic, copy, nullable) BOOL (^fwBackBarBlock)(void);

@end

NS_ASSUME_NONNULL_END
