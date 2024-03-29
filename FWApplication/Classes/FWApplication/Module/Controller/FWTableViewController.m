/**
 @header     FWTableViewController.m
 @indexgroup FWApplication
      FWTableViewController
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/8/28
 */

#import "FWTableViewController.h"
#import <objc/runtime.h>
@import FWFramework;

#pragma mark - FWViewControllerManager+FWTableViewController

@implementation FWViewControllerManager (FWTableViewController)

+ (void)load
{
    FWViewControllerIntercepter *intercepter = [[FWViewControllerIntercepter alloc] init];
    intercepter.loadViewIntercepter = @selector(tableViewControllerLoadView:);
    intercepter.forwardSelectors = @{
        @"tableView" : @"fw_innerTableView",
        @"tableData" : @"fw_innerTableData",
        @"renderTableStyle" : @"fw_innerRenderTableStyle",
        @"renderTableLayout" : @"fw_innerRenderTableLayout",
    };
    [[FWViewControllerManager sharedInstance] registerProtocol:@protocol(FWTableViewController) withIntercepter:intercepter];
}

- (void)tableViewControllerLoadView:(UIViewController<FWTableViewController> *)viewController
{
    UITableView *tableView = [viewController tableView];
    tableView.dataSource = viewController;
    tableView.delegate = viewController;
    [viewController.view addSubview:tableView];
    
    if (self.hookTableViewController) {
        self.hookTableViewController(viewController);
    }
    
    if ([viewController respondsToSelector:@selector(renderTableView)]) {
        [viewController renderTableView];
    }
    
    [viewController renderTableLayout];
    [tableView setNeedsLayout];
    [tableView layoutIfNeeded];
}

@end

#pragma mark - UIViewController+FWTableViewController

@interface UIViewController (FWTableViewController)

@end

@implementation UIViewController (FWTableViewController)

- (UITableView *)fw_innerTableView
{
    UITableView *tableView = objc_getAssociatedObject(self, _cmd);
    if (!tableView) {
        UITableViewStyle tableStyle = [(id<FWTableViewController>)self renderTableStyle];
        tableView = [[UITableView alloc] initWithFrame:CGRectZero style:tableStyle];
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        objc_setAssociatedObject(self, _cmd, tableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tableView;
}

- (NSMutableArray *)fw_innerTableData
{
    NSMutableArray *tableData = objc_getAssociatedObject(self, _cmd);
    if (!tableData) {
        tableData = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, _cmd, tableData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return tableData;
}

- (UITableViewStyle)fw_innerRenderTableStyle
{
    return UITableViewStylePlain;
}

- (void)fw_innerRenderTableLayout
{
    UITableView *tableView = [(id<FWTableViewController>)self tableView];
    [tableView fw_pinEdgesToSuperview];
}

@end
