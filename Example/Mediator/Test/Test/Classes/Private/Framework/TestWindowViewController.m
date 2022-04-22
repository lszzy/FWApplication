//
//  TestWindowViewController.m
//  Example
//
//  Created by wuyong on 2018/10/11.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestWindowViewController.h"
@import Mediator;

@interface TestWindowPresentController : TestViewController

@property (nonatomic, strong) UIButton *loginButton;

@end

@implementation TestWindowPresentController

- (void)renderView
{
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginButton = loginButton;
    [loginButton addTarget:self action:@selector(onMediator) forControlEvents:UIControlEventTouchUpInside];
    loginButton.frame = CGRectMake(self.view.frame.size.width / 2 - 75, 20, 150, 30);
    [self.view addSubview:loginButton];
    [self.view.fw addTapGestureWithTarget:self action:@selector(onClose)];
}

- (void)renderData {
    if ([Mediator.userModule isLogin]) {
        [self.loginButton setTitle:@"模拟登录失效" forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:@"点击登录" forState:UIControlStateNormal];
    }
}

#pragma mark - Action

- (void)onClose {
    [self.fw closeViewControllerAnimated:YES];
}

- (void)onMediator {
    if ([Mediator.userModule isLogin]) {
        [self onInvalid];
    } else {
        [self onLogin];
    }
}

- (void)onLogin {
    FWWeakifySelf();
    [Mediator.userModule login:^{
        FWStrongifySelf();
        [self renderData];
    }];
}

- (void)onInvalid {
    FWWeakifySelf();
    [UIWindow.fw.topPresentedController.fw showConfirmWithTitle:@"模拟登录失效" message:nil cancel:nil confirm:nil confirmBlock:^{
        FWStrongifySelf();
        [UIWindow.fw.mainWindow.fw dismissViewControllers:^{
            FWStrongifySelf();
            [Mediator.userModule logout:^{
                FWStrongifySelf();
                [self renderData];
                [self onLogin];
            }];
        }];
    }];
}

@end

@interface TestWindowViewController () <FWTableViewController>

@end

@implementation TestWindowViewController

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderData
{
    [self.tableData addObjectsFromArray:@[
                                         @[@"push", @"onPush"],
                                         @[@"present", @"onPresent"],
                                         @[@"present nav && push", @"onPush2"],
                                         @[@"present nav && present", @"onPresent2"],
                                         @[@"present vc && push", @"onPush3"],
                                         @[@"present vc && present", @"onPresent3"],
                                         @[@"url review", @"onReview"],
                                         @[@"app review", @"onReview2"],
                                         ]];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell.fw cellWithTableView:tableView];
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

- (void)onPush
{
    [UIWindow.fw pushViewController:[TestWindowPresentController new] animated:YES];
}

- (void)onPresent
{
    [UIWindow.fw presentViewController:[TestWindowPresentController new] animated:YES completion:nil];
}

- (void)onPush2
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[TestWindowPresentController new]];
    [self presentViewController:nav animated:YES completion:^{
        [UIWindow.fw pushViewController:[TestWindowPresentController new] animated:YES];
    }];
}

- (void)onPresent2
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[TestWindowPresentController new]];
    [self presentViewController:nav animated:YES completion:^{
        [UIWindow.fw presentViewController:[TestWindowPresentController new] animated:YES completion:nil];
    }];
}

- (void)onPush3
{
    [self presentViewController:[TestWindowPresentController new] animated:YES completion:^{
        [UIWindow.fw pushViewController:[TestWindowPresentController new] animated:YES];
    }];
}

- (void)onPresent3
{
    [self presentViewController:[TestWindowPresentController new] animated:YES completion:^{
        [UIWindow.fw presentViewController:[TestWindowPresentController new] animated:YES completion:nil];
    }];
}

- (void)onReview
{
    [UIApplication.fw openAppStoreReview:@"923302754"];
}

- (void)onReview2
{
    [UIApplication.fw openAppReview];
}

@end
