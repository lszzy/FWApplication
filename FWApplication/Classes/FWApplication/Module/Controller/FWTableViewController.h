/**
 @header     FWTableViewController.h
 @indexgroup FWApplication
      FWTableViewController
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/8/28
 */

#import "FWViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 表格视图控制器协议，可覆写
 */
NS_SWIFT_NAME(TableViewControllerProtocol)
@protocol FWTableViewController <FWViewController, UITableViewDataSource, UITableViewDelegate>

@optional

/// 表格视图，默认不显示滚动条，Footer为空视图。Plain有悬停，Group无悬停
@property (nonatomic, readonly) UITableView *tableView NS_SWIFT_UNAVAILABLE("");

/// 表格数据，默认空数组，延迟加载
@property (nonatomic, readonly) NSMutableArray *tableData NS_SWIFT_UNAVAILABLE("");

/// 渲染表格视图样式，默认Plain
- (UITableViewStyle)renderTableStyle;

/// 渲染表格视图，renderView之前调用，默认未实现
- (void)renderTableView;

/// 渲染表格视图布局，renderView之前调用，默认铺满
- (void)renderTableLayout;

@end

/**
 管理器表格视图控制器分类
 */
@interface FWViewControllerManager (FWTableViewController)

@end

NS_ASSUME_NONNULL_END
