/**
 @header     UICollectionView+FWApplication.m
 @indexgroup FWApplication
      UICollectionView+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/31
 */

#import "UICollectionView+FWApplication.h"
@import FWFramework;

@implementation UICollectionView (FWApplication)

- (void)fw_reloadDataWithCompletion:(void (^)(void))completion
{
    [UIView animateWithDuration:0 animations:^{
        [self reloadData];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)fw_reloadDataWithoutCache
{
    [self fw_clearSizeCache];
    [self reloadData];
}

- (void)fw_reloadDataWithoutAnimation
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self reloadData];
    [CATransaction commit];
}

- (void)fw_reloadSectionsWithoutAnimation:(NSIndexSet *)sections
{
    [self performBatchUpdates:^{
        [self reloadSections:sections];
    } completion:nil];
}

- (void)fw_reloadItemsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths
{
    [self performBatchUpdates:^{
        [self reloadItemsAtIndexPaths:indexPaths];
    } completion:nil];
}

- (void)fw_performUpdates:(void (NS_NOESCAPE ^)(void))updates
{
    [self performBatchUpdates:updates completion:nil];
}

@end

@implementation UICollectionViewFlowLayout (FWApplication)

- (void)fw_hoverWithHeader:(BOOL)header footer:(BOOL)footer
{
    self.sectionHeadersPinToVisibleBounds = header;
    self.sectionFootersPinToVisibleBounds = footer;
}

@end
