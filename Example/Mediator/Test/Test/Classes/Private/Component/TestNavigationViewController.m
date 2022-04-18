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
    [self.fw setRightBarItem:@"Push" block:^(id sender) {
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
        if (!self.fw.tempObject) {
            self.fw.tempObject = UIColor.fw.randomColor;
        }
        self.navigationController.navigationBar.fw.backgroundColor = self.fw.tempObject;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.fullscreenPop) {
        self.navigationController.fw.fullscreenPopGestureEnabled = YES;
    } else {
        self.navigationController.fw.fullscreenPopGestureEnabled = NO;
    }
}

- (void)renderView
{
    // 允许同时识别手势处理
    if (self.fullscreenPop) {
        FWWeakifySelf();
        self.scrollView.fwShouldRecognizeSimultaneously = ^BOOL(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer) {
            FWStrongifySelf();
            if (self.scrollView.contentOffset.x <= 0) {
                if ([UINavigationController.fw isFullscreenPopGestureRecognizer:otherGestureRecognizer]) {
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
        [imageView.fw setDimension:NSLayoutAttributeWidth toSize:FWScreenWidth];
        [imageView.fw pinEdgesToSuperviewWithInsets:UIEdgeInsetsZero];
        [imageView.fw setDimension:NSLayoutAttributeHeight toSize:FWScreenHeight];
    }
}

@end
