//
//  FWAlertPluginImpl.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWAlertPluginImpl.h"
#import <objc/runtime.h>

#pragma mark - FWAlertActionWrapper+FWAlert

@implementation FWAlertActionWrapper (FWAlert)

- (FWAlertAppearance *)alertAppearance
{
    FWAlertAppearance *appearance = objc_getAssociatedObject(self.base, @selector(alertAppearance));
    return appearance ?: FWAlertAppearance.appearance;
}

- (void)setAlertAppearance:(FWAlertAppearance *)alertAppearance
{
    objc_setAssociatedObject(self.base, @selector(alertAppearance), alertAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isPreferred
{
    return [objc_getAssociatedObject(self.base, @selector(isPreferred)) boolValue];
}

- (void)setIsPreferred:(BOOL)isPreferred
{
    objc_setAssociatedObject(self.base, @selector(isPreferred), @(isPreferred), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.titleColor || self.base.title.length < 1 || !self.alertAppearance.actionEnabled) return;
    
    UIColor *titleColor = nil;
    if (!self.base.enabled) {
        titleColor = self.alertAppearance.disabledActionColor;
    } else if (isPreferred) {
        titleColor = self.alertAppearance.preferredActionColor;
    } else if (self.base.style == UIAlertActionStyleDestructive) {
        titleColor = self.alertAppearance.destructiveActionColor;
    } else if (self.base.style == UIAlertActionStyleCancel) {
        titleColor = self.alertAppearance.cancelActionColor;
    } else {
        titleColor = self.alertAppearance.actionColor;
    }
    if (titleColor) {
        [self invokeSetter:@"titleTextColor" withObject:titleColor];
    }
}

- (UIColor *)titleColor
{
    return objc_getAssociatedObject(self.base, @selector(titleColor));
}

- (void)setTitleColor:(UIColor *)titleColor
{
    objc_setAssociatedObject(self.base, @selector(titleColor), titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self invokeSetter:@"titleTextColor" withObject:titleColor];
}

@end

@implementation FWAlertActionClassWrapper (FWAlert)

- (UIAlertAction *)actionWithObject:(id)object style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler
{
    return [self actionWithObject:object style:style appearance:nil handler:handler];
}

- (UIAlertAction *)actionWithObject:(id)object style:(UIAlertActionStyle)style appearance:(FWAlertAppearance *)appearance handler:(void (^)(UIAlertAction *))handler
{
    NSAttributedString *attributedTitle = [object isKindOfClass:[NSAttributedString class]] ? object : nil;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:(attributedTitle ? attributedTitle.string : object)
                                                          style:style
                                                         handler:handler];
    
    alertAction.fw.alertAppearance = appearance;
    alertAction.fw.isPreferred = NO;
    
    return alertAction;
}

@end

#pragma mark - FWAlertControllerWrapper+FWAlert

@implementation FWAlertControllerWrapper (FWAlert)

- (FWAlertAppearance *)alertAppearance
{
    FWAlertAppearance *appearance = objc_getAssociatedObject(self.base, @selector(alertAppearance));
    return appearance ?: FWAlertAppearance.appearance;
}

- (void)setAlertAppearance:(FWAlertAppearance *)alertAppearance
{
    objc_setAssociatedObject(self.base, @selector(alertAppearance), alertAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSAttributedString *)attributedTitle
{
    return objc_getAssociatedObject(self.base, @selector(attributedTitle));
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    objc_setAssociatedObject(self.base, @selector(attributedTitle), attributedTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self invokeSetter:@"attributedTitle" withObject:attributedTitle];
}

- (NSAttributedString *)attributedMessage
{
    return objc_getAssociatedObject(self.base, @selector(attributedMessage));
}

- (void)setAttributedMessage:(NSAttributedString *)attributedMessage
{
    objc_setAssociatedObject(self.base, @selector(attributedMessage), attributedMessage, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self invokeSetter:@"attributedMessage" withObject:attributedMessage];
}

@end

@implementation FWAlertControllerClassWrapper (FWAlert)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIAlertController, @selector(viewDidLoad), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.preferredStyle != UIAlertControllerStyleActionSheet) return;
            if (!selfObject.fw.attributedTitle && !selfObject.fw.attributedMessage) return;
            
            // 兼容iOS13操作表设置title和message样式不生效问题
            if (@available(iOS 13.0, *)) {
                Class targetClass = objc_getClass("_UIInterfaceActionGroupHeaderScrollView");
                if (!targetClass) return;
                
                [UIAlertController.fw alertSubview:selfObject.view block:^BOOL(UIView *view) {
                    if (![view isKindOfClass:targetClass]) return NO;
                    
                    [UIAlertController.fw alertSubview:view block:^BOOL(UIView *view) {
                        if ([view isKindOfClass:[UIVisualEffectView class]]) {
                            // 取消effect效果，否则样式不生效，全是灰色
                            ((UIVisualEffectView *)view).effect = nil;
                            return YES;
                        }
                        return NO;
                    }];
                    return YES;
                }];
            }
        }));
    });
}

- (UIView *)alertSubview:(UIView *)view block:(BOOL (^)(UIView *view))block
{
    if (block(view)) {
        return view;
    }
    
    for (UIView *subview in view.subviews) {
        UIView *resultView = [self alertSubview:subview block:block];
        if (resultView) {
            return resultView;
        }
    }
    
    return nil;
}

- (UIAlertController *)alertControllerWithTitle:(id)title message:(id)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    return [self alertControllerWithTitle:title message:message preferredStyle:preferredStyle appearance:nil];
}

- (UIAlertController *)alertControllerWithTitle:(id)title message:(id)message preferredStyle:(UIAlertControllerStyle)preferredStyle appearance:(FWAlertAppearance *)appearance
{
    NSAttributedString *attributedTitle = [title isKindOfClass:[NSAttributedString class]] ? title : nil;
    NSAttributedString *attributedMessage = [message isKindOfClass:[NSAttributedString class]] ? message : nil;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:(attributedTitle ? attributedTitle.string : title)
                                                                             message:(attributedMessage ? attributedMessage.string : message)
                                                                      preferredStyle:preferredStyle];
    
    alertController.fw.alertAppearance = appearance;
    if (attributedTitle) {
        alertController.fw.attributedTitle = attributedTitle;
    } else if (alertController.title.length > 0 && alertController.fw.alertAppearance.controllerEnabled) {
        NSMutableDictionary *titleAttributes = [NSMutableDictionary new];
        if (alertController.fw.alertAppearance.titleFont) {
            titleAttributes[NSFontAttributeName] = alertController.fw.alertAppearance.titleFont;
        }
        if (alertController.fw.alertAppearance.titleColor) {
            titleAttributes[NSForegroundColorAttributeName] = alertController.fw.alertAppearance.titleColor;
        }
        alertController.fw.attributedTitle = [[NSAttributedString alloc] initWithString:alertController.title attributes:titleAttributes];
    }
    
    if (attributedMessage) {
        alertController.fw.attributedMessage = attributedMessage;
    } else if (alertController.message.length > 0 && alertController.fw.alertAppearance.controllerEnabled) {
        NSMutableDictionary *messageAttributes = [NSMutableDictionary new];
        if (alertController.fw.alertAppearance.messageFont) {
            messageAttributes[NSFontAttributeName] = alertController.fw.alertAppearance.messageFont;
        }
        if (alertController.fw.alertAppearance.messageColor) {
            messageAttributes[NSForegroundColorAttributeName] = alertController.fw.alertAppearance.messageColor;
        }
        alertController.fw.attributedMessage = [[NSAttributedString alloc] initWithString:alertController.message attributes:messageAttributes];
    }
    
    [alertController.fw observeProperty:@"preferredAction" block:^(UIAlertController *object, NSDictionary *change) {
        [object.actions enumerateObjectsUsingBlock:^(UIAlertAction *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fw.isPreferred) obj.fw.isPreferred = NO;
        }];
        object.preferredAction.fw.isPreferred = YES;
    }];
    
    return alertController;
}

@end

#pragma mark - FWAlertAppearance

@implementation FWAlertAppearance

+ (FWAlertAppearance *)appearance
{
    static FWAlertAppearance *appearance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appearance = [[FWAlertAppearance alloc] init];
    });
    return appearance;
}

- (BOOL)controllerEnabled
{
    return self.titleColor || self.titleFont || self.messageColor || self.messageFont;
}

- (BOOL)actionEnabled
{
    return self.actionColor || self.preferredActionColor || self.cancelActionColor || self.destructiveActionColor || self.disabledActionColor;
}

@end

#pragma mark - FWAlertPluginImpl

@implementation FWAlertPluginImpl

+ (FWAlertPluginImpl *)sharedInstance
{
    static FWAlertPluginImpl *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWAlertPluginImpl alloc] init];
    });
    return instance;
}

- (void)viewController:(UIViewController *)viewController
               showAlert:(UIAlertControllerStyle)style
                   title:(id)title
                 message:(id)message
                  cancel:(id)cancel
                 actions:(NSArray *)actions
             promptCount:(NSInteger)promptCount
             promptBlock:(void (^)(UITextField *, NSInteger))promptBlock
             actionBlock:(void (^)(NSArray<NSString *> *, NSInteger))actionBlock
             cancelBlock:(void (^)(void))cancelBlock
             customBlock:(void (^)(id))customBlock
{
    // 初始化Alert
    FWAlertAppearance *customAppearance = style == UIAlertControllerStyleActionSheet ? self.customSheetAppearance : self.customAlertAppearance;
    UIAlertController *alertController = [UIAlertController.fw alertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:style
                                                                            appearance:customAppearance];
    
    // 添加输入框
    for (NSInteger promptIndex = 0; promptIndex < promptCount; promptIndex++) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            if (promptBlock) promptBlock(textField, promptIndex);
        }];
    }
    
    // 添加动作按钮
    for (NSInteger actionIndex = 0; actionIndex < actions.count; actionIndex++) {
        UIAlertAction *alertAction = [UIAlertAction.fw actionWithObject:actions[actionIndex] style:UIAlertActionStyleDefault appearance:customAppearance handler:^(UIAlertAction *action) {
            if (actionBlock) {
                NSMutableArray *values = [NSMutableArray new];
                for (NSInteger fieldIndex = 0; fieldIndex < promptCount; fieldIndex++) {
                    UITextField *textField = alertController.textFields[fieldIndex];
                    [values addObject:textField.text ?: @""];
                }
                actionBlock(values.copy, actionIndex);
            }
        }];
        [alertController addAction:alertAction];
    }
    
    // 添加取消按钮
    if (cancel != nil) {
        UIAlertAction *cancelAction = [UIAlertAction.fw actionWithObject:cancel style:UIAlertActionStyleCancel appearance:customAppearance handler:^(UIAlertAction *action) {
            if (cancelBlock) cancelBlock();
        }];
        [alertController addAction:cancelAction];
    }
    
    // 添加首选按钮
    if (alertController.fw.alertAppearance.preferredActionBlock && alertController.actions.count > 0) {
        UIAlertAction *preferredAction = alertController.fw.alertAppearance.preferredActionBlock(alertController);
        if (preferredAction) {
            alertController.preferredAction = preferredAction;
        }
    }
    
    // 自定义Alert
    if (self.customBlock) self.customBlock(alertController);
    if (customBlock) customBlock(alertController);
    
    // 显示Alert
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
