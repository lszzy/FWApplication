//
//  UITextView+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/29.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UITextView+FWApplication.h"
#import <objc/runtime.h>

#pragma mark - FWTextViewWrapper+FWApplication

@implementation FWTextViewWrapper (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UITextView, @selector(canPerformAction:withSender:), FWSwizzleReturn(BOOL), FWSwizzleArgs(SEL action, id sender), FWSwizzleCode({
            if (selfObject.fw.menuDisabled) {
                return NO;
            }
            return FWSwizzleOriginal(action, sender);
        }));
        
        FWSwizzleClass(UITextView, @selector(caretRectForPosition:), FWSwizzleReturn(CGRect), FWSwizzleArgs(UITextPosition *position), FWSwizzleCode({
            CGRect caretRect = FWSwizzleOriginal(position);
            NSValue *rectValue = objc_getAssociatedObject(selfObject, @selector(cursorRect));
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

- (BOOL)menuDisabled
{
    return [objc_getAssociatedObject(self.base, @selector(menuDisabled)) boolValue];
}

- (void)setMenuDisabled:(BOOL)menuDisabled
{
    objc_setAssociatedObject(self.base, @selector(menuDisabled), @(menuDisabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Select

- (UIColor *)cursorColor
{
    return self.base.tintColor;
}

- (void)setCursorColor:(UIColor *)cursorColor
{
    self.base.tintColor = cursorColor;
}

- (CGRect)cursorRect
{
    NSValue *value = objc_getAssociatedObject(self.base, @selector(cursorRect));
    return value ? [value CGRectValue] : CGRectZero;
}

- (void)setCursorRect:(CGRect)cursorRect
{
    objc_setAssociatedObject(self.base, @selector(cursorRect), [NSValue valueWithCGRect:cursorRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSRange)selectedRange
{
    UITextPosition *beginning = self.base.beginningOfDocument;
    
    UITextRange *selectedRange = self.base.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    NSInteger location = [self.base offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self.base offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

- (void)setSelectedRange:(NSRange)range
{
    UITextPosition *beginning = self.base.beginningOfDocument;
    UITextPosition *startPosition = [self.base positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self.base positionFromPosition:beginning offset:NSMaxRange(range)];
    UITextRange *selectionRange = [self.base textRangeFromPosition:startPosition toPosition:endPosition];
    [self.base setSelectedTextRange:selectionRange];
}

- (void)selectAllText
{
    UITextRange *range = [self.base textRangeFromPosition:self.base.beginningOfDocument toPosition:self.base.endOfDocument];
    [self.base setSelectedTextRange:range];
}

#pragma mark - Size

- (CGSize)textSize
{
    if (CGSizeEqualToSize(self.base.frame.size, CGSizeZero)) {
        [self.base setNeedsLayout];
        [self.base layoutIfNeeded];
    }
    
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] init];
    attr[NSFontAttributeName] = self.base.font;
    
    CGSize drawSize = CGSizeMake(self.base.frame.size.width, CGFLOAT_MAX);
    CGSize size = [self.base.text boundingRectWithSize:drawSize
                                          options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attr
                                          context:nil].size;
    return CGSizeMake(MIN(drawSize.width, ceilf(size.width)) + self.base.textContainerInset.left + self.base.textContainerInset.right, MIN(drawSize.height, ceilf(size.height)) + self.base.textContainerInset.top + self.base.textContainerInset.bottom);
}

- (CGSize)attributedTextSize
{
    if (CGSizeEqualToSize(self.base.frame.size, CGSizeZero)) {
        [self.base setNeedsLayout];
        [self.base layoutIfNeeded];
    }
    
    CGSize drawSize = CGSizeMake(self.base.frame.size.width, CGFLOAT_MAX);
    CGSize size = [self.base.attributedText boundingRectWithSize:drawSize
                                                    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil].size;
    return CGSizeMake(MIN(drawSize.width, ceilf(size.width)) + self.base.textContainerInset.left + self.base.textContainerInset.right, MIN(drawSize.height, ceilf(size.height)) + self.base.textContainerInset.top + self.base.textContainerInset.bottom);
}

@end
