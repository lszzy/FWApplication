//
//  UITableView+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 2017/6/1.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UITableView+FWApplication.h"
#import <objc/runtime.h>
@import FWFramework;

@implementation UITableView (FWApplication)

+ (void)fwResetTableStyle
{
#if __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        UITableView.appearance.sectionHeaderTopPadding = 0;
    }
#endif
}

- (void)fwResetGroupedStyle
{
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.sectionHeaderHeight = 0;
    self.sectionFooterHeight = 0;
#if __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        self.sectionHeaderTopPadding = 0;
    }
#endif
}

- (void)fwFollowWithHeader:(CGFloat)headerHeight footer:(CGFloat)footerHeight
{
    CGFloat offsetY = self.contentOffset.y;
    if (offsetY >= 0 && offsetY <= headerHeight) {
        self.contentInset = UIEdgeInsetsMake(-offsetY, 0, -footerHeight, 0);
    } else if (offsetY >= headerHeight && offsetY <= self.contentSize.height - self.frame.size.height - footerHeight) {
        self.contentInset = UIEdgeInsetsMake(-headerHeight, 0, -footerHeight, 0);
    } else if (offsetY >= self.contentSize.height - self.frame.size.height - footerHeight && offsetY <= self.contentSize.height - self.frame.size.height) {
        self.contentInset = UIEdgeInsetsMake(-offsetY, 0, -(self.contentSize.height - self.frame.size.height - footerHeight), 0);
    }
}

- (void)fwReloadDataWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0 animations:^{
        [self reloadData];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)fwReloadDataWithoutCache
{
    [self fwClearHeightCache];
    [self fwClearTemplateHeightCache];
    [self reloadData];
}

- (void)fwReloadDataWithoutAnimation
{
    [UIView performWithoutAnimation:^{
        [self reloadData];
    }];
}

- (void)fwReloadSectionsWithoutAnimation:(NSIndexSet *)sections
{
    [UIView performWithoutAnimation:^{
        [self reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)fwReloadRowsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths
{
    [UIView performWithoutAnimation:^{
        [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)fwPerformUpdates:(void (NS_NOESCAPE ^)(void))updates
{
    [self performBatchUpdates:updates completion:nil];
}

@end

@implementation UITableViewCell (FWApplication)

- (UIEdgeInsets)fwSeparatorInset
{
    return self.separatorInset;
}

- (void)setFwSeparatorInset:(UIEdgeInsets)fwSeparatorInset
{
    self.separatorInset = fwSeparatorInset;
    
    // iOS8+
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self setPreservesSuperviewLayoutMargins:NO];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:fwSeparatorInset];
    }
}

- (UITableView *)fwTableView
{
    UIView *superview = self.superview;
    while (superview) {
        if ([superview isKindOfClass:[UITableView class]]) {
            return (UITableView *)superview;
        }
        superview = superview.superview;
    }
    return nil;
}

- (NSIndexPath *)fwIndexPath
{
    return [[self fwTableView] indexPathForCell:self];
}

@end

@implementation FWTableViewCellBackgroundView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.layer.masksToBounds = NO;
        [self addSubview:_contentView];
        [_contentView.fw pinEdgesToSuperview];
    }
    return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    
    [self.contentView.fw pinEdgesToSuperviewWithInsets:contentInset];
}

- (void)setSectionContentInset:(UIEdgeInsets)contentInset tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sectionRows = [tableView numberOfRowsInSection:indexPath.section];
    BOOL isFirstRow = (indexPath.row == 0);
    BOOL isLastRow = (indexPath.row == sectionRows - 1);
    if (isFirstRow && isLastRow) {
        self.contentInset = contentInset;
    } else if (isFirstRow) {
        self.contentInset = UIEdgeInsetsMake(contentInset.top, contentInset.left, -contentInset.bottom, contentInset.right);
    } else if (isLastRow) {
        self.contentInset = UIEdgeInsetsMake(-contentInset.top, contentInset.left, contentInset.bottom, contentInset.right);
    } else {
        self.contentInset = UIEdgeInsetsMake(-contentInset.top, contentInset.left, -contentInset.bottom, contentInset.right);
    }
}

@end

@implementation UITableViewCell (FWBackgroundView)

- (FWTableViewCellBackgroundView *)fwBackgroundView
{
    FWTableViewCellBackgroundView *backgroundView = objc_getAssociatedObject(self, _cmd);
    if (!backgroundView) {
        backgroundView = [[FWTableViewCellBackgroundView alloc] initWithFrame:CGRectZero];
        objc_setAssociatedObject(self, _cmd, backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // 需设置cell背景色为透明
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;
    }
    return backgroundView;
}

@end

#pragma mark - UITableView+FWTemplateLayout

@implementation UITableView (FWTemplateLayout)

- (void)fwSetTemplateLayout:(BOOL)enabled
{
    if (enabled) {
        self.rowHeight = UITableViewAutomaticDimension;
        self.sectionHeaderHeight = UITableViewAutomaticDimension;
        self.sectionFooterHeight = UITableViewAutomaticDimension;
        self.estimatedRowHeight = UITableViewAutomaticDimension;
        self.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        self.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
    } else {
        self.estimatedRowHeight = 0.f;
        self.estimatedSectionHeaderHeight = 0.f;
        self.estimatedSectionFooterHeight = 0.f;
    }
}

- (CGFloat)fwTemplateHeightAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = [self.fwInnerTemplateHeightCache objectForKey:indexPath];
    if (height) {
        return height.floatValue;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (void)fwSetTemplateHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath
{
    if (height > 0) {
        [self.fwInnerTemplateHeightCache setObject:@(height) forKey:indexPath];
    } else {
        [self.fwInnerTemplateHeightCache removeObjectForKey:indexPath];
    }
}

- (void)fwClearTemplateHeightCache
{
    [self.fwInnerTemplateHeightCache removeAllObjects];
}

- (NSMutableDictionary *)fwInnerTemplateHeightCache
{
    NSMutableDictionary *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [NSMutableDictionary new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end
