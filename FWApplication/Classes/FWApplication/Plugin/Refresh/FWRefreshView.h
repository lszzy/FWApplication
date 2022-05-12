/**
 @header     FWRefreshView.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/10/16
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWScrollViewWrapper+FWPullRefresh

typedef NS_ENUM(NSUInteger, FWPullRefreshState) {
    FWPullRefreshStateStopped = 0,
    FWPullRefreshStateTriggered,
    FWPullRefreshStateLoading,
    FWPullRefreshStateAll = 10
};

@protocol FWIndicatorViewPlugin;

/**
 下拉刷新视图，默认高度60
 @note 如果indicatorView为自定义指示器时会自动隐藏标题和箭头，仅显示指示器视图
*/
@interface FWPullRefreshView : UIView

@property (class, nonatomic, assign) CGFloat height;
@property (nullable, nonatomic, strong) UIColor *arrowColor;
@property (nullable, nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView<FWIndicatorViewPlugin> *indicatorView;
@property (nullable, nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, assign) CGFloat indicatorPadding;
@property (nonatomic, assign) BOOL showsTitleLabel;
@property (nonatomic, assign) BOOL showsArrowView;
@property (nonatomic, assign) BOOL shouldChangeAlpha;

@property (nonatomic, readonly) FWPullRefreshState state;
@property (nonatomic, assign, readonly) BOOL userTriggered;
@property (nullable, nonatomic, copy) void (^stateBlock)(FWPullRefreshView *view, FWPullRefreshState state);
@property (nullable, nonatomic, copy) void (^progressBlock)(FWPullRefreshView *view, CGFloat progress);

- (void)setTitle:(nullable NSString *)title forState:(FWPullRefreshState)state;
- (void)setSubtitle:(nullable NSString *)subtitle forState:(FWPullRefreshState)state;
- (void)setCustomView:(nullable UIView *)view forState:(FWPullRefreshState)state;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end

/**
 FWScrollViewWrapper+FWPullRefresh
 
 @see https://github.com/samvermette/SVPullToRefresh
 */
@interface FWScrollViewWrapper (FWPullRefresh)

- (void)addPullRefreshWithBlock:(void (^)(void))block;
- (void)addPullRefreshWithTarget:(id)target action:(SEL)action;
- (void)triggerPullRefresh;

@property (nullable, nonatomic, strong, readonly) FWPullRefreshView *pullRefreshView;
@property (nonatomic, assign) CGFloat pullRefreshHeight;
@property (nonatomic, assign) BOOL showPullRefresh;

@end

#pragma mark - FWScrollViewWrapper+FWInfiniteScroll

typedef NS_ENUM(NSUInteger, FWInfiniteScrollState) {
    FWInfiniteScrollStateStopped = 0,
    FWInfiniteScrollStateTriggered,
    FWInfiniteScrollStateLoading,
    FWInfiniteScrollStateAll = 10
};

/**
 上拉追加视图，默认高度60
 */
@interface FWInfiniteScrollView : UIView

@property (class, nonatomic, assign) CGFloat height;
@property (nonatomic, readwrite) BOOL enabled;
@property (nonatomic, readwrite, assign) CGFloat preloadHeight;
@property (nonatomic, strong) UIView<FWIndicatorViewPlugin> *indicatorView;
@property (nullable, nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, assign) CGFloat indicatorPadding;

@property (nonatomic, readonly) FWInfiniteScrollState state;
@property (nonatomic, assign, readonly) BOOL userTriggered;
@property (nullable, nonatomic, copy) void (^stateBlock)(FWInfiniteScrollView *view, FWInfiniteScrollState state);
@property (nullable, nonatomic, copy) void (^progressBlock)(FWInfiniteScrollView *view, CGFloat progress);

- (void)setCustomView:(nullable UIView *)view forState:(FWInfiniteScrollState)state;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end

/**
 FWScrollViewWrapper+FWInfiniteScroll
 
 @see https://github.com/samvermette/SVPullToRefresh
 */
@interface FWScrollViewWrapper (FWInfiniteScroll)

- (void)addInfiniteScrollWithBlock:(void (^)(void))block;
- (void)addInfiniteScrollWithTarget:(id)target action:(SEL)action;
- (void)triggerInfiniteScroll;

@property (nullable, nonatomic, strong, readonly) FWInfiniteScrollView *infiniteScrollView;
@property (nonatomic, assign) CGFloat infiniteScrollHeight;
@property (nonatomic, assign) BOOL showInfiniteScroll;

@end

NS_ASSUME_NONNULL_END
