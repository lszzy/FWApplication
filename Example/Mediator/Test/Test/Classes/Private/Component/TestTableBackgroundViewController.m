//
//  TestTableBackgroundViewController.m
//  Example
//
//  Created by wuyong on 2018/10/25.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestTableBackgroundViewController.h"

@interface TestTableBackgroundViewController () <FWTableViewController>

@property (nonatomic, strong) UIView *bgView;

@end

@implementation TestTableBackgroundViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fw_extendedLayoutEdge = UIRectEdgeTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.fw_backgroundTransparent = YES;
}

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderTableView
{
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)renderView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FWScreenWidth, FWScreenHeight)];
    _bgView = bgView;
    bgView.backgroundColor = UIColor.fw_randomColor;
    [self.view insertSubview:bgView atIndex:0];
    self.view.clipsToBounds = YES;
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, FWScreenHeight / 2, FWScreenWidth, FWScreenHeight / 2)];
    subView.backgroundColor = UIColor.fw_randomColor;
    [bgView addSubview:subView];
}

- (void)renderData
{
    [self.tableData addObjectsFromArray:@[
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         @"我是数据",
                                         ]];
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _bgView.fw_y = -scrollView.contentOffset.y;
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell fw_cellWithTableView:tableView];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

@end
