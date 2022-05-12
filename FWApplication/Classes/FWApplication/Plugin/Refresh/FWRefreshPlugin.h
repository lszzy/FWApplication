/**
 @header     FWRefreshPlugin.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/10/16
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWRefreshPlugin

/// 刷新插件协议，应用可自定义刷新插件实现
@protocol FWRefreshPlugin <NSObject>

@optional

#pragma mark - Refreshing

/// 是否正在刷新中
- (BOOL)isRefreshing:(UIScrollView *)scrollView;

/// 是否显示刷新组件
- (BOOL)showRefreshing:(UIScrollView *)scrollView;

/// 设置是否显示刷新组件
- (void)setShowRefreshing:(BOOL)showRefreshing scrollView:(UIScrollView *)scrollView;

/// 配置下拉刷新句柄
- (void)setRefreshingBlock:(void (^)(void))block scrollView:(UIScrollView *)scrollView;

/// 配置下拉刷新事件
- (void)setRefreshingTarget:(id)target action:(SEL)action scrollView:(UIScrollView *)scrollView;

/// 开始下拉刷新
- (void)beginRefreshing:(UIScrollView *)scrollView;

/// 结束下拉刷新
- (void)endRefreshing:(UIScrollView *)scrollView;

#pragma mark - Loading

/// 是否正在追加中
- (BOOL)isLoading:(UIScrollView *)scrollView;

/// 是否显示追加组件
- (BOOL)showLoading:(UIScrollView *)scrollView;

/// 设置是否显示追加组件
- (void)setShowLoading:(BOOL)showLoading scrollView:(UIScrollView *)scrollView;

/// 配置上拉追加句柄
- (void)setLoadingBlock:(void (^)(void))block scrollView:(UIScrollView *)scrollView;

/// 配置上拉追加事件
- (void)setLoadingTarget:(id)target action:(SEL)action scrollView:(UIScrollView *)scrollView;

/// 开始上拉追加
- (void)beginLoading:(UIScrollView *)scrollView;

/// 结束上拉追加
- (void)endLoading:(UIScrollView *)scrollView;

@end

#pragma mark - FWScrollViewWrapper+FWRefreshPlugin

/// UIScrollView刷新插件分类
@interface FWScrollViewWrapper (FWRefreshPlugin)

/// 自定义刷新插件，未设置时自动从插件池加载
@property (nonatomic, strong, nullable) id<FWRefreshPlugin> refreshPlugin;

#pragma mark - Refreshing

/// 是否正在刷新中
@property (nonatomic, readonly) BOOL isRefreshing;

/// 是否显示刷新组件
@property (nonatomic, assign) BOOL showRefreshing;

/// 配置下拉刷新句柄
- (void)setRefreshingBlock:(void (^)(void))block;

/// 配置下拉刷新事件
- (void)setRefreshingTarget:(id)target action:(SEL)action;

/// 开始下拉刷新
- (void)beginRefreshing;

/// 结束下拉刷新
- (void)endRefreshing;

#pragma mark - Loading

/// 是否正在追加中
@property (nonatomic, readonly) BOOL isLoading;

/// 是否显示追加组件
@property (nonatomic, assign) BOOL showLoading;

/// 配置上拉追加句柄
- (void)setLoadingBlock:(void (^)(void))block;

/// 配置上拉追加事件
- (void)setLoadingTarget:(id)target action:(SEL)action;

/// 开始上拉追加
- (void)beginLoading;

/// 结束上拉追加
- (void)endLoading;

@end

NS_ASSUME_NONNULL_END
