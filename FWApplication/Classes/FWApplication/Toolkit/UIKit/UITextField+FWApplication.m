//
//  UITextField+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/29.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UITextField+FWApplication.h"
#import <objc/runtime.h>

#pragma mark - UITextField+FWApplication

@implementation UITextField (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UITextField, @selector(canPerformAction:withSender:), FWSwizzleReturn(BOOL), FWSwizzleArgs(SEL action, id sender), FWSwizzleCode({
            if (selfObject.fw_menuDisabled) {
                return NO;
            }
            return FWSwizzleOriginal(action, sender);
        }));
        
        FWSwizzleClass(UITextField, @selector(caretRectForPosition:), FWSwizzleReturn(CGRect), FWSwizzleArgs(UITextPosition *position), FWSwizzleCode({
            CGRect caretRect = FWSwizzleOriginal(position);
            NSValue *rectValue = objc_getAssociatedObject(selfObject, @selector(fw_cursorRect));
            if (!rectValue) return caretRect;
            
            CGRect rect = rectValue.CGRectValue;
            if (rect.origin.x != 0) caretRect.origin.x = rect.origin.x;
            if (rect.origin.y != 0) caretRect.origin.y = rect.origin.y;
            if (rect.size.width != 0) caretRect.size.width = rect.size.width;
            if (rect.size.height != 0) caretRect.size.height = rect.size.height;
            return caretRect;
        }));
    });
}

#pragma mark - Menu

- (BOOL)fw_menuDisabled
{
    return [objc_getAssociatedObject(self, @selector(fw_menuDisabled)) boolValue];
}

- (void)setFw_menuDisabled:(BOOL)menuDisabled
{
    objc_setAssociatedObject(self, @selector(fw_menuDisabled), @(menuDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Select

- (UIColor *)fw_cursorColor
{
    return self.tintColor;
}

- (void)setFw_cursorColor:(UIColor *)cursorColor
{
    self.tintColor = cursorColor;
}

- (CGRect)fw_cursorRect
{
    NSValue *value = objc_getAssociatedObject(self, @selector(fw_cursorRect));
    return value ? [value CGRectValue] : CGRectZero;
}

- (void)setFw_cursorRect:(CGRect)cursorRect
{
    objc_setAssociatedObject(self, @selector(fw_cursorRect), [NSValue valueWithCGRect:cursorRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSRange)fw_selectedRange
{
    UITextPosition *beginning = self.beginningOfDocument;
    
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setFw_selectedRange:(NSRange)range
{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

- (void)fw_selectAllRange
{
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

- (void)fw_moveCursor:(NSInteger)offset
{
    __weak UITextField *weakBase = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UITextPosition *position = [weakBase positionFromPosition:weakBase.beginningOfDocument offset:offset];
        weakBase.selectedTextRange = [weakBase textRangeFromPosition:position toPosition:position];
    });
}

@end
