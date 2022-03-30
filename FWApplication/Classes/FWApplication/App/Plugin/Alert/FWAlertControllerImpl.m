//
//  FWAlertControllerImpl.m
//  FWApplication
//
//  Created by wuyong on 2020/4/25.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

#import "FWAlertControllerImpl.h"
#import <objc/runtime.h>
@import FWFramework;

#pragma mark - FWAlertControllerPlugin

@interface FWAlertAction (FWAlertControllerPlugin)

@end

@implementation FWAlertAction (FWAlertControllerPlugin)

- (BOOL)fwIsPreferred
{
    return [objc_getAssociatedObject(self, @selector(fwIsPreferred)) boolValue];
}

- (void)setFwIsPreferred:(BOOL)fwIsPreferred
{
    objc_setAssociatedObject(self, @selector(fwIsPreferred), @(fwIsPreferred), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.attributedTitle || self.title.length < 1 || !self.alertAppearance.actionEnabled) return;
    
    UIColor *titleColor = nil;
    if (!self.enabled) {
        titleColor = self.alertAppearance.disabledActionColor;
    } else if (fwIsPreferred) {
        titleColor = self.alertAppearance.preferredActionColor;
    } else if (self.style == UIAlertActionStyleDestructive) {
        titleColor = self.alertAppearance.destructiveActionColor;
    } else if (self.style == UIAlertActionStyleCancel) {
        titleColor = self.alertAppearance.cancelActionColor;
    } else {
        titleColor = self.alertAppearance.actionColor;
    }
    if (titleColor) self.titleColor = titleColor;
}

@end

@implementation FWAlertControllerPlugin

+ (FWAlertControllerPlugin *)sharedInstance
{
    static FWAlertControllerPlugin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWAlertControllerPlugin alloc] init];
    });
    return instance;
}

- (void)fwViewController:(UIViewController *)viewController
               showAlert:(UIAlertControllerStyle)style
                   title:(id)title
                 message:(id)message
                  cancel:(id)cancel
                 actions:(NSArray *)actions
             promptCount:(NSInteger)promptCount
             promptBlock:(void (^)(UITextField * _Nonnull, NSInteger))promptBlock
             actionBlock:(void (^)(NSArray<NSString *> * _Nonnull, NSInteger))actionBlock
             cancelBlock:(void (^)(void))cancelBlock
             customBlock:(void (^)(id))customBlock
                priority:(FWAlertPriority)priority
{
    // 初始化Alert
    FWAlertController *alertController = [self alertControllerWithTitle:title
                                                                message:message
                                                         preferredStyle:(FWAlertControllerStyle)style];
    
    // 添加输入框
    for (NSInteger promptIndex = 0; promptIndex < promptCount; promptIndex++) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            if (promptBlock) promptBlock(textField, promptIndex);
        }];
    }
    
    // 添加动作按钮
    for (NSInteger actionIndex = 0; actionIndex < actions.count; actionIndex++) {
        FWAlertAction *alertAction = [self actionWithObject:actions[actionIndex] style:FWAlertActionStyleDefault handler:^(FWAlertAction *action) {
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
        FWAlertAction *cancelAction = [self actionWithObject:cancel style:FWAlertActionStyleCancel handler:^(FWAlertAction *action) {
            if (cancelBlock) cancelBlock();
        }];
        [alertController addAction:cancelAction];
    }
    
    // 添加首选按钮
    if (alertController.alertAppearance.preferredActionBlock && alertController.actions.count > 0) {
        FWAlertAction *preferredAction = alertController.alertAppearance.preferredActionBlock(alertController);
        if (preferredAction) {
            alertController.preferredAction = preferredAction;
        }
    }
    
    // 自定义Alert
    if (self.customBlock) self.customBlock(alertController);
    if (customBlock) customBlock(alertController);
    
    // 显示Alert
    alertController.fwAlertPriorityEnabled = YES;
    alertController.fwAlertPriority = priority;
    [alertController fwAlertPriorityPresentIn:viewController];
}

- (void)fwViewController:(UIViewController *)viewController
               showAlert:(UIAlertControllerStyle)style
              headerView:(UIView *)headerView
                  cancel:(id)cancel
                 actions:(NSArray *)actions
             actionBlock:(void (^)(NSInteger))actionBlock
             cancelBlock:(void (^)(void))cancelBlock
             customBlock:(void (^)(id _Nonnull))customBlock
                priority:(FWAlertPriority)priority
{
    // 初始化Alert
    FWAlertController *alertController = [self alertControllerWithHeaderView:headerView
                                                              preferredStyle:(FWAlertControllerStyle)style];
    
    // 添加动作按钮
    for (NSInteger actionIndex = 0; actionIndex < actions.count; actionIndex++) {
        FWAlertAction *alertAction = [self actionWithObject:actions[actionIndex] style:FWAlertActionStyleDefault handler:^(FWAlertAction *action) {
            if (actionBlock) actionBlock(actionIndex);
        }];
        [alertController addAction:alertAction];
    }
    
    // 添加取消按钮
    if (cancel != nil) {
        FWAlertAction *cancelAction = [self actionWithObject:cancel style:FWAlertActionStyleCancel handler:^(FWAlertAction *action) {
            if (cancelBlock) cancelBlock();
        }];
        [alertController addAction:cancelAction];
    }
    
    // 添加首选按钮
    if (alertController.alertAppearance.preferredActionBlock && alertController.actions.count > 0) {
        FWAlertAction *preferredAction = alertController.alertAppearance.preferredActionBlock(alertController);
        if (preferredAction) {
            alertController.preferredAction = preferredAction;
        }
    }
    
    // 自定义Alert
    if (self.customBlock) self.customBlock(alertController);
    if (customBlock) customBlock(alertController);
    
    // 显示Alert
    alertController.fwAlertPriorityEnabled = YES;
    alertController.fwAlertPriority = priority;
    [alertController fwAlertPriorityPresentIn:viewController];
}

- (FWAlertController *)alertControllerWithTitle:(id)title message:(id)message preferredStyle:(FWAlertControllerStyle)preferredStyle
{
    NSAttributedString *attributedTitle = [title isKindOfClass:[NSAttributedString class]] ? title : nil;
    NSAttributedString *attributedMessage = [message isKindOfClass:[NSAttributedString class]] ? message : nil;
    FWAlertController *alertController = [FWAlertController alertControllerWithTitle:(attributedTitle ? nil : title)
                                                                             message:(attributedMessage ? nil : message)
                                                                      preferredStyle:preferredStyle
                                                                       animationType:FWAlertAnimationTypeDefault
                                                                          appearance:self.customAppearance];
    alertController.tapBackgroundViewDismiss = (preferredStyle == FWAlertControllerStyleActionSheet);
    
    if (attributedTitle) {
        alertController.attributedTitle = attributedTitle;
    } else if (alertController.title.length > 0 && alertController.alertAppearance.controllerEnabled) {
        NSMutableDictionary *titleAttributes = [NSMutableDictionary new];
        if (alertController.alertAppearance.titleFont) {
            titleAttributes[NSFontAttributeName] = alertController.alertAppearance.titleFont;
        }
        if (alertController.alertAppearance.titleColor) {
            titleAttributes[NSForegroundColorAttributeName] = alertController.alertAppearance.titleColor;
        }
        alertController.attributedTitle = [[NSAttributedString alloc] initWithString:alertController.title attributes:titleAttributes];
    }
    
    if (attributedMessage) {
        alertController.attributedMessage = attributedMessage;
    } else if (alertController.message.length > 0 && alertController.alertAppearance.controllerEnabled) {
        NSMutableDictionary *messageAttributes = [NSMutableDictionary new];
        if (alertController.alertAppearance.messageFont) {
            messageAttributes[NSFontAttributeName] = alertController.alertAppearance.messageFont;
        }
        if (alertController.alertAppearance.messageColor) {
            messageAttributes[NSForegroundColorAttributeName] = alertController.alertAppearance.messageColor;
        }
        alertController.attributedMessage = [[NSAttributedString alloc] initWithString:alertController.message attributes:messageAttributes];
    }
    
    [alertController.fw observeProperty:@"preferredAction" block:^(FWAlertController *object, NSDictionary *change) {
        [object.actions enumerateObjectsUsingBlock:^(FWAlertAction *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fwIsPreferred) obj.fwIsPreferred = NO;
        }];
        object.preferredAction.fwIsPreferred = YES;
    }];
    
    return alertController;
}

- (FWAlertController *)alertControllerWithHeaderView:(UIView *)headerView preferredStyle:(FWAlertControllerStyle)preferredStyle
{
    FWAlertController *alertController = [FWAlertController alertControllerWithCustomHeaderView:headerView
                                                                                 preferredStyle:preferredStyle
                                                                                  animationType:FWAlertAnimationTypeDefault
                                                                                     appearance:self.customAppearance];
    alertController.tapBackgroundViewDismiss = (preferredStyle == FWAlertControllerStyleActionSheet);
    
    [alertController.fw observeProperty:@"preferredAction" block:^(FWAlertController *object, NSDictionary *change) {
        [object.actions enumerateObjectsUsingBlock:^(FWAlertAction *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fwIsPreferred) obj.fwIsPreferred = NO;
        }];
        object.preferredAction.fwIsPreferred = YES;
    }];
    
    return alertController;
}

- (FWAlertAction *)actionWithObject:(id)object style:(FWAlertActionStyle)style handler:(void (^)(FWAlertAction *))handler
{
    NSAttributedString *attributedTitle = [object isKindOfClass:[NSAttributedString class]] ? object : nil;
    FWAlertAction *alertAction = [FWAlertAction actionWithTitle:(attributedTitle ? nil : object)
                                                          style:style
                                                     appearance:self.customAppearance
                                                         handler:handler];
    
    if (attributedTitle) {
        alertAction.attributedTitle = attributedTitle;
    } else {
        alertAction.fwIsPreferred = NO;
    }
    
    [alertAction.fw observeProperty:@"enabled" block:^(FWAlertAction *object, NSDictionary *change) {
        object.fwIsPreferred = object.fwIsPreferred;
    }];
    
    return alertAction;
}

@end
