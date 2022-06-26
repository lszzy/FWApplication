//
//  UIScrollView+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIScrollView+FWApplication.h"
#import <objc/runtime.h>
@import FWFramework;

@implementation UIScrollView (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIScrollView fw_exchangeInstanceMethod:@selector(gestureRecognizerShouldBegin:) swizzleMethod:@selector(fw_innerGestureRecognizerShouldBegin:)];
        [UIScrollView fw_exchangeInstanceMethod:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) swizzleMethod:@selector(fw_innerGestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
        [UIScrollView fw_exchangeInstanceMethod:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:) swizzleMethod:@selector(fw_innerGestureRecognizer:shouldRequireFailureOfGestureRecognizer:)];
        [UIScrollView fw_exchangeInstanceMethod:@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:) swizzleMethod:@selector(fw_innerGestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)];
    });
}

- (BOOL)fw_innerGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fw_shouldBegin));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer);
    }
    
    return [self fw_innerGestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)fw_innerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fw_shouldRecognizeSimultaneously));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self fw_innerGestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)fw_innerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fw_shouldRequireFailure));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self fw_innerGestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)fw_innerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fw_shouldBeRequiredToFail));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self fw_innerGestureRecognizer:gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
}

#pragma mark - Content

- (UIView *)fw_contentView
{
    UIView *contentView = objc_getAssociatedObject(self, _cmd);
    if (!contentView) {
        contentView = [[UIView alloc] init];
        objc_setAssociatedObject(self, _cmd, contentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:contentView];
        [contentView fw_pinEdgesToSuperview];
    }
    return contentView;
}

#pragma mark - Frame

- (CGFloat)fw_contentWidth
{
    return self.contentSize.width;
}

- (void)setFw_contentWidth:(CGFloat)contentWidth
{
    self.contentSize = CGSizeMake(contentWidth, self.contentSize.height);
}

- (CGFloat)fw_contentHeight
{
    return self.contentSize.height;
}

- (void)setFw_contentHeight:(CGFloat)contentHeight
{
    self.contentSize = CGSizeMake(self.contentSize.width, contentHeight);
}

- (CGFloat)fw_contentOffsetX
{
    return self.contentOffset.x;
}

- (void)setFw_contentOffsetX:(CGFloat)contentOffsetX
{
    self.contentOffset = CGPointMake(contentOffsetX, self.contentOffset.y);
}

- (CGFloat)fw_contentOffsetY
{
    return self.contentOffset.y;
}

- (void)setFw_contentOffsetY:(CGFloat)contentOffsetY
{
    self.contentOffset = CGPointMake(self.contentOffset.x, contentOffsetY);
}

#pragma mark - Scroll

- (UIEdgeInsets)fw_contentInset
{
    return self.adjustedContentInset;
}

- (UISwipeGestureRecognizerDirection)fw_scrollDirection
{
    return [self.panGestureRecognizer fw_swipeDirection];
}

- (CGFloat)fw_scrollPercent
{
    return [self.panGestureRecognizer fw_swipePercent];
}

- (CGFloat)fw_scrollPercentOfDirection:(UISwipeGestureRecognizerDirection)direction
{
    return [self.panGestureRecognizer fw_swipePercentOfDirection:direction];
}

#pragma mark - Content

- (void)fw_contentInsetAdjustmentNever
{
    self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

#pragma mark - Keyboard

- (BOOL)fw_keyboardDismissOnDrag
{
    return self.keyboardDismissMode == UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)setFw_keyboardDismissOnDrag:(BOOL)keyboardDismissOnDrag
{
    self.keyboardDismissMode = keyboardDismissOnDrag ? UIScrollViewKeyboardDismissModeOnDrag : UIScrollViewKeyboardDismissModeNone;
}

#pragma mark - Gesture

- (BOOL (^)(UIGestureRecognizer *))fw_shouldBegin
{
    return objc_getAssociatedObject(self, @selector(fw_shouldBegin));
}

- (void)setFw_shouldBegin:(BOOL (^)(UIGestureRecognizer *))shouldBegin
{
    objc_setAssociatedObject(self, @selector(fw_shouldBegin), shouldBegin, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fw_shouldRecognizeSimultaneously
{
    return objc_getAssociatedObject(self, @selector(fw_shouldRecognizeSimultaneously));
}

- (void)setFw_shouldRecognizeSimultaneously:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldRecognizeSimultaneously
{
    objc_setAssociatedObject(self, @selector(fw_shouldRecognizeSimultaneously), shouldRecognizeSimultaneously, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fw_shouldRequireFailure
{
    return objc_getAssociatedObject(self, @selector(fw_shouldRequireFailure));
}

- (void)setFw_shouldRequireFailure:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldRequireFailure
{
    objc_setAssociatedObject(self, @selector(fw_shouldRequireFailure), shouldRequireFailure, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fw_shouldBeRequiredToFail
{
    return objc_getAssociatedObject(self, @selector(fw_shouldBeRequiredToFail));
}

- (void)setFw_shouldBeRequiredToFail:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldBeRequiredToFail
{
    objc_setAssociatedObject(self, @selector(fw_shouldBeRequiredToFail), shouldBeRequiredToFail, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - Hover

- (CGFloat)fw_hoverView:(UIView *)view
         fromSuperview:(UIView *)fromSuperview
           toSuperview:(UIView *)toSuperview
            toPosition:(CGFloat)toPosition
{
    CGFloat distance = [fromSuperview.superview convertPoint:fromSuperview.frame.origin toView:toSuperview].y - toPosition;
    if (distance <= 0) {
        if (view.superview != toSuperview) {
            [view removeFromSuperview];
            [toSuperview addSubview:view]; {
                [view fw_pinEdgeToSuperview:NSLayoutAttributeLeft];
                [view fw_pinEdgeToSuperview:NSLayoutAttributeTop withInset:toPosition];
                [view fw_setDimensionsToSize:view.bounds.size];
            }
        }
    } else {
        if (view.superview != fromSuperview) {
            [view removeFromSuperview];
            [fromSuperview addSubview:view]; {
                [view fw_pinEdgesToSuperview];
            }
        }
    }
    return distance;
}

+ (instancetype)fw_scrollView
{
    UIScrollView *scrollView = [[self alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    return scrollView;
}

@end

#pragma mark - UIGestureRecognizer+FWApplication

@implementation UIGestureRecognizer (FWApplication)

- (UIView *)fw_targetView
{
    CGPoint location = [self locationInView:self.view];
    UIView *targetView = [self.view hitTest:location withEvent:nil];
    return targetView;
}

- (BOOL)fw_isTracking
{
    return self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged;
}

- (BOOL)fw_isActive
{
    return self.isEnabled && (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged);
}

@end

@implementation UIPanGestureRecognizer (FWApplication)

- (UISwipeGestureRecognizerDirection)fw_swipeDirection
{
    CGPoint transition = [self translationInView:self.view];
    if (fabs(transition.x) > fabs(transition.y)) {
        if (transition.x < 0.0f) {
            return UISwipeGestureRecognizerDirectionLeft;
        } else if (transition.x > 0.0f) {
            return UISwipeGestureRecognizerDirectionRight;
        }
    } else {
        if (transition.y > 0.0f) {
            return UISwipeGestureRecognizerDirectionDown;
        } else if (transition.y < 0.0f) {
            return UISwipeGestureRecognizerDirectionUp;
        }
    }
    return 0;
}

- (CGFloat)fw_swipePercent
{
    CGFloat percent = 0;
    CGPoint transition = [self translationInView:self.view];
    if (fabs(transition.x) > fabs(transition.y)) {
        percent = fabs(transition.x) / self.view.bounds.size.width;
    } else {
        percent = fabs(transition.y) / self.view.bounds.size.height;
    }
    return MAX(0, MIN(1, percent));
}

- (CGFloat)fw_swipePercentOfDirection:(UISwipeGestureRecognizerDirection)direction
{
    CGFloat percent = 0;
    CGPoint transition = [self translationInView:self.view];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            percent = -transition.x / self.view.bounds.size.width;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            percent = transition.x / self.view.bounds.size.width;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            percent = -transition.y / self.view.bounds.size.height;
            break;
        case UISwipeGestureRecognizerDirectionDown:
        default:
            percent = transition.y / self.view.bounds.size.height;
            break;
    }
    return MAX(0, MIN(1, percent));
}

@end
