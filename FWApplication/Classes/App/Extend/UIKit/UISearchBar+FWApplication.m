/*!
 @header     UISearchBar+FWApplication.m
 @indexgroup FWApplication
 @brief      UISearchBar+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/10/15
 */

#import "UISearchBar+FWApplication.h"
#import "FWSwizzle.h"
#import "FWMessage.h"
#import "FWAdaptive.h"
#import "FWToolkit.h"
#import <objc/runtime.h>

@implementation UISearchBar (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UISearchBar, @selector(layoutSubviews), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (@available(iOS 13, *)) { } else {
                CGFloat textFieldMaxX = selfObject.bounds.size.width;
                NSValue *cancelInsetValue = objc_getAssociatedObject(selfObject, @selector(fwCancelButtonInset));
                if (cancelInsetValue) {
                    UIButton *cancelButton = [selfObject fwCancelButton];
                    if (cancelButton) {
                        UIEdgeInsets cancelInset = [cancelInsetValue UIEdgeInsetsValue];
                        CGFloat cancelWidth = [cancelButton sizeThatFits:selfObject.bounds.size].width;
                        textFieldMaxX = selfObject.bounds.size.width - cancelWidth - cancelInset.left - cancelInset.right;
                        UITextField *textField = [selfObject fwTextField];
                        CGRect frame = textField.frame;
                        frame.size.width = textFieldMaxX - frame.origin.x;
                        textField.frame = frame;
                    }
                }
                
                NSValue *contentInsetValue = objc_getAssociatedObject(selfObject, @selector(fwContentInset));
                if (contentInsetValue) {
                    UIEdgeInsets contentInset = [contentInsetValue UIEdgeInsetsValue];
                    UITextField *textField = [selfObject fwTextField];
                    textField.frame = CGRectMake(contentInset.left, contentInset.top, textFieldMaxX - contentInset.left - contentInset.right, selfObject.bounds.size.height - contentInset.top - contentInset.bottom);
                }
            }
            
            NSNumber *isCenterValue = objc_getAssociatedObject(selfObject, @selector(fwSearchIconCenter));
            if (isCenterValue) {
                if (![isCenterValue boolValue]) {
                    NSNumber *offset = objc_getAssociatedObject(selfObject, @selector(fwSearchIconOffset));
                    [selfObject setPositionAdjustment:UIOffsetMake(offset ? offset.doubleValue : 0, 0) forSearchBarIcon:UISearchBarIconSearch];
                } else {
                    UITextField *textField = [selfObject fwTextField];
                    CGFloat placeholdWidth = [selfObject.placeholder boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:textField.font, NSFontAttributeName, nil] context:nil].size.width;
                    CGFloat textOffset = 4 + [selfObject searchTextPositionAdjustment].horizontal;
                    CGFloat iconWidth = textField.leftView ? textField.leftView.frame.size.width : 0;
                    CGFloat targetWidth = textField.frame.size.width - ceilf(placeholdWidth) - textOffset - iconWidth;
                    CGFloat position = targetWidth / 2 - 6;
                    [selfObject setPositionAdjustment:UIOffsetMake(position > 0 ? position : 0, 0) forSearchBarIcon:UISearchBarIconSearch];
                }
            }
        }));
        
        // iOS13因为层级关系变化，兼容处理
        if (@available(iOS 13, *)) {
            FWSwizzleMethod(objc_getClass("UISearchBarTextField"), @selector(setFrame:), nil, FWSwizzleType(UITextField *), FWSwizzleReturn(void), FWSwizzleArgs(CGRect frame), FWSwizzleCode({
                UISearchBar *searchBar = nil;
                if (@available(iOS 13.0, *)) {
                    searchBar = (UISearchBar *)selfObject.superview.superview.superview;
                } else {
                    searchBar = (UISearchBar *)selfObject.superview.superview;
                }
                if ([searchBar isKindOfClass:[UISearchBar class]]) {
                    CGFloat textFieldMaxX = searchBar.bounds.size.width;
                    NSValue *cancelInsetValue = objc_getAssociatedObject(searchBar, @selector(fwCancelButtonInset));
                    if (cancelInsetValue) {
                        UIButton *cancelButton = [searchBar fwCancelButton];
                        if (cancelButton) {
                            UIEdgeInsets cancelInset = [cancelInsetValue UIEdgeInsetsValue];
                            CGFloat cancelWidth = [cancelButton sizeThatFits:searchBar.bounds.size].width;
                            textFieldMaxX = searchBar.bounds.size.width - cancelWidth - cancelInset.left - cancelInset.right;
                            frame.size.width = textFieldMaxX - frame.origin.x;
                        }
                    }
                    
                    NSValue *contentInsetValue = objc_getAssociatedObject(searchBar, @selector(fwContentInset));
                    if (contentInsetValue) {
                        UIEdgeInsets contentInset = [contentInsetValue UIEdgeInsetsValue];
                        frame = CGRectMake(contentInset.left, contentInset.top, textFieldMaxX - contentInset.left - contentInset.right, searchBar.bounds.size.height - contentInset.top - contentInset.bottom);
                    }
                }
                
                FWSwizzleOriginal(frame);
            }));
        }
        
        FWSwizzleMethod(objc_getClass("UINavigationButton"), @selector(setFrame:), nil, FWSwizzleType(UIButton *), FWSwizzleReturn(void), FWSwizzleArgs(CGRect frame), FWSwizzleCode({
            UISearchBar *searchBar = nil;
            if (@available(iOS 13.0, *)) {
                searchBar = (UISearchBar *)selfObject.superview.superview.superview;
            } else {
                searchBar = (UISearchBar *)selfObject.superview.superview;
            }
            if ([searchBar isKindOfClass:[UISearchBar class]]) {
                NSValue *cancelButtonInsetValue = objc_getAssociatedObject(searchBar, @selector(fwCancelButtonInset));
                if (cancelButtonInsetValue) {
                    UIEdgeInsets cancelButtonInset = [cancelButtonInsetValue UIEdgeInsetsValue];
                    CGFloat cancelButtonWidth = [selfObject sizeThatFits:searchBar.bounds.size].width;
                    frame.origin.x = searchBar.bounds.size.width - cancelButtonWidth - cancelButtonInset.right;
                    frame.origin.y = cancelButtonInset.top;
                    frame.size.height = searchBar.bounds.size.height - cancelButtonInset.top - cancelButtonInset.bottom;
                }
            }
            
            FWSwizzleOriginal(frame);
        }));
    });
}

- (UIEdgeInsets)fwContentInset
{
    return [objc_getAssociatedObject(self, @selector(fwContentInset)) UIEdgeInsetsValue];
}

- (void)setFwContentInset:(UIEdgeInsets)fwContentInset
{
    objc_setAssociatedObject(self, @selector(fwContentInset), [NSValue valueWithUIEdgeInsets:fwContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIEdgeInsets)fwCancelButtonInset
{
    return [objc_getAssociatedObject(self, @selector(fwCancelButtonInset)) UIEdgeInsetsValue];
}

- (void)setFwCancelButtonInset:(UIEdgeInsets)fwCancelButtonInset
{
    objc_setAssociatedObject(self, @selector(fwCancelButtonInset), [NSValue valueWithUIEdgeInsets:fwCancelButtonInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UITextField *)fwTextField
{
    return [self fwPerformGetter:@"searchField"];
}

- (UIButton *)fwCancelButton
{
    return [self fwPerformGetter:@"cancelButton"];
}

- (UIColor *)fwBackgroundColor
{
    return objc_getAssociatedObject(self, @selector(fwBackgroundColor));
}

- (void)setFwBackgroundColor:(UIColor *)color
{
    objc_setAssociatedObject(self, @selector(fwBackgroundColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.backgroundImage = [UIImage fwImageWithColor:color];
}

- (UIColor *)fwTextFieldBackgroundColor
{
    UITextField *textField = [self fwTextField];
    return textField.backgroundColor;
}

- (void)setFwTextFieldBackgroundColor:(UIColor *)color
{
    UITextField *textField = [self fwTextField];
    textField.backgroundColor = color;
}

- (CGFloat)fwSearchIconOffset
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(fwSearchIconOffset));
    if (value) return value.doubleValue;
    return [self positionAdjustmentForSearchBarIcon:UISearchBarIconSearch].horizontal;
}

- (void)setFwSearchIconOffset:(CGFloat)offset
{
    objc_setAssociatedObject(self, @selector(fwSearchIconOffset), @(offset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setPositionAdjustment:UIOffsetMake(offset, 0) forSearchBarIcon:UISearchBarIconSearch];
}

- (CGFloat)fwSearchTextOffset
{
    return [self searchTextPositionAdjustment].horizontal;
}

- (void)setFwSearchTextOffset:(CGFloat)offset
{
    [self setSearchTextPositionAdjustment:UIOffsetMake(offset, 0)];
}

- (BOOL)fwSearchIconCenter
{
    return [objc_getAssociatedObject(self, @selector(fwSearchIconCenter)) boolValue];
}

- (void)setFwSearchIconCenter:(BOOL)center
{
    objc_setAssociatedObject(self, @selector(fwSearchIconCenter), @(center), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (BOOL)fwForceCancelButtonEnabled
{
    return [objc_getAssociatedObject(self, @selector(fwForceCancelButtonEnabled)) boolValue];
}

- (void)setFwForceCancelButtonEnabled:(BOOL)enabled
{
    objc_setAssociatedObject(self, @selector(fwForceCancelButtonEnabled), @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIButton *cancelButton = [self fwCancelButton];
    if (enabled) {
        cancelButton.enabled = YES;
        [cancelButton fwObserveProperty:@"enabled" block:^(UIButton *object, NSDictionary *change) {
            if (!object.enabled) object.enabled = YES;
        }];
    } else {
        [cancelButton fwUnobserveProperty:@"enabled"];
    }
}

@end
