//
//  UIWindow+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 2017/6/19.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIWindow+FWApplication.h"

@implementation FWWindowWrapper (FWApplication)

- (void)dismissViewControllers:(void (^)(void))completion
{
    if (self.base.rootViewController.presentedViewController) {
        [self.base.rootViewController dismissViewControllerAnimated:YES completion:completion];
    } else {
        if (completion) completion();
    }
}

- (UIViewController *)selectTabBarController:(Class)viewController
{
    if (![self.base.rootViewController isKindOfClass:[UITabBarController class]]) return nil;
    
    UINavigationController *targetNavigation = nil;
    UITabBarController *tabbarController = (UITabBarController *)self.base.rootViewController;
    for (UINavigationController *navigationController in tabbarController.viewControllers) {
        if ([navigationController isKindOfClass:viewController] ||
            ([navigationController isKindOfClass:[UINavigationController class]] &&
             [navigationController.viewControllers.firstObject isKindOfClass:viewController])) {
            targetNavigation = navigationController;
            break;
        }
    }
    if (!targetNavigation) return nil;
    
    return [self selectTabBarNavigation:targetNavigation];
}

- (UIViewController *)selectTabBarIndex:(NSUInteger)index
{
    if (![self.base.rootViewController isKindOfClass:[UITabBarController class]]) return nil;
    
    UINavigationController *targetNavigation = nil;
    UITabBarController *tabbarController = (UITabBarController *)self.base.rootViewController;
    if (tabbarController.viewControllers.count > index) {
        targetNavigation = tabbarController.viewControllers[index];
    }
    if (!targetNavigation) return nil;
    
    return [self selectTabBarNavigation:targetNavigation];
}

- (UIViewController *)selectTabBarNavigation:(UINavigationController *)targetNavigation
{
    UITabBarController *tabbarController = (UITabBarController *)self.base.rootViewController;
    UINavigationController *currentNavigation = tabbarController.selectedViewController;
    if (currentNavigation != targetNavigation) {
        if ([currentNavigation isKindOfClass:[UINavigationController class]] &&
            currentNavigation.viewControllers.count > 1) {
            [currentNavigation popToRootViewControllerAnimated:NO];
        }
        tabbarController.selectedViewController = targetNavigation;
    }
    
    UIViewController *targetController = targetNavigation;
    if ([targetNavigation isKindOfClass:[UINavigationController class]]) {
        targetController = targetNavigation.viewControllers.firstObject;
        if (targetNavigation.viewControllers.count > 1) {
            [targetNavigation popToRootViewControllerAnimated:NO];
        }
    }
    return targetController;
}

@end
