/**
 @header     UISearchBar+FWApplication.m
 @indexgroup FWApplication
      UISearchBar+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/10/15
 */

#import "UISearchBar+FWApplication.h"
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
                NSValue *cancelInsetValue = objc_getAssociatedObject(selfObject, @selector(fw_cancelButtonInset));
                if (cancelInsetValue) {
                    UIButton *cancelButton = [selfObject fw_cancelButton];
                    if (cancelButton) {
                        UIEdgeInsets cancelInset = [cancelInsetValue UIEdgeInsetsValue];
                        CGFloat cancelWidth = [cancelButton sizeThatFits:selfObject.bounds.size].width;
                        textFieldMaxX = selfObject.bounds.size.width - cancelWidth - cancelInset.left - cancelInset.right;
                        UITextField *textField = [selfObject fw_textField];
                        CGRect frame = textField.frame;
                        frame.size.width = textFieldMaxX - frame.origin.x;
                        textField.frame = frame;
                    }
                }
                
                NSValue *contentInsetValue = objc_getAssociatedObject(selfObject, @selector(fw_contentInset));
                if (contentInsetValue) {
                    UIEdgeInsets contentInset = [contentInsetValue UIEdgeInsetsValue];
                    UITextField *textField = [selfObject fw_textField];
                    textField.frame = CGRectMake(contentInset.left, contentInset.top, textFieldMaxX - contentInset.left - contentInset.right, selfObject.bounds.size.height - contentInset.top - contentInset.bottom);
                }
            }
            
            NSNumber *isCenterValue = objc_getAssociatedObject(selfObject, @selector(fw_searchIconCenter));
            if (isCenterValue) {
                if (![isCenterValue boolValue]) {
                    NSNumber *offset = objc_getAssociatedObject(selfObject, @selector(fw_searchIconOffset));
                    [selfObject setPositionAdjustment:UIOffsetMake(offset ? offset.doubleValue : 0, 0) forSearchBarIcon:UISearchBarIconSearch];
                } else {
                    UITextField *textField = [selfObject fw_textField];
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
                    NSValue *cancelInsetValue = objc_getAssociatedObject(searchBar, @selector(fw_cancelButtonInset));
                    if (cancelInsetValue) {
                        UIButton *cancelButton = [searchBar fw_cancelButton];
                        if (cancelButton) {
                            UIEdgeInsets cancelInset = [cancelInsetValue UIEdgeInsetsValue];
                            CGFloat cancelWidth = [cancelButton sizeThatFits:searchBar.bounds.size].width;
                            textFieldMaxX = searchBar.bounds.size.width - cancelWidth - cancelInset.left - cancelInset.right;
                            frame.size.width = textFieldMaxX - frame.origin.x;
                        }
                    }
                    
                    NSValue *contentInsetValue = objc_getAssociatedObject(searchBar, @selector(fw_contentInset));
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
                NSValue *cancelButtonInsetValue = objc_getAssociatedObject(searchBar, @selector(fw_cancelButtonInset));
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

- (UIEdgeInsets)fw_contentInset
{
    return [objc_getAssociatedObject(self, @selector(fw_contentInset)) UIEdgeInsetsValue];
}

- (void)setFw_contentInset:(UIEdgeInsets)contentInset
{
    objc_setAssociatedObject(self, @selector(fw_contentInset), [NSValue valueWithUIEdgeInsets:contentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIEdgeInsets)fw_cancelButtonInset
{
    return [objc_getAssociatedObject(self, @selector(fw_cancelButtonInset)) UIEdgeInsetsValue];
}

- (void)setFw_cancelButtonInset:(UIEdgeInsets)cancelButtonInset
{
    objc_setAssociatedObject(self, @selector(fw_cancelButtonInset), [NSValue valueWithUIEdgeInsets:cancelButtonInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UITextField *)fw_textField
{
    return [self fw_invokeGetter:@"searchField"];
}

- (UIButton *)fw_cancelButton
{
    return [self fw_invokeGetter:@"cancelButton"];
}

- (UIColor *)fw_backgroundColor
{
    return objc_getAssociatedObject(self, @selector(fw_backgroundColor));
}

- (void)setFw_backgroundColor:(UIColor *)color
{
    objc_setAssociatedObject(self, @selector(fw_backgroundColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.backgroundImage = [UIImage fw_imageWithColor:color];
}

- (UIColor *)fw_textFieldBackgroundColor
{
    UITextField *textField = [self fw_textField];
    return textField.backgroundColor;
}

- (void)setFw_textFieldBackgroundColor:(UIColor *)color
{
    UITextField *textField = [self fw_textField];
    textField.backgroundColor = color;
}

- (CGFloat)fw_searchIconOffset
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(fw_searchIconOffset));
    if (value) return value.doubleValue;
    return [self positionAdjustmentForSearchBarIcon:UISearchBarIconSearch].horizontal;
}

- (void)setFw_searchIconOffset:(CGFloat)offset
{
    objc_setAssociatedObject(self, @selector(fw_searchIconOffset), @(offset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setPositionAdjustment:UIOffsetMake(offset, 0) forSearchBarIcon:UISearchBarIconSearch];
}

- (CGFloat)fw_searchTextOffset
{
    return [self searchTextPositionAdjustment].horizontal;
}

- (void)setFw_searchTextOffset:(CGFloat)offset
{
    [self setSearchTextPositionAdjustment:UIOffsetMake(offset, 0)];
}

- (BOOL)fw_searchIconCenter
{
    return [objc_getAssociatedObject(self, @selector(fw_searchIconCenter)) boolValue];
}

- (void)setFw_searchIconCenter:(BOOL)center
{
    objc_setAssociatedObject(self, @selector(fw_searchIconCenter), @(center), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (BOOL)fw_forceCancelButtonEnabled
{
    return [objc_getAssociatedObject(self, @selector(fw_forceCancelButtonEnabled)) boolValue];
}

- (void)setFw_forceCancelButtonEnabled:(BOOL)enabled
{
    objc_setAssociatedObject(self, @selector(fw_forceCancelButtonEnabled), @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIButton *cancelButton = [self fw_cancelButton];
    if (enabled) {
        cancelButton.enabled = YES;
        [cancelButton fw_observeProperty:@"enabled" block:^(UIButton *object, NSDictionary *change) {
            if (!object.enabled) object.enabled = YES;
        }];
    } else {
        [cancelButton fw_unobserveProperty:@"enabled"];
    }
}

@end
