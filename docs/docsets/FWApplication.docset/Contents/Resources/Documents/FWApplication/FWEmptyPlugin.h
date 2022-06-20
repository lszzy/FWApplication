/**
 @header     FWEmptyPlugin.h
 @indexgroup FWApplication
      FWEmptyPlugin
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/3
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWEmptyPlugin

/// 空界面插件协议，应用可自定义空界面插件实现
NS_SWIFT_NAME(EmptyPlugin)
@protocol FWEmptyPlugin <NSObject>

@optional

/// 显示空界面，指定文本、详细文本、图片、加载视图和最多两个动作按钮
- (void)showEmptyViewWithText:(nullable NSString *)text detail:(nullable NSString *)detail image:(nullable UIImage *)image loading:(BOOL)loading actions:(nullable NSArray<NSString *> *)actions block:(nullable void (^)(NSInteger index, id sender))block inView:(UIView *)view;

/// 隐藏空界面
- (void)hideEmptyView:(UIView *)view;

/// 是否显示空界面
- (BOOL)hasEmptyView:(UIView *)view;

@end

#pragma mark - FWEmptyPluginView

/// 空界面插件视图协议，使用空界面插件
NS_REFINED_FOR_SWIFT
@protocol FWEmptyPluginView <NSObject>
@required

/// 设置空界面外间距，默认zero
@property (nonatomic, assign) UIEdgeInsets emptyInsets;

/// 是否显示空界面
@property (nonatomic, assign, readonly) BOOL hasEmptyView;

/// 显示空界面
- (void)showEmptyView;

/// 显示空界面加载视图
- (void)showEmptyViewLoading;

/// 显示空界面，指定文本
- (void)showEmptyViewWithText:(nullable NSString *)text;

/// 显示空界面，指定文本和详细文本
- (void)showEmptyViewWithText:(nullable NSString *)text detail:(nullable NSString *)detail;

/// 显示空界面，指定文本、详细文本和图片
- (void)showEmptyViewWithText:(nullable NSString *)text detail:(nullable NSString *)detail image:(nullable UIImage *)image;

/// 显示空界面，指定文本、详细文本、图片和动作按钮
- (void)showEmptyViewWithText:(nullable NSString *)text detail:(nullable NSString *)detail image:(nullable UIImage *)image action:(nullable NSString *)action block:(nullable void (^)(id sender))block;

/// 显示空界面，指定文本、详细文本、图片、是否显示加载视图和动作按钮
- (void)showEmptyViewWithText:(nullable NSString *)text detail:(nullable NSString *)detail image:(nullable UIImage *)image loading:(BOOL)loading action:(nullable NSString *)action block:(nullable void (^)(id sender))block;

/// 显示空界面，指定文本、详细文本、图片、是否显示加载视图和最多两个动作按钮
- (void)showEmptyViewWithText:(nullable NSString *)text detail:(nullable NSString *)detail image:(nullable UIImage *)image loading:(BOOL)loading actions:(nullable NSArray<NSString *> *)actions block:(nullable void (^)(NSInteger index, id sender))block;

/// 隐藏空界面
- (void)hideEmptyView;

@end

/// UIView使用空界面插件，兼容UITableView|UICollectionView
@interface FWViewWrapper (FWEmptyPluginView) <FWEmptyPluginView>

/// 自定义空界面插件，未设置时自动从插件池加载
@property (nonatomic, strong, nullable) id<FWEmptyPlugin> emptyPlugin;

@end

/// UIViewController使用空界面插件，内部使用UIViewController.view
@interface FWViewControllerWrapper (FWEmptyPluginView) <FWEmptyPluginView>

@end

#pragma mark - FWScrollViewWrapper+FWEmptyPlugin

/// 空界面代理协议
NS_SWIFT_NAME(EmptyViewDelegate)
@protocol FWEmptyViewDelegate <NSObject>
@optional

/// 显示空界面，默认调用UIScrollView.fwShowEmptyView
- (void)showEmptyView:(UIScrollView *)scrollView;

/// 隐藏空界面，默认调用UIScrollView.fwHideEmptyView
- (void)hideEmptyView:(UIScrollView *)scrollView;

/// 显示空界面时是否允许滚动，默认NO
- (BOOL)emptyViewShouldScroll:(UIScrollView *)scrollView;

/// 无数据时是否显示空界面，默认YES
- (BOOL)emptyViewShouldDisplay:(UIScrollView *)scrollView;

/// 有数据时是否强制显示空界面，默认NO
- (BOOL)emptyViewForceDisplay:(UIScrollView *)scrollView;

@end

/**
 滚动视图空界面分类
 
 @see https://github.com/dzenbot/DZNEmptyDataSet
 */
@interface FWScrollViewWrapper (FWEmptyPlugin)

/// 空界面代理，默认nil
@property (nonatomic, weak, nullable) id<FWEmptyViewDelegate> emptyViewDelegate;

/// 刷新空界面
- (void)reloadEmptyView;

@end

NS_ASSUME_NONNULL_END
