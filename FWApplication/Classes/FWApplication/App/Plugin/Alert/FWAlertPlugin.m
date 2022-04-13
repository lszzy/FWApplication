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
@import FWFramework;

#pragma mark - FWAlertPluginController

@implementation UIViewController (FWAlertPluginController)

- (id<FWAlertPlugin>)fwAlertPlugin
{
    id<FWAlertPlugin> alertPlugin = objc_getAssociatedObject(self, @selector(fwAlertPlugin));
    if (!alertPlugin) alertPlugin = [FWPluginManager loadPlugin:@protocol(FWAlertPlugin)];
    if (!alertPlugin) alertPlugin = FWAlertPluginImpl.sharedInstance;
    return alertPlugin;
}

- (void)setFwAlertPlugin:(id<FWAlertPlugin>)fwAlertPlugin
{
    objc_setAssociatedObject(self, @selector(fwAlertPlugin), fwAlertPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)fwShowAlertWithTitle:(id)title
                     message:(id)message
{
    [self fwShowAlertWithTitle:title
                       message:message
                        cancel:nil
                   cancelBlock:nil];
}

- (void)fwShowAlertWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                 cancelBlock:(void (^)(void))cancelBlock
{
    [self fwShowAlertWithTitle:title
                       message:message
                        cancel:cancel
                       actions:nil
                   actionBlock:nil
                   cancelBlock:cancelBlock];
}

- (void)fwShowAlertWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    [self fwShowAlertWithStyle:UIAlertControllerStyleAlert
                         title:title
                       message:message
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

- (void)fwShowConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
{
    [self fwShowConfirmWithTitle:title
                         message:message
                          cancel:cancel
                         confirm:confirm
                    confirmBlock:confirmBlock
                     cancelBlock:nil];
}

- (void)fwShowConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
                   cancelBlock:(void (^)(void))cancelBlock
{
    if (!confirm) {
        confirm = FWAlertPluginImpl.sharedInstance.defaultConfirmButton ? FWAlertPluginImpl.sharedInstance.defaultConfirmButton() : FWAppBundle.confirmButton;
    }
    
    [self fwShowAlertWithStyle:UIAlertControllerStyleAlert
                         title:title
                       message:message
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

- (void)fwShowPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                 confirmBlock:(void (^)(NSString *))confirmBlock
{
    [self fwShowPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                    promptBlock:nil
                   confirmBlock:confirmBlock
                    cancelBlock:nil];
}

- (void)fwShowPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                  promptBlock:(void (^)(UITextField *))promptBlock
                 confirmBlock:(void (^)(NSString *))confirmBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    [self fwShowPromptWithTitle:title
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

- (void)fwShowPromptWithTitle:(id)title
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
    
    [self fwShowAlertWithStyle:UIAlertControllerStyleAlert
                         title:title
                       message:message
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

- (void)fwShowSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
{
    [self fwShowSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                   actionBlock:actionBlock
                   cancelBlock:nil];
}

- (void)fwShowSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    [self fwShowAlertWithStyle:UIAlertControllerStyleActionSheet
                         title:title
                       message:message
                        cancel:cancel
                       actions:actions
                   promptCount:0
                   promptBlock:nil
                   actionBlock:^(NSArray<NSString *> * _Nonnull values, NSInteger index) {
                       if (actionBlock) actionBlock(index);
                   }
                   cancelBlock:cancelBlock
                   customBlock:nil];
}

- (void)fwShowAlertWithStyle:(UIAlertControllerStyle)style
                       title:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 promptCount:(NSInteger)promptCount
                 promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
                 actionBlock:(void (^)(NSArray<NSString *> *, NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
                 customBlock:(nullable void (^)(id))customBlock
{
    // 处理取消按钮，Sheet时默认取消，Alert多按钮时默认取消，单按钮时默认关闭
    if (!cancel) {
        if (style == UIAlertControllerStyleActionSheet || actions.count > 0) {
            cancel = FWAlertPluginImpl.sharedInstance.defaultCancelButton ? FWAlertPluginImpl.sharedInstance.defaultCancelButton() : FWAppBundle.cancelButton;
        } else {
            cancel = FWAlertPluginImpl.sharedInstance.defaultCloseButton ? FWAlertPluginImpl.sharedInstance.defaultCloseButton() : FWAppBundle.closeButton;
        }
    }
    
    // 优先调用插件，不存在时使用默认
    id<FWAlertPlugin> alertPlugin = self.fwAlertPlugin;
    if (!alertPlugin || ![alertPlugin respondsToSelector:@selector(fwViewController:showAlert:title:message:cancel:actions:promptCount:promptBlock:actionBlock:cancelBlock:customBlock:)]) {
        alertPlugin = FWAlertPluginImpl.sharedInstance;
    }
    [alertPlugin fwViewController:self showAlert:style title:title message:message cancel:cancel actions:actions promptCount:promptCount promptBlock:promptBlock actionBlock:actionBlock cancelBlock:cancelBlock customBlock:customBlock];
}

@end

@implementation UIView (FWAlertPluginController)

- (void)fwShowAlertWithTitle:(id)title
                     message:(id)message
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowAlertWithTitle:title
                       message:message];
}

- (void)fwShowAlertWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                 cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowAlertWithTitle:title
                       message:message
                        cancel:cancel
                   cancelBlock:cancelBlock];
}

- (void)fwShowAlertWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowAlertWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                   actionBlock:actionBlock
                   cancelBlock:cancelBlock];
}

- (void)fwShowConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowConfirmWithTitle:title
                         message:message
                          cancel:cancel
                         confirm:confirm
                    confirmBlock:confirmBlock];
}

- (void)fwShowConfirmWithTitle:(id)title
                       message:(id)message
                        cancel:(id)cancel
                       confirm:(id)confirm
                  confirmBlock:(void (^)(void))confirmBlock
                   cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowConfirmWithTitle:title
                         message:message
                          cancel:cancel
                         confirm:confirm
                    confirmBlock:confirmBlock
                     cancelBlock:cancelBlock];
}

- (void)fwShowPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                 confirmBlock:(void (^)(NSString *))confirmBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                   confirmBlock:confirmBlock];
}

- (void)fwShowPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                  promptBlock:(void (^)(UITextField *))promptBlock
                 confirmBlock:(void (^)(NSString *))confirmBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                    promptBlock:promptBlock
                   confirmBlock:confirmBlock
                    cancelBlock:cancelBlock];
}

- (void)fwShowPromptWithTitle:(id)title
                      message:(id)message
                       cancel:(id)cancel
                      confirm:(id)confirm
                  promptCount:(NSInteger)promptCount
                  promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
                 confirmBlock:(void (^)(NSArray<NSString *> *))confirmBlock
                  cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowPromptWithTitle:title
                        message:message
                         cancel:cancel
                        confirm:confirm
                    promptCount:promptCount
                    promptBlock:promptBlock
                   confirmBlock:confirmBlock
                    cancelBlock:cancelBlock];
}

- (void)fwShowSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                   actionBlock:actionBlock];
}

- (void)fwShowSheetWithTitle:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 actionBlock:(void (^)(NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowSheetWithTitle:title
                       message:message
                        cancel:cancel
                       actions:actions
                   actionBlock:actionBlock
                   cancelBlock:cancelBlock];
}

- (void)fwShowAlertWithStyle:(UIAlertControllerStyle)style
                       title:(id)title
                     message:(id)message
                      cancel:(id)cancel
                     actions:(NSArray *)actions
                 promptCount:(NSInteger)promptCount
                 promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
                 actionBlock:(void (^)(NSArray<NSString *> *, NSInteger))actionBlock
                 cancelBlock:(void (^)(void))cancelBlock
                 customBlock:(nullable void (^)(id))customBlock
{
    UIViewController *ctrl = self.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw.topPresentedController;
    }
    [ctrl fwShowAlertWithStyle:style
                         title:title
                       message:message
                        cancel:cancel
                       actions:actions
                   promptCount:promptCount
                   promptBlock:promptBlock
                   actionBlock:actionBlock
                   cancelBlock:cancelBlock
                   customBlock:customBlock];
}

@end
