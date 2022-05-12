/**
 @header     FWNavigationController.m
 @indexgroup FWApplication
      FWNavigationController
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/2/14
 */

#import "FWNavigationController.h"
#import "FWNavigationStyle.h"
#import <objc/runtime.h>

#pragma mark - FWNavigationControllerWrapper+FWBarTransition

@interface FWNavigationControllerWrapper (FWBarInternal)

@property (nonatomic, assign) BOOL backgroundViewHidden;
@property (nonatomic, weak) UIViewController *transitionContextToViewController;

@end

@interface FWViewControllerWrapper (FWBarInternal)

@property (nonatomic, strong) UINavigationBar *transitionNavigationBar;

- (void)addTransitionNavigationBarIfNeeded;

@end

@implementation FWNavigationBarWrapper (FWBarTransition)

- (UIView *)backgroundView
{
    return [self invokeGetter:@"_backgroundView"];
}

- (BOOL)isFakeBar
{
    return [objc_getAssociatedObject(self.base, @selector(isFakeBar)) boolValue];
}

- (void)setIsFakeBar:(BOOL)isFakeBar
{
    objc_setAssociatedObject(self.base, @selector(isFakeBar), @(isFakeBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)replaceStyleWithNavigationBar:(UINavigationBar *)navigationBar
{
    self.base.barTintColor = navigationBar.barTintColor;
    [self.base setBackgroundImage:[navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [self.base setShadowImage:navigationBar.shadowImage];
    
    self.base.tintColor = navigationBar.tintColor;
    self.base.titleTextAttributes = navigationBar.titleTextAttributes;
    self.base.largeTitleTextAttributes = navigationBar.largeTitleTextAttributes;
    
    if (@available(iOS 13.0, *)) {
        self.base.standardAppearance = navigationBar.standardAppearance;
        self.base.compactAppearance = navigationBar.compactAppearance;
        self.base.scrollEdgeAppearance = navigationBar.scrollEdgeAppearance;
        #if __IPHONE_15_0
        if (@available(iOS 15.0, *)) {
            self.base.compactScrollEdgeAppearance = navigationBar.compactScrollEdgeAppearance;
        }
        #endif
    }
}

@end

@implementation FWViewControllerWrapper (FWBarTransition)

#pragma mark - Accessor

- (id)barTransitionIdentifier
{
    return objc_getAssociatedObject(self.base, @selector(barTransitionIdentifier));
}

- (void)setBarTransitionIdentifier:(id)identifier
{
    objc_setAssociatedObject(self.base, @selector(barTransitionIdentifier), identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationBar *)transitionNavigationBar
{
    return objc_getAssociatedObject(self.base, @selector(transitionNavigationBar));
}

- (void)setTransitionNavigationBar:(UINavigationBar *)navigationBar
{
    objc_setAssociatedObject(self.base, @selector(transitionNavigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Private

- (void)resizeTransitionNavigationBarFrame
{
    if (!self.base.view.window) {
        return;
    }
    UIView *backgroundView = self.base.navigationController.navigationBar.fw.backgroundView;
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.base.view];
    self.transitionNavigationBar.frame = rect;
}

- (void)addTransitionNavigationBarIfNeeded
{
    if (!self.base.isViewLoaded || !self.base.view.window) {
        return;
    }
    if (!self.base.navigationController.navigationBar) {
        return;
    }
    UINavigationBar *bar = [[UINavigationBar alloc] init];
    bar.fw.isFakeBar = YES;
    // 修复iOS14假的NavigationBar不生效问题
    if (@available(iOS 14.0, *)) {
        bar.items = @[[UINavigationItem new]];
    }
    bar.barStyle = self.base.navigationController.navigationBar.barStyle;
    if (bar.translucent != self.base.navigationController.navigationBar.translucent) {
        bar.translucent = self.base.navigationController.navigationBar.translucent;
    }
    [bar.fw replaceStyleWithNavigationBar:self.base.navigationController.navigationBar];
    [self.transitionNavigationBar removeFromSuperview];
    self.transitionNavigationBar = bar;
    [self resizeTransitionNavigationBarFrame];
    if (!self.base.navigationController.navigationBarHidden && !self.base.navigationController.navigationBar.hidden) {
        [self.base.view addSubview:self.transitionNavigationBar];
    }
}

- (BOOL)shouldCustomTransitionFrom:(UIViewController *)from to:(UIViewController *)to
{
    if (!from || !to) {
        return YES;
    }
    
    // 如果identifier有值则比较之，不相等才启用转场
    id fromIdentifier = [from.fw barTransitionIdentifier];
    id toIdentifier = [to.fw barTransitionIdentifier];
    if (fromIdentifier || toIdentifier) {
        return ![fromIdentifier isEqual:toIdentifier];
    }
    
    return YES;
}

@end

@implementation FWNavigationControllerWrapper (FWBarTransition)

#pragma mark - Accessor

- (UIColor *)containerBackgroundColor
{
    UIColor *backgroundColor = objc_getAssociatedObject(self.base, @selector(containerBackgroundColor));
    return backgroundColor ?: [UIColor clearColor];
}

- (void)setContainerBackgroundColor:(UIColor *)backgroundColor
{
    objc_setAssociatedObject(self.base, @selector(containerBackgroundColor), backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)backgroundViewHidden
{
    return [objc_getAssociatedObject(self.base, @selector(backgroundViewHidden)) boolValue];
}

- (void)setBackgroundViewHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self.base, @selector(backgroundViewHidden), @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.base.navigationBar.fw.backgroundView setHidden:hidden];
}

- (UIViewController *)transitionContextToViewController
{
    FWWeakObject *value = objc_getAssociatedObject(self.base, @selector(transitionContextToViewController));
    return value.object;
}

- (void)setTransitionContextToViewController:(UIViewController *)viewController
{
    objc_setAssociatedObject(self.base, @selector(transitionContextToViewController), [[FWWeakObject alloc] initWithObject:viewController], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FWNavigationControllerClassWrapper (FWBarTransition)

- (void)enableBarTransition
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UINavigationBar, @selector(layoutSubviews), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            UIView *backgroundView = selfObject.fw.backgroundView;
            CGRect frame = backgroundView.frame;
            frame.size.height = selfObject.frame.size.height + fabs(frame.origin.y);
            backgroundView.frame = frame;
        }));
        
        FWSwizzleMethod(objc_getClass("_UIBarBackground"), @selector(setHidden:), nil, FWSwizzleType(UIView *), FWSwizzleReturn(void), FWSwizzleArgs(BOOL hidden), FWSwizzleCode({
            UIResponder *responder = (UIResponder *)selfObject;
            while (responder) {
                if ([responder isKindOfClass:[UINavigationBar class]] && ((UINavigationBar *)responder).fw.isFakeBar) {
                    return;
                }
                if ([responder isKindOfClass:[UINavigationController class]]) {
                    FWSwizzleOriginal(((UINavigationController *)responder).fw.backgroundViewHidden);
                    return;
                }
                responder = responder.nextResponder;
            }
            
            FWSwizzleOriginal(hidden);
        }));
        FWSwizzleMethod(objc_getClass("_UIParallaxDimmingView"), @selector(layoutSubviews), nil, FWSwizzleType(UIView *), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            // 处理导航栏左侧阴影占不满的问题。兼容iOS13下如果navigationBar是磨砂的，则每个视图内部都会有一个磨砂，而磨砂再包裹了imageView等subview
            if ([selfObject.subviews.firstObject isKindOfClass:[UIImageView class]] ||
                [selfObject.subviews.firstObject isKindOfClass:[UIVisualEffectView class]]) {
                UIView *shadowView = selfObject.subviews.firstObject;
                if (selfObject.frame.origin.y > 0 && shadowView.frame.origin.y == 0) {
                    shadowView.frame = CGRectMake(shadowView.frame.origin.x,
                                                  shadowView.frame.origin.y - selfObject.frame.origin.y,
                                                  shadowView.frame.size.width,
                                                  shadowView.frame.size.height + selfObject.frame.origin.y);
                }
            }
        }));
        
        FWSwizzleClass(UIViewController, @selector(viewDidAppear:), FWSwizzleReturn(void), FWSwizzleArgs(BOOL animated), FWSwizzleCode({
            UIViewController *transitionViewController = selfObject.navigationController.fw.transitionContextToViewController;
            if (selfObject.fw.transitionNavigationBar) {
                [selfObject.navigationController.navigationBar.fw replaceStyleWithNavigationBar:selfObject.fw.transitionNavigationBar];
                if (!transitionViewController || [transitionViewController isEqual:selfObject]) {
                    [selfObject.fw.transitionNavigationBar removeFromSuperview];
                    selfObject.fw.transitionNavigationBar = nil;
                }
            }
            if ([transitionViewController isEqual:selfObject]) {
                selfObject.navigationController.fw.transitionContextToViewController = nil;
            }
            selfObject.navigationController.fw.backgroundViewHidden = NO;
            FWSwizzleOriginal(animated);
        }));
        FWSwizzleClass(UIViewController, @selector(viewWillLayoutSubviews), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            id<UIViewControllerTransitionCoordinator> tc = selfObject.transitionCoordinator;
            UIViewController *fromViewController = [tc viewControllerForKey:UITransitionContextFromViewControllerKey];
            UIViewController *toViewController = [tc viewControllerForKey:UITransitionContextToViewControllerKey];
            if (![selfObject.fw shouldCustomTransitionFrom:fromViewController to:toViewController]) {
                FWSwizzleOriginal();
                return;
            }
            
            if ([selfObject isEqual:selfObject.navigationController.viewControllers.lastObject] && [toViewController isEqual:selfObject] && tc.presentationStyle == UIModalPresentationNone) {
                if (selfObject.navigationController.navigationBar.translucent) {
                    [tc containerView].backgroundColor = [selfObject.navigationController.fw containerBackgroundColor];
                }
                fromViewController.view.clipsToBounds = NO;
                toViewController.view.clipsToBounds = NO;
                if (!selfObject.fw.transitionNavigationBar) {
                    [selfObject.fw addTransitionNavigationBarIfNeeded];
                    selfObject.navigationController.fw.backgroundViewHidden = YES;
                }
                [selfObject.fw resizeTransitionNavigationBarFrame];
            }
            if (selfObject.fw.transitionNavigationBar) {
                [selfObject.view bringSubviewToFront:selfObject.fw.transitionNavigationBar];
            }
            FWSwizzleOriginal();
        }));
        
        FWSwizzleClass(UINavigationController, @selector(pushViewController:animated:), FWSwizzleReturn(void), FWSwizzleArgs(UIViewController *viewController, BOOL animated), FWSwizzleCode({
            UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
            if (!disappearingViewController) {
                return FWSwizzleOriginal(viewController, animated);
            }
            if (![selfObject.fw shouldCustomTransitionFrom:disappearingViewController to:viewController]) {
                return FWSwizzleOriginal(viewController, animated);
            }
            
            if (!selfObject.fw.transitionContextToViewController || !disappearingViewController.fw.transitionNavigationBar) {
                [disappearingViewController.fw addTransitionNavigationBarIfNeeded];
            }
            if (animated) {
                selfObject.fw.transitionContextToViewController = viewController;
                if (disappearingViewController.fw.transitionNavigationBar) {
                    disappearingViewController.navigationController.fw.backgroundViewHidden = YES;
                }
            }
            return FWSwizzleOriginal(viewController, animated);
        }));
        FWSwizzleClass(UINavigationController, @selector(popViewControllerAnimated:), FWSwizzleReturn(UIViewController *), FWSwizzleArgs(BOOL animated), FWSwizzleCode({
            if (selfObject.viewControllers.count < 2) {
                return FWSwizzleOriginal(animated);
            }
            UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
            UIViewController *appearingViewController = selfObject.viewControllers[selfObject.viewControllers.count - 2];
            if (![selfObject.fw shouldCustomTransitionFrom:disappearingViewController to:appearingViewController]) {
                return FWSwizzleOriginal(animated);
            }
            
            [disappearingViewController.fw addTransitionNavigationBarIfNeeded];
            if (appearingViewController.fw.transitionNavigationBar) {
                UINavigationBar *appearingNavigationBar = appearingViewController.fw.transitionNavigationBar;
                [selfObject.navigationBar.fw replaceStyleWithNavigationBar:appearingNavigationBar];
            }
            if (animated) {
                disappearingViewController.navigationController.fw.backgroundViewHidden = YES;
            }
            return FWSwizzleOriginal(animated);
        }));
        FWSwizzleClass(UINavigationController, @selector(popToViewController:animated:), FWSwizzleReturn(NSArray<UIViewController *> *), FWSwizzleArgs(UIViewController *viewController, BOOL animated), FWSwizzleCode({
            if (![selfObject.viewControllers containsObject:viewController] || selfObject.viewControllers.count < 2) {
                return FWSwizzleOriginal(viewController, animated);
            }
            UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
            if (![selfObject.fw shouldCustomTransitionFrom:disappearingViewController to:viewController]) {
                return FWSwizzleOriginal(viewController, animated);
            }
            
            [disappearingViewController.fw addTransitionNavigationBarIfNeeded];
            if (viewController.fw.transitionNavigationBar) {
                UINavigationBar *appearingNavigationBar = viewController.fw.transitionNavigationBar;
                [selfObject.navigationBar.fw replaceStyleWithNavigationBar:appearingNavigationBar];
            }
            if (animated) {
                disappearingViewController.navigationController.fw.backgroundViewHidden = YES;
            }
            return FWSwizzleOriginal(viewController, animated);
        }));
        FWSwizzleClass(UINavigationController, @selector(popToRootViewControllerAnimated:), FWSwizzleReturn(NSArray<UIViewController *> *), FWSwizzleArgs(BOOL animated), FWSwizzleCode({
            if (selfObject.viewControllers.count < 2) {
                return FWSwizzleOriginal(animated);
            }
            UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
            UIViewController *rootViewController = selfObject.viewControllers.firstObject;
            if (![selfObject.fw shouldCustomTransitionFrom:disappearingViewController to:rootViewController]) {
                return FWSwizzleOriginal(animated);
            }
            
            [disappearingViewController.fw addTransitionNavigationBarIfNeeded];
            if (rootViewController.fw.transitionNavigationBar) {
                UINavigationBar *appearingNavigationBar = rootViewController.fw.transitionNavigationBar;
                [selfObject.navigationBar.fw replaceStyleWithNavigationBar:appearingNavigationBar];
            }
            if (animated) {
                disappearingViewController.navigationController.fw.backgroundViewHidden = YES;
            }
            return FWSwizzleOriginal(animated);
        }));
        FWSwizzleClass(UINavigationController, @selector(setViewControllers:animated:), FWSwizzleReturn(void), FWSwizzleArgs(NSArray<UIViewController *> *viewControllers, BOOL animated), FWSwizzleCode({
            UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
            UIViewController *appearingViewController = viewControllers.count > 0 ? viewControllers.lastObject : nil;
            if (![selfObject.fw shouldCustomTransitionFrom:disappearingViewController to:appearingViewController]) {
                return FWSwizzleOriginal(viewControllers, animated);
            }
            
            if (animated && disappearingViewController && ![disappearingViewController isEqual:viewControllers.lastObject]) {
                [disappearingViewController.fw addTransitionNavigationBarIfNeeded];
                if (disappearingViewController.fw.transitionNavigationBar) {
                    disappearingViewController.navigationController.fw.backgroundViewHidden = YES;
                }
            }
            return FWSwizzleOriginal(viewControllers, animated);
        }));
    });
}

@end

#pragma mark - FWNavigationControllerWrapper+FWFullscreenPopGesture

@interface FWFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation FWFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.fw.fullscreenPopGestureDisabled) {
        return NO;
    }
    
    if ([topViewController respondsToSelector:@selector(shouldPopController)] &&
        ![topViewController shouldPopController]) {
        return NO;
    }
    
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.fw.fullscreenPopGestureDistance;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : - 1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }
    
    return YES;
}

@end

@implementation FWViewControllerWrapper (FWFullscreenPopGesture)

- (BOOL)fullscreenPopGestureDisabled
{
    return [objc_getAssociatedObject(self.base, _cmd) boolValue];
}

- (void)setFullscreenPopGestureDisabled:(BOOL)disabled
{
    objc_setAssociatedObject(self.base, @selector(fullscreenPopGestureDisabled), @(disabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)fullscreenPopGestureDistance
{
#if CGFLOAT_IS_DOUBLE
    return [objc_getAssociatedObject(self.base, _cmd) doubleValue];
#else
    return [objc_getAssociatedObject(self.base, _cmd) floatValue];
#endif
}

- (void)setFullscreenPopGestureDistance:(CGFloat)distance
{
    objc_setAssociatedObject(self.base, @selector(fullscreenPopGestureDistance), @(MAX(0, distance)), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FWNavigationControllerWrapper (FWFullscreenPopGesture)

- (BOOL)fullscreenPopGestureEnabled
{
    return self.fullscreenPopGestureRecognizer.enabled;
}

- (void)setFullscreenPopGestureEnabled:(BOOL)enabled
{
    if (![self.base.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.fullscreenPopGestureRecognizer]) {
        [self.base.interactivePopGestureRecognizer.view addGestureRecognizer:self.fullscreenPopGestureRecognizer];
        
        NSArray *internalTargets = [self.base.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.fullscreenPopGestureRecognizer.delegate = self.popGestureRecognizerDelegate;
        [self.fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
    }
    
    self.fullscreenPopGestureRecognizer.enabled = enabled;
    self.base.interactivePopGestureRecognizer.enabled = !enabled;
}

- (FWFullscreenPopGestureRecognizerDelegate *)popGestureRecognizerDelegate
{
    FWFullscreenPopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self.base, _cmd);
    if (!delegate) {
        delegate = [[FWFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self.base;
        objc_setAssociatedObject(self.base, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

- (UIPanGestureRecognizer *)fullscreenPopGestureRecognizer
{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self.base, _cmd);
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        objc_setAssociatedObject(self.base, _cmd, panGestureRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return panGestureRecognizer;
}

@end

@implementation FWNavigationControllerClassWrapper (FWFullscreenPopGesture)

- (BOOL)isFullscreenPopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer.delegate isKindOfClass:[FWFullscreenPopGestureRecognizerDelegate class]]) {
        return YES;
    }
    return NO;
}

@end
