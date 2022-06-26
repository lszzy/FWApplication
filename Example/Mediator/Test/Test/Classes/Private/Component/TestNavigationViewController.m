//
//  TestNavigationViewController.m
//  Example
//
//  Created by wuyong on 2019/1/15.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

#import "TestNavigationViewController.h"

@interface TestNavigationViewController () <FWScrollViewController>

@property (nonatomic, assign) BOOL fullscreenPop;

@end

@implementation TestNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FWWeakifySelf();
    [self fw_setRightBarItem:@"Push" block:^(id sender) {
        FWStrongifySelf();
        TestNavigationViewController *viewController = [TestNavigationViewController new];
        viewController.fullscreenPop = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.fullscreenPop) {
        if (!self.fw_tempObject) {
            self.fw_tempObject = UIColor.fw_randomColor;
        }
        self.navigationController.navigationBar.fw_backgroundColor = self.fw_tempObject;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.fullscreenPop) {
        self.navigationController.fw_fullscreenPopGestureEnabled = YES;
    } else {
        self.navigationController.fw_fullscreenPopGestureEnabled = NO;
    }
}

- (void)renderView
{
    // 允许同时识别手势处理
    if (self.fullscreenPop) {
        FWWeakifySelf();
        self.scrollView.fw_shouldRecognizeSimultaneously = ^BOOL(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer) {
            FWStrongifySelf();
            if (self.scrollView.contentOffset.x <= 0) {
                if ([UINavigationController fw_isFullscreenPopGestureRecognizer:otherGestureRecognizer]) {
                    return YES;
                }
            }
            return NO;
        };
    }
    
    // 添加内容
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [TestBundle imageNamed:@"public_picture"];
    [self.contentView addSubview:imageView]; {
        [imageView fw_setDimension:NSLayoutAttributeWidth toSize:FWScreenWidth];
        [imageView fw_pinEdgesToSuperviewWithInsets:UIEdgeInsetsZero];
        [imageView fw_setDimension:NSLayoutAttributeHeight toSize:FWScreenHeight];
    }
}

@end
