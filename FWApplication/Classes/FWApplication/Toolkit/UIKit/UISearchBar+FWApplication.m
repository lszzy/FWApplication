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

@implementation FWSearchBarWrapper (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UISearchBar, @selector(layoutSubviews), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (@available(iOS 13, *)) { } else {
                CGFloat textFieldMaxX = selfObject.bounds.size.width;
                NSValue *cancelInsetValue = objc_getAssociatedObject(selfObject, @selector(cancelButtonInset));
                if (cancelInsetValue) {
                    UIButton *cancelButton = [selfObject.fw cancelButton];
                    if (cancelButton) {
                        UIEdgeInsets cancelInset = [cancelInsetValue UIEdgeInsetsValue];
                        CGFloat cancelWidth = [cancelButton sizeThatFits:selfObject.bounds.size].width;
                        textFieldMaxX = selfObject.bounds.size.width - cancelWidth - cancelInset.left - cancelInset.right;
                        UITextField *textField = [selfObject.fw textField];
                        CGRect frame = textField.frame;
                        frame.size.width = textFieldMaxX - frame.origin.x;
                        textField.frame = frame;
                    }
                }
                
                NSValue *contentInsetValue = objc_getAssociatedObject(selfObject, @selector(contentInset));
                if (contentInsetValue) {
                    UIEdgeInsets contentInset = [contentInsetValue UIEdgeInsetsValue];
                    UITextField *textField = [selfObject.fw textField];
                    textField.frame = CGRectMake(contentInset.left, contentInset.top, textFieldMaxX - contentInset.left - contentInset.right, selfObject.bounds.size.height - contentInset.top - contentInset.bottom);
                }
            }
            
            NSNumber *isCenterValue = objc_getAssociatedObject(selfObject, @selector(searchIconCenter));
            if (isCenterValue) {
                if (![isCenterValue boolValue]) {
                    NSNumber *offset = objc_getAssociatedObject(selfObject, @selector(searchIconOffset));
                    [selfObject setPositionAdjustment:UIOffsetMake(offset ? offset.doubleValue : 0, 0) forSearchBarIcon:UISearchBarIconSearch];
                } else {
                    UITextField *textField = [selfObject.fw textField];
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
                    NSValue *cancelInsetValue = objc_getAssociatedObject(searchBar, @selector(cancelButtonInset));
                    if (cancelInsetValue) {
                        UIButton *cancelButton = [searchBar.fw cancelButton];
                        if (cancelButton) {
                            UIEdgeInsets cancelInset = [cancelInsetValue UIEdgeInsetsValue];
                            CGFloat cancelWidth = [cancelButton sizeThatFits:searchBar.bounds.size].width;
                            textFieldMaxX = searchBar.bounds.size.width - cancelWidth - cancelInset.left - cancelInset.right;
                            frame.size.width = textFieldMaxX - frame.origin.x;
                        }
                    }
                    
                    NSValue *contentInsetValue = objc_getAssociatedObject(searchBar, @selector(contentInset));
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
                NSValue *cancelButtonInsetValue = objc_getAssociatedObject(searchBar, @selector(cancelButtonInset));
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

- (UIEdgeInsets)contentInset
{
    return [objc_getAssociatedObject(self.base, @selector(contentInset)) UIEdgeInsetsValue];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    objc_setAssociatedObject(self.base, @selector(contentInset), [NSValue valueWithUIEdgeInsets:contentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.base setNeedsLayout];
}

- (UIEdgeInsets)cancelButtonInset
{
    return [objc_getAssociatedObject(self.base, @selector(cancelButtonInset)) UIEdgeInsetsValue];
}

- (void)setCancelButtonInset:(UIEdgeInsets)cancelButtonInset
{
    objc_setAssociatedObject(self.base, @selector(cancelButtonInset), [NSValue valueWithUIEdgeInsets:cancelButtonInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.base setNeedsLayout];
}

- (UITextField *)textField
{
    return [self invokeGetter:@"searchField"];
}

- (UIButton *)cancelButton
{
    return [self invokeGetter:@"cancelButton"];
}

- (UIColor *)backgroundColor
{
    return objc_getAssociatedObject(self.base, @selector(backgroundColor));
}

- (void)setBackgroundColor:(UIColor *)color
{
    objc_setAssociatedObject(self.base, @selector(backgroundColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.base.backgroundImage = [UIImage.fw imageWithColor:color];
}

- (UIColor *)textFieldBackgroundColor
{
    UITextField *textField = [self textField];
    return textField.backgroundColor;
}

- (void)setTextFieldBackgroundColor:(UIColor *)color
{
    UITextField *textField = [self textField];
    textField.backgroundColor = color;
}

- (CGFloat)searchIconOffset
{
    NSNumber *value = objc_getAssociatedObject(self.base, @selector(searchIconOffset));
    if (value) return value.doubleValue;
    return [self.base positionAdjustmentForSearchBarIcon:UISearchBarIconSearch].horizontal;
}

- (void)setSearchIconOffset:(CGFloat)offset
{
    objc_setAssociatedObject(self.base, @selector(searchIconOffset), @(offset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.base setPositionAdjustment:UIOffsetMake(offset, 0) forSearchBarIcon:UISearchBarIconSearch];
}

- (CGFloat)searchTextOffset
{
    return [self.base searchTextPositionAdjustment].horizontal;
}

- (void)setSearchTextOffset:(CGFloat)offset
{
    [self.base setSearchTextPositionAdjustment:UIOffsetMake(offset, 0)];
}

- (BOOL)searchIconCenter
{
    return [objc_getAssociatedObject(self.base, @selector(searchIconCenter)) boolValue];
}

- (void)setSearchIconCenter:(BOOL)center
{
    objc_setAssociatedObject(self.base, @selector(searchIconCenter), @(center), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.base setNeedsLayout];
    [self.base layoutIfNeeded];
}

- (BOOL)forceCancelButtonEnabled
{
    return [objc_getAssociatedObject(self.base, @selector(forceCancelButtonEnabled)) boolValue];
}

- (void)setForceCancelButtonEnabled:(BOOL)enabled
{
    objc_setAssociatedObject(self.base, @selector(forceCancelButtonEnabled), @(enabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    UIButton *cancelButton = [self cancelButton];
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
