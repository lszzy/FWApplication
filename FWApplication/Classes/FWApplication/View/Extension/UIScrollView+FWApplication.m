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
        [UIScrollView.fw swizzleInstanceMethod:@selector(gestureRecognizerShouldBegin:) with:@selector(fwInnerGestureRecognizerShouldBegin:)];
        [UIScrollView.fw swizzleInstanceMethod:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) with:@selector(fwInnerGestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
        [UIScrollView.fw swizzleInstanceMethod:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:) with:@selector(fwInnerGestureRecognizer:shouldRequireFailureOfGestureRecognizer:)];
        [UIScrollView.fw swizzleInstanceMethod:@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:) with:@selector(fwInnerGestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)];
    });
}

#pragma mark - Content

+ (instancetype)fwScrollView
{
    UIScrollView *scrollView = [[self alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    return scrollView;
}

- (UIView *)fwContentView
{
    UIView *contentView = objc_getAssociatedObject(self, _cmd);
    if (!contentView) {
        contentView = [[UIView alloc] init];
        objc_setAssociatedObject(self, _cmd, contentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:contentView];
        [contentView fwPinEdgesToSuperview];
    }
    return contentView;
}

#pragma mark - Frame

- (CGFloat)fwContentWidth
{
    return self.contentSize.width;
}

- (void)setFwContentWidth:(CGFloat)fwContentWidth
{
    self.contentSize = CGSizeMake(fwContentWidth, self.contentSize.height);
}

- (CGFloat)fwContentHeight
{
    return self.contentSize.height;
}

- (void)setFwContentHeight:(CGFloat)fwContentHeight
{
    self.contentSize = CGSizeMake(self.contentSize.width, fwContentHeight);
}

- (CGFloat)fwContentOffsetX
{
    return self.contentOffset.x;
}

- (void)setFwContentOffsetX:(CGFloat)fwContentOffsetX
{
    self.contentOffset = CGPointMake(fwContentOffsetX, self.contentOffset.y);
}

- (CGFloat)fwContentOffsetY
{
    return self.contentOffset.y;
}

- (void)setFwContentOffsetY:(CGFloat)fwContentOffsetY
{
    self.contentOffset = CGPointMake(self.contentOffset.x, fwContentOffsetY);
}

#pragma mark - Scroll

- (UIEdgeInsets)fwContentInset
{
    return self.adjustedContentInset;
}

- (UISwipeGestureRecognizerDirection)fwScrollDirection
{
    return [self.panGestureRecognizer fwSwipeDirection];
}

- (CGFloat)fwScrollPercent
{
    return [self.panGestureRecognizer fwSwipePercent];
}

- (CGFloat)fwScrollPercentOfDirection:(UISwipeGestureRecognizerDirection)direction
{
    return [self.panGestureRecognizer fwSwipePercentOfDirection:direction];
}

#pragma mark - Content

- (void)fwContentInsetAdjustmentNever
{
    self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

#pragma mark - Keyboard

- (BOOL)fwKeyboardDismissOnDrag
{
    return self.keyboardDismissMode == UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)setFwKeyboardDismissOnDrag:(BOOL)fwKeyboardDismissOnDrag
{
    self.keyboardDismissMode = fwKeyboardDismissOnDrag ? UIScrollViewKeyboardDismissModeOnDrag : UIScrollViewKeyboardDismissModeNone;
}

#pragma mark - Gesture

- (BOOL (^)(UIGestureRecognizer *))fwShouldBegin
{
    return objc_getAssociatedObject(self, @selector(fwShouldBegin));
}

- (void)setFwShouldBegin:(BOOL (^)(UIGestureRecognizer *))fwShouldBegin
{
    objc_setAssociatedObject(self, @selector(fwShouldBegin), fwShouldBegin, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fwShouldRecognizeSimultaneously
{
    return objc_getAssociatedObject(self, @selector(fwShouldRecognizeSimultaneously));
}

- (void)setFwShouldRecognizeSimultaneously:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fwShouldRecognizeSimultaneously
{
    objc_setAssociatedObject(self, @selector(fwShouldRecognizeSimultaneously), fwShouldRecognizeSimultaneously, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fwShouldRequireFailure
{
    return objc_getAssociatedObject(self, @selector(fwShouldRequireFailure));
}

- (void)setFwShouldRequireFailure:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fwShouldRequireFailure
{
    objc_setAssociatedObject(self, @selector(fwShouldRequireFailure), fwShouldRequireFailure, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fwShouldBeRequiredToFail
{
    return objc_getAssociatedObject(self, @selector(fwShouldBeRequiredToFail));
}

- (void)setFwShouldBeRequiredToFail:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))fwShouldBeRequiredToFail
{
    objc_setAssociatedObject(self, @selector(fwShouldBeRequiredToFail), fwShouldBeRequiredToFail, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)fwInnerGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fwShouldBegin));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer);
    }
    
    return [self fwInnerGestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)fwInnerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fwShouldRecognizeSimultaneously));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self fwInnerGestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)fwInnerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fwShouldRequireFailure));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self fwInnerGestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)fwInnerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(fwShouldBeRequiredToFail));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self fwInnerGestureRecognizer:gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
}

#pragma mark - Hover

- (CGFloat)fwHoverView:(UIView *)view
         fromSuperview:(UIView *)fromSuperview
           toSuperview:(UIView *)toSuperview
            toPosition:(CGFloat)toPosition
{
    CGFloat distance = [fromSuperview.superview convertPoint:fromSuperview.frame.origin toView:toSuperview].y - toPosition;
    if (distance <= 0) {
        if (view.superview != toSuperview) {
            [view removeFromSuperview];
            [toSuperview addSubview:view]; {
                [view fwPinEdgeToSuperview:NSLayoutAttributeLeft];
                [view fwPinEdgeToSuperview:NSLayoutAttributeTop withInset:toPosition];
                [view fwSetDimensionsToSize:view.bounds.size];
            }
        }
    } else {
        if (view.superview != fromSuperview) {
            [view removeFromSuperview];
            [fromSuperview addSubview:view]; {
                [view fwPinEdgesToSuperview];
            }
        }
    }
    return distance;
}

@end

#pragma mark - UIGestureRecognizer+FWApplication

@implementation UIGestureRecognizer (FWApplication)

- (UIView *)fwTargetView
{
    CGPoint location = [self locationInView:self.view];
    UIView *targetView = [self.view hitTest:location withEvent:nil];
    return targetView;
}

- (BOOL)fwIsTracking
{
    return self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged;
}

- (BOOL)fwIsActive
{
    return self.isEnabled && (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged);
}

@end

@implementation UIPanGestureRecognizer (FWApplication)

- (UISwipeGestureRecognizerDirection)fwSwipeDirection
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

- (CGFloat)fwSwipePercent
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

- (CGFloat)fwSwipePercentOfDirection:(UISwipeGestureRecognizerDirection)direction
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
