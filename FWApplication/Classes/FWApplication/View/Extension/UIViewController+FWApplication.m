//
//  UIViewController+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIViewController+FWApplication.h"
#import <objc/runtime.h>

@implementation FWViewControllerWrapper (FWApplication)

#pragma mark - Child

- (UIViewController *)childViewController
{
    return [self.base.childViewControllers firstObject];
}

- (void)setChildViewController:(UIViewController *)viewController
{
    // 移除旧的控制器
    UIViewController *childViewController = [self childViewController];
    if (childViewController) {
        [self removeChildViewController:childViewController];
    }
    
    // 设置新的控制器
    [self addChildViewController:viewController];
}

- (void)removeChildViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [viewController.view removeFromSuperview];
}

- (void)addChildViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController inView:self.base.view];
}

- (void)addChildViewController:(UIViewController *)viewController inView:(UIView *)view
{
    [self.base addChildViewController:viewController];
    [viewController didMoveToParentViewController:self.base];
    [view addSubview:viewController.view];
    // viewController.view.frame = view.bounds;
    [viewController.view.fw pinEdgesToSuperview];
}

#pragma mark - Previous

- (UIViewController *)previousViewController
{
    if (self.base.navigationController.viewControllers &&
        self.base.navigationController.viewControllers.count > 1 &&
        self.base.navigationController.topViewController == self.base) {
        NSUInteger count = self.base.navigationController.viewControllers.count;
        return (UIViewController *)[self.base.navigationController.viewControllers objectAtIndex:count - 2];
    }
    return nil;
}

@end

API_AVAILABLE(ios(13.0))
static UIModalPresentationStyle fwStaticModalPresentationStyle = UIModalPresentationAutomatic;

@implementation FWViewControllerClassWrapper (FWApplication)

- (UIModalPresentationStyle)defaultModalPresentationStyle
{
    if (@available(iOS 13.0, *)) {
        return fwStaticModalPresentationStyle;
    } else {
        return UIModalPresentationFullScreen;
    }
}

- (void)setDefaultModalPresentationStyle:(UIModalPresentationStyle)style
{
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            FWSwizzleClass(UIViewController, @selector(setModalPresentationStyle:), FWSwizzleReturn(void), FWSwizzleArgs(UIModalPresentationStyle style), FWSwizzleCode({
                objc_setAssociatedObject(selfObject, @selector(defaultModalPresentationStyle), @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                FWSwizzleOriginal(style);
            }));
            FWSwizzleClass(UIViewController, @selector(presentViewController:animated:completion:), FWSwizzleReturn(void), FWSwizzleArgs(UIViewController *viewController, BOOL animated, void (^completion)(void)), FWSwizzleCode({
                if (!objc_getAssociatedObject(viewController, @selector(defaultModalPresentationStyle)) &&
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
