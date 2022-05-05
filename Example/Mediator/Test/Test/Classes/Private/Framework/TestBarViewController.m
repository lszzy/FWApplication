//
//  TestBarViewController.m
//  Example
//
//  Created by wuyong on 2019/1/17.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

#import "TestBarViewController.h"

@interface TestBarSubViewController : TestViewController

@property (nonatomic, assign) NSInteger index;

@end

@implementation TestBarSubViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fw.extendedLayoutEdge = UIRectEdgeAll;
    if (self.index < 1) {
        self.fw.navigationBarStyle = FWNavigationBarStyleDefault;
    } else if (self.index < 2) {
        self.fw.navigationBarStyle = FWNavigationBarStyleWhite;
    } else if (self.index < 3) {
        self.fw.navigationBarStyle = FWNavigationBarStyleTransparent;
    } else {
        self.fw.navigationBarStyle = [[@[@(-1), @(FWNavigationBarStyleDefault), @(FWNavigationBarStyleWhite), @(FWNavigationBarStyleTransparent)].fw randomObject] integerValue];
        self.fw.navigationBarHidden = self.fw.navigationBarStyle == -1;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"标题:%@ 样式:%@", @(self.index + 1), @(self.fw.navigationBarStyle)];
    
    FWWeakifySelf();
    [self.fw setRightBarItem:@"打开界面" block:^(id sender) {
        FWStrongifySelf();
        TestBarSubViewController *viewController = [TestBarSubViewController new];
        viewController.index = self.index + 1;
        [self.navigationController pushViewController:viewController animated:YES];
    }];
    [self.view.fw addTapGestureWithBlock:^(id sender) {
        FWStrongifySelf();
        TestBarSubViewController *viewController = [TestBarSubViewController new];
        viewController.index = self.index + 1;
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

@end

@interface TestBarViewController () <FWTableViewController>

FWPropertyWeak(UILabel *, frameLabel);
FWPropertyAssign(BOOL, hideToast);

@end

@implementation TestBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fw.tabBarHidden = YES;
    [self.fw observeNotification:UIDeviceOrientationDidChangeNotification target:self action:@selector(refreshBarFrame)];
    
    if (!self.hideToast) {
        [self.fw setRightBarItem:@"启用" block:^(id sender) {
            [UINavigationController.fw enableBarTransition];
        }];
    } else {
        [self.fw setLeftBarItem:FWIcon.closeImage block:^(id  _Nonnull sender) {
            [FWRouter closeViewControllerAnimated:YES];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.hideToast) {
        [UIWindow.fw showMessageWithText:[NSString stringWithFormat:@"viewWillAppear:%@", @(animated)]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (!self.hideToast) {
        [UIWindow.fw showMessageWithText:[NSString stringWithFormat:@"viewWillDisappear:%@", @(animated)]];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self refreshBarFrame];
}

- (UITableViewStyle)renderTableStyle
{
    return UITableViewStyleGrouped;
}

- (void)renderTableLayout
{
    UILabel *frameLabel = [UILabel new];
    self.frameLabel = frameLabel;
    frameLabel.numberOfLines = 0;
    frameLabel.textColor = [Theme textColor];
    frameLabel.font = [UIFont.fw fontOfSize:15];
    frameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:frameLabel]; {
        frameLabel.fw.layoutChain.leftWithInset(10).rightWithInset(10)
            .bottomWithInset(FWTabBarHeight + 10);
    }
    
    self.tableView.backgroundColor = [Theme tableColor];
    self.tableView.fw.layoutChain.edgesHorizontal().top()
        .bottomToTopOfViewWithOffset(self.frameLabel, -10);
}

- (void)renderData
{
    [self.tableData addObjectsFromArray:@[
                                         @[@"状态栏切换", @"onStatusBar"],
                                         @[@"状态栏样式", @"onStatusStyle"],
                                         @[@"导航栏切换", @"onNavigationBar"],
                                         @[@"导航栏样式", @"onNavigationStyle"],
                                         @[@"标题栏颜色", @"onTitleColor"],
                                         @[@"大标题切换", @"onLargeTitle"],
                                         @[@"标签栏切换", @"onTabBar"],
                                         @[@"工具栏切换", @"onToolBar"],
                                         @[@"导航栏转场", @"onTransitionBar"],
                                         ]];
    if (!self.hideToast) {
        [self.tableData addObject:@[@"Present(默认)", @"onPresent"]];
        [self.tableData addObject:@[@"Present(FullScreen)", @"onPresent2"]];
        [self.tableData addObject:@[@"Present(PageSheet)", @"onPresent3"]];
        [self.tableData addObject:@[@"Present(默认带导航栏)", @"onPresent4"]];
        [self.tableData addObject:@[@"Present(Popover)", @"onPresent5:"]];
    } else {
        [self.tableData addObject:@[@"Dismiss", @"onDismiss"]];
    }
    [self.tableData addObject:@[@"设备转向", @"onOrientation"]];
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
        [self performSelector:selector withObject:indexPath];
        FWIgnoredEnd();
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self refreshBarFrame];
}

#pragma mark - Protected

- (BOOL)prefersStatusBarHidden
{
    return self.fw.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.fw.statusBarStyle;
}

#pragma mark - Action

- (void)refreshBarFrame
{
    self.frameLabel.text = [NSString stringWithFormat:@"全局状态栏：%.0f 当前状态栏：%.0f\n全局导航栏：%.0f 当前导航栏：%.0f\n全局顶部栏：%.0f 当前顶部栏：%.0f\n全局标签栏：%.0f 当前标签栏：%.0f\n全局工具栏：%.0f 当前工具栏：%.0f\n全局安全区域：%@",
                            [UIScreen.fw statusBarHeight], [self.fw statusBarHeight],
                            [UIScreen.fw navigationBarHeight], [self.fw navigationBarHeight],
                            [UIScreen.fw topBarHeight], [self.fw topBarHeight],
                            [UIScreen.fw tabBarHeight], [self.fw tabBarHeight],
                            [UIScreen.fw toolBarHeight], [self.fw toolBarHeight],
                            NSStringFromUIEdgeInsets([UIScreen.fw safeAreaInsets])];
}

- (void)onStatusBar
{
    self.fw.statusBarHidden = !self.fw.statusBarHidden;
    [self refreshBarFrame];
}

- (void)onStatusStyle
{
    if (self.fw.statusBarStyle == UIStatusBarStyleDefault) {
        self.fw.statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        self.fw.statusBarStyle = UIStatusBarStyleDefault;
    }
    [self refreshBarFrame];
}

- (void)onNavigationBar
{
    self.fw.navigationBarHidden = !self.fw.navigationBarHidden;
    [self refreshBarFrame];
}

- (void)onNavigationStyle
{
    if (self.fw.navigationBarStyle == FWNavigationBarStyleDefault) {
        self.fw.navigationBarStyle = FWNavigationBarStyleWhite;
    } else {
        self.fw.navigationBarStyle = FWNavigationBarStyleDefault;
    }
    [self refreshBarFrame];
}

- (void)onTitleColor
{
    self.navigationController.navigationBar.fw.titleColor = self.navigationController.navigationBar.fw.titleColor ? nil : Theme.buttonColor;
}

- (void)onLargeTitle
{
    self.navigationController.navigationBar.prefersLargeTitles = !self.navigationController.navigationBar.prefersLargeTitles;
    [self refreshBarFrame];
}

- (void)onTabBar
{
    self.fw.tabBarHidden = !self.fw.tabBarHidden;
    [self refreshBarFrame];
}

- (void)onToolBar
{
    if (self.fw.toolBarHidden) {
        UIBarButtonItem *item = [UIBarButtonItem.fw itemWithObject:@(UIBarButtonSystemItemCancel) target:self action:@selector(onToolBar)];
        UIBarButtonItem *item2 = [UIBarButtonItem.fw itemWithObject:@(UIBarButtonSystemItemDone) target:self action:@selector(onPresent)];
        self.toolbarItems = @[item, item2];
        self.fw.toolBarHidden = NO;
    } else {
        self.fw.toolBarHidden = YES;
    }
    [self refreshBarFrame];
}

- (void)onPresent
{
    TestBarViewController *viewController = [[TestBarViewController alloc] init];
    viewController.fw.presentationDidDismiss = ^{
        [UIWindow.fw showMessageWithText:@"fwPresentationDidDismiss"];
    };
    viewController.fw.completionHandler = ^(id  _Nullable result) {
        [UIWindow.fw showMessageWithText:@"fwCompletionHandler"];
    };
    viewController.hideToast = YES;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)onPresent2
{
    TestBarViewController *viewController = [[TestBarViewController alloc] init];
    viewController.hideToast = YES;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)onPresent3
{
    TestBarViewController *viewController = [[TestBarViewController alloc] init];
    viewController.fw.presentationDidDismiss = ^{
        [UIWindow.fw showMessageWithText:@"fwPresentationDidDismiss"];
    };
    viewController.fw.completionHandler = ^(id  _Nullable result) {
        [UIWindow.fw showMessageWithText:@"fwCompletionHandler"];
    };
    viewController.hideToast = YES;
    viewController.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)onPresent4
{
    TestBarViewController *viewController = [[TestBarViewController alloc] init];
    viewController.hideToast = YES;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.fw.presentationDidDismiss = ^{
        [UIWindow.fw showMessageWithText:@"fwPresentationDidDismiss"];
    };
    navController.fw.completionHandler = ^(id  _Nullable result) {
        [UIWindow.fw showMessageWithText:@"fwCompletionHandler"];
    };
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)onPresent5:(NSIndexPath *)indexPath
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    TestBarViewController *viewController = [[TestBarViewController alloc] init];
    viewController.hideToast = YES;
    viewController.preferredContentSize = CGSizeMake(FWScreenWidth / 2, FWScreenHeight / 2);
    [viewController.fw setPopoverPresentation:^(UIPopoverPresentationController *controller) {
        controller.barButtonItem = self.navigationItem.rightBarButtonItem;
        controller.permittedArrowDirections = UIPopoverArrowDirectionUp;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        controller.passthroughViews = [NSArray arrayWithObjects:cell, nil];
    } shouldDismiss:[@[@0, @1].fw.randomObject fw].safeBool];
    viewController.fw.presentationDidDismiss = ^{
        [UIWindow.fw showMessageWithText:@"fwPresentationDidDismiss"];
    };
    viewController.fw.completionHandler = ^(id  _Nullable result) {
        [UIWindow.fw showMessageWithText:@"fwCompletionHandler"];
    };
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)onDismiss
{
    FWWeakifySelf();
    [self dismissViewControllerAnimated:YES completion:^{
        FWStrongifySelf();
        NSLog(@"self: %@", self);
    }];
}

- (void)onTransitionBar
{
    [self.navigationController pushViewController:[TestBarSubViewController new] animated:YES];
}

- (void)onOrientation
{
    if ([UIDevice.fw isDeviceLandscape]) {
        [UIDevice.fw setDeviceOrientation:UIDeviceOrientationPortrait];
    } else {
        [UIDevice.fw setDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    }
    [self refreshBarFrame];
}

@end
