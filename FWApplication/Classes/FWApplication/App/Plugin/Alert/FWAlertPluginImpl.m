//
//  FWAlertPluginImpl.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWAlertPluginImpl.h"
#import <objc/runtime.h>
@import FWFramework;

#pragma mark - UIAlertAction+FWAlert

@implementation UIAlertAction (FWAlert)

+ (instancetype)fwActionWithObject:(id)object style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *))handler
{
    return [self fwActionWithObject:object style:style appearance:nil handler:handler];
}

+ (instancetype)fwActionWithObject:(id)object style:(UIAlertActionStyle)style appearance:(FWAlertAppearance *)appearance handler:(void (^)(UIAlertAction *))handler
{
    NSAttributedString *attributedTitle = [object isKindOfClass:[NSAttributedString class]] ? object : nil;
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:(attributedTitle ? attributedTitle.string : object)
                                                          style:style
                                                         handler:handler];
    
    alertAction.fwAlertAppearance = appearance;
    alertAction.fwIsPreferred = NO;
    
    return alertAction;
}

- (FWAlertAppearance *)fwAlertAppearance
{
    FWAlertAppearance *appearance = objc_getAssociatedObject(self, @selector(fwAlertAppearance));
    return appearance ?: FWAlertAppearance.appearance;
}

- (void)setFwAlertAppearance:(FWAlertAppearance *)fwAlertAppearance
{
    objc_setAssociatedObject(self, @selector(fwAlertAppearance), fwAlertAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fwIsPreferred
{
    return [objc_getAssociatedObject(self, @selector(fwIsPreferred)) boolValue];
}

- (void)setFwIsPreferred:(BOOL)fwIsPreferred
{
    objc_setAssociatedObject(self, @selector(fwIsPreferred), @(fwIsPreferred), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.fwTitleColor || self.title.length < 1 || !self.fwAlertAppearance.actionEnabled) return;
    
    UIColor *titleColor = nil;
    if (!self.enabled) {
        titleColor = self.fwAlertAppearance.disabledActionColor;
    } else if (fwIsPreferred) {
        titleColor = self.fwAlertAppearance.preferredActionColor;
    } else if (self.style == UIAlertActionStyleDestructive) {
        titleColor = self.fwAlertAppearance.destructiveActionColor;
    } else if (self.style == UIAlertActionStyleCancel) {
        titleColor = self.fwAlertAppearance.cancelActionColor;
    } else {
        titleColor = self.fwAlertAppearance.actionColor;
    }
    if (titleColor) {
        [self.fw invokeSetter:@"titleTextColor" withObject:titleColor];
    }
}

- (UIColor *)fwTitleColor
{
    return objc_getAssociatedObject(self, @selector(fwTitleColor));
}

- (void)setFwTitleColor:(UIColor *)fwTitleColor
{
    objc_setAssociatedObject(self, @selector(fwTitleColor), fwTitleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.fw invokeSetter:@"titleTextColor" withObject:fwTitleColor];
}

@end

#pragma mark - UIAlertController+FWAlert

@implementation UIAlertController (FWAlert)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIAlertController, @selector(viewDidLoad), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.preferredStyle != UIAlertControllerStyleActionSheet) return;
            if (!selfObject.fwAttributedTitle && !selfObject.fwAttributedMessage) return;
            
            // 兼容iOS13操作表设置title和message样式不生效问题
            if (@available(iOS 13.0, *)) {
                Class targetClass = objc_getClass("_UIInterfaceActionGroupHeaderScrollView");
                if (!targetClass) return;
                
                [UIAlertController fwAlertSubview:selfObject.view block:^BOOL(UIView *view) {
                    if (![view isKindOfClass:targetClass]) return NO;
                    
                    [UIAlertController fwAlertSubview:view block:^BOOL(UIView *view) {
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

+ (UIView *)fwAlertSubview:(UIView *)view block:(BOOL (^)(UIView *view))block
{
    if (block(view)) {
        return view;
    }
    
    for (UIView *subview in view.subviews) {
        UIView *resultView = [UIAlertController fwAlertSubview:subview block:block];
        if (resultView) {
            return resultView;
        }
    }
    
    return nil;
}

+ (instancetype)fwAlertControllerWithTitle:(id)title message:(id)message preferredStyle:(UIAlertControllerStyle)preferredStyle
{
    return [self fwAlertControllerWithTitle:title message:message preferredStyle:preferredStyle appearance:nil];
}

+ (instancetype)fwAlertControllerWithTitle:(id)title message:(id)message preferredStyle:(UIAlertControllerStyle)preferredStyle appearance:(FWAlertAppearance *)appearance
{
    NSAttributedString *attributedTitle = [title isKindOfClass:[NSAttributedString class]] ? title : nil;
    NSAttributedString *attributedMessage = [message isKindOfClass:[NSAttributedString class]] ? message : nil;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:(attributedTitle ? attributedTitle.string : title)
                                                                             message:(attributedMessage ? attributedMessage.string : message)
                                                                      preferredStyle:preferredStyle];
    
    alertController.fwAlertAppearance = appearance;
    if (attributedTitle) {
        alertController.fwAttributedTitle = attributedTitle;
    } else if (alertController.title.length > 0 && alertController.fwAlertAppearance.controllerEnabled) {
        NSMutableDictionary *titleAttributes = [NSMutableDictionary new];
        if (alertController.fwAlertAppearance.titleFont) {
            titleAttributes[NSFontAttributeName] = alertController.fwAlertAppearance.titleFont;
        }
        if (alertController.fwAlertAppearance.titleColor) {
            titleAttributes[NSForegroundColorAttributeName] = alertController.fwAlertAppearance.titleColor;
        }
        alertController.fwAttributedTitle = [[NSAttributedString alloc] initWithString:alertController.title attributes:titleAttributes];
    }
    
    if (attributedMessage) {
        alertController.fwAttributedMessage = attributedMessage;
    } else if (alertController.message.length > 0 && alertController.fwAlertAppearance.controllerEnabled) {
        NSMutableDictionary *messageAttributes = [NSMutableDictionary new];
        if (alertController.fwAlertAppearance.messageFont) {
            messageAttributes[NSFontAttributeName] = alertController.fwAlertAppearance.messageFont;
        }
        if (alertController.fwAlertAppearance.messageColor) {
            messageAttributes[NSForegroundColorAttributeName] = alertController.fwAlertAppearance.messageColor;
        }
        alertController.fwAttributedMessage = [[NSAttributedString alloc] initWithString:alertController.message attributes:messageAttributes];
    }
    
    [alertController.fw observeProperty:@"preferredAction" block:^(UIAlertController *object, NSDictionary *change) {
        [object.actions enumerateObjectsUsingBlock:^(UIAlertAction *obj, NSUInteger idx, BOOL *stop) {
            if (obj.fwIsPreferred) obj.fwIsPreferred = NO;
        }];
        object.preferredAction.fwIsPreferred = YES;
    }];
    
    return alertController;
}

- (FWAlertAppearance *)fwAlertAppearance
{
    FWAlertAppearance *appearance = objc_getAssociatedObject(self, @selector(fwAlertAppearance));
    return appearance ?: FWAlertAppearance.appearance;
}

- (void)setFwAlertAppearance:(FWAlertAppearance *)fwAlertAppearance
{
    objc_setAssociatedObject(self, @selector(fwAlertAppearance), fwAlertAppearance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSAttributedString *)fwAttributedTitle
{
    return objc_getAssociatedObject(self, @selector(fwAttributedTitle));
}

- (void)setFwAttributedTitle:(NSAttributedString *)fwAttributedTitle
{
    objc_setAssociatedObject(self, @selector(fwAttributedTitle), fwAttributedTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self.fw invokeSetter:@"attributedTitle" withObject:fwAttributedTitle];
}

- (NSAttributedString *)fwAttributedMessage
{
    return objc_getAssociatedObject(self, @selector(fwAttributedMessage));
}

- (void)setFwAttributedMessage:(NSAttributedString *)fwAttributedMessage
{
    objc_setAssociatedObject(self, @selector(fwAttributedMessage), fwAttributedMessage, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self.fw invokeSetter:@"attributedMessage" withObject:fwAttributedMessage];
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
    UIAlertController *alertController = [UIAlertController fwAlertControllerWithTitle:title
                                                                               message:message
                                                                        preferredStyle:style
                                                                            appearance:self.customAppearance];
    
    // 添加输入框
    for (NSInteger promptIndex = 0; promptIndex < promptCount; promptIndex++) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            if (promptBlock) promptBlock(textField, promptIndex);
        }];
    }
    
    // 添加动作按钮
    for (NSInteger actionIndex = 0; actionIndex < actions.count; actionIndex++) {
        UIAlertAction *alertAction = [UIAlertAction fwActionWithObject:actions[actionIndex] style:UIAlertActionStyleDefault appearance:self.customAppearance handler:^(UIAlertAction *action) {
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
        UIAlertAction *cancelAction = [UIAlertAction fwActionWithObject:cancel style:UIAlertActionStyleCancel appearance:self.customAppearance handler:^(UIAlertAction *action) {
            if (cancelBlock) cancelBlock();
        }];
        [alertController addAction:cancelAction];
    }
    
    // 添加首选按钮
    if (alertController.fwAlertAppearance.preferredActionBlock && alertController.actions.count > 0) {
        UIAlertAction *preferredAction = alertController.fwAlertAppearance.preferredActionBlock(alertController);
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
