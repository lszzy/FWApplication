//
//  FWAlertPlugin.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWAlertPlugin.h"
#import "FWAlertPluginImpl.h"
#import "FWAppBundle.h"
#import <objc/runtime.h>

#pragma mark - FWAlertPluginController

@implementation FWViewControllerWrapper (FWAlertPluginController)

- (id<FWAlertPlugin>)alertPlugin
{
    id<FWAlertPlugin> alertPlugin = objc_getAssociatedObject(self.base, @selector(alertPlugin));
    if (!alertPlugin) alertPlugin = [FWPluginManager loadPlugin:@protocol(FWAlertPlugin)];
    if (!alertPlugin) alertPlugin = FWAlertPluginImpl.sharedInstance;
    return alertPlugin;
}

- (void)setAlertPlugin:(id<FWAlertPlugin>)alertPlugin
{
    objc_setAssociatedObject(self.base, @selector(alertPlugin), alertPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showAlertWithTitle:(id)title
                     message:(id)message
{
    [self showAlertWithTitle:title
                       message:message
                        cancel:nil
                   cancelBlock:nil];
}

- (void)showAlertWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                 cancelBlock:(void (^)(void))cancelBlock
{
    [self showAlertWithTitle:title
                     message:message
                       style:FWAlertStyleDefault
                        cancel:cancel
                       actions:nil
                   actionBlock:nil
                   cancelBlock:cancelBlock];
}

- (void)showAlertWithTitle:(id)title
                   message:(id)message
                     style:(FWAlertStyle)style
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    [self showAlertWithTitle:title
                       message:message
                         style:style
                        cancel:cancel
                       actions:actions
                   promptCount:0
                   promptBlock:nil
                   actionBlock:^(NSArray<NSString *> *values, NSInteger index) {
                       if (actionBlock) actionBlock(index);
                   }
                   cancelBlock:cancelBlock
                   customBlock:nil];
}

- (void)showConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
{
    [self showConfirmWithTitle:title
                         message:message
                          cancel:cancel
                         confirm:confirm
                    confirmBlock:confirmBlock
                     cancelBlock:nil];
}

- (void)showConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
                   cancelBlock:(void (^)(void))cancelBlock
{
    if (!confirm) {
        confirm = FWAlertPluginImpl.sharedInstance.defaultConfirmButton ? FWAlertPluginImpl.sharedInstance.defaultConfirmButton() : FWAppBundle.confirmButton;
    }
    
    [self showAlertWithTitle:title
                       message:message
                         style:FWAlertStyleDefault
                        cancel:cancel
                       actions:[NSArray arrayWithObjects:confirm, nil]
                   promptCount:0
                   promptBlock:nil
                   actionBlock:^(NSArray<NSString *> *values, NSInteger index) {
                       if (confirmBlock) confirmBlock();
                   }
                   cancelBlock:cancelBlock
                   customBlock:nil];
}

- (void)showPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                 confirmBlock:(void (^)(NSString *))confirmBlock
{
    [self showPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                    promptBlock:nil
                   confirmBlock:confirmBlock
                    cancelBlock:nil];
}

- (void)showPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                  promptBlock:(void (^)(UITextField *))promptBlock
                 confirmBlock:(void (^)(NSString *))confirmBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    [self showPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                    promptCount:1
                    promptBlock:^(UITextField *textField, NSInteger index) {
                        if (promptBlock) promptBlock(textField);
                    }
                   confirmBlock:^(NSArray<NSString *> *values) {
                        if (confirmBlock) confirmBlock(values.firstObject);
                    }
                    cancelBlock:cancelBlock];
}

- (void)showPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                  promptCount:(NSInteger)promptCount
                  promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
                 confirmBlock:(void (^)(NSArray<NSString *> *))confirmBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    if (!confirm) {
        confirm = FWAlertPluginImpl.sharedInstance.defaultConfirmButton ? FWAlertPluginImpl.sharedInstance.defaultConfirmButton() : FWAppBundle.confirmButton;
    }
    
    [self showAlertWithTitle:title
                       message:message
                         style:FWAlertStyleDefault
                        cancel:cancel
                       actions:(confirm ? @[confirm] : nil)
                   promptCount:promptCount
                   promptBlock:promptBlock
                   actionBlock:^(NSArray<NSString *> *values, NSInteger index) {
                       if (confirmBlock) confirmBlock(values);
                   }
                   cancelBlock:cancelBlock
                   customBlock:nil];
}

- (void)showAlertWithTitle:(id)title
                     message:(id)message
                       style:(FWAlertStyle)style
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 promptCount:(NSInteger)promptCount
                 promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
                 actionBlock:(void (^)(NSArray<NSString *> *, NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
                 customBlock:(nullable void (^)(id))customBlock
{
    // 处理取消按钮，Alert多按钮时默认取消，单按钮时默认关闭
    if (!cancel) {
        if (actions.count > 0) {
            cancel = FWAlertPluginImpl.sharedInstance.defaultCancelButton ? FWAlertPluginImpl.sharedInstance.defaultCancelButton() : FWAppBundle.cancelButton;
        } else {
            cancel = FWAlertPluginImpl.sharedInstance.defaultCloseButton ? FWAlertPluginImpl.sharedInstance.defaultCloseButton() : FWAppBundle.closeButton;
        }
    }
    
    // 优先调用插件，不存在时使用默认
    id<FWAlertPlugin> alertPlugin = self.alertPlugin;
    if (!alertPlugin || ![alertPlugin respondsToSelector:@selector(viewController:showAlertWithTitle:message:style:cancel:actions:promptCount:promptBlock:actionBlock:cancelBlock:customBlock:)]) {
        alertPlugin = FWAlertPluginImpl.sharedInstance;
    }
    [alertPlugin viewController:self.base showAlertWithTitle:title message:message style:style cancel:cancel actions:actions promptCount:promptCount promptBlock:promptBlock actionBlock:actionBlock cancelBlock:cancelBlock customBlock:customBlock];
}

- (void)showSheetWithTitle:(id)title
                   message:(id)message
                    cancel:(id)cancel
               cancelBlock:(void (^)(void))cancelBlock
{
    [self showSheetWithTitle:title
                     message:message
                      cancel:cancel
                     actions:nil
                currentIndex:-1
                 actionBlock:nil
                 cancelBlock:cancelBlock];
}

- (void)showSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
{
    [self showSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                  currentIndex:-1
                   actionBlock:actionBlock
                   cancelBlock:nil];
}

- (void)showSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                currentIndex:(NSInteger)currentIndex
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    [self showSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                  currentIndex:currentIndex
                   actionBlock:^(NSInteger index) {
                       if (actionBlock) actionBlock(index);
                   }
                   cancelBlock:cancelBlock
                   customBlock:nil];
}

- (void)showSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                currentIndex:(NSInteger)currentIndex
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
                 customBlock:(nullable void (^)(id))customBlock
{
    // 处理取消按钮，Sheet多按钮时默认取消，单按钮时默认关闭
    if (!cancel) {
        if (actions.count > 0) {
            cancel = FWAlertPluginImpl.sharedInstance.defaultCancelButton ? FWAlertPluginImpl.sharedInstance.defaultCancelButton() : FWAppBundle.cancelButton;
        } else {
            cancel = FWAlertPluginImpl.sharedInstance.defaultCloseButton ? FWAlertPluginImpl.sharedInstance.defaultCloseButton() : FWAppBundle.closeButton;
        }
    }
    
    // 优先调用插件，不存在时使用默认
    id<FWAlertPlugin> alertPlugin = self.alertPlugin;
    if (!alertPlugin || ![alertPlugin respondsToSelector:@selector(viewController:showSheetWithTitle:message:cancel:actions:currentIndex:actionBlock:cancelBlock:customBlock:)]) {
        alertPlugin = FWAlertPluginImpl.sharedInstance;
    }
    [alertPlugin viewController:self.base showSheetWithTitle:title message:message cancel:cancel actions:actions currentIndex:currentIndex actionBlock:actionBlock cancelBlock:cancelBlock customBlock:customBlock];
}

@end

@implementation FWViewWrapper (FWAlertPluginController)

- (void)showAlertWithTitle:(id)title
                     message:(id)message
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showAlertWithTitle:title
                       message:message];
}

- (void)showAlertWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                 cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showAlertWithTitle:title
                       message:message
                        cancel:cancel
                   cancelBlock:cancelBlock];
}

- (void)showAlertWithTitle:(id)title
                     message:(id)message
                       style:(FWAlertStyle)style
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showAlertWithTitle:title
                       message:message
                         style:style
                        cancel:cancel
                       actions:actions
                   actionBlock:actionBlock
                   cancelBlock:cancelBlock];
}

- (void)showConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showConfirmWithTitle:title
                         message:message
                          cancel:cancel
                         confirm:confirm
                    confirmBlock:confirmBlock];
}

- (void)showConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
                   cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showConfirmWithTitle:title
                         message:message
                          cancel:cancel
                         confirm:confirm
                    confirmBlock:confirmBlock
                     cancelBlock:cancelBlock];
}

- (void)showPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                 confirmBlock:(void (^)(NSString *))confirmBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                   confirmBlock:confirmBlock];
}

- (void)showPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                  promptBlock:(void (^)(UITextField *))promptBlock
                 confirmBlock:(void (^)(NSString *))confirmBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                    promptBlock:promptBlock
                   confirmBlock:confirmBlock
                    cancelBlock:cancelBlock];
}

- (void)showPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                  promptCount:(NSInteger)promptCount
                  promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
                 confirmBlock:(void (^)(NSArray<NSString *> *))confirmBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                    promptCount:promptCount
                    promptBlock:promptBlock
                   confirmBlock:confirmBlock
                    cancelBlock:cancelBlock];
}

- (void)showAlertWithTitle:(id)title
                     message:(id)message
                       style:(FWAlertStyle)style
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 promptCount:(NSInteger)promptCount
                 promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
                 actionBlock:(void (^)(NSArray<NSString *> *, NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
                 customBlock:(nullable void (^)(id))customBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showAlertWithTitle:title
                       message:message
                         style:style
                        cancel:cancel
                       actions:actions
                   promptCount:promptCount
                   promptBlock:promptBlock
                   actionBlock:actionBlock
                   cancelBlock:cancelBlock
                   customBlock:customBlock];
}

- (void)showSheetWithTitle:(id)title
                   message:(id)message
                    cancel:(id)cancel
               cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showSheetWithTitle:title
                        message:message
                         cancel:cancel
                    cancelBlock:cancelBlock];
}

- (void)showSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                   actionBlock:actionBlock];
}

- (void)showSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                currentIndex:(NSInteger)currentIndex
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                   currentIndex:currentIndex
                   actionBlock:actionBlock
                   cancelBlock:cancelBlock];
}

- (void)showSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                currentIndex:(NSInteger)currentIndex
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
                 customBlock:(nullable void (^)(id))customBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                  currentIndex:currentIndex
                   actionBlock:actionBlock
                   cancelBlock:cancelBlock
                   customBlock:customBlock];
}

@end
