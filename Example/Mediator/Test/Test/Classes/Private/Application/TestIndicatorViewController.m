/*!
 @header     TestIndicatorViewController.m
 @indexgroup Example
 @brief      TestIndicatorViewController
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "TestIndicatorViewController.h"

@interface TestIndicatorViewController () <FWTableViewController>

@end

@implementation TestIndicatorViewController

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderData
{
    [self.tableData addObjectsFromArray:@[
                                         @[@"无文本", @"onIndicator"],
                                         @[@"有文本", @"onIndicator2"],
                                         @[@"文本太长", @"onIndicator3"],
                                         @[@"加载动画", @"onLoading"],
                                         @[@"进度动画", @"onProgress"],
                                         @[@"加载动画(window)", @"onLoadingWindow"],
                                         @[@"加载进度动画(window)", @"onProgressWindow"],
                                         @[@"单行吐司(可点击)", @"onToast"],
                                         @[@"多行吐司(默认不可点击)", @"onToast2"],
                                         ]];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell fw_cellWithTableView:tableView];
    NSArray *rowData = [self.tableData objectAtIndex:indexPath.row];
    cell.textLabel.text = [rowData objectAtIndex:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *rowData = [self.tableData objectAtIndex:indexPath.row];
    SEL selector = NSSelectorFromString([rowData objectAtIndex:1]);
    if ([self respondsToSelector:selector]) {
        FWIgnoredBegin();
        [self performSelector:selector];
        FWIgnoredEnd();
    }
}

#pragma mark - Action

- (void)onIndicator
{
    [self.fw showLoadingWithText:@""];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.fw hideLoading];
    });
}

- (void)onIndicator2
{
    [self.fw showLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.fw hideLoading];
    });
}

- (void)onIndicator3
{
    [self.fw showLoadingWithText:@"我是很长很长很长很长很长很长很长很长很长很长的加载文案"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.fw hideLoading];
    });
}

- (void)onLoading
{
    [self.fw showLoadingWithText:@"加载中\n请耐心等待"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.fw hideLoading];
    });
}

- (void)onProgress
{
    FWWeakifySelf();
    [self mockProgress:^(double progress, BOOL finished) {
        FWStrongifySelf();
        if (!finished) {
            [self.fw showProgressWithText:[NSString stringWithFormat:@"上传中(%.0f%%)", progress * 100] progress:progress];
        } else {
            [self.fw hideProgress];
        }
    }];
}

- (void)onLoadingWindow
{
    self.view.window.fw.toastInsets = UIEdgeInsetsMake(FWTopBarHeight, 0, 0, 0);
    [self.view.window.fw showLoadingWithText:@"加载中"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.window.fw.toastInsets = UIEdgeInsetsZero;
        [self.view.window.fw hideLoading];
    });
}

- (void)onProgressWindow
{
    FWWeakifySelf();
    [self mockProgress:^(double progress, BOOL finished) {
        FWStrongifySelf();
        if (!finished) {
            [self.view.window.fw showLoadingWithText:[NSString stringWithFormat:@"上传中(%.0f%%)", progress * 100]];
        } else {
            [self.view.window.fw hideLoading];
        }
    }];
}

- (void)onToast
{
    self.view.tag = 100;
    static int count = 0;
    [self.fw showMessageWithText:[NSString stringWithFormat:@"吐司消息%@", @(++count)]];
}

- (void)onToast2
{
    NSString *text = @"我是很长很长很长很长很长很长很长很长很长很长很长的吐司消息";
    FWWeakifySelf();
    [self.fw showMessageWithText:text style:FWToastStyleDefault completion:^{
        FWStrongifySelf();
        [self onToast];
    }];
}

@end
