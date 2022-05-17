/**
 @header     FWRefreshPlugin.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/10/16
 */

#import "FWRefreshPlugin.h"
#import "FWRefreshPluginImpl.h"
#import <objc/runtime.h>

#pragma mark - FWScrollViewWrapper+FWRefreshPlugin

@implementation FWScrollViewWrapper (FWRefreshPlugin)

- (id<FWRefreshPlugin>)refreshPlugin
{
    id<FWRefreshPlugin> refreshPlugin = objc_getAssociatedObject(self.base, @selector(refreshPlugin));
    if (!refreshPlugin) refreshPlugin = [FWPluginManager loadPlugin:@protocol(FWRefreshPlugin)];
    if (!refreshPlugin) refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    return refreshPlugin;
}

- (void)setRefreshPlugin:(id<FWRefreshPlugin>)refreshPlugin
{
    objc_setAssociatedObject(self.base, @selector(refreshPlugin), refreshPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Refreshing

- (BOOL)isRefreshing {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(isRefreshing:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    return [refreshPlugin isRefreshing:self.base];
}

- (BOOL)shouldRefreshing {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(shouldRefreshing:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    return [refreshPlugin shouldRefreshing:self.base];
}

- (void)setShouldRefreshing:(BOOL)shouldRefreshing {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(setShouldRefreshing:scrollView:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin setShouldRefreshing:shouldRefreshing scrollView:self.base];
}

- (void)setRefreshingBlock:(void (^)(void))block {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(setRefreshingBlock:scrollView:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin setRefreshingBlock:block scrollView:self.base];
}

- (void)setRefreshingTarget:(id)target action:(SEL)action {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(setRefreshingTarget:action:scrollView:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin setRefreshingTarget:target action:action scrollView:self.base];
}

- (void)beginRefreshing {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(beginRefreshing:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin beginRefreshing:self.base];
}

- (void)endRefreshing {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(endRefreshing:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin endRefreshing:self.base];
}

#pragma mark - Loading

- (BOOL)isLoading {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(isLoading:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    return [refreshPlugin isLoading:self.base];
}

- (BOOL)shouldLoading {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(shouldLoading:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    return [refreshPlugin shouldLoading:self.base];
}

- (void)setShouldLoading:(BOOL)shouldLoading {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(setShouldLoading:scrollView:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin setShouldLoading:shouldLoading scrollView:self.base];
}

- (void)setLoadingBlock:(void (^)(void))block {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(setLoadingBlock:scrollView:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin setLoadingBlock:block scrollView:self.base];
}

- (void)setLoadingTarget:(id)target action:(SEL)action {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(setLoadingTarget:action:scrollView:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin setLoadingTarget:target action:action scrollView:self.base];
}

- (void)beginLoading {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(beginLoading:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin beginLoading:self.base];
}

- (void)endLoading {
    id<FWRefreshPlugin> refreshPlugin = self.refreshPlugin;
    if (!refreshPlugin || ![refreshPlugin respondsToSelector:@selector(endLoading:)]) {
        refreshPlugin = FWRefreshPluginImpl.sharedInstance;
    }
    [refreshPlugin endLoading:self.base];
}

@end
