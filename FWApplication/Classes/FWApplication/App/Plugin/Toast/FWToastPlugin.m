/**
 @header     FWToastPlugin.m
 @indexgroup FWApplication
      FWToastPlugin
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "FWToastPlugin.h"
#import "FWToastPluginImpl.h"
#import <objc/runtime.h>

#pragma mark - FWToastPluginView

@implementation FWViewWrapper (FWToastPluginView)

- (id<FWToastPlugin>)toastPlugin
{
    id<FWToastPlugin> toastPlugin = objc_getAssociatedObject(self.base, @selector(toastPlugin));
    if (!toastPlugin) toastPlugin = [FWPluginManager loadPlugin:@protocol(FWToastPlugin)];
    if (!toastPlugin) toastPlugin = FWToastPluginImpl.sharedInstance;
    return toastPlugin;
}

- (void)setToastPlugin:(id<FWToastPlugin>)toastPlugin
{
    objc_setAssociatedObject(self.base, @selector(toastPlugin), toastPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)toastInsets
{
    NSValue *insets = objc_getAssociatedObject(self.base, @selector(toastInsets));
    return insets ? [insets UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setToastInsets:(UIEdgeInsets)toastInsets
{
    objc_setAssociatedObject(self.base, @selector(toastInsets), [NSValue valueWithUIEdgeInsets:toastInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showLoading
{
    [self showLoadingWithText:nil];
}

- (void)showLoadingWithText:(id)text
{
    NSAttributedString *attributedText = [text isKindOfClass:[NSString class]] ? [[NSAttributedString alloc] initWithString:text] : text;
    id<FWToastPlugin> plugin = self.toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(showLoadingWithAttributedText:inView:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin showLoadingWithAttributedText:attributedText inView:self.base];
}

- (void)hideLoading
{
    id<FWToastPlugin> plugin = self.toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hideLoading:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin hideLoading:self.base];
}

- (void)showProgressWithText:(id)text progress:(CGFloat)progress
{
    NSAttributedString *attributedText = [text isKindOfClass:[NSString class]] ? [[NSAttributedString alloc] initWithString:text] : text;
    id<FWToastPlugin> plugin = self.toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(showProgressWithAttributedText:progress:inView:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin showProgressWithAttributedText:attributedText progress:progress inView:self.base];
}

- (void)hideProgress
{
    id<FWToastPlugin> plugin = self.toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hideProgress:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin hideProgress:self.base];
}

- (void)showMessageWithText:(id)text
{
    [self showMessageWithText:text style:FWToastStyleDefault];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style
{
    [self showMessageWithText:text style:style completion:nil];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style completion:(void (^)(void))completion
{
    [self showMessageWithText:text style:style autoHide:YES completion:completion];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(void (^)(void))completion
{
    NSAttributedString *attributedText = [text isKindOfClass:[NSString class]] ? [[NSAttributedString alloc] initWithString:text] : text;
    id<FWToastPlugin> plugin = self.toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(showMessageWithAttributedText:style:autoHide:completion:inView:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin showMessageWithAttributedText:attributedText style:style autoHide:autoHide completion:completion inView:self.base];
}

- (void)hideMessage
{
    id<FWToastPlugin> plugin = self.toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hideMessage:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin hideMessage:self.base];
}

@end

@implementation FWViewControllerWrapper (FWToastPluginView)

- (UIEdgeInsets)toastInsets
{
    return self.base.view.fw.toastInsets;
}

- (void)setToastInsets:(UIEdgeInsets)toastInsets
{
    self.base.view.fw.toastInsets = toastInsets;
}

- (void)showLoading
{
    [self.base.view.fw showLoading];
}

- (void)showLoadingWithText:(id)text
{
    [self.base.view.fw showLoadingWithText:text];
}

- (void)hideLoading
{
    [self.base.view.fw hideLoading];
}

- (void)showProgressWithText:(id)text progress:(CGFloat)progress
{
    [self.base.view.fw showProgressWithText:text progress:progress];
}

- (void)hideProgress
{
    [self.base.view.fw hideProgress];
}

- (void)showMessageWithText:(id)text
{
    [self.base.view.fw showMessageWithText:text];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style
{
    [self.base.view.fw showMessageWithText:text style:style];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style completion:(void (^)(void))completion
{
    [self.base.view.fw showMessageWithText:text style:style completion:completion];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(void (^)(void))completion
{
    [self.base.view.fw showMessageWithText:text style:style autoHide:autoHide completion:completion];
}

- (void)hideMessage
{
    [self.base.view.fw hideMessage];
}

@end

@implementation FWWindowClassWrapper (FWToastPluginView)

- (UIEdgeInsets)toastInsets
{
    return UIWindow.fw.mainWindow.fw.toastInsets;
}

- (void)setToastInsets:(UIEdgeInsets)toastInsets
{
    UIWindow.fw.mainWindow.fw.toastInsets = toastInsets;
}

- (void)showLoading
{
    [UIWindow.fw.mainWindow.fw showLoading];
}

- (void)showLoadingWithText:(id)text
{
    [UIWindow.fw.mainWindow.fw showLoadingWithText:text];
}

- (void)hideLoading
{
    [UIWindow.fw.mainWindow.fw hideLoading];
}

- (void)showProgressWithText:(id)text progress:(CGFloat)progress
{
    [UIWindow.fw.mainWindow.fw showProgressWithText:text progress:progress];
}

- (void)hideProgress
{
    [UIWindow.fw.mainWindow.fw hideProgress];
}

- (void)showMessageWithText:(id)text
{
    [UIWindow.fw.mainWindow.fw showMessageWithText:text];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style
{
    [UIWindow.fw.mainWindow.fw showMessageWithText:text style:style];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style completion:(void (^)(void))completion
{
    [UIWindow.fw.mainWindow.fw showMessageWithText:text style:style completion:completion];
}

- (void)showMessageWithText:(id)text style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(void (^)(void))completion
{
    [UIWindow.fw.mainWindow.fw showMessageWithText:text style:style autoHide:autoHide completion:completion];
}

- (void)hideMessage
{
    [UIWindow.fw.mainWindow.fw hideMessage];
}

@end
