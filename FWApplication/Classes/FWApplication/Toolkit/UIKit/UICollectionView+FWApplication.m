/**
 @header     UICollectionView+FWApplication.m
 @indexgroup FWApplication
      UICollectionView+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/31
 */

#import "UICollectionView+FWApplication.h"

@implementation FWCollectionViewWrapper (FWApplication)

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
    [self.base fw_clearSizeCache];
    [self.base reloadData];
}

- (void)reloadDataWithoutAnimation
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.base reloadData];
    [CATransaction commit];
}

- (void)reloadSectionsWithoutAnimation:(NSIndexSet *)sections
{
    [self.base performBatchUpdates:^{
        [self.base reloadSections:sections];
    } completion:nil];
}

- (void)reloadItemsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.base performBatchUpdates:^{
        [self.base reloadItemsAtIndexPaths:indexPaths];
    } completion:nil];
}

- (void)performUpdates:(void (NS_NOESCAPE ^)(void))updates
{
    [self.base performBatchUpdates:updates completion:nil];
}

@end

@implementation FWCollectionViewCellWrapper (FWApplication)

- (UICollectionView *)collectionView
{
    UIView *superview = self.base.superview;
    while (superview) {
        if ([superview isKindOfClass:[UICollectionView class]]) {
            return (UICollectionView *)superview;
        }
        superview = superview.superview;
    }
    return nil;
}

- (NSIndexPath *)indexPath
{
    return [[self collectionView] indexPathForCell:self.base];
}

@end

@implementation FWCollectionViewFlowLayoutWrapper (FWApplication)

- (void)hoverWithHeader:(BOOL)header footer:(BOOL)footer
{
    self.base.sectionHeadersPinToVisibleBounds = header;
    self.base.sectionFootersPinToVisibleBounds = footer;
}

@end
