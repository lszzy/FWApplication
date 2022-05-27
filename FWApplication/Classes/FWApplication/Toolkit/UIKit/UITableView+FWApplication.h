//
//  UITableView+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 2017/6/1.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

// UITableView分类(Plain有悬停，Group无悬停)
@interface FWTableViewWrapper (FWApplication)

/// 是否启动高度估算布局，启用后需要子视图布局完整，无需实现heightForRow方法(iOS11默认启用，会先cellForRow再heightForRow)
@property (nonatomic, assign) BOOL estimatedLayout UI_APPEARANCE_SELECTOR;

/// 清空Grouped样式默认多余边距，注意CGFLOAT_MIN才会生效，0不会生效
- (void)resetGroupedStyle;

/// 设置Plain样式sectionHeader和Footer跟随滚动(不悬停)，在scrollViewDidScroll:中调用即可(需先禁用内边距适应)
- (void)followWithHeader:(CGFloat)headerHeight footer:(CGFloat)footerHeight;

/// reloadData完成回调
- (void)reloadDataWithCompletion:(nullable void (^)(void))completion;

/// reloadData清空尺寸缓存
- (void)reloadDataWithoutCache;

/// reloadData禁用动画
- (void)reloadDataWithoutAnimation;

/// reloadSections禁用动画
- (void)reloadSectionsWithoutAnimation:(NSIndexSet *)sections;

/// reloadRows禁用动画
- (void)reloadRowsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths;

/// 刷新高度等，不触发reload方式
- (void)performUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates;

@end

@interface FWTableViewClassWrapper (FWApplication)

/// 全局清空TableView默认多余边距
- (void)resetTableStyle;

@end

@interface FWTableViewCellWrapper (FWApplication)

/// 设置分割线内边距，iOS8+默认15.f，设为UIEdgeInsetsZero可去掉
@property (nonatomic, assign) UIEdgeInsets separatorInset;

/// 获取当前所属tableView
@property (nonatomic, weak, readonly, nullable) UITableView *tableView;

/// 获取当前显示indexPath
@property (nonatomic, readonly, nullable) NSIndexPath *indexPath;

@end

/**
 TableViewCell背景视图，处理section圆角、阴影等
 */
NS_SWIFT_NAME(TableViewCellBackgroundView)
@interface FWTableViewCellBackgroundView : UIView

// 背景内容视图，此视图用于设置圆角，阴影等
@property (nonatomic, strong, readonly) UIView *contentView;

// 内容视图间距，处理section圆角时该值可能为负。默认zoro占满
@property (nonatomic, assign) UIEdgeInsets contentInset;

// 设置section内容间距，设置后再设置圆角，阴影即可。第一个顶部间距(底部超出)，最后一个底部间距(顶部超出)，中间无上下间距(上下超出)
- (void)setSectionContentInset:(UIEdgeInsets)contentInset tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 backgroundView不会影响contentView布局等，如果设置了contentInset，注意布局时留出对应间距
 */
@interface FWTableViewCellWrapper (FWBackgroundView)

// 延迟加载背景视图，处理section圆角、阴影等。会自动设置backgroundView
@property (nonatomic, strong, readonly) FWTableViewCellBackgroundView *backgroundView;

@end

NS_ASSUME_NONNULL_END
