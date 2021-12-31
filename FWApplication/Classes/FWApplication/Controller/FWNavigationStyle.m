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
@import FWFramework;

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

#pragma mark - UIViewController+FWStyle

@implementation UIViewController (FWStyle)

#pragma mark - Bar

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIViewController, @selector(prefersStatusBarHidden), FWSwizzleReturn(BOOL), FWSwizzleArgs(), FWSwizzleCode({
            NSNumber *hiddenValue = objc_getAssociatedObject(selfObject, @selector(fwStatusBarHidden));
            if (hiddenValue) {
                return [hiddenValue boolValue];
            } else {
                return FWSwizzleOriginal();
            }
        }));
        
        FWSwizzleClass(UIViewController, @selector(preferredStatusBarStyle), FWSwizzleReturn(UIStatusBarStyle), FWSwizzleArgs(), FWSwizzleCode({
            NSNumber *styleValue = objc_getAssociatedObject(selfObject, @selector(fwStatusBarStyle));
            if (styleValue) {
                return [styleValue integerValue];
            } else {
                return FWSwizzleOriginal();
            }
        }));
        
        FWSwizzleClass(UIViewController, @selector(viewWillAppear:), FWSwizzleReturn(void), FWSwizzleArgs(BOOL animated), FWSwizzleCode({
            FWSwizzleOriginal(animated);
            [selfObject fwUpdateNavigationBarStyle:animated];
        }));
    });
}

- (UIStatusBarStyle)fwStatusBarStyle
{
    return [objc_getAssociatedObject(self, @selector(fwStatusBarStyle)) integerValue];
}

- (void)setFwStatusBarStyle:(UIStatusBarStyle)fwStatusBarStyle
{
    objc_setAssociatedObject(self, @selector(fwStatusBarStyle), @(fwStatusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)fwStatusBarHidden
{
    return [objc_getAssociatedObject(self, @selector(fwStatusBarHidden)) boolValue];
}

- (void)setFwStatusBarHidden:(BOOL)fwStatusBarHidden
{
    objc_setAssociatedObject(self, @selector(fwStatusBarHidden), @(fwStatusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsStatusBarAppearanceUpdate];
}

- (FWNavigationBarAppearance *)fwNavigationBarAppearance
{
    return objc_getAssociatedObject(self, @selector(fwNavigationBarAppearance));
}

- (void)setFwNavigationBarAppearance:(FWNavigationBarAppearance *)fwNavigationBarAppearance
{
    objc_setAssociatedObject(self, @selector(fwNavigationBarAppearance), fwNavigationBarAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.isViewLoaded && self.view.window) {
        [self fwUpdateNavigationBarStyle:NO];
    }
}

- (FWNavigationBarStyle)fwNavigationBarStyle
{
    return [objc_getAssociatedObject(self, @selector(fwNavigationBarStyle)) integerValue];
}

- (void)setFwNavigationBarStyle:(FWNavigationBarStyle)fwNavigationBarStyle
{
    objc_setAssociatedObject(self, @selector(fwNavigationBarStyle), @(fwNavigationBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.isViewLoaded && self.view.window) {
        [self fwUpdateNavigationBarStyle:NO];
    }
}

- (BOOL)fwNavigationBarHidden
{
    return [objc_getAssociatedObject(self, @selector(fwNavigationBarHidden)) boolValue];
}

- (void)setFwNavigationBarHidden:(BOOL)hidden
{
    [self fwSetNavigationBarHidden:hidden animated:NO];
}

- (void)fwSetNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    objc_setAssociatedObject(self, @selector(fwNavigationBarHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (self.isViewLoaded && self.view.window) {
        [self fwUpdateNavigationBarStyle:animated];
    }
}

- (FWNavigationBarAppearance *)fwCurrentNavigationBarAppearance
{
    // 1. 检查VC是否自定义appearance
    FWNavigationBarAppearance *appearance = self.fwNavigationBarAppearance;
    if (appearance) return appearance;
    // 2. 检查VC是否自定义style
    NSNumber *style = objc_getAssociatedObject(self, @selector(fwNavigationBarStyle));
    if (style) {
        appearance = [FWNavigationBarAppearance appearanceForStyle:style.integerValue];
        return appearance;
    }
    // 3. 检查NAV是否自定义appearance
    appearance = self.navigationController.fwNavigationBarAppearance;
    if (appearance) return appearance;
    // 4. 检查NAV是否自定义style
    style = objc_getAssociatedObject(self.navigationController, @selector(fwNavigationBarStyle));
    if (style) {
        appearance = [FWNavigationBarAppearance appearanceForStyle:style.integerValue];
    }
    return appearance;
}

- (void)fwUpdateNavigationBarStyle:(BOOL)animated
{
    // 含有导航栏且不是child控制器且不是导航栏控制器时才处理
    if (!self.navigationController || self.fwIsChild ||
        [self isKindOfClass:[UINavigationController class]]) return;
    
    // fwNavigationBarHidden设置即生效，动态切换导航栏不突兀，一般在viewWillAppear:中调用
    NSNumber *hidden = objc_getAssociatedObject(self, @selector(fwNavigationBarHidden));
    if (hidden && self.navigationController.navigationBarHidden != hidden.boolValue) {
        [self.navigationController setNavigationBarHidden:hidden.boolValue animated:animated];
    }
    
    // 获取当前用于显示的appearance
    FWNavigationBarAppearance *appearance = [self fwCurrentNavigationBarAppearance];
    if (!appearance) return;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if (appearance.isTranslucent != navigationBar.fwIsTranslucent) {
        navigationBar.fwIsTranslucent = appearance.isTranslucent;
    }
    if (appearance.backgroundTransparent) {
        navigationBar.fwBackgroundTransparent = appearance.backgroundTransparent;
    } else if (appearance.backgroundImage) {
        navigationBar.fwBackgroundImage = appearance.backgroundImage;
    } else if (appearance.backgroundColor) {
        navigationBar.fwBackgroundColor = appearance.backgroundColor;
    }
    if (appearance.shadowImage) {
        navigationBar.fwShadowImage = appearance.shadowImage;
    } else if (appearance.shadowColor) {
        navigationBar.fwShadowColor = appearance.shadowColor;
    } else {
        navigationBar.fwShadowColor = nil;
    }
    if (appearance.foregroundColor) navigationBar.fwForegroundColor = appearance.foregroundColor;
    if (appearance.titleColor) navigationBar.fwTitleColor = appearance.titleColor;
    if (appearance.appearanceBlock) appearance.appearanceBlock(navigationBar);
}

- (BOOL)fwTabBarHidden
{
    return self.tabBarController.tabBar.hidden;
}

- (void)setFwTabBarHidden:(BOOL)fwTabBarHidden
{
    self.tabBarController.tabBar.hidden = fwTabBarHidden;
}

- (BOOL)fwToolBarHidden
{
    return self.navigationController.toolbarHidden;
}

- (void)setFwToolBarHidden:(BOOL)fwToolBarHidden
{
    self.navigationController.toolbarHidden = fwToolBarHidden;
}

- (void)fwSetToolBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self.navigationController setToolbarHidden:hidden animated:animated];
}

- (UIRectEdge)fwExtendedLayoutEdge
{
    return self.edgesForExtendedLayout;
}

- (void)setFwExtendedLayoutEdge:(UIRectEdge)edge
{
    self.edgesForExtendedLayout = edge;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

#pragma mark - Item

- (id)fwBarTitle
{
    // 系统导航栏
    return self.navigationItem.titleView ?: self.navigationItem.title;
}

- (void)setFwBarTitle:(id)title
{
    if ([title isKindOfClass:[UIView class]]) {
        self.navigationItem.titleView = title;
    } else {
        self.navigationItem.title = title;
    }
}

- (id)fwLeftBarItem
{
    return self.navigationItem.leftBarButtonItem;
}

- (void)setFwLeftBarItem:(id)object
{
    if (!object || [object isKindOfClass:[UIBarButtonItem class]]) {
        self.navigationItem.leftBarButtonItem = object;
    } else {
        __weak __typeof__(self) self_weak_ = self;
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem fwBarItemWithObject:object block:^(id  _Nonnull sender) {
            __typeof__(self) self = self_weak_;
            if (![self fwPopBackBarItem]) return;
            [self fwCloseViewControllerAnimated:YES];
        }];
    }
}

- (id)fwRightBarItem
{
    return self.navigationItem.rightBarButtonItem;
}

- (void)setFwRightBarItem:(id)object
{
    if (!object || [object isKindOfClass:[UIBarButtonItem class]]) {
        self.navigationItem.rightBarButtonItem = object;
    } else {
        __weak __typeof__(self) self_weak_ = self;
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem fwBarItemWithObject:object block:^(id  _Nonnull sender) {
            __typeof__(self) self = self_weak_;
            if (![self fwPopBackBarItem]) return;
            [self fwCloseViewControllerAnimated:YES];
        }];
    }
}

- (void)fwSetLeftBarItem:(id)object target:(id)target action:(SEL)action
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem fwBarItemWithObject:object target:target action:action];
}

- (void)fwSetLeftBarItem:(id)object block:(void (^)(id sender))block
{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem fwBarItemWithObject:object block:block];
}

- (void)fwSetRightBarItem:(id)object target:(id)target action:(SEL)action
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem fwBarItemWithObject:object target:target action:action];
}

- (void)fwSetRightBarItem:(id)object block:(void (^)(id sender))block
{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem fwBarItemWithObject:object block:block];
}

- (void)fwAddLeftBarItem:(id)object target:(id)target action:(SEL)action
{
    UIBarButtonItem *barItem = [UIBarButtonItem fwBarItemWithObject:object target:target action:action];
    NSMutableArray *items = self.navigationItem.leftBarButtonItems ? [self.navigationItem.leftBarButtonItems mutableCopy] : [NSMutableArray new];
    [items addObject:barItem];
    self.navigationItem.leftBarButtonItems = [items copy];
}

- (void)fwAddLeftBarItem:(id)object block:(void (^)(id sender))block
{
    UIBarButtonItem *barItem = [UIBarButtonItem fwBarItemWithObject:object block:block];
    NSMutableArray *items = self.navigationItem.leftBarButtonItems ? [self.navigationItem.leftBarButtonItems mutableCopy] : [NSMutableArray new];
    [items addObject:barItem];
    self.navigationItem.leftBarButtonItems = [items copy];
}

- (void)fwAddRightBarItem:(id)object target:(id)target action:(SEL)action
{
    UIBarButtonItem *barItem = [UIBarButtonItem fwBarItemWithObject:object target:target action:action];
    NSMutableArray *items = self.navigationItem.rightBarButtonItems ? [self.navigationItem.rightBarButtonItems mutableCopy] : [NSMutableArray new];
    [items addObject:barItem];
    self.navigationItem.rightBarButtonItems = [items copy];
}

- (void)fwAddRightBarItem:(id)object block:(void (^)(id sender))block
{
    UIBarButtonItem *barItem = [UIBarButtonItem fwBarItemWithObject:object block:block];
    NSMutableArray *items = self.navigationItem.rightBarButtonItems ? [self.navigationItem.rightBarButtonItems mutableCopy] : [NSMutableArray new];
    [items addObject:barItem];
    self.navigationItem.rightBarButtonItems = [items copy];
}

#pragma mark - Back

- (id)fwBackBarItem
{
    return self.navigationItem.backBarButtonItem;
}

- (void)setFwBackBarItem:(id)object
{
    if ([object isKindOfClass:[UIImage class]]) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage new] style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.fwBackImage = (UIImage *)object;
    } else {
        UIBarButtonItem *backItem = [object isKindOfClass:[UIBarButtonItem class]] ? (UIBarButtonItem *)object : [UIBarButtonItem fwBarItemWithObject:object ?: [UIImage new] target:nil action:nil];
        self.navigationItem.backBarButtonItem = backItem;
        self.navigationController.navigationBar.fwBackImage = nil;
    }
}

- (BOOL)fwPopBackBarItem
{
    BOOL shouldPop = YES;
    BOOL (^block)(void) = objc_getAssociatedObject(self, @selector(fwPopBackBarItem));
    if (block) {
        shouldPop = block();
    }
    return shouldPop;
}

- (BOOL (^)(void))fwBackBarBlock
{
    return objc_getAssociatedObject(self, @selector(fwPopBackBarItem));
}

- (void)setFwBackBarBlock:(BOOL (^)(void))block
{
    if (block) {
        objc_setAssociatedObject(self, @selector(fwPopBackBarItem), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, @selector(fwPopBackBarItem), nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

@end
