/**
 @header     UICollectionView+FWApplication.h
 @indexgroup FWApplication
      UICollectionView+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/31
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (FWApplication)

/// reloadData完成回调
- (void)fw_reloadDataWithCompletion:(nullable void (^)(void))completion NS_REFINED_FOR_SWIFT;

/// reloadData清空尺寸缓存
- (void)fw_reloadDataWithoutCache NS_REFINED_FOR_SWIFT;

/// reloadData禁用动画
- (void)fw_reloadDataWithoutAnimation NS_REFINED_FOR_SWIFT;

/// reloadSections禁用动画
- (void)fw_reloadSectionsWithoutAnimation:(NSIndexSet *)sections NS_REFINED_FOR_SWIFT;

/// reloadItems禁用动画
- (void)fw_reloadItemsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths NS_REFINED_FOR_SWIFT;

/// 刷新高度等，不触发reload方式
- (void)fw_performUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates NS_REFINED_FOR_SWIFT;

@end

// iOS9+可通过UICollectionViewFlowLayout调用sectionHeadersPinToVisibleBounds实现Header悬停效果
@interface UICollectionViewFlowLayout (FWApplication)

/// 设置Header和Footer是否悬停，支持iOS9+
- (void)fw_hoverWithHeader:(BOOL)header footer:(BOOL)footer NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
