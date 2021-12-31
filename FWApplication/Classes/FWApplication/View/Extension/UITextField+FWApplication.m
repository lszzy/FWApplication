//
//  UITextField+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/29.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UITextField+FWApplication.h"
#import <objc/runtime.h>
@import FWFramework;

#pragma mark - UITextField+FWApplication

@implementation UITextField (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UITextField, @selector(canPerformAction:withSender:), FWSwizzleReturn(BOOL), FWSwizzleArgs(SEL action, id sender), FWSwizzleCode({
            if (selfObject.fwMenuDisabled) {
                return NO;
            }
            return FWSwizzleOriginal(action, sender);
        }));
        
        FWSwizzleClass(UITextField, @selector(caretRectForPosition:), FWSwizzleReturn(CGRect), FWSwizzleArgs(UITextPosition *position), FWSwizzleCode({
            CGRect caretRect = FWSwizzleOriginal(position);
            NSValue *rectValue = objc_getAssociatedObject(selfObject, @selector(fwCursorRect));
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

- (BOOL)fwMenuDisabled
{
    return [objc_getAssociatedObject(self, @selector(fwMenuDisabled)) boolValue];
}

- (void)setFwMenuDisabled:(BOOL)fwMenuDisabled
{
    objc_setAssociatedObject(self, @selector(fwMenuDisabled), @(fwMenuDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Select

- (UIColor *)fwCursorColor
{
    return self.tintColor;
}

- (void)setFwCursorColor:(UIColor *)fwCursorColor
{
    self.tintColor = fwCursorColor;
}

- (CGRect)fwCursorRect
{
    NSValue *value = objc_getAssociatedObject(self, @selector(fwCursorRect));
    return value ? [value CGRectValue] : CGRectZero;
}

- (void)setFwCursorRect:(CGRect)fwCursorRect
{
    objc_setAssociatedObject(self, @selector(fwCursorRect), [NSValue valueWithCGRect:fwCursorRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSRange)fwSelectedRange
{
    UITextPosition *beginning = self.beginningOfDocument;
    
    UITextRange *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setFwSelectedRange:(NSRange)range
{
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

- (void)fwSelectAllText
{
    UITextRange *range = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
    [self setSelectedTextRange:range];
}

@end
