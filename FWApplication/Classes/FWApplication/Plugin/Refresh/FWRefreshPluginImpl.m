/**
 @header     FWRefreshPluginImpl.m
 @indexgroup FWApplication
      FWRefreshPlugin
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/10/16
 */

#import "FWRefreshPluginImpl.h"

#pragma mark - FWRefreshPluginImpl

@implementation FWRefreshPluginImpl

+ (FWRefreshPluginImpl *)sharedInstance {
    static FWRefreshPluginImpl *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWRefreshPluginImpl alloc] init];
    });
    return instance;
}

#pragma mark - Refreshing

- (BOOL)isRefreshing:(UIScrollView *)scrollView {
    return scrollView.fw.pullRefreshView.state == FWPullRefreshStateLoading;
}

- (BOOL)shouldRefreshing:(UIScrollView *)scrollView {
    return scrollView.fw.showPullRefresh;
}

- (void)setShouldRefreshing:(BOOL)shouldRefreshing scrollView:(UIScrollView *)scrollView {
    scrollView.fw.showPullRefresh = shouldRefreshing;
}

- (void)setRefreshingBlock:(void (^)(void))block scrollView:(UIScrollView *)scrollView {
    [scrollView.fw addPullRefreshWithBlock:block];
    if (self.pullRefreshBlock) self.pullRefreshBlock(scrollView.fw.pullRefreshView);
}

- (void)setRefreshingTarget:(id)target action:(SEL)action scrollView:(UIScrollView *)scrollView {
    [scrollView.fw addPullRefreshWithTarget:target action:action];
    if (self.pullRefreshBlock) self.pullRefreshBlock(scrollView.fw.pullRefreshView);
}

- (void)beginRefreshing:(UIScrollView *)scrollView {
    [scrollView.fw triggerPullRefresh];
}

- (void)endRefreshing:(UIScrollView *)scrollView {
    [scrollView.fw.pullRefreshView stopAnimating];
}

#pragma mark - Loading

- (BOOL)isLoading:(UIScrollView *)scrollView {
    return scrollView.fw.infiniteScrollView.state == FWInfiniteScrollStateLoading;
}

- (BOOL)shouldLoading:(UIScrollView *)scrollView {
    return scrollView.fw.showInfiniteScroll;
}

- (void)setShouldLoading:(BOOL)shouldLoading scrollView:(UIScrollView *)scrollView {
    scrollView.fw.showInfiniteScroll = shouldLoading;
}

- (void)setLoadingBlock:(void (^)(void))block scrollView:(UIScrollView *)scrollView {
    [scrollView.fw addInfiniteScrollWithBlock:block];
    if (self.infiniteScrollBlock) self.infiniteScrollBlock(scrollView.fw.infiniteScrollView);
}

- (void)setLoadingTarget:(id)target action:(SEL)action scrollView:(UIScrollView *)scrollView {
    [scrollView.fw addInfiniteScrollWithTarget:target action:action];
    if (self.infiniteScrollBlock) self.infiniteScrollBlock(scrollView.fw.infiniteScrollView);
}

- (void)beginLoading:(UIScrollView *)scrollView {
    [scrollView.fw triggerInfiniteScroll];
}

- (void)endLoading:(UIScrollView *)scrollView {
    [scrollView.fw.infiniteScrollView stopAnimating];
}

@end
