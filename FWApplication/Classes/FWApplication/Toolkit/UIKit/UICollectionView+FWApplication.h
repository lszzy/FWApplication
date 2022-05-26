/**
 @header     UICollectionView+FWApplication.h
 @indexgroup FWApplication
      UICollectionView+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/31
 */

#import "FWAppWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FWCollectionViewWrapper (FWApplication)

/// reloadData完成回调
- (void)reloadDataWithCompletion:(nullable void (^)(void))completion;

/// reloadData清空尺寸缓存
- (void)reloadDataWithoutCache;

/// reloadData禁用动画
- (void)reloadDataWithoutAnimation;

/// reloadSections禁用动画
- (void)reloadSectionsWithoutAnimation:(NSIndexSet *)sections;

/// reloadItems禁用动画
- (void)reloadItemsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths;

/// 刷新高度等，不触发reload方式
- (void)performUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates;

@end

@interface FWCollectionViewCellWrapper (FWApplication)

/// 获取当前所属collectionView
@property (nonatomic, weak, readonly, nullable) UICollectionView *collectionView;

/// 获取当前显示indexPath
@property (nonatomic, readonly, nullable) NSIndexPath *indexPath;

@end

// iOS9+可通过UICollectionViewFlowLayout调用sectionHeadersPinToVisibleBounds实现Header悬停效果
@interface FWCollectionViewFlowLayoutWrapper (FWApplication)

/// 设置Header和Footer是否悬停，支持iOS9+
- (void)hoverWithHeader:(BOOL)header footer:(BOOL)footer;

@end

NS_ASSUME_NONNULL_END
