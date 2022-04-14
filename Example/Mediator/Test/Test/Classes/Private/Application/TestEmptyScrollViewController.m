//
//  TestEmptyScrollViewController.m
//  Example
//
//  Created by wuyong on 2020/9/3.
//  Copyright © 2020 site.wuyong. All rights reserved.
//

#import "TestEmptyScrollViewController.h"

@interface TestEmptyScrollViewController () <FWTableViewController, FWEmptyViewDelegate>

@end

@implementation TestEmptyScrollViewController

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderModel
{
    FWWeakifySelf();
    [self fwSetRightBarItem:FWIcon.refreshImage block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        [self.tableData removeAllObjects];
        [self.tableView reloadData];
    }];
}

- (void)renderView
{
    self.tableView.fw.emptyViewDelegate = self;
    FWWeakifySelf();
    [self.tableView.fw addPullRefreshWithBlock:^{
        FWStrongifySelf();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            FWStrongifySelf();
            [self.tableData removeAllObjects];
            [self.tableView reloadData];
            [self.tableView.fw endRefreshing];
        });
    }];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FWScreenWidth, 100)];
    view.backgroundColor = Theme.cellColor;
    
    UILabel *label = [UILabel.fw labelWithFont:[UIFont.fw fontOfSize:15] textColor:Theme.textColor text:@"我是Section头视图"];
    [view addSubview:label];
    label.fw.layoutChain.leftWithInset(15).centerY();
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell.fw cellWithTableView:tableView];
    cell.textLabel.textColor = Theme.textColor;
    cell.textLabel.text = FWSafeString([self.tableData objectAtIndex:indexPath.row]);
    return cell;
}

#pragma mark - FWEmptyViewDelegate

- (void)showEmptyView:(UIScrollView *)scrollView
{
    FWWeakifySelf();
    scrollView.fw.overlayView.backgroundColor = Theme.tableColor;
    scrollView.fw.overlayView.fw.emptyInsets = UIEdgeInsetsMake(35 + 50, 0, 0, 0);
    [scrollView.fw showEmptyViewWithText:nil detail:nil image:nil action:nil block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        
        [self.tableData addObjectsFromArray:@[@1, @2, @3, @4, @5, @6, @7, @8]];
        [self.tableView reloadData];
    }];
}

- (void)hideEmptyView:(UIScrollView *)scrollView
{
    [self.fw hideEmptyView];
}

@end
