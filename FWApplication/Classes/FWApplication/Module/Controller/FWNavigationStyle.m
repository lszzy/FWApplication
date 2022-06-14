/**
 @header     FWNavigationStyle.m
 @indexgroup FWApplication
      FWNavigationStyle
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/12/5
 */

#import "FWNavigationStyle.h"
#import <objc/runtime.h>

#pragma mark - FWNavigationBarAppearance

@implementation FWNavigationBarAppearance

+ (NSMutableDictionary *)styleAppearances
{
    static NSMutableDictionary *appearances = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appearances = [[NSMutableDictionary alloc] init];
    });
    return appearances;
}

+ (FWNavigationBarAppearance *)appearanceForStyle:(FWNavigationBarStyle)style
{
    return [[self styleAppearances] objectForKey:@(style)];
}

+ (void)setAppearance:(FWNavigationBarAppearance *)appearance forStyle:(FWNavigationBarStyle)style
{
    if (appearance) {
        [[self styleAppearances] setObject:appearance forKey:@(style)];
    } else {
        [[self styleAppearances] removeObjectForKey:@(style)];
    }
}

@end

#pragma mark - FWViewControllerWrapper+FWStyle

@implementation FWViewControllerWrapper (FWStyle)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIViewController, @selector(prefersStatusBarHidden), FWSwizzleReturn(BOOL), FWSwizzleArgs(), FWSwizzleCode({
            NSNumber *hiddenValue = objc_getAssociatedObject(selfObject, @selector(statusBarHidden));
            if (hiddenValue) {
                return [hiddenValue boolValue];
            } else {
                return FWSwizzleOriginal();
            }
        }));
        
        FWSwizzleClass(UIViewController, @selector(preferredStatusBarStyle), FWSwizzleReturn(UIStatusBarStyle), FWSwizzleArgs(), FWSwizzleCode({
            NSNumber *styleValue = objc_getAssociatedObject(selfObject, @selector(statusBarStyle));
            if (styleValue) {
                return [styleValue integerValue];
            } else {
                return FWSwizzleOriginal();
            }
        }));
        
        FWSwizzleClass(UIViewController, @selector(viewWillAppear:), FWSwizzleReturn(void), FWSwizzleArgs(BOOL animated), FWSwizzleCode({
            FWSwizzleOriginal(animated);
            [selfObject.fw updateNavigationBarStyle:animated];
        }));
    });
}

- (UIStatusBarStyle)statusBarStyle
{
    return [objc_getAssociatedObject(self.base, @selector(statusBarStyle)) integerValue];
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    objc_setAssociatedObject(self.base, @selector(statusBarStyle), @(statusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.base setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)statusBarHidden
{
    return [objc_getAssociatedObject(self.base, @selector(statusBarHidden)) boolValue];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden
{
    objc_setAssociatedObject(self.base, @selector(statusBarHidden), @(statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.base setNeedsStatusBarAppearanceUpdate];
}

- (FWNavigationBarAppearance *)navigationBarAppearance
{
    return objc_getAssociatedObject(self.base, @selector(navigationBarAppearance));
}

- (void)setNavigationBarAppearance:(FWNavigationBarAppearance *)navigationBarAppearance
{
    objc_setAssociatedObject(self.base, @selector(navigationBarAppearance), navigationBarAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.base.isViewLoaded && self.base.view.window) {
        [self updateNavigationBarStyle:NO];
    }
}

- (FWNavigationBarStyle)navigationBarStyle
{
    return [objc_getAssociatedObject(self.base, @selector(navigationBarStyle)) integerValue];
}

- (void)setNavigationBarStyle:(FWNavigationBarStyle)navigationBarStyle
{
    objc_setAssociatedObject(self.base, @selector(navigationBarStyle), @(navigationBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.base.isViewLoaded && self.base.view.window) {
        [self updateNavigationBarStyle:NO];
    }
}

- (BOOL)navigationBarHidden
{
    return [objc_getAssociatedObject(self.base, @selector(navigationBarHidden)) boolValue];
}

- (void)setNavigationBarHidden:(BOOL)hidden
{
    [self setNavigationBarHidden:hidden animated:NO];
    // 直接设置navigtionBar.isHidden不会影响右滑关闭手势
    // self.navigationController.navigationBar.isHidden = YES;
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    objc_setAssociatedObject(self.base, @selector(navigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.base.isViewLoaded && self.base.view.window) {
        [self updateNavigationBarStyle:animated];
    }
}

- (FWNavigationBarAppearance *)currentNavigationBarAppearance
{
    // 1. 检查VC是否自定义appearance
    FWNavigationBarAppearance *appearance = self.navigationBarAppearance;
    if (appearance) return appearance;
    // 2. 检查VC是否自定义style
    NSNumber *style = objc_getAssociatedObject(self.base, @selector(navigationBarStyle));
    if (style) {
        appearance = [FWNavigationBarAppearance appearanceForStyle:style.integerValue];
        return appearance;
    }
    // 3. 检查NAV是否自定义appearance
    appearance = self.base.navigationController.fw.navigationBarAppearance;
    if (appearance) return appearance;
    // 4. 检查NAV是否自定义style
    style = objc_getAssociatedObject(self.base.navigationController, @selector(navigationBarStyle));
    if (style) {
        appearance = [FWNavigationBarAppearance appearanceForStyle:style.integerValue];
    }
    return appearance;
}

- (void)updateNavigationBarStyle:(BOOL)animated
{
    // 含有导航栏且不是child控制器且不是导航栏控制器时才处理
    if (!self.base.navigationController || self.isChild ||
        [self.base isKindOfClass:[UINavigationController class]]) return;
    
    // fwNavigationBarHidden设置即生效，动态切换导航栏不突兀，一般在viewWillAppear:中调用
    NSNumber *hidden = objc_getAssociatedObject(self.base, @selector(navigationBarHidden));
    if (hidden && self.base.navigationController.navigationBarHidden != hidden.boolValue) {
        [self.base.navigationController setNavigationBarHidden:hidden.boolValue animated:animated];
    }
    
    // 获取当前用于显示的appearance
    FWNavigationBarAppearance *appearance = [self currentNavigationBarAppearance];
    if (!appearance) return;
    UINavigationBar *navigationBar = self.base.navigationController.navigationBar;
    if (appearance.isTranslucent != navigationBar.fw_isTranslucent) {
        navigationBar.fw_isTranslucent = appearance.isTranslucent;
    }
    if (appearance.backgroundTransparent) {
        navigationBar.fw_backgroundTransparent = appearance.backgroundTransparent;
    } else if (appearance.backgroundImage) {
        navigationBar.fw_backgroundImage = appearance.backgroundImage;
    } else if (appearance.backgroundColor) {
        navigationBar.fw_backgroundColor = appearance.backgroundColor;
    }
    if (appearance.shadowImage) {
        navigationBar.fw_shadowImage = appearance.shadowImage;
    } else if (appearance.shadowColor) {
        navigationBar.fw_shadowColor = appearance.shadowColor;
    } else {
        navigationBar.fw_shadowColor = nil;
    }
    if (appearance.foregroundColor) navigationBar.fw_foregroundColor = appearance.foregroundColor;
    if (appearance.titleAttributes) navigationBar.fw_titleAttributes = appearance.titleAttributes;
    if (appearance.buttonAttributes) navigationBar.fw_buttonAttributes = appearance.buttonAttributes;
    if (appearance.appearanceBlock) appearance.appearanceBlock(navigationBar);
}

- (BOOL)tabBarHidden
{
    return self.base.tabBarController.tabBar.hidden;
}

- (void)setTabBarHidden:(BOOL)tabBarHidden
{
    self.base.tabBarController.tabBar.hidden = tabBarHidden;
}

- (BOOL)toolBarHidden
{
    return self.base.navigationController.toolbarHidden;
}

- (void)setToolBarHidden:(BOOL)toolBarHidden
{
    self.base.navigationController.toolbarHidden = toolBarHidden;
}

- (void)setToolBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self.base.navigationController setToolbarHidden:hidden animated:animated];
}

- (UIRectEdge)extendedLayoutEdge
{
    return self.base.edgesForExtendedLayout;
}

- (void)setExtendedLayoutEdge:(UIRectEdge)edge
{
    self.base.edgesForExtendedLayout = edge;
    self.base.extendedLayoutIncludesOpaqueBars = YES;
}

@end
