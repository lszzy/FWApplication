/**
 @header     UINavigationController+FWApplication.m
 @indexgroup FWApplication
      UINavigationController+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "UINavigationController+FWApplication.h"
#import <objc/runtime.h>

@interface UINavigationController (FWApplication)

@end

@implementation UINavigationController (FWApplication)

- (BOOL)innerShouldBottomBarBeHidden
{
    return [objc_getAssociatedObject(self, @selector(innerShouldBottomBarBeHidden)) boolValue];
}

- (void)setInnerShouldBottomBarBeHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, @selector(innerShouldBottomBarBeHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FWNavigationControllerWrapper (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 修复iOS14.0如果pop到一个hidesBottomBarWhenPushed=NO的vc，tabBar无法正确显示出来的bug；iOS14.2已修复该问题
        if (@available(iOS 14.2, *)) {} else if (@available(iOS 14.0, *)) {
            FWSwizzleClass(UINavigationController, @selector(popToViewController:animated:), FWSwizzleReturn(NSArray<UIViewController *> *), FWSwizzleArgs(UIViewController *viewController, BOOL animated), FWSwizzleCode({
                if (animated && selfObject.tabBarController && !viewController.hidesBottomBarWhenPushed) {
                    BOOL systemShouldHideTabBar = NO;
                    NSUInteger index = [selfObject.viewControllers indexOfObject:viewController];
                    if (index != NSNotFound) {
                        NSArray<UIViewController *> *viewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(0, index + 1)];
                        for (UIViewController *vc in viewControllers) {
                            if (vc.hidesBottomBarWhenPushed) {
                                systemShouldHideTabBar = YES;
                            }
                        }
                        if (!systemShouldHideTabBar) {
                            selfObject.innerShouldBottomBarBeHidden = YES;
                        }
                    }
                }
                
                NSArray<UIViewController *> *result = FWSwizzleOriginal(viewController, animated);
                selfObject.innerShouldBottomBarBeHidden = NO;
                return result;
            }));
            FWSwizzleClass(UINavigationController, @selector(popToRootViewControllerAnimated:), FWSwizzleReturn(NSArray<UIViewController *> *), FWSwizzleArgs(BOOL animated), FWSwizzleCode({
                if (animated && selfObject.tabBarController && !selfObject.viewControllers.firstObject.hidesBottomBarWhenPushed && selfObject.viewControllers.count > 2) {
                    selfObject.innerShouldBottomBarBeHidden = YES;
                }
                
                NSArray<UIViewController *> *result = FWSwizzleOriginal(animated);
                selfObject.innerShouldBottomBarBeHidden = NO;
                return result;
            }));
            FWSwizzleClass(UINavigationController, @selector(setViewControllers:animated:), FWSwizzleReturn(void), FWSwizzleArgs(NSArray<UIViewController *> *viewControllers, BOOL animated), FWSwizzleCode({
                UIViewController *viewController = viewControllers.lastObject;
                if (animated && selfObject.tabBarController && !viewController.hidesBottomBarWhenPushed) {
                    BOOL systemShouldHideTabBar = NO;
                    for (UIViewController *vc in viewControllers) {
                        if (vc.hidesBottomBarWhenPushed) {
                            systemShouldHideTabBar = YES;
                        }
                    }
                    if (!systemShouldHideTabBar) {
                        selfObject.innerShouldBottomBarBeHidden = YES;
                    }
                }
                
                FWSwizzleOriginal(viewControllers, animated);
                selfObject.innerShouldBottomBarBeHidden = NO;
            }));
            FWSwizzleClass(UINavigationController, NSSelectorFromString(@"_shouldBottomBarBeHidden"), FWSwizzleReturn(BOOL), FWSwizzleArgs(), FWSwizzleCode({
                BOOL result = FWSwizzleOriginal();
                if (selfObject.innerShouldBottomBarBeHidden) {
                    result = NO;
                }
                return result;
            }));
        }
    });
}

@end

@implementation FWNavigationBarWrapper (FWApplication)

- (UIView *)contentView
{
    for (UIView *subview in self.base.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"ContentView"]) return subview;
    }
    return nil;
}

- (UIView *)largeTitleView
{
    for (UIView *subview in self.base.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"LargeTitleView"]) return subview;
    }
    return nil;
}

@end

@implementation FWNavigationBarClassWrapper (FWApplication)

- (CGFloat)largeTitleHeight
{
    return 52;
}

@end

@implementation FWToolbarWrapper (FWApplication)

- (UIView *)contentView
{
    for (UIView *subview in self.base.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"ContentView"]) return subview;
    }
    return nil;
}

- (UIView *)backgroundView
{
    return [self.base fw_invokeGetter:@"_backgroundView"];
}

@end
