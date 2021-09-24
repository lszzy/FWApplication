//
//  UIScrollView+FWApplication.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "UIScrollView+FWApplication.h"
#import "UIGestureRecognizer+FWApplication.h"
#import "FWAutoLayout.h"
#import "FWSwizzle.h"
#import <objc/runtime.h>

@implementation UIScrollView (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self fwSwizzleInstanceMethod:@selector(gestureRecognizerShouldBegin:) with:@selector(fwInnerGestureRecognizerShouldBegin:)];
        [self fwSwizzleInstanceMethod:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:) with:@selector(fwInnerGestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
        [self fwSwizzleInstanceMethod:@selector(gestureRecognizer:shouldRequireFailureOfGestureRecognizer:) with:@selector(fwInnerGestureRecognizer:shouldRequireFailureOfGestureRecognizer:)];
        [self fwSwizzleInstanceMethod:@selector(gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:) with:@selector(fwInnerGestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)];
    });
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