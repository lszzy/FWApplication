/*!
 @header     TestBadgeViewController.m
 @indexgroup Example
 @brief      TestBadgeViewController
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/21
 */

#import "TestBadgeViewController.h"

@implementation TestBadgeViewController

- (void)renderInit
{
    self.hidesBottomBarWhenPushed = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fw_tabBarHidden = NO;
    
    [self fw_setLeftBarItem:FWIcon.backImage target:self action:@selector(onClose)];
    FWBadgeView *badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleDot];
    [self.navigationItem.leftBarButtonItem fw_showBadgeView:badgeView badgeValue:nil];
    
    UIBarButtonItem *rightItem = [UIBarButtonItem fw_itemWithObject:FWIcon.backImage target:self action:@selector(onClick:)];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleSmall];
    [rightItem fw_showBadgeView:badgeView badgeValue:@"1"];
    
    UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    customView.backgroundColor = [Theme textColor];
    UIBarButtonItem *customItem = [UIBarButtonItem fw_itemWithObject:customView target:self action:@selector(onClick:)];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleSmall];
    [customItem fw_showBadgeView:badgeView badgeValue:@"1"];
    self.navigationItem.rightBarButtonItems = @[rightItem, customItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    FWBadgeView *badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleDot];
    [self.tabBarController.tabBar.items[0] fw_showBadgeView:badgeView badgeValue:nil];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleSmall];
    [self.tabBarController.tabBar.items[1] fw_showBadgeView:badgeView badgeValue:@"99"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tabBarController.tabBar.items[0] fw_hideBadgeView];
    [self.tabBarController.tabBar.items[1] fw_hideBadgeView];
}

- (void)renderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    view.backgroundColor = [Theme textColor];
    FWBadgeView *badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleDot];
    [view fw_showBadgeView:badgeView badgeValue:nil];
    [self.view addSubview:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(20, 90, 50, 50)];
    view.backgroundColor = [Theme textColor];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleSmall];
    [view fw_showBadgeView:badgeView badgeValue:@"9"];
    [self.view addSubview:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(90, 90, 50, 50)];
    view.backgroundColor = [Theme textColor];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleSmall];
    [view fw_showBadgeView:badgeView badgeValue:@"99"];
    [self.view addSubview:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(160, 90, 50, 50)];
    view.backgroundColor = [Theme textColor];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleSmall];
    [view fw_showBadgeView:badgeView badgeValue:@"99+"];
    [self.view addSubview:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(20, 160, 50, 50)];
    view.backgroundColor = [Theme textColor];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleBig];
    [view fw_showBadgeView:badgeView badgeValue:@"9"];
    [self.view addSubview:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(90, 160, 50, 50)];
    view.backgroundColor = [Theme textColor];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleBig];
    [view fw_showBadgeView:badgeView badgeValue:@"99"];
    [self.view addSubview:view];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(160, 160, 50, 50)];
    view.backgroundColor = [Theme textColor];
    badgeView = [[FWBadgeView alloc] initWithBadgeStyle:FWBadgeStyleBig];
    [view fw_showBadgeView:badgeView badgeValue:@"99+"];
    [self.view addSubview:view];
}

#pragma mark - Action

- (BOOL)shouldPopController
{
    [self onClose];
    return NO;
}

- (void)onClose
{
    FWWeakifySelf();
    [self fw_showConfirmWithTitle:nil message:@"是否关闭" cancel:nil confirm:nil confirmBlock:^{
        FWStrongifySelf();
        [self fw_closeViewControllerAnimated:YES];
    }];
}

- (void)onClick:(UIBarButtonItem *)sender
{
    [sender fw_hideBadgeView];
}

@end
