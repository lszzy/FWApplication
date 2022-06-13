//
//  FWViewTransition.m
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWViewTransition.h"
#import <objc/runtime.h>

#pragma mark - FWAnimatedTransition

@interface FWAnimatedTransition ()

@property (nonatomic, assign) BOOL isSystem;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) FWPanGestureRecognizer *gestureRecognizer;

@property (nonatomic, copy) void(^interactBegan)(void);

@end

@implementation FWAnimatedTransition

#pragma mark - Lifecycle

+ (instancetype)systemTransition
{
    static FWAnimatedTransition *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWAnimatedTransition alloc] init];
        instance.isSystem = YES;
    });
    return instance;
}

+ (instancetype)transitionWithBlock:(void (^)(FWAnimatedTransition *))block
{
    FWAnimatedTransition *transition = [[self alloc] init];
    transition.transitionBlock = block;
    return transition;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _transitionDuration = 0.35;
        self.completionSpeed = 0.35;
    }
    return self;
}

#pragma mark - Private

- (void)setInteractEnabled:(BOOL)interactEnabled
{
    _interactEnabled = interactEnabled;
    self.gestureRecognizer.enabled = interactEnabled;
}

- (void)interactWith:(UIViewController *)viewController
{
    if (!viewController.view) return;

    for (UIGestureRecognizer *gestureRecognizer in viewController.view.gestureRecognizers) {
        if (gestureRecognizer == self.gestureRecognizer) return;
    }
    [viewController.view addGestureRecognizer:self.gestureRecognizer];
}

- (FWPanGestureRecognizer *)gestureRecognizer
{
    if (!_gestureRecognizer) {
        _gestureRecognizer = [[FWPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)];
    }
    return _gestureRecognizer;
}

- (void)gestureRecognizerAction:(FWPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _isInteractive = YES;
            
            BOOL interactBegan = self.interactBlock ? self.interactBlock(gestureRecognizer) : YES;
            if (interactBegan && self.interactBegan) {
                self.interactBegan();
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            BOOL interactChanged = self.interactBlock ? self.interactBlock(gestureRecognizer) : YES;
            if (interactChanged) {
                CGFloat percent = [gestureRecognizer swipePercent];
                [self updateInteractiveTransition:percent];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            _isInteractive = NO;
            
            BOOL interactEnded = self.interactBlock ? self.interactBlock(gestureRecognizer) : YES;
            if (interactEnded) {
                BOOL finished = NO;
                if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                    finished = NO;
                } else if (self.percentComplete >= 0.5) {
                    finished = YES;
                } else {
                    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
                    CGPoint transition = [gestureRecognizer translationInView:gestureRecognizer.view];
                    switch (gestureRecognizer.direction) {
                        case UISwipeGestureRecognizerDirectionUp:
                            if (velocity.y <= -100 && fabs(transition.x) < fabs(transition.y)) finished = YES;
                            break;
                        case UISwipeGestureRecognizerDirectionLeft:
                            if (velocity.x <= -100 && fabs(transition.x) > fabs(transition.y)) finished = YES;
                            break;
                        case UISwipeGestureRecognizerDirectionDown:
                            if (velocity.y >= 100 && fabs(transition.x) < fabs(transition.y)) finished = YES;
                            break;
                        case UISwipeGestureRecognizerDirectionRight:
                            if (velocity.x >= 100 && fabs(transition.x) > fabs(transition.y)) finished = YES;
                            break;
                        default:
                            break;
                    }
                }
                
                if (finished) {
                    [self finishInteractiveTransition];
                } else {
                    [self cancelInteractiveTransition];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (BOOL)presentationEnabled
{
    return self.presentationBlock != nil;
}

- (void)setPresentationEnabled:(BOOL)presentationEnabled
{
    if (presentationEnabled == self.presentationEnabled) return;
    
    if (presentationEnabled) {
        self.presentationBlock = ^UIPresentationController *(UIViewController *presented, UIViewController *presenting) {
            return [[FWPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
        };
    } else {
        self.presentationBlock = nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)interactiveTransitionForTransition:(id<UIViewControllerAnimatedTransitioning>)transition
{
    if (self.transitionType == FWAnimatedTransitionTypeDismiss || self.transitionType == FWAnimatedTransitionTypePop) {
        if (!self.isSystem && self.interactEnabled && self.isInteractive) {
            return self;
        }
    }
    return nil;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.transitionType = FWAnimatedTransitionTypePresent;
    // 自动设置和绑定dismiss交互转场，在dismiss前设置生效
    if (!self.isSystem && self.interactEnabled && !self.interactBlock) {
        __weak UIViewController *weakPresented = presented;
        self.interactBegan = ^{
            [weakPresented dismissViewControllerAnimated:YES completion:nil];
        };
        [self interactWith:presented];
    }
    return !self.isSystem ? self : nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transitionType = FWAnimatedTransitionTypeDismiss;
    return !self.isSystem ? self : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return [self interactiveTransitionForTransition:animator];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return [self interactiveTransitionForTransition:animator];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    if (self.presentationBlock) {
        return self.presentationBlock(presented, presenting);
    }
    return nil;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        // push时检查toVC的转场代理
        FWAnimatedTransition *transition = toVC.fw.viewTransition ?: self;
        transition.transitionType = FWAnimatedTransitionTypePush;
        // 自动设置和绑定pop交互转场，在pop前设置生效
        if (!transition.isSystem && transition.interactEnabled && !transition.interactBlock) {
            transition.interactBegan = ^{
                [navigationController popViewControllerAnimated:YES];
            };
            [transition interactWith:toVC];
        }
        return !transition.isSystem ? transition : nil;
    } else if (operation == UINavigationControllerOperationPop) {
        // pop时检查fromVC的转场代理
        FWAnimatedTransition *transition = fromVC.fw.viewTransition ?: self;
        transition.transitionType = FWAnimatedTransitionTypePop;
        return !transition.isSystem ? transition : nil;
    }
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    return [self interactiveTransitionForTransition:animationController];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return transitionContext.isAnimated ? self.transitionDuration : 0.f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.transitionContext = transitionContext;
    
    if (self.transitionBlock) {
        self.transitionBlock(self);
    } else {
        [self animate];
    }
}

#pragma mark - Animate

- (FWAnimatedTransitionType)transitionType
{
    // 如果自定义type，优先使用之
    if (_transitionType != FWAnimatedTransitionTypeNone) {
        return _transitionType;
    }
    
    // 自动根据上下文获取type
    if (!self.transitionContext) {
        return FWAnimatedTransitionTypeNone;
    }
    
    UIViewController *fromViewController = [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    // 导航栏为同一个时为push|pop
    if (fromViewController.navigationController && toViewController.navigationController &&
        fromViewController.navigationController == toViewController.navigationController) {
        NSInteger toIndex = [toViewController.navigationController.viewControllers indexOfObject:toViewController];
        NSInteger fromIndex = [fromViewController.navigationController.viewControllers indexOfObject:fromViewController];
        if (toIndex > fromIndex) {
            return FWAnimatedTransitionTypePush;
        } else {
            return FWAnimatedTransitionTypePop;
        }
    } else {
        if (toViewController.presentingViewController == fromViewController) {
            return FWAnimatedTransitionTypePresent;
        } else {
            return FWAnimatedTransitionTypeDismiss;
        }
    }
}

- (void)start
{
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [self.transitionContext viewForKey:UITransitionContextToViewKey];
    switch (self.transitionType) {
        // push时fromView在下，toView在上
        case FWAnimatedTransitionTypePush: {
            [self.transitionContext.containerView addSubview:fromView];
            [self.transitionContext.containerView addSubview:toView];
            break;
        }
        // pop时fromView在上，toView在下
        case FWAnimatedTransitionTypePop: {
            // 此处后添加fromView，方便做pop动画，可自行移动toView到上面
            [self.transitionContext.containerView addSubview:toView];
            [self.transitionContext.containerView addSubview:fromView];
            break;
        }
        // present时使用toView做动画
        case FWAnimatedTransitionTypePresent: {
            [self.transitionContext.containerView addSubview:toView];
            break;
        }
        // dismiss时使用fromView做动画
        case FWAnimatedTransitionTypeDismiss: {
            [self.transitionContext.containerView addSubview:fromView];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)animate
{
    // 子类可重写，默认alpha动画
    FWAnimatedTransitionType transitionType = [self transitionType];
    BOOL transitionIn = (transitionType == FWAnimatedTransitionTypePush || transitionType == FWAnimatedTransitionTypePresent);
    UIView *transitionView = transitionIn ? [self.transitionContext viewForKey:UITransitionContextToViewKey] : [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [self start];
    if (transitionIn) transitionView.alpha = 0;
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        transitionView.alpha = transitionIn ? 1 : 0;
    } completion:^(BOOL finished) {
        [self complete];
    }];
}

- (void)complete
{
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
}

@end

#pragma mark - FWSwipeAnimatedTransition

@implementation FWSwipeAnimatedTransition

+ (instancetype)transitionWithInDirection:(UISwipeGestureRecognizerDirection)inDirection
                             outDirection:(UISwipeGestureRecognizerDirection)outDirection
{
    FWSwipeAnimatedTransition *transition = [[self alloc] init];
    transition.inDirection = inDirection;
    transition.outDirection = outDirection;
    return transition;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _inDirection = UISwipeGestureRecognizerDirectionUp;
        _outDirection = UISwipeGestureRecognizerDirectionDown;
    }
    return self;
}

- (void)setOutDirection:(UISwipeGestureRecognizerDirection)outDirection
{
    _outDirection = outDirection;
    self.gestureRecognizer.direction = outDirection;
}

- (void)animate
{
    FWAnimatedTransitionType transitionType = [self transitionType];
    BOOL transitionIn = (transitionType == FWAnimatedTransitionTypePush || transitionType == FWAnimatedTransitionTypePresent);
    UISwipeGestureRecognizerDirection direction = transitionIn ? self.inDirection : self.outDirection;
    CGVector offset;
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft: {
            offset = CGVectorMake(-1.f, 0.f);
            break;
        }
        case UISwipeGestureRecognizerDirectionRight: {
            offset = CGVectorMake(1.f, 0.f);
            break;
        }
        case UISwipeGestureRecognizerDirectionUp: {
            offset = CGVectorMake(0.f, -1.f);
            break;
        }
        case UISwipeGestureRecognizerDirectionDown:
        default: {
            offset = CGVectorMake(0.f, 1.f);
            break;
        }
    }
    
    CGRect fromFrame = [self.transitionContext initialFrameForViewController:[self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey]];
    CGRect toFrame = [self.transitionContext finalFrameForViewController:[self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey]];
    UIView *fromView = [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [self.transitionContext viewForKey:UITransitionContextToViewKey];
    if (transitionIn) {
        [self.transitionContext.containerView addSubview:toView];
        toView.frame = [self animateFrameWithFrame:toFrame offset:offset initial:YES show:transitionIn];
        fromView.frame = fromFrame;
    } else {
        [self.transitionContext.containerView insertSubview:toView belowSubview:fromView];
        fromView.frame = [self animateFrameWithFrame:fromFrame offset:offset initial:YES show:transitionIn];
        toView.frame = toFrame;
    }
    
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] animations:^{
        if (transitionIn) {
            toView.frame = [self animateFrameWithFrame:toFrame offset:offset initial:NO show:transitionIn];
        } else {
            fromView.frame = [self animateFrameWithFrame:fromFrame offset:offset initial:NO show:transitionIn];
        }
    } completion:^(BOOL finished) {
        BOOL cancelled = [self.transitionContext transitionWasCancelled];
        if (cancelled) {
            [toView removeFromSuperview];
        }
        [self.transitionContext completeTransition:!cancelled];
    }];
}

- (CGRect)animateFrameWithFrame:(CGRect)frame offset:(CGVector)offset initial:(BOOL)initial show:(BOOL)show
{
    NSInteger vectorValue = offset.dx == 0 ? offset.dy : offset.dx;
    NSInteger flag = 0;
    if (initial) {
        vectorValue = vectorValue > 0 ? -vectorValue : vectorValue;
        flag = show ? vectorValue : 0;
    } else {
        vectorValue = vectorValue > 0 ? vectorValue : -vectorValue;
        flag = show ? 0 : vectorValue;
    }
    
    CGFloat offsetX = frame.size.width * offset.dx * flag;
    CGFloat offsetY = frame.size.height * offset.dy * flag;
    return CGRectOffset(frame, offsetX, offsetY);
}

@end

#pragma mark - FWTransformAnimatedTransition

@implementation FWTransformAnimatedTransition

+ (instancetype)transitionWithInTransform:(CGAffineTransform)inTransform
                             outTransform:(CGAffineTransform)outTransform
{
    FWTransformAnimatedTransition *transition = [[self alloc] init];
    transition.inTransform = inTransform;
    transition.outTransform = outTransform;
    return transition;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _inTransform = CGAffineTransformMakeScale(0.01, 0.01);
        _outTransform = CGAffineTransformMakeScale(0.01, 0.01);
    }
    return self;
}

- (void)animate
{
    FWAnimatedTransitionType transitionType = [self transitionType];
    BOOL transitionIn = (transitionType == FWAnimatedTransitionTypePush || transitionType == FWAnimatedTransitionTypePresent);
    UIView *transitionView = transitionIn ? [self.transitionContext viewForKey:UITransitionContextToViewKey] : [self.transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [self start];
    if (transitionIn) {
        transitionView.transform = self.inTransform;
        transitionView.alpha = 0;
    }
    [UIView animateWithDuration:[self transitionDuration:self.transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        transitionView.transform = transitionIn ? CGAffineTransformIdentity : self.outTransform;
        transitionView.alpha = transitionIn ? 1 : 0;
    } completion:^(BOOL finished) {
        [self complete];
    }];
}

@end

#pragma mark - FWPresentationController

@interface FWPresentationController ()

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation FWPresentationController

#pragma mark - Lifecycle

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _showDimming = YES;
        _dimmingClick = YES;
        _dimmingAnimated = YES;
        _dimmingColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _rectCorner = UIRectCornerTopLeft | UIRectCornerTopRight;
        _cornerRadius = 0;
        _presentedFrame = CGRectZero;
        _presentedSize = CGSizeZero;
        _verticalInset = 0;
    }
    return self;
}

#pragma mark - Accessor

- (UIView *)dimmingView
{
    if (!_dimmingView) {
        _dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _dimmingView.backgroundColor = self.dimmingColor;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)];
        [_dimmingView addGestureRecognizer:tapGesture];
    }
    return _dimmingView;
}

- (void)setShowDimming:(BOOL)showDimming
{
    _showDimming = showDimming;
    self.dimmingView.hidden = !showDimming;
}

- (void)setDimmingClick:(BOOL)dimmingClick
{
    _dimmingClick = dimmingClick;
    self.dimmingView.userInteractionEnabled = dimmingClick;
}

- (void)onTapAction:(id)sender
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Protected

- (void)presentationTransitionWillBegin
{
    [super presentationTransitionWillBegin];
    
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
    if (self.cornerRadius > 0) {
        self.presentedView.layer.masksToBounds = YES;
        if ((self.rectCorner & UIRectCornerAllCorners) == UIRectCornerAllCorners) {
            self.presentedView.layer.cornerRadius = self.cornerRadius;
        } else {
            [self.presentedView.fw setCornerLayer:self.rectCorner radius:self.cornerRadius];
        }
    }
    self.dimmingView.frame = self.containerView.bounds;
    [self.containerView insertSubview:self.dimmingView atIndex:0];
    
    if (self.dimmingAnimated) {
        self.dimmingView.alpha = 0;
        [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.dimmingView.alpha = 1.0;
        } completion:nil];
    }
}

- (void)dismissalTransitionWillBegin
{
    [super dismissalTransitionWillBegin];
    
    if (self.dimmingAnimated) {
        [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.dimmingView.alpha = 0;
        } completion:nil];
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    [super dismissalTransitionDidEnd:completed];
    
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView
{
    if (self.frameBlock) {
        return self.frameBlock(self);
    } else if (!CGRectEqualToRect(self.presentedFrame, CGRectZero)) {
        return self.presentedFrame;
    } else if (!CGSizeEqualToSize(self.presentedSize, CGSizeZero)) {
        CGRect presentedFrame = CGRectMake(0, 0, self.presentedSize.width, self.presentedSize.height);
        presentedFrame.origin.x = (self.containerView.bounds.size.width - self.presentedSize.width) / 2;
        presentedFrame.origin.y = (self.containerView.bounds.size.height - self.presentedSize.height) / 2;
        return presentedFrame;
    } else if (self.verticalInset != 0) {
        CGRect presentedFrame = self.containerView.bounds;
        presentedFrame.origin.y = self.verticalInset;
        presentedFrame.size.height -= self.verticalInset;
        return presentedFrame;
    } else {
        return self.containerView.bounds;
    }
}

@end

#pragma mark - FWPanGestureRecognizer

@interface FWPanGestureRecognizer () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSNumber *isFailed;

@end

@implementation FWPanGestureRecognizer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _direction = UISwipeGestureRecognizerDirectionDown;
        _autoDetected = YES;
        self.delegate = self;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        _direction = UISwipeGestureRecognizerDirectionDown;
        _autoDetected = YES;
        self.delegate = self;
    }
    return self;
}

- (CGFloat)swipePercent
{
    CGFloat percent = 0;
    CGPoint transition = [self translationInView:self.view];
    switch (self.direction) {
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

- (void)reset
{
    [super reset];
    self.isFailed = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (!self.scrollView || !self.scrollView.scrollEnabled) return;
    
    if (self.direction == UISwipeGestureRecognizerDirectionUp || self.direction == UISwipeGestureRecognizerDirectionDown) {
        if (![self.scrollView.fw canScrollVertical]) return;
    } else {
        if (![self.scrollView.fw canScrollHorizontal]) return;
    }

    if (self.state == UIGestureRecognizerStateFailed) return;
    if (self.isFailed) {
        if (self.isFailed.boolValue) {
            self.state = UIGestureRecognizerStateFailed;
        }
        return;
    }

    CGPoint velocity = [self velocityInView:self.view];
    CGPoint location = [touches.anyObject locationInView:self.view];
    CGPoint prevLocation = [touches.anyObject previousLocationInView:self.view];
    if (CGPointEqualToPoint(velocity, CGPointZero) && CGPointEqualToPoint(location, prevLocation)) return;
    
    BOOL isFailed = NO;
    switch (self.direction) {
        case UISwipeGestureRecognizerDirectionDown: {
            CGFloat edgeOffset = [self.scrollView.fw contentOffsetOfEdge:UIRectEdgeTop].y;
            if ((fabs(velocity.x) < fabs(velocity.y)) && (location.y > prevLocation.y) && (self.scrollView.contentOffset.y <= edgeOffset)) {
                isFailed = NO;
            } else if (self.scrollView.contentOffset.y >= edgeOffset) {
                isFailed = YES;
            }
            break;
        }
        case UISwipeGestureRecognizerDirectionUp: {
            CGFloat edgeOffset = [self.scrollView.fw contentOffsetOfEdge:UIRectEdgeBottom].y;
            if ((fabs(velocity.x) < fabs(velocity.y)) && (location.y < prevLocation.y) && (self.scrollView.contentOffset.y >= edgeOffset)) {
                isFailed = NO;
            } else if (self.scrollView.contentOffset.y <= edgeOffset) {
                isFailed = YES;
            }
            break;
        }
        case UISwipeGestureRecognizerDirectionRight: {
            CGFloat edgeOffset = [self.scrollView.fw contentOffsetOfEdge:UIRectEdgeLeft].x;
            if ((fabs(velocity.y) < fabs(velocity.x)) && (location.x > prevLocation.x) && (self.scrollView.contentOffset.x <= edgeOffset)) {
                isFailed = NO;
            } else if (self.scrollView.contentOffset.x >= edgeOffset) {
                isFailed = YES;
            }
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft: {
            CGFloat edgeOffset = [self.scrollView.fw contentOffsetOfEdge:UIRectEdgeRight].x;
            if ((fabs(velocity.y) < fabs(velocity.x)) && (location.x < prevLocation.x) && (self.scrollView.contentOffset.x >= edgeOffset)) {
                isFailed = NO;
            } else if (self.scrollView.contentOffset.x <= edgeOffset) {
                isFailed = YES;
            }
            break;
        }
        default:
            break;
    }
    
    if (isFailed && self.shouldFailed) {
        isFailed = self.shouldFailed(self);
    }
    
    if (isFailed) {
        self.state = UIGestureRecognizerStateFailed;
        self.isFailed = @YES;
    } else {
        self.isFailed = @NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.shouldBegin) return self.shouldBegin(self);
    if (self.maximumDistance <= 0) return YES;
    
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    switch (self.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            return gestureRecognizer.view.bounds.size.width - location.x <= self.maximumDistance;
        case UISwipeGestureRecognizerDirectionRight:
            return location.x <= self.maximumDistance;
        case UISwipeGestureRecognizerDirectionUp:
            return gestureRecognizer.view.bounds.size.height - location.y <= self.maximumDistance;
        case UISwipeGestureRecognizerDirectionDown:
        default:
            return location.y <= self.maximumDistance;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
        [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        if (self.autoDetected) {
            UIScrollView *scrollView = (UIScrollView *)otherGestureRecognizer.view;
            if (self.direction == UISwipeGestureRecognizerDirectionUp || self.direction == UISwipeGestureRecognizerDirectionDown) {
                if ([scrollView.fw canScrollHorizontal]) return NO;
            } else {
                if ([scrollView.fw canScrollVertical]) return NO;
            }
            
            if (scrollView != self.scrollView) self.scrollView = scrollView;
            return YES;
        } else {
            if (self.scrollView && self.scrollView == otherGestureRecognizer.view) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
        [otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        if (self.autoDetected) {
            UIScrollView *scrollView = (UIScrollView *)otherGestureRecognizer.view;
            if (self.direction == UISwipeGestureRecognizerDirectionUp || self.direction == UISwipeGestureRecognizerDirectionDown) {
                if ([scrollView.fw canScrollHorizontal]) return NO;
            } else {
                if ([scrollView.fw canScrollVertical]) return NO;
            }
            
            if (scrollView != self.scrollView) self.scrollView = scrollView;
            return self.shouldBeRequiredToFail ? self.shouldBeRequiredToFail(otherGestureRecognizer) : YES;
        } else {
            if (self.scrollView && self.scrollView == otherGestureRecognizer.view) {
                return self.shouldBeRequiredToFail ? self.shouldBeRequiredToFail(otherGestureRecognizer) : YES;
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (self.shouldRequireFailure) {
        return self.shouldRequireFailure(otherGestureRecognizer);
    }
    return NO;
}

@end

#pragma mark - FWPresentationTarget

@interface FWPresentationTarget : NSObject <UIPopoverPresentationControllerDelegate>

@property (nonatomic, assign) BOOL isPopover;
@property (nonatomic, assign) BOOL shouldDismiss;

@end

@implementation FWPresentationTarget

- (instancetype)init
{
    self = [super init];
    if (self) {
        _shouldDismiss = YES;
    }
    return self;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return self.isPopover ? UIModalPresentationNone : controller.presentationStyle;
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    return self.shouldDismiss;
}

- (BOOL)presentationControllerShouldDismiss:(UIPresentationController *)presentationController
{
    return self.shouldDismiss;
}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController
{
    if (presentationController.presentedViewController.fw.presentationDidDismiss) {
        presentationController.presentedViewController.fw.presentationDidDismiss();
    }
}

@end

#pragma mark - FWViewControllerWrapper+FWTransition

@implementation FWViewControllerWrapper (FWTransition)

- (FWAnimatedTransition *)modalTransition
{
    return objc_getAssociatedObject(self.base, @selector(modalTransition));
}

// 注意：App退出后台时如果弹出页面，整个present动画不会执行。如果需要设置遮罩层等，需要在viewDidAppear中处理兼容
- (void)setModalTransition:(FWAnimatedTransition *)modalTransition
{
    // 设置delegation动画，nil时清除delegate动画
    self.base.transitioningDelegate = modalTransition;
    // 强引用，防止被自动释放，nil时释放引用
    objc_setAssociatedObject(self.base, @selector(modalTransition), modalTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FWAnimatedTransition *)viewTransition
{
    return objc_getAssociatedObject(self.base, @selector(viewTransition));
}

- (void)setViewTransition:(FWAnimatedTransition *)viewTransition
{
    objc_setAssociatedObject(self.base, @selector(viewTransition), viewTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FWAnimatedTransition *)setPresentTransition:(void (^)(FWPresentationController *))presentationBlock
{
    FWSwipeAnimatedTransition *modalTransition = [[FWSwipeAnimatedTransition alloc] init];
    modalTransition.presentationBlock = ^UIPresentationController *(UIViewController *presented, UIViewController *presenting) {
        FWPresentationController *presentationController = [[FWPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
        if (presentationBlock) presentationBlock(presentationController);
        return presentationController;
    };
    self.base.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransition = modalTransition;
    return modalTransition;
}

- (FWAnimatedTransition *)setAlertTransition:(void (^)(FWPresentationController *))presentationBlock
{
    FWTransformAnimatedTransition *modalTransition = [FWTransformAnimatedTransition transitionWithInTransform:CGAffineTransformMakeScale(1.1, 1.1) outTransform:CGAffineTransformIdentity];
    modalTransition.presentationBlock = ^UIPresentationController *(UIViewController *presented, UIViewController *presenting) {
        FWPresentationController *presentationController = [[FWPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
        if (presentationBlock) presentationBlock(presentationController);
        return presentationController;
    };
    self.base.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransition = modalTransition;
    return modalTransition;
}

- (FWAnimatedTransition *)setFadeTransition:(void (^)(FWPresentationController *))presentationBlock
{
    FWAnimatedTransition *modalTransition = [[FWAnimatedTransition alloc] init];
    modalTransition.presentationBlock = ^UIPresentationController *(UIViewController *presented, UIViewController *presenting) {
        FWPresentationController *presentationController = [[FWPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
        if (presentationBlock) presentationBlock(presentationController);
        return presentationController;
    };
    self.base.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransition = modalTransition;
    return modalTransition;
}

- (void (^)(void))presentationDidDismiss
{
    return objc_getAssociatedObject(self.base, @selector(presentationDidDismiss));
}

- (void)setPresentationDidDismiss:(void (^)(void))presentationDidDismiss
{
    objc_setAssociatedObject(self.base, @selector(presentationDidDismiss), presentationDidDismiss, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (@available(iOS 13.0, *)) {
        self.base.presentationController.delegate = [self presentationTarget];
    }
}

- (void)setPopoverPresentation:(void (NS_NOESCAPE ^)(UIPopoverPresentationController *))presentationBlock shouldDismiss:(BOOL)shouldDismiss
{
    self.base.modalPresentationStyle = UIModalPresentationPopover;
    [self presentationTarget].isPopover = YES;
    [self presentationTarget].shouldDismiss = shouldDismiss;
    self.base.popoverPresentationController.delegate = [self presentationTarget];
    if (self.base.popoverPresentationController && presentationBlock) {
        presentationBlock(self.base.popoverPresentationController);
    }
}

- (FWPresentationTarget *)presentationTarget
{
    FWPresentationTarget *target = objc_getAssociatedObject(self.base, _cmd);
    if (!target) {
        target = [[FWPresentationTarget alloc] init];
        objc_setAssociatedObject(self.base, _cmd, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return target;
}

@end

#pragma mark - FWViewWrapper+FWTransition

@implementation FWViewWrapper (FWTransition)

- (UIView *)transitionToController:(UIViewController *)viewController pinEdges:(BOOL)pinEdges
{
    UIView *containerView = nil;
    if (viewController.tabBarController && !viewController.tabBarController.tabBar.hidden) {
        containerView = viewController.tabBarController.view;
    } else if (viewController.navigationController && !viewController.navigationController.navigationBarHidden) {
        containerView = viewController.navigationController.view;
    } else {
        containerView = viewController.view;
    }
    [containerView addSubview:self.base];
    if (pinEdges) {
        [self.base.fw pinEdgesToSuperview];
        [containerView setNeedsLayout];
        [containerView layoutIfNeeded];
    }
    return containerView;
}

- (UIViewController *)wrappedTransitionController:(BOOL)pinEdges
{
    UIViewController *viewController = [[UIViewController alloc] init];
    [viewController.view addSubview:self.base];
    if (pinEdges) {
        [self.base.fw pinEdgesToSuperview];
        [viewController.view setNeedsLayout];
        [viewController.view layoutIfNeeded];
    }
    return viewController;
}

- (void)setPresentTransition:(FWAnimatedTransitionType)transitionType
                   contentView:(UIView *)contentView
                    completion:(void (^)(BOOL))completion
{
    BOOL transitionIn = (transitionType == FWAnimatedTransitionTypePush || transitionType == FWAnimatedTransitionTypePresent);
    if (transitionIn) {
        self.base.alpha = 0;
        contentView.transform = CGAffineTransformMakeTranslation(0, contentView.frame.size.height);
        [UIView animateWithDuration:0.25 animations:^{
            contentView.transform = CGAffineTransformIdentity;
            self.base.alpha = 1;
        } completion:^(BOOL finished) {
            if (completion) completion(finished);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            contentView.transform = CGAffineTransformMakeTranslation(0, contentView.frame.size.height);
            self.base.alpha = 0;
        } completion:^(BOOL finished) {
            contentView.transform = CGAffineTransformIdentity;
            [self.base removeFromSuperview];
            if (completion) completion(finished);
        }];
    }
}

- (void)setAlertTransition:(FWAnimatedTransitionType)transitionType
                  completion:(void (^)(BOOL))completion
{
    BOOL transitionIn = (transitionType == FWAnimatedTransitionTypePush || transitionType == FWAnimatedTransitionTypePresent);
    if (transitionIn) {
        self.base.alpha = 0;
        self.base.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [UIView animateWithDuration:0.25 animations:^{
            self.base.transform = CGAffineTransformIdentity;
            self.base.alpha = 1;
        } completion:^(BOOL finished) {
            if (completion) completion(finished);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.base.alpha = 0;
        } completion:^(BOOL finished) {
            [self.base removeFromSuperview];
            if (completion) completion(finished);
        }];
    }
}

- (void)setFadeTransition:(FWAnimatedTransitionType)transitionType
                 completion:(void (^)(BOOL))completion
{
    BOOL transitionIn = (transitionType == FWAnimatedTransitionTypePush || transitionType == FWAnimatedTransitionTypePresent);
    if (transitionIn) {
        self.base.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.base.alpha = 1;
        } completion:^(BOOL finished) {
            if (completion) completion(finished);
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.base.alpha = 0;
        } completion:^(BOOL finished) {
            [self.base removeFromSuperview];
            if (completion) completion(finished);
        }];
    }
}

@end

#pragma mark - FWNavigationControllerWrapper+FWTransition

@implementation FWNavigationControllerWrapper (FWTransition)

- (FWAnimatedTransition *)navigationTransition
{
    return objc_getAssociatedObject(self.base, @selector(navigationTransition));
}

- (void)setNavigationTransition:(FWAnimatedTransition *)navigationTransition
{
    // 设置delegate动画，nil时清理delegate动画，无需清理CA动画
    self.base.delegate = navigationTransition;
    // 强引用，防止被自动释放，nil时释放引用
    objc_setAssociatedObject(self.base, @selector(navigationTransition), navigationTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
