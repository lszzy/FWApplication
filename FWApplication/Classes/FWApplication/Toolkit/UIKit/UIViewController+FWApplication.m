//
//  UIViewController+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIViewController+FWApplication.h"
#import <objc/runtime.h>

API_AVAILABLE(ios(13.0))
static UIModalPresentationStyle fwStaticModalPresentationStyle = UIModalPresentationAutomatic;

@implementation UIViewController (FWApplication)

#pragma mark - Child

- (UIViewController *)fw_childViewController
{
    return [self.childViewControllers firstObject];
}

- (void)fw_setChildViewController:(UIViewController *)viewController
{
    // 移除旧的控制器
    UIViewController *childViewController = [self fw_childViewController];
    if (childViewController) {
        [self fw_removeChildViewController:childViewController];
    }
    
    // 设置新的控制器
    [self fw_addChildViewController:viewController];
}

- (void)fw_removeChildViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [viewController.view removeFromSuperview];
}

- (void)fw_addChildViewController:(UIViewController *)viewController
{
    [self fw_addChildViewController:viewController inView:self.view];
}

- (void)fw_addChildViewController:(UIViewController *)viewController inView:(UIView *)view
{
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    [view addSubview:viewController.view];
    // viewController.view.frame = view.bounds;
    [viewController.view fw_pinEdgesToSuperview];
}

#pragma mark - Previous

- (UIViewController *)fw_previousViewController
{
    if (self.navigationController.viewControllers &&
        self.navigationController.viewControllers.count > 1 &&
        self.navigationController.topViewController == self) {
        NSUInteger count = self.navigationController.viewControllers.count;
        return (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count - 2];
    }
    return nil;
}

+ (UIModalPresentationStyle)fw_defaultModalPresentationStyle
{
    if (@available(iOS 13.0, *)) {
        return fwStaticModalPresentationStyle;
    } else {
        return UIModalPresentationFullScreen;
    }
}

+ (void)setFw_defaultModalPresentationStyle:(UIModalPresentationStyle)style
{
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            FWSwizzleClass(UIViewController, @selector(setModalPresentationStyle:), FWSwizzleReturn(void), FWSwizzleArgs(UIModalPresentationStyle style), FWSwizzleCode({
                objc_setAssociatedObject(selfObject, @selector(fw_defaultModalPresentationStyle), @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                FWSwizzleOriginal(style);
            }));
            FWSwizzleClass(UIViewController, @selector(presentViewController:animated:completion:), FWSwizzleReturn(void), FWSwizzleArgs(UIViewController *viewController, BOOL animated, void (^completion)(void)), FWSwizzleCode({
                if (!objc_getAssociatedObject(viewController, @selector(fw_defaultModalPresentationStyle)) &&
                    fwStaticModalPresentationStyle != UIModalPresentationAutomatic) {
                    if (viewController.modalPresentationStyle == UIModalPresentationAutomatic ||
                        viewController.modalPresentationStyle == UIModalPresentationPageSheet) {
                        viewController.modalPresentationStyle = fwStaticModalPresentationStyle;
                    }
                }
                FWSwizzleOriginal(viewController, animated, completion);
            }));
        });
        fwStaticModalPresentationStyle = style;
    }
}

@end
