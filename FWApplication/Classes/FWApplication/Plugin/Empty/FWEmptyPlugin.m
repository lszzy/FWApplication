/**
 @header     FWEmptyPlugin.m
 @indexgroup FWApplication
      FWEmptyPlugin
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/3
 */

#import "FWEmptyPlugin.h"
#import "FWEmptyPluginImpl.h"
#import <objc/runtime.h>

#pragma mark - FWEmptyPluginView

@implementation FWViewWrapper (FWEmptyPluginView)

- (id<FWEmptyPlugin>)emptyPlugin
{
    id<FWEmptyPlugin> emptyPlugin = objc_getAssociatedObject(self.base, @selector(emptyPlugin));
    if (!emptyPlugin) emptyPlugin = [FWPluginManager loadPlugin:@protocol(FWEmptyPlugin)];
    if (!emptyPlugin) emptyPlugin = FWEmptyPluginImpl.sharedInstance;
    return emptyPlugin;
}

- (void)setEmptyPlugin:(id<FWEmptyPlugin>)emptyPlugin
{
    objc_setAssociatedObject(self.base, @selector(emptyPlugin), emptyPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)emptyInsets
{
    NSValue *insets = objc_getAssociatedObject(self.base, @selector(emptyInsets));
    return insets ? [insets UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setEmptyInsets:(UIEdgeInsets)emptyInsets
{
    objc_setAssociatedObject(self.base, @selector(emptyInsets), [NSValue valueWithUIEdgeInsets:emptyInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showEmptyView
{
    [self showEmptyViewWithText:nil];
}

- (void)showEmptyViewLoading
{
    [self showEmptyViewWithText:nil detail:nil image:nil loading:YES action:nil block:nil];
}

- (void)showEmptyViewWithText:(NSString *)text
{
    [self showEmptyViewWithText:text detail:nil];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail
{
    [self showEmptyViewWithText:text detail:detail image:nil];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image
{
    [self showEmptyViewWithText:text detail:detail image:image action:nil block:nil];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image action:(NSString *)action block:(void (^)(id _Nonnull))block
{
    [self showEmptyViewWithText:text detail:detail image:image loading:NO action:action block:block];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image loading:(BOOL)loading action:(NSString *)action block:(void (^)(id _Nonnull))block
{
    id<FWEmptyPlugin> plugin = self.emptyPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(showEmptyViewWithText:detail:image:loading:action:block:inView:)]) {
        plugin = FWEmptyPluginImpl.sharedInstance;
    }
    
    if ([self.base isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.base;
        [scrollView.fw showOverlayView];
        [plugin showEmptyViewWithText:text detail:detail image:image loading:loading action:action block:block inView:scrollView.fw.overlayView];
    } else {
        [plugin showEmptyViewWithText:text detail:detail image:image loading:loading action:action block:block inView:self.base];
    }
}

- (void)hideEmptyView
{
    id<FWEmptyPlugin> plugin = self.emptyPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hideEmptyView:)]) {
        plugin = FWEmptyPluginImpl.sharedInstance;
    }
    
    if ([self.base isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.base;
        [plugin hideEmptyView:scrollView.fw.overlayView];
        [scrollView.fw hideOverlayView];
    } else {
        [plugin hideEmptyView:self.base];
    }
}

- (BOOL)hasEmptyView
{
    id<FWEmptyPlugin> plugin = self.emptyPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hasEmptyView:)]) {
        plugin = FWEmptyPluginImpl.sharedInstance;
    }
    
    if ([self.base isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.base;
        return scrollView.fw.hasOverlayView && [plugin hasEmptyView:scrollView.fw.overlayView];;
    } else {
        return [plugin hasEmptyView:self.base];
    }
}

@end

@implementation FWViewControllerWrapper (FWEmptyPluginView)

- (UIEdgeInsets)emptyInsets
{
    return self.base.view.fw.emptyInsets;
}

- (void)setEmptyInsets:(UIEdgeInsets)emptyInsets
{
    self.base.view.fw.emptyInsets = emptyInsets;
}

- (void)showEmptyView
{
    [self.base.view.fw showEmptyView];
}

- (void)showEmptyViewLoading
{
    [self.base.view.fw showEmptyViewLoading];
}

- (void)showEmptyViewWithText:(NSString *)text
{
    [self.base.view.fw showEmptyViewWithText:text];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail
{
    [self.base.view.fw showEmptyViewWithText:text detail:detail];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image
{
    [self.base.view.fw showEmptyViewWithText:text detail:detail image:image];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image action:(NSString *)action block:(void (^)(id _Nonnull))block
{
    [self.base.view.fw showEmptyViewWithText:text detail:detail image:image action:action block:block];
}

- (void)showEmptyViewWithText:(NSString *)text detail:(NSString *)detail image:(UIImage *)image loading:(BOOL)loading action:(NSString *)action block:(void (^)(id _Nonnull))block
{
    [self.base.view.fw showEmptyViewWithText:text detail:detail image:image loading:loading action:action block:block];
}

- (void)hideEmptyView
{
    [self.base.view.fw hideEmptyView];
}

- (BOOL)hasEmptyView
{
    return [self.base.view.fw hasEmptyView];
}

@end

#pragma mark - FWScrollViewWrapper+FWEmptyPlugin

@interface FWScrollViewClassWrapper (FWEmptyPlugin)

@end

@implementation FWScrollViewClassWrapper (FWEmptyPlugin)

- (void)enableEmptyPlugin
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UITableView, @selector(reloadData), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            [selfObject.fw reloadEmptyView];
            FWSwizzleOriginal();
        }));
        
        FWSwizzleClass(UITableView, @selector(endUpdates), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            [selfObject.fw reloadEmptyView];
            FWSwizzleOriginal();
        }));
        
        FWSwizzleClass(UICollectionView, @selector(reloadData), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            [selfObject.fw reloadEmptyView];
            FWSwizzleOriginal();
        }));
    });
}

@end

@implementation FWScrollViewWrapper (FWEmptyPlugin)

- (id<FWEmptyViewDelegate>)emptyViewDelegate
{
    FWWeakObject *value = objc_getAssociatedObject(self.base, @selector(emptyViewDelegate));
    return value.object;
}

- (void)setEmptyViewDelegate:(id<FWEmptyViewDelegate>)delegate
{
    if (!delegate) [self invalidateEmptyView];
    objc_setAssociatedObject(self.base, @selector(emptyViewDelegate), [[FWWeakObject alloc] initWithObject:delegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [UIScrollView.fw enableEmptyPlugin];
}

- (void)reloadEmptyView
{
    if (!self.emptyViewDelegate) return;
    
    BOOL shouldDisplay = NO;
    if ([self.emptyViewDelegate respondsToSelector:@selector(emptyViewForceDisplay:)]) {
        shouldDisplay = [self.emptyViewDelegate emptyViewForceDisplay:self.base];
    }
    if (!shouldDisplay) {
        if ([self.emptyViewDelegate respondsToSelector:@selector(emptyViewShouldDisplay:)]) {
            shouldDisplay = [self.emptyViewDelegate emptyViewShouldDisplay:self.base] && [self emptyItemsCount] == 0;
        } else {
            shouldDisplay = [self emptyItemsCount] == 0;
        }
    }
    
    BOOL hideSuccess = [self invalidateEmptyView];
    if (shouldDisplay) {
        objc_setAssociatedObject(self.base, @selector(invalidateEmptyView), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if ([self.emptyViewDelegate respondsToSelector:@selector(emptyViewShouldScroll:)]) {
            self.base.scrollEnabled = [self.emptyViewDelegate emptyViewShouldScroll:self.base];
        } else {
            self.base.scrollEnabled = NO;
        }
        
        BOOL fadeAnimated = FWEmptyPluginImpl.sharedInstance.fadeAnimated;
        FWEmptyPluginImpl.sharedInstance.fadeAnimated = hideSuccess ? NO : fadeAnimated;
        if ([self.emptyViewDelegate respondsToSelector:@selector(showEmptyView:)]) {
            [self.emptyViewDelegate showEmptyView:self.base];
        } else {
            [self showEmptyView];
        }
        FWEmptyPluginImpl.sharedInstance.fadeAnimated = fadeAnimated;
    }
}

- (BOOL)invalidateEmptyView
{
    if (![objc_getAssociatedObject(self.base, @selector(invalidateEmptyView)) boolValue]) return NO;
    objc_setAssociatedObject(self.base, @selector(invalidateEmptyView), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.base.scrollEnabled = YES;
    
    if ([self.emptyViewDelegate respondsToSelector:@selector(hideEmptyView:)]) {
        [self.emptyViewDelegate hideEmptyView:self.base];
    } else {
        [self hideEmptyView];
    }
    return YES;
}

- (NSInteger)emptyItemsCount
{
    NSInteger items = 0;
    if (![self.base respondsToSelector:@selector(dataSource)]) {
        return items;
    }
    
    if ([self.base isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.base;
        id<UITableViewDataSource> dataSource = tableView.dataSource;
        
        NSInteger sections = 1;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            sections = [dataSource numberOfSectionsInTableView:tableView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource tableView:tableView numberOfRowsInSection:section];
            }
        }
    } else if ([self.base isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.base;
        id<UICollectionViewDataSource> dataSource = collectionView.dataSource;
        
        NSInteger sections = 1;
        if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            sections = [dataSource numberOfSectionsInCollectionView:collectionView];
        }
        
        if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
            for (NSInteger section = 0; section < sections; section++) {
                items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
            }
        }
    }
    return items;
}

@end
