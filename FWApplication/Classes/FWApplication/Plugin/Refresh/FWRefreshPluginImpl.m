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
    return scrollView.fw_pullRefreshView.state == FWPullRefreshStateLoading;
}

- (BOOL)shouldRefreshing:(UIScrollView *)scrollView {
    return scrollView.fw_showPullRefresh;
}

- (void)setShouldRefreshing:(BOOL)shouldRefreshing scrollView:(UIScrollView *)scrollView {
    scrollView.fw_showPullRefresh = shouldRefreshing;
}

- (void)setRefreshingBlock:(void (^)(void))block scrollView:(UIScrollView *)scrollView {
    [scrollView fw_addPullRefreshWithBlock:block];
    if (self.pullRefreshBlock) self.pullRefreshBlock(scrollView.fw_pullRefreshView);
}

- (void)setRefreshingTarget:(id)target action:(SEL)action scrollView:(UIScrollView *)scrollView {
    [scrollView fw_addPullRefreshWithTarget:target action:action];
    if (self.pullRefreshBlock) self.pullRefreshBlock(scrollView.fw_pullRefreshView);
}

- (void)beginRefreshing:(UIScrollView *)scrollView {
    [scrollView fw_triggerPullRefresh];
}

- (void)endRefreshing:(UIScrollView *)scrollView {
    [scrollView.fw_pullRefreshView stopAnimating];
}

#pragma mark - Loading

- (BOOL)isLoading:(UIScrollView *)scrollView {
    return scrollView.fw_infiniteScrollView.state == FWInfiniteScrollStateLoading;
}

- (BOOL)shouldLoading:(UIScrollView *)scrollView {
    return scrollView.fw_showInfiniteScroll;
}

- (void)setShouldLoading:(BOOL)shouldLoading scrollView:(UIScrollView *)scrollView {
    scrollView.fw_showInfiniteScroll = shouldLoading;
}

- (BOOL)loadingFinished:(UIScrollView *)scrollView {
    return scrollView.fw_infiniteScrollFinished;
}

- (void)setLoadingFinished:(BOOL)loadingFinished scrollView:(UIScrollView *)scrollView {
    scrollView.fw_infiniteScrollFinished = loadingFinished;
}

- (void)setLoadingBlock:(void (^)(void))block scrollView:(UIScrollView *)scrollView {
    [scrollView fw_addInfiniteScrollWithBlock:block];
    if (self.infiniteScrollBlock) self.infiniteScrollBlock(scrollView.fw_infiniteScrollView);
}

- (void)setLoadingTarget:(id)target action:(SEL)action scrollView:(UIScrollView *)scrollView {
    [scrollView fw_addInfiniteScrollWithTarget:target action:action];
    if (self.infiniteScrollBlock) self.infiniteScrollBlock(scrollView.fw_infiniteScrollView);
}

- (void)beginLoading:(UIScrollView *)scrollView {
    [scrollView fw_triggerInfiniteScroll];
}

- (void)endLoading:(UIScrollView *)scrollView {
    [scrollView.fw_infiniteScrollView stopAnimating];
}

@end
