//
//  UITableView+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 2017/6/1.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// UITableView分类(Plain有悬停，Group无悬停)
@interface UITableView (FWApplication)

/// 全局清空TableView默认多余边距
+ (void)fwResetTableStyle;

/// 清空Grouped样式默认多余边距，注意CGFLOAT_MIN才会生效，0不会生效
- (void)fwResetGroupedStyle;

/// 设置Plain样式sectionHeader和Footer跟随滚动(不悬停)，在scrollViewDidScroll:中调用即可(需先禁用内边距适应)
- (void)fwFollowWithHeader:(CGFloat)headerHeight footer:(CGFloat)footerHeight;

/// reloadData完成回调
- (void)fwReloadDataWithCompletion:(nullable void (^)(void))completion;

/// reloadData清空尺寸缓存
- (void)fwReloadDataWithoutCache;

/// reloadData禁用动画
- (void)fwReloadDataWithoutAnimation;

/// reloadSections禁用动画
- (void)fwReloadSectionsWithoutAnimation:(NSIndexSet *)sections;

/// reloadRows禁用动画
- (void)fwReloadRowsWithoutAnimation:(NSArray<NSIndexPath *> *)indexPaths;

/// 刷新高度等，不触发reload方式
- (void)fwPerformUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates;

@end

@interface UITableViewCell (FWApplication)

/// 设置分割线内边距，iOS8+默认15.f，设为UIEdgeInsetsZero可去掉
@property (nonatomic, assign) UIEdgeInsets fwSeparatorInset;

/// 获取当前所属tableView
@property (nonatomic, weak, readonly, nullable) UITableView *fwTableView;

/// 获取当前显示indexPath
@property (nonatomic, readonly, nullable) NSIndexPath *fwIndexPath;

@end

/*!
 @brief TableViewCell背景视图，处理section圆角、阴影等
 */
@interface FWTableViewCellBackgroundView : UIView

// 背景内容视图，此视图用于设置圆角，阴影等
@property (nonatomic, strong, readonly) UIView *contentView;

// 内容视图间距，处理section圆角时该值可能为负。默认zoro占满
@property (nonatomic, assign) UIEdgeInsets contentInset;

// 设置section内容间距，设置后再设置圆角，阴影即可。第一个顶部间距(底部超出)，最后一个底部间距(顶部超出)，中间无上下间距(上下超出)
- (void)setSectionContentInset:(UIEdgeInsets)contentInset tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end

/*!
 @brief UITableViewCell+FWBackgroundView
 @discussion backgroundView不会影响contentView布局等，如果设置了contentInset，注意布局时留出对应间距
 */
@interface UITableViewCell (FWBackgroundView)

// 延迟加载背景视图，处理section圆角、阴影等。会自动设置backgroundView
@property (nonatomic, strong, readonly) FWTableViewCellBackgroundView *fwBackgroundView;

@end

#pragma mark - UITableView+FWTemplateLayout

/*!
 @brief 表格自动计算并缓存cell高度分类，布局必须完整，系统方案实现
 */
@interface UITableView (FWTemplateLayout)

/*!
 @brief 单独启用或禁用高度估算
 @discussion 启用高度估算，需要子视图布局完整，无需实现heightForRow方法；禁用高度估算(iOS11默认启用，会先cellForRow再heightForRow)
 
 @param enabled 是否启用
 */
- (void)fwSetTemplateLayout:(BOOL)enabled UI_APPEARANCE_SELECTOR;

// 缓存方式获取估算高度，estimatedHeightForRowAtIndexPath调用即可。解决reloadData闪烁跳动问题
- (CGFloat)fwTemplateHeightAtIndexPath:(NSIndexPath *)indexPath;

// 设置估算高度缓存，willDisplayCell调用即可，height为cell.frame.size.height。设置为0时清除缓存。解决reloadData闪烁跳动问题
- (void)fwSetTemplateHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath;

// 清空估算高度缓存，cell高度动态变化时调用
- (void)fwClearTemplateHeightCache;

@end

NS_ASSUME_NONNULL_END
