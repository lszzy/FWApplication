//
//  UITableView+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 2017/6/1.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UITableView+FWApplication.h"
#import <objc/runtime.h>

@implementation FWTableViewWrapper (FWApplication)

- (BOOL)estimatedLayout
{
    return self.base.estimatedRowHeight == UITableViewAutomaticDimension;
}

- (void)setEstimatedLayout:(BOOL)enabled
{
    if (enabled) {
        self.base.estimatedRowHeight = UITableViewAutomaticDimension;
        self.base.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        self.base.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
    } else {
        self.base.estimatedRowHeight = 0.f;
        self.base.estimatedSectionHeaderHeight = 0.f;
        self.base.estimatedSectionFooterHeight = 0.f;
    }
}

- (void)resetGroupedStyle
{
    self.base.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.base.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.base.sectionHeaderHeight = 0;
    self.base.sectionFooterHeight = 0;
#if __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        self.base.sectionHeaderTopPadding = 0;
    }
#endif
}

- (void)followWithHeader:(CGFloat)headerHeight footer:(CGFloat)footerHeight
{
    CGFloat offsetY = self.base.contentOffset.y;
    if (offsetY >= 0 && offsetY <= headerHeight) {
        self.base.contentInset = UIEdgeInsetsMake(-offsetY, 0, -footerHeight, 0);
    } else if (offsetY >= headerHeight && offsetY <= self.base.contentSize.height - self.base.frame.size.height - footerHeight) {
        self.base.contentInset = UIEdgeInsetsMake(-headerHeight, 0, -footerHeight, 0);
    } else if (offsetY >= self.base.contentSize.height - self.base.frame.size.height - footerHeight && offsetY <= self.base.contentSize.height - self.base.frame.size.height) {
        self.base.contentInset = UIEdgeInsetsMake(-offsetY, 0, -(self.base.contentSize.height - self.base.frame.size.height - footerHeight), 0);
    }
}

- (void)reloadDataWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0 animations:^{
        [self.base reloadData];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)reloadDataWithoutCache
{
    [self.base fw_clearHeightCache];
    [self.base reloadData];
}

- (void)reloadDataWithoutAnimation
{
    [UIView performWithoutAnimation:^{
        [self.base reloadData];
    }];
}

- (void)reloadSectionsWithoutAnimation:(NSIndexSet *)sections
{
    [UIView performWithoutAnimation:^{
        [self.base reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)reloadRowsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths
{
    [UIView performWithoutAnimation:^{
        [self.base reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)performUpdates:(void (NS_NOESCAPE ^)(void))updates
{
    [self.base performBatchUpdates:updates completion:nil];
}

@end

@implementation FWTableViewClassWrapper (FWApplication)

- (void)resetTableStyle
{
#if __IPHONE_15_0
    if (@available(iOS 15.0, *)) {
        UITableView.appearance.sectionHeaderTopPadding = 0;
    }
#endif
}

@end

@implementation FWTableViewCellWrapper (FWApplication)

- (UIEdgeInsets)separatorInset
{
    return self.base.separatorInset;
}

- (void)setSeparatorInset:(UIEdgeInsets)separatorInset
{
    self.base.separatorInset = separatorInset;
    
    if ([self.base respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self.base setPreservesSuperviewLayoutMargins:NO];
    }
    if ([self.base respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.base setLayoutMargins:separatorInset];
    }
}

- (UITableView *)tableView
{
    UIView *superview = self.base.superview;
    while (superview) {
        if ([superview isKindOfClass:[UITableView class]]) {
            return (UITableView *)superview;
        }
        superview = superview.superview;
    }
    return nil;
}

- (NSIndexPath *)indexPath
{
    return [[self tableView] indexPathForCell:self.base];
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
        [_contentView fw_pinEdgesToSuperview];
    }
    return self;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    
    [self.contentView fw_pinEdgesToSuperviewWithInsets:contentInset];
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

@implementation FWTableViewCellWrapper (FWBackgroundView)

- (FWTableViewCellBackgroundView *)backgroundView
{
    FWTableViewCellBackgroundView *backgroundView = objc_getAssociatedObject(self.base, _cmd);
    if (!backgroundView) {
        backgroundView = [[FWTableViewCellBackgroundView alloc] initWithFrame:CGRectZero];
        objc_setAssociatedObject(self.base, _cmd, backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        // 需设置cell背景色为透明
        self.base.backgroundColor = [UIColor clearColor];
        self.base.backgroundView = backgroundView;
    }
    return backgroundView;
}

@end
