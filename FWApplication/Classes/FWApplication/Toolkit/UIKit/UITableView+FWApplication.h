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
@interface UITableView (FWApplication)

/// 是否启动高度估算布局，启用后需要子视图布局完整，无需实现heightForRow方法(iOS11默认启用，会先cellForRow再heightForRow)
@property (nonatomic, assign) BOOL fw_estimatedLayout UI_APPEARANCE_SELECTOR NS_REFINED_FOR_SWIFT;

/// 清空Grouped样式默认多余边距，注意CGFLOAT_MIN才会生效，0不会生效
- (void)fw_resetGroupedStyle NS_REFINED_FOR_SWIFT;

/// 设置Plain样式sectionHeader和Footer跟随滚动(不悬停)，在scrollViewDidScroll:中调用即可(需先禁用内边距适应)
- (void)fw_followWithHeader:(CGFloat)headerHeight footer:(CGFloat)footerHeight NS_REFINED_FOR_SWIFT;

/// reloadData完成回调
- (void)fw_reloadDataWithCompletion:(nullable void (^)(void))completion NS_REFINED_FOR_SWIFT;

/// reloadData清空尺寸缓存
- (void)fw_reloadDataWithoutCache NS_REFINED_FOR_SWIFT;

/// reloadData禁用动画
- (void)fw_reloadDataWithoutAnimation NS_REFINED_FOR_SWIFT;

/// reloadSections禁用动画
- (void)fw_reloadSectionsWithoutAnimation:(NSIndexSet *)sections NS_REFINED_FOR_SWIFT;

/// reloadRows禁用动画
- (void)fw_reloadRowsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths NS_REFINED_FOR_SWIFT;

/// 刷新高度等，不触发reload方式
- (void)fw_performUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates NS_REFINED_FOR_SWIFT;

/// 全局清空TableView默认多余边距
+ (void)fw_resetTableStyle NS_REFINED_FOR_SWIFT;

@end

/**
 TableViewCell背景视图，处理section圆角、阴影等
 */
NS_SWIFT_NAME(TableViewCellBackgroundView)
@interface FWTableViewCellBackgroundView : UIView

// 背景内容视图，此视图用于设置圆角，阴影等
@property (nonatomic, strong, readonly) UIView *contentView NS_REFINED_FOR_SWIFT;

// 内容视图间距，处理section圆角时该值可能为负。默认zoro占满
@property (nonatomic, assign) UIEdgeInsets contentInset NS_REFINED_FOR_SWIFT;

// 设置section内容间距，设置后再设置圆角，阴影即可。第一个顶部间距(底部超出)，最后一个底部间距(顶部超出)，中间无上下间距(上下超出)
- (void)setSectionContentInset:(UIEdgeInsets)contentInset tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath NS_REFINED_FOR_SWIFT;

@end

/**
 backgroundView不会影响contentView布局等，如果设置了contentInset，注意布局时留出对应间距
 */
@interface UITableViewCell (FWBackgroundView)

// 延迟加载背景视图，处理section圆角、阴影等。会自动设置backgroundView
@property (nonatomic, strong, readonly) FWTableViewCellBackgroundView *fw_backgroundView NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
