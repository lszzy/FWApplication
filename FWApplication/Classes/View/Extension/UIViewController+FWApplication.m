//
//  UIViewController+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIViewController+FWApplication.h"
#import "FWAutoLayout.h"
#import "FWSwizzle.h"
#import "FWToolkit.h"
#import <objc/runtime.h>

#pragma mark - UIViewController+FWApplication

API_AVAILABLE(ios(13.0))
static UIModalPresentationStyle fwStaticModalPresentationStyle = UIModalPresentationAutomatic;

@implementation UIViewController (FWApplication)

#pragma mark - Present

+ (void)fwDefaultModalPresentationStyle:(UIModalPresentationStyle)style
{
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            FWSwizzleClass(UIViewController, @selector(setModalPresentationStyle:), FWSwizzleReturn(void), FWSwizzleArgs(UIModalPresentationStyle style), FWSwizzleCode({
                objc_setAssociatedObject(selfObject, @selector(fwDefaultModalPresentationStyle:), @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                FWSwizzleOriginal(style);
            }));
            FWSwizzleClass(UIViewController, @selector(presentViewController:animated:completion:), FWSwizzleReturn(void), FWSwizzleArgs(UIViewController *viewController, BOOL animated, void (^completion)(void)), FWSwizzleCode({
                if (!objc_getAssociatedObject(viewController, @selector(fwDefaultModalPresentationStyle:)) &&
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

#pragma mark - Child

- (UIViewController *)fwChildViewController
{
    return [self.childViewControllers firstObject];
}

- (void)fwSetChildViewController:(UIViewController *)viewController
{
    // 移除旧的控制器
    UIViewController *childViewController = [self fwChildViewController];
    if (childViewController) {
        [self fwRemoveChildViewController:childViewController];
    }
    
    // 设置新的控制器
    [self fwAddChildViewController:viewController];
}

- (void)fwRemoveChildViewController:(UIViewController *)viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [viewController.view removeFromSuperview];
}

- (void)fwAddChildViewController:(UIViewController *)viewController
{
    [self fwAddChildViewController:viewController inView:self.view];
}

- (void)fwAddChildViewController:(UIViewController *)viewController inView:(UIView *)view
{
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    [view addSubview:viewController.view];
    // viewController.view.frame = view.bounds;
    [viewController.view fwPinEdgesToSuperview];
}

#pragma mark - Previous

- (UIViewController *)fwPreviousViewController
{
    if (self.navigationController.viewControllers &&
        self.navigationController.viewControllers.count > 1 &&
        self.navigationController.topViewController == self) {
        NSUInteger count = self.navigationController.viewControllers.count;
        return (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count - 2];
    }
    return nil;
}

@end
