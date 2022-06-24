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

@implementation UIView (FWToastPlugin)

- (id<FWToastPlugin>)fw_toastPlugin
{
    id<FWToastPlugin> toastPlugin = objc_getAssociatedObject(self, @selector(fw_toastPlugin));
    if (!toastPlugin) toastPlugin = [FWPluginManager loadPlugin:@protocol(FWToastPlugin)];
    if (!toastPlugin) toastPlugin = FWToastPluginImpl.sharedInstance;
    return toastPlugin;
}

- (void)setFw_toastPlugin:(id<FWToastPlugin>)toastPlugin
{
    objc_setAssociatedObject(self, @selector(fw_toastPlugin), toastPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)fw_toastInsets
{
    NSValue *insets = objc_getAssociatedObject(self, @selector(fw_toastInsets));
    return insets ? [insets UIEdgeInsetsValue] : UIEdgeInsetsZero;
}

- (void)setFw_toastInsets:(UIEdgeInsets)toastInsets
{
    objc_setAssociatedObject(self, @selector(fw_toastInsets), [NSValue valueWithUIEdgeInsets:toastInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)fw_showLoading
{
    [self fw_showLoadingWithText:nil];
}

- (void)fw_showLoadingWithText:(id)text
{
    NSAttributedString *attributedText = [text isKindOfClass:[NSString class]] ? [[NSAttributedString alloc] initWithString:text] : text;
    id<FWToastPlugin> plugin = self.fw_toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(showLoadingWithAttributedText:inView:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin showLoadingWithAttributedText:attributedText inView:self];
}

- (void)fw_hideLoading
{
    id<FWToastPlugin> plugin = self.fw_toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hideLoading:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin hideLoading:self];
}

- (void)fw_showProgressWithText:(id)text progress:(CGFloat)progress
{
    NSAttributedString *attributedText = [text isKindOfClass:[NSString class]] ? [[NSAttributedString alloc] initWithString:text] : text;
    id<FWToastPlugin> plugin = self.fw_toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(showProgressWithAttributedText:progress:inView:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin showProgressWithAttributedText:attributedText progress:progress inView:self];
}

- (void)fw_hideProgress
{
    id<FWToastPlugin> plugin = self.fw_toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hideProgress:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin hideProgress:self];
}

- (void)fw_showMessageWithText:(id)text
{
    [self fw_showMessageWithText:text style:FWToastStyleDefault];
}

- (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style
{
    [self fw_showMessageWithText:text style:style completion:nil];
}

- (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style completion:(void (^)(void))completion
{
    [self fw_showMessageWithText:text style:style autoHide:YES completion:completion];
}

- (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(void (^)(void))completion
{
    NSAttributedString *attributedText = [text isKindOfClass:[NSString class]] ? [[NSAttributedString alloc] initWithString:text] : text;
    id<FWToastPlugin> plugin = self.fw_toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(showMessageWithAttributedText:style:autoHide:completion:inView:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin showMessageWithAttributedText:attributedText style:style autoHide:autoHide completion:completion inView:self];
}

- (void)fw_hideMessage
{
    id<FWToastPlugin> plugin = self.fw_toastPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(hideMessage:)]) {
        plugin = FWToastPluginImpl.sharedInstance;
    }
    [plugin hideMessage:self];
}

@end

@implementation UIViewController (FWToastPlugin)

- (UIEdgeInsets)fw_toastInsets
{
    return self.view.fw_toastInsets;
}

- (void)setFw_toastInsets:(UIEdgeInsets)toastInsets
{
    self.view.fw_toastInsets = toastInsets;
}

- (void)fw_showLoading
{
    [self.view fw_showLoading];
}

- (void)fw_showLoadingWithText:(id)text
{
    [self.view fw_showLoadingWithText:text];
}

- (void)fw_hideLoading
{
    [self.view fw_hideLoading];
}

- (void)fw_showProgressWithText:(id)text progress:(CGFloat)progress
{
    [self.view fw_showProgressWithText:text progress:progress];
}

- (void)fw_hideProgress
{
    [self.view fw_hideProgress];
}

- (void)fw_showMessageWithText:(id)text
{
    [self.view fw_showMessageWithText:text];
}

- (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style
{
    [self.view fw_showMessageWithText:text style:style];
}

- (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style completion:(void (^)(void))completion
{
    [self.view fw_showMessageWithText:text style:style completion:completion];
}

- (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(void (^)(void))completion
{
    [self.view fw_showMessageWithText:text style:style autoHide:autoHide completion:completion];
}

- (void)fw_hideMessage
{
    [self.view fw_hideMessage];
}

@end

@implementation UIWindow (FWToastPlugin)

+ (UIEdgeInsets)fw_toastInsets
{
    return UIWindow.fw_mainWindow.fw_toastInsets;
}

+ (void)setFw_toastInsets:(UIEdgeInsets)toastInsets
{
    UIWindow.fw_mainWindow.fw_toastInsets = toastInsets;
}

+ (void)fw_showLoading
{
    [UIWindow.fw_mainWindow fw_showLoading];
}

+ (void)fw_showLoadingWithText:(id)text
{
    [UIWindow.fw_mainWindow fw_showLoadingWithText:text];
}

+ (void)fw_hideLoading
{
    [UIWindow.fw_mainWindow fw_hideLoading];
}

+ (void)fw_showProgressWithText:(id)text progress:(CGFloat)progress
{
    [UIWindow.fw_mainWindow fw_showProgressWithText:text progress:progress];
}

+ (void)fw_hideProgress
{
    [UIWindow.fw_mainWindow fw_hideProgress];
}

+ (void)fw_showMessageWithText:(id)text
{
    [UIWindow.fw_mainWindow fw_showMessageWithText:text];
}

+ (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style
{
    [UIWindow.fw_mainWindow fw_showMessageWithText:text style:style];
}

+ (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style completion:(void (^)(void))completion
{
    [UIWindow.fw_mainWindow fw_showMessageWithText:text style:style completion:completion];
}

+ (void)fw_showMessageWithText:(id)text style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(void (^)(void))completion
{
    [UIWindow.fw_mainWindow fw_showMessageWithText:text style:style autoHide:autoHide completion:completion];
}

+ (void)fw_hideMessage
{
    [UIWindow.fw_mainWindow fw_hideMessage];
}

@end
