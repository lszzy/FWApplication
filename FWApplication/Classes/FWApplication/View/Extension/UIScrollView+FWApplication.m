//
//  UIScrollView+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIScrollView+FWApplication.h"
#import <objc/runtime.h>

@interface UIScrollView (FWApplication)

@end

@implementation UIScrollView (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIScrollView.fw exchangeInstanceMethod:@selector(gestureRecognizerShouldBegin:) swizzleMethod:@selector(innerGestureRecognizerShouldBegin:)];
        [UIScrollView.fw exchangeInstanceMethod:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) swizzleMethod:@selector(innerGestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
        [UIScrollView.fw exchangeInstanceMethod:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:) swizzleMethod:@selector(innerGestureRecognizer:shouldRequireFailureOfGestureRecognizer:)];
        [UIScrollView.fw exchangeInstanceMethod:@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:) swizzleMethod:@selector(innerGestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)];
    });
}

- (BOOL)innerGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(shouldBegin));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer);
    }
    
    return [self innerGestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL)innerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(shouldRecognizeSimultaneously));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self innerGestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)innerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(shouldRequireFailure));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self innerGestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
}

- (BOOL)innerGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    BOOL (^shouldBlock)(UIGestureRecognizer *, UIGestureRecognizer *) = objc_getAssociatedObject(self, @selector(shouldBeRequiredToFail));
    if (shouldBlock) {
        return shouldBlock(gestureRecognizer, otherGestureRecognizer);
    }
    
    return [self innerGestureRecognizer:gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
}

@end

@implementation FWScrollViewWrapper (FWApplication)

#pragma mark - Content

- (UIView *)contentView
{
    UIView *contentView = objc_getAssociatedObject(self.base, _cmd);
    if (!contentView) {
        contentView = [[UIView alloc] init];
        objc_setAssociatedObject(self.base, _cmd, contentView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self.base addSubview:contentView];
        [contentView.fw pinEdgesToSuperview];
    }
    return contentView;
}

#pragma mark - Frame

- (CGFloat)contentWidth
{
    return self.base.contentSize.width;
}

- (void)setContentWidth:(CGFloat)contentWidth
{
    self.base.contentSize = CGSizeMake(contentWidth, self.base.contentSize.height);
}

- (CGFloat)contentHeight
{
    return self.base.contentSize.height;
}

- (void)setContentHeight:(CGFloat)contentHeight
{
    self.base.contentSize = CGSizeMake(self.base.contentSize.width, contentHeight);
}

- (CGFloat)contentOffsetX
{
    return self.base.contentOffset.x;
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX
{
    self.base.contentOffset = CGPointMake(contentOffsetX, self.base.contentOffset.y);
}

- (CGFloat)contentOffsetY
{
    return self.base.contentOffset.y;
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY
{
    self.base.contentOffset = CGPointMake(self.base.contentOffset.x, contentOffsetY);
}

#pragma mark - Scroll

- (UIEdgeInsets)contentInset
{
    return self.base.adjustedContentInset;
}

- (UISwipeGestureRecognizerDirection)scrollDirection
{
    return [self.base.panGestureRecognizer.fw swipeDirection];
}

- (CGFloat)scrollPercent
{
    return [self.base.panGestureRecognizer.fw swipePercent];
}

- (CGFloat)scrollPercentOfDirection:(UISwipeGestureRecognizerDirection)direction
{
    return [self.base.panGestureRecognizer.fw swipePercentOfDirection:direction];
}

#pragma mark - Content

- (void)contentInsetAdjustmentNever
{
    self.base.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}

#pragma mark - Keyboard

- (BOOL)keyboardDismissOnDrag
{
    return self.base.keyboardDismissMode == UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)setKeyboardDismissOnDrag:(BOOL)keyboardDismissOnDrag
{
    self.base.keyboardDismissMode = keyboardDismissOnDrag ? UIScrollViewKeyboardDismissModeOnDrag : UIScrollViewKeyboardDismissModeNone;
}

#pragma mark - Gesture

- (BOOL (^)(UIGestureRecognizer *))shouldBegin
{
    return objc_getAssociatedObject(self.base, @selector(shouldBegin));
}

- (void)setShouldBegin:(BOOL (^)(UIGestureRecognizer *))shouldBegin
{
    objc_setAssociatedObject(self.base, @selector(shouldBegin), shouldBegin, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldRecognizeSimultaneously
{
    return objc_getAssociatedObject(self.base, @selector(shouldRecognizeSimultaneously));
}

- (void)setShouldRecognizeSimultaneously:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldRecognizeSimultaneously
{
    objc_setAssociatedObject(self.base, @selector(shouldRecognizeSimultaneously), shouldRecognizeSimultaneously, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldRequireFailure
{
    return objc_getAssociatedObject(self.base, @selector(shouldRequireFailure));
}

- (void)setShouldRequireFailure:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldRequireFailure
{
    objc_setAssociatedObject(self.base, @selector(shouldRequireFailure), shouldRequireFailure, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldBeRequiredToFail
{
    return objc_getAssociatedObject(self.base, @selector(shouldBeRequiredToFail));
}

- (void)setShouldBeRequiredToFail:(BOOL (^)(UIGestureRecognizer *, UIGestureRecognizer *))shouldBeRequiredToFail
{
    objc_setAssociatedObject(self.base, @selector(shouldBeRequiredToFail), shouldBeRequiredToFail, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - Hover

- (CGFloat)hoverView:(UIView *)view
         fromSuperview:(UIView *)fromSuperview
           toSuperview:(UIView *)toSuperview
            toPosition:(CGFloat)toPosition
{
    CGFloat distance = [fromSuperview.superview convertPoint:fromSuperview.frame.origin toView:toSuperview].y - toPosition;
    if (distance <= 0) {
        if (view.superview != toSuperview) {
            [view removeFromSuperview];
            [toSuperview addSubview:view]; {
                [view.fw pinEdgeToSuperview:NSLayoutAttributeLeft];
                [view.fw pinEdgeToSuperview:NSLayoutAttributeTop withInset:toPosition];
                [view.fw setDimensionsToSize:view.bounds.size];
            }
        }
    } else {
        if (view.superview != fromSuperview) {
            [view removeFromSuperview];
            [fromSuperview addSubview:view]; {
                [view.fw pinEdgesToSuperview];
            }
        }
    }
    return distance;
}

@end

@implementation FWScrollViewClassWrapper (FWApplication)

- (__kindof UIScrollView *)scrollView
{
    UIScrollView *scrollView = [[self.base alloc] init];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    return scrollView;
}

@end

#pragma mark - FWGestureRecognizerWrapper+FWApplication

@implementation FWGestureRecognizerWrapper (FWApplication)

- (UIView *)targetView
{
    CGPoint location = [self.base locationInView:self.base.view];
    UIView *targetView = [self.base.view hitTest:location withEvent:nil];
    return targetView;
}

- (BOOL)isTracking
{
    return self.base.state == UIGestureRecognizerStateBegan || self.base.state == UIGestureRecognizerStateChanged;
}

- (BOOL)isActive
{
    return self.base.isEnabled && (self.base.state == UIGestureRecognizerStateBegan || self.base.state == UIGestureRecognizerStateChanged);
}

@end

@implementation FWPanGestureRecognizerWrapper (FWApplication)

- (UISwipeGestureRecognizerDirection)swipeDirection
{
    CGPoint transition = [self.base translationInView:self.base.view];
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

- (CGFloat)swipePercent
{
    CGFloat percent = 0;
    CGPoint transition = [self.base translationInView:self.base.view];
    if (fabs(transition.x) > fabs(transition.y)) {
        percent = fabs(transition.x) / self.base.view.bounds.size.width;
    } else {
        percent = fabs(transition.y) / self.base.view.bounds.size.height;
    }
    return MAX(0, MIN(1, percent));
}

- (CGFloat)swipePercentOfDirection:(UISwipeGestureRecognizerDirection)direction
{
    CGFloat percent = 0;
    CGPoint transition = [self.base translationInView:self.base.view];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            percent = -transition.x / self.base.view.bounds.size.width;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            percent = transition.x / self.base.view.bounds.size.width;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            percent = -transition.y / self.base.view.bounds.size.height;
            break;
        case UISwipeGestureRecognizerDirectionDown:
        default:
            percent = transition.y / self.base.view.bounds.size.height;
            break;
    }
    return MAX(0, MIN(1, percent));
}

@end
