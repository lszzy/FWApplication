//
//  UIWindow+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 2017/6/19.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIWindow+FWApplication.h"

@implementation UIWindow (FWApplication)

- (void)fw_dismissViewControllers:(void (^)(void))completion
{
    if (self.rootViewController.presentedViewController) {
        [self.rootViewController dismissViewControllerAnimated:YES completion:completion];
    } else {
        if (completion) completion();
    }
}

- (__kindof UIViewController *)fw_selectTabBarIndex:(NSUInteger)index
{
    UITabBarController *tabbarController = [self fw_rootTabBarController];
    if (!tabbarController) return nil;
    
    UINavigationController *targetNavigation = nil;
    if (tabbarController.viewControllers.count > index) {
        targetNavigation = tabbarController.viewControllers[index];
    }
    if (!targetNavigation) return nil;
    
    return [self fw_selectTabBar:tabbarController navigation:targetNavigation];
}

- (__kindof UIViewController *)fw_selectTabBarController:(Class)viewController
{
    UITabBarController *tabbarController = [self fw_rootTabBarController];
    if (!tabbarController) return nil;
    
    UINavigationController *targetNavigation = nil;
    for (UINavigationController *navigationController in tabbarController.viewControllers) {
        if ([navigationController isKindOfClass:viewController] ||
            ([navigationController isKindOfClass:[UINavigationController class]] &&
             [navigationController.viewControllers.firstObject isKindOfClass:viewController])) {
            targetNavigation = navigationController;
            break;
        }
    }
    if (!targetNavigation) return nil;
    
    return [self fw_selectTabBar:tabbarController navigation:targetNavigation];
}

- (__kindof UIViewController *)fw_selectTabBarBlock:(__attribute__((noescape)) BOOL (^)(__kindof UIViewController *))block
{
    UITabBarController *tabbarController = [self fw_rootTabBarController];
    if (!tabbarController) return nil;
    
    UINavigationController *targetNavigation = nil;
    for (UINavigationController *navigationController in tabbarController.viewControllers) {
        UIViewController *viewController = navigationController;
        if ([navigationController isKindOfClass:[UINavigationController class]]) {
            viewController = navigationController.viewControllers.firstObject;
        }
        if (viewController && block(viewController)) {
            targetNavigation = navigationController;
            break;
        }
    }
    if (!targetNavigation) return nil;
    
    return [self fw_selectTabBar:tabbarController navigation:targetNavigation];
}

- (UITabBarController *)fw_rootTabBarController
{
    if ([self.rootViewController isKindOfClass:[UITabBarController class]]) {
        return (UITabBarController *)self.rootViewController;
    }
    
    if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *firstController = ((UINavigationController *)self.rootViewController).viewControllers.firstObject;
        if ([firstController isKindOfClass:[UITabBarController class]]) {
            return (UITabBarController *)firstController;
        }
    }
    
    return nil;
}

- (UIViewController *)fw_selectTabBar:(UITabBarController *)tabbarController navigation:(UINavigationController *)targetNavigation
{
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
