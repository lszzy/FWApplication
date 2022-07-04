/**
 @header     UIView+FWApplication.m
 @indexgroup FWApplication
      UIView+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "UIView+FWApplication.h"
#import "UIBezierPath+FWApplication.h"
#import <objc/runtime.h>

@implementation UIView (FWApplication)

#pragma mark - Transform

- (CGFloat)fw_scaleX
{
    return self.transform.a;
}

- (CGFloat)fw_scaleY
{
    return self.transform.d;
}

- (CGFloat)fw_translationX
{
    return self.transform.tx;
}

- (CGFloat)fw_translationY
{
    return self.transform.ty;
}

#pragma mark - Subview

- (void)fw_removeAllSubviews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIView *)fw_subviewOfClass:(Class)clazz
{
    return [self fw_subviewOfBlock:^BOOL(UIView *view) {
        return [view isKindOfClass:clazz];
    }];
}

- (UIView *)fw_subviewOfBlock:(BOOL (^)(UIView *view))block
{
    if (block(self)) {
        return self;
    }
    
    /* 如果需要顺序查找所有子视图，失败后再递归查找，参考此代码即可
    for (UIView *subview in self.subviews) {
        if (block(subview)) {
            return subview;
        }
    } */
    
    for (UIView *subview in self.subviews) {
        UIView *resultView = [subview fw_subviewOfBlock:block];
        if (resultView) {
            return resultView;
        }
    }
    
    return nil;
}

- (void)fw_moveToSuperview:(UIView *)view
{
    if (view) {
        [view addSubview:self];
    } else {
        [self removeFromSuperview];
    }
}

#pragma mark - Snapshot

- (UIImage *)fw_snapshotImage
{
    return [UIImage fw_imageWithView:self];
}

- (NSData *)fw_snapshotPdf
{
    CGRect bounds = self.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

#pragma mark - Drag

- (BOOL)fw_dragEnabled
{
    return self.fw_dragGesture.enabled;
}

- (void)setFw_dragEnabled:(BOOL)dragEnabled
{
    self.fw_dragGesture.enabled = dragEnabled;
}

- (CGRect)fw_dragLimit
{
    return [objc_getAssociatedObject(self, @selector(fw_dragLimit)) CGRectValue];
}

- (void)setFw_dragLimit:(CGRect)dragLimit
{
    if (CGRectEqualToRect(dragLimit, CGRectZero) ||
        CGRectContainsRect(dragLimit, self.frame)) {
        objc_setAssociatedObject(self, @selector(fw_dragLimit), [NSValue valueWithCGRect:dragLimit], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (CGRect)fw_dragArea
{
    return [objc_getAssociatedObject(self, @selector(fw_dragArea)) CGRectValue];
}

- (void)setFw_dragArea:(CGRect)dragArea
{
    CGRect relativeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (CGRectContainsRect(relativeFrame, dragArea)) {
        objc_setAssociatedObject(self, @selector(fw_dragArea), [NSValue valueWithCGRect:dragArea], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)fw_dragVertical
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(fw_dragVertical));
    return value ? [value boolValue] : YES;
}

- (void)setFw_dragVertical:(BOOL)dragVertical
{
    objc_setAssociatedObject(self, @selector(fw_dragVertical), [NSNumber numberWithBool:dragVertical], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fw_dragHorizontal
{
    NSNumber *value = objc_getAssociatedObject(self, @selector(fw_dragHorizontal));
    return value ? [value boolValue] : YES;
}

- (void)setFw_dragHorizontal:(BOOL)dragHorizontal
{
    objc_setAssociatedObject(self, @selector(fw_dragHorizontal), [NSNumber numberWithBool:dragHorizontal], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(UIView *))fw_dragStartedBlock
{
    return objc_getAssociatedObject(self, @selector(fw_dragStartedBlock));
}

- (void)setFw_dragStartedBlock:(void (^)(UIView *))dragStartedBlock
{
    objc_setAssociatedObject(self, @selector(fw_dragStartedBlock), dragStartedBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIView *))fw_dragMovedBlock
{
    return objc_getAssociatedObject(self, @selector(fw_dragMovedBlock));
}

- (void)setFw_dragMovedBlock:(void (^)(UIView *))dragMovedBlock
{
    objc_setAssociatedObject(self, @selector(fw_dragMovedBlock), dragMovedBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIView *))fw_dragEndedBlock
{
    return objc_getAssociatedObject(self, @selector(fw_dragEndedBlock));
}

- (void)setFw_dragEndedBlock:(void (^)(UIView *))dragEndedBlock
{
    objc_setAssociatedObject(self, @selector(fw_dragEndedBlock), dragEndedBlock, OBJC_ASSOCIATION_COPY);
}

- (UIPanGestureRecognizer *)fw_dragGesture
{
    UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self, _cmd);
    if (!gesture) {
        // 初始化拖动手势，默认禁用
        gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fw_innerDragHandler:)];
        gesture.maximumNumberOfTouches = 1;
        gesture.minimumNumberOfTouches = 1;
        gesture.cancelsTouchesInView = NO;
        gesture.enabled = NO;
        self.fw_dragArea = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addGestureRecognizer:gesture];
        
        objc_setAssociatedObject(self, _cmd, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gesture;
}

- (void)fw_innerDragHandler:(UIPanGestureRecognizer *)sender
{
    // 检查是否能够在拖动区域拖动
    CGPoint locationInView = [sender locationInView:self];
    if (!CGRectContainsPoint(self.fw_dragArea, locationInView) &&
        sender.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint locationInView = [sender locationInView:self];
        CGPoint locationInSuperview = [sender locationInView:self.superview];
        
        self.layer.anchorPoint = CGPointMake(locationInView.x / self.bounds.size.width, locationInView.y / self.bounds.size.height);
        self.center = locationInSuperview;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan && self.fw_dragStartedBlock) {
        self.fw_dragStartedBlock(self);
    }
    
    if (sender.state == UIGestureRecognizerStateChanged && self.fw_dragMovedBlock) {
        self.fw_dragMovedBlock(self);
    }
    
    if (sender.state == UIGestureRecognizerStateEnded && self.fw_dragEndedBlock) {
        self.fw_dragEndedBlock(self);
    }
    
    CGPoint translation = [sender translationInView:[self superview]];
    
    CGFloat newXOrigin = CGRectGetMinX(self.frame) + (([self fw_dragHorizontal]) ? translation.x : 0);
    CGFloat newYOrigin = CGRectGetMinY(self.frame) + (([self fw_dragVertical]) ? translation.y : 0);
    
    CGRect cagingArea = self.fw_dragLimit;
    
    CGFloat cagingAreaOriginX = CGRectGetMinX(cagingArea);
    CGFloat cagingAreaOriginY = CGRectGetMinY(cagingArea);
    
    CGFloat cagingAreaRightSide = cagingAreaOriginX + CGRectGetWidth(cagingArea);
    CGFloat cagingAreaBottomSide = cagingAreaOriginY + CGRectGetHeight(cagingArea);
    
    if (!CGRectEqualToRect(cagingArea, CGRectZero)) {
        // 确保视图在限制区域内
        if (newXOrigin <= cagingAreaOriginX ||
            newXOrigin + CGRectGetWidth(self.frame) >= cagingAreaRightSide) {
            newXOrigin = CGRectGetMinX(self.frame);
        }
        
        if (newYOrigin <= cagingAreaOriginY ||
            newYOrigin + CGRectGetHeight(self.frame) >= cagingAreaBottomSide) {
            newYOrigin = CGRectGetMinY(self.frame);
        }
    }
    
    [self setFrame:CGRectMake(newXOrigin,
                              newYOrigin,
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame))];
    
    [sender setTranslation:(CGPoint){0, 0} inView:[self superview]];
}

- (void)fw_innerAnimationDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context
{
    void (^completion)(BOOL finished) = objc_getAssociatedObject(self, @selector(fw_innerAnimationDidStop:finished:context:));
    if (completion) {
        completion([finished boolValue]);
    }
}

@end

#pragma mark - UIView+FWAnimation

@implementation UIView (FWAnimation)

#pragma mark - Animation

- (void)fw_addAnimationWithBlock:(void (^)(void))block
                     completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:(7<<16)
                     animations:block
                     completion:completion];
}

- (void)fw_addAnimationWithBlock:(void (^)(void))block
                       duration:(NSTimeInterval)duration
                     completion:(void (^)(BOOL finished))completion
{
    // 注意：AutoLayout动画需要调用父视图(如控制器self.view)的layoutIfNeeded更新布局才能生效
    [UIView animateWithDuration:duration
                     animations:block
                     completion:completion];
}

- (void)fw_addAnimationWithCurve:(UIViewAnimationCurve)curve
                     transition:(UIViewAnimationTransition)transition
                       duration:(NSTimeInterval)duration
                     completion:(void (^)(BOOL finished))completion
{
    [UIView beginAnimations:@"FWAnimation" context:NULL];
    [UIView setAnimationCurve:curve];
    // 默认值0.2
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:transition forView:self cache:NO];
    
    // 设置完成事件
    if (completion) {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(fw_innerAnimationDidStop:finished:context:)];
        objc_setAssociatedObject(self, @selector(fw_innerAnimationDidStop:finished:context:), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    [UIView commitAnimations];
}

- (CABasicAnimation *)fw_addAnimationWithKeyPath:(NSString *)keyPath
                                      fromValue:(id)fromValue
                                        toValue:(id)toValue
                                       duration:(CFTimeInterval)duration
                                     completion:(void (^)(BOOL))completion
{
    // keyPath支持值如下：
    // transform.rotation[.(x|y|z)]: 轴旋转动画
    // transform.scale[.(x|y|z)]: 轴缩放动画
    // transform.translation[.(x|y|z)]: 轴平移动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    // 默认值0.25
    animation.duration = duration;
    
    // 设置完成事件，需要在add之前设置才能生效，因为add时会copy动画对象
    if (completion) {
        animation.fw_stopBlock = ^(CAAnimation *animation, BOOL finished) {
            completion(finished);
        };
    }
    
    [self.layer addAnimation:animation forKey:@"FWAnimation"];
    return animation;
}

- (void)fw_addTransitionWithOption:(UIViewAnimationOptions)option
                            block:(void (^)(void))block
                         duration:(NSTimeInterval)duration
                       completion:(void (^)(BOOL finished))completion
{
    [UIView transitionWithView:self
                      duration:duration
                       options:option
                    animations:block
                    completion:completion];
}

- (void)fw_addTransitionWithOption:(UIViewAnimationOptions)option
                            block:(void (^)(void))block
                         duration:(NSTimeInterval)duration
                animationsEnabled:(BOOL)animationsEnabled
                       completion:(void (^)(BOOL finished))completion
{
    [UIView transitionWithView:self
                      duration:duration
                       options:option
                    animations:^{
                        BOOL wasEnabled = UIView.areAnimationsEnabled;
                        [UIView setAnimationsEnabled:animationsEnabled];
                        if (block) block();
                        [UIView setAnimationsEnabled:wasEnabled];
                    }
                    completion:completion];
}

- (void)fw_addTransitionToView:(UIView *)toView
                   withOption:(UIViewAnimationOptions)option
                     duration:(NSTimeInterval)duration
                   completion:(void (^)(BOOL finished))completion
{
    [UIView transitionFromView:self
                        toView:toView
                      duration:duration
                       options:option
                    completion:completion];
}

- (CATransition *)fw_addTransitionWithType:(NSString *)type
                                  subtype:(NSString *)subtype
                           timingFunction:(NSString *)timingFunction
                                 duration:(CFTimeInterval)duration
                               completion:(void (^)(BOOL finished))completion
{
    // 默认动画完成后自动移除，removedOnCompletion为YES
    CATransition *transition = [CATransition new];
    
    /** type
     *
     *  各种动画效果
     *  kCATransitionFade           交叉淡化过渡(不支持过渡方向)，同fade，默认效果
     *  kCATransitionMoveIn         新视图移到旧视图上面
     *  kCATransitionPush           新视图把旧视图推出去
     *  kCATransitionReveal         显露效果(将旧视图移开,显示下面的新视图)
     *
     *  @"fade"                     交叉淡化过渡(不支持过渡方向)，默认效果
     *  @"moveIn"                   新视图移到旧视图上面
     *  @"push"                     新视图把旧视图推出去
     *  @"reveal"                   显露效果(将旧视图移开,显示下面的新视图)
     *
     *  @"cube"                     立方体翻滚效果
     *  @"pageCurl"                 向上翻一页
     *  @"pageUnCurl"               向下翻一页
     *  @"suckEffect"               收缩效果，类似系统最小化窗口时的神奇效果(不支持过渡方向)
     *  @"rippleEffect"             滴水效果,(不支持过渡方向)
     *  @"oglFlip"                  上下左右翻转效果
     *  @"rotate"                   旋转效果
     *  @"cameraIrisHollowOpen"     相机镜头打开效果(不支持过渡方向)
     *  @"cameraIrisHollowClose"    相机镜头关上效果(不支持过渡方向)
     */
    transition.type = type;
    
    /** subtype
     *
     *  各种动画方向
     *
     *  kCATransitionFromRight;      同字面意思(下同)
     *  kCATransitionFromLeft;
     *  kCATransitionFromTop;
     *  kCATransitionFromBottom;
     *
     *  当type为@"rotate"(旋转)的时候,它也有几个对应的subtype,分别为:
     *  90cw    逆时针旋转90°
     *  90ccw   顺时针旋转90°
     *  180cw   逆时针旋转180°
     *  180ccw  顺时针旋转180°
      *
     *  type与subtype的对应关系(必看),如果对应错误,动画不会显现.
     *  http://iphonedevwiki.net/index.php/CATransition
     */
    if (subtype) transition.subtype = subtype;
    
    /** timingFunction
     *
     *  用于变化起点和终点之间的插值计算,形象点说它决定了动画运行的节奏,比如是均匀变化(相同时间变化量相同)还是
     *  先快后慢,先慢后快还是先慢再快再慢.
     *
     *  动画的开始与结束的快慢,有五个预置分别为(下同):
     *  kCAMediaTimingFunctionLinear            线性,即匀速
     *  kCAMediaTimingFunctionEaseIn            先慢后快
     *  kCAMediaTimingFunctionEaseOut           先快后慢
     *  kCAMediaTimingFunctionEaseInEaseOut     先慢后快再慢
     *  kCAMediaTimingFunctionDefault           实际效果是动画中间比较快.
      */
    if (timingFunction) transition.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
    
    // 动画持续时间，默认为0.25秒，传0即可
    transition.duration = duration;
    
    // 设置完成事件
    if (completion) {
        transition.fw_stopBlock = ^(CAAnimation *animation, BOOL finished) {
            completion(finished);
        };
    }
    
    // 所有核心动画和特效都是基于CAAnimation(作用于CALayer)
    [self.layer addAnimation:transition forKey:@"FWAnimation"];
    return transition;
}

- (void)fw_removeAnimation
{
    [self.layer removeAnimationForKey:@"FWAnimation"];
}

- (void)fw_removeAllAnimations
{
    [self.layer removeAllAnimations];
}

#pragma mark - Custom

- (CABasicAnimation *)fw_strokeWithLayer:(CAShapeLayer *)layer
                               duration:(NSTimeInterval)duration
                             completion:(void (^)(BOOL finished))completion
{
    // strokeEnd动画，仅CAShapeLayer支持
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = duration;
    animation.fromValue = [NSNumber numberWithFloat:0.0];
    animation.toValue = [NSNumber numberWithFloat:1.0];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = NO;
    
    // 设置完成事件
    if (completion) {
        animation.fw_stopBlock = ^(CAAnimation *animation, BOOL finished) {
            completion(finished);
        };
    }
    
    [layer addAnimation:animation forKey:@"FWAnimation"];
    return animation;
}

- (void)fw_shakeWithTimes:(NSInteger)times
                   delta:(CGFloat)delta
                duration:(NSTimeInterval)duration
              completion:(void (^)(BOOL finished))completion
{
    [self fw_shakeWithTimes:(times > 0 ? times : 10)
                     delta:(delta > 0 ? delta : 5)
                  duration:(duration > 0 ? duration : 0.03)
                 direction:1
              currentTimes:0
                completion:completion];
}

- (void)fw_shakeWithTimes:(NSInteger)times
                   delta:(CGFloat)delta
                duration:(NSTimeInterval)duration
               direction:(NSInteger)direction
            currentTimes:(NSInteger)currentTimes
              completion:(void (^)(BOOL finished))completion
{
    // 是否是文本输入框
    BOOL isTextField = [self isKindOfClass:[UITextField class]];
    
    [UIView animateWithDuration:duration animations:^{
        if (isTextField) {
            // 水平摇摆
            self.transform = CGAffineTransformMakeTranslation(delta * direction, 0);
            // 垂直摇摆
            // self.transform = CGAffineTransformMakeTranslation(0, delta * direction);
        } else {
            // 水平摇摆
            self.layer.affineTransform = CGAffineTransformMakeTranslation(delta * direction, 0);
            // 垂直摇摆
            // self.layer.affineTransform = CGAffineTransformMakeTranslation(0, delta * direction);
        }
    } completion:^(BOOL finished) {
        if (currentTimes >= times) {
            [UIView animateWithDuration:duration animations:^{
                if (isTextField) {
                    self.transform = CGAffineTransformIdentity;
                } else {
                    self.layer.affineTransform = CGAffineTransformIdentity;
                }
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
            return;
        }
        [self fw_shakeWithTimes:(times - 1)
                         delta:delta
                      duration:duration
                     direction:direction * -1
                  currentTimes:currentTimes + 1
                    completion:completion];
    }];
}

- (void)fw_fadeWithAlpha:(float)alpha
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.alpha = alpha;
                     }
                     completion:completion];
}

- (void)fw_fadeWithBlock:(void (^)(void))block
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL))completion
{
    [UIView transitionWithView:self
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                    animations:block
                    completion:completion];
}

- (void)fw_rotateWithDegree:(CGFloat)degree
                  duration:(NSTimeInterval)duration
                completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, (degree * M_PI / 180.f));
                     }
                     completion:completion];
}

- (void)fw_scaleWithScaleX:(float)scaleX
                   scaleY:(float)scaleY
                 duration:(NSTimeInterval)duration
               completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformScale(self.transform, scaleX, scaleY);
                     } completion:completion];
}

- (void)fw_moveWithPoint:(CGPoint)point
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
                     } completion:completion];
}

- (void)fw_moveWithFrame:(CGRect)frame
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.frame = frame;
                     } completion:completion];
}

#pragma mark - Block

+ (void)fw_animateNoneWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block
{
    [UIView performWithoutAnimation:block];
}

+ (void)fw_animateNoneWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block completion:(nullable __attribute__((noescape)) void (^)(void))completion
{
    [UIView animateWithDuration:0 animations:block completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

+ (void)fw_animateWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block completion:(nullable __attribute__((noescape)) void (^)(void))completion
{
    if (!block) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    block();
    [CATransaction commit];
}

@end

#pragma mark - FWGradientView

@implementation FWGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    self = [super init];
    if (self) {
        [self setColors:colors locations:locations startPoint:startPoint endPoint:endPoint];
    }
    return self;
}

- (void)setColors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [cgColors addObject:(__bridge id)color.CGColor];
    }
    self.gradientLayer.colors = [cgColors copy];
    self.gradientLayer.locations = locations;
    self.gradientLayer.startPoint = startPoint;
    self.gradientLayer.endPoint = endPoint;
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer *)self.layer;
}

- (NSArray *)colors
{
    return self.gradientLayer.colors;
}

- (void)setColors:(NSArray *)colors
{
    self.gradientLayer.colors = colors;
}

- (NSArray<NSNumber *> *)locations
{
    return self.gradientLayer.locations;
}

- (void)setLocations:(NSArray<NSNumber *> *)locations
{
    self.gradientLayer.locations = locations;
}

- (CGPoint)startPoint
{
    return self.gradientLayer.startPoint;
}

- (void)setStartPoint:(CGPoint)startPoint
{
    self.gradientLayer.startPoint = startPoint;
}

- (CGPoint)endPoint
{
    return self.gradientLayer.endPoint;
}

- (void)setEndPoint:(CGPoint)endPoint
{
    self.gradientLayer.endPoint = endPoint;
}

@end

#pragma mark - CALayer+FWLayer

@implementation CALayer (FWLayer)

- (void)fw_setShadowColor:(UIColor *)color
                  offset:(CGSize)offset
                  radius:(CGFloat)radius
{
    self.shadowColor = color.CGColor;
    self.shadowOffset = offset;
    self.shadowRadius = radius;
    self.shadowOpacity = 1.0;
}

@end

#pragma mark - CAGradientLayer+FWLayer

@implementation CAGradientLayer (FWLayer)

+ (CAGradientLayer *)fw_gradientLayer:(CGRect)frame
                              colors:(NSArray *)colors
                           locations:(NSArray<NSNumber *> *)locations
                          startPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    // 渐变区域
    gradientLayer.frame = frame;
    // CGColor颜色
    gradientLayer.colors = colors;
    // 颜色变化点，取值范围0~1
    gradientLayer.locations = locations;
    // 渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    return gradientLayer;
}

@end

#pragma mark - UIView+FWLayer

@implementation UIView (FWLayer)

#pragma mark - Effect

- (UIVisualEffectView *)fw_setBlurEffect:(UIBlurEffectStyle)style
{
    // 移除旧毛玻璃视图
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIVisualEffectView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    // 设置新毛玻璃效果，清空为-1
    if (((NSInteger)style) > -1) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self addSubview:effectView];
        [effectView fw_pinEdgesToSuperview];
        return effectView;
    }
    return nil;
}

#pragma mark - Bezier

- (void)fw_drawBezierPath:(UIBezierPath *)bezierPath
             strokeWidth:(CGFloat)strokeWidth
             strokeColor:(UIColor *)strokeColor
               fillColor:(UIColor *)fillColor
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, strokeWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    [strokeColor setStroke];
    CGContextAddPath(ctx, bezierPath.CGPath);
    CGContextStrokePath(ctx);
    
    if (fillColor) {
        [fillColor setFill];
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextFillPath(ctx);
    }
    
    CGContextRestoreGState(ctx);
}

#pragma mark - Gradient

- (void)fw_drawLinearGradient:(CGRect)rect
                      colors:(NSArray *)colors
                   locations:(const CGFloat *)locations
                   direction:(UISwipeGestureRecognizerDirection)direction
{
    NSArray<NSValue *> *linePoints = [UIBezierPath fw_linePointsWithRect:rect direction:direction];
    CGPoint startPoint = [linePoints.firstObject CGPointValue];
    CGPoint endPoint = [linePoints.lastObject CGPointValue];
    [self fw_drawLinearGradient:rect colors:colors locations:locations startPoint:startPoint endPoint:endPoint];
}

- (void)fw_drawLinearGradient:(CGRect)rect
                      colors:(NSArray *)colors
                   locations:(const CGFloat *)locations
                  startPoint:(CGPoint)startPoint
                    endPoint:(CGPoint)endPoint
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextAddRect(ctx, rect);
    CGContextClip(ctx);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextRestoreGState(ctx);
}

- (CAGradientLayer *)fw_addGradientLayer:(CGRect)frame
                                 colors:(NSArray *)colors
                              locations:(NSArray<NSNumber *> *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    // 渐变区域
    gradientLayer.frame = frame;
    // CGColor颜色
    gradientLayer.colors = colors;
    // 颜色变化点，取值范围0~1
    gradientLayer.locations = locations;
    // 渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    
    [self.layer addSublayer:gradientLayer];
    return gradientLayer;
}

#pragma mark - Circle

- (CAShapeLayer *)fw_addCircleLayer:(CGRect)rect
                            degree:(CGFloat)degree
                          progress:(CGFloat)progress
                       strokeColor:(UIColor *)strokeColor
                       strokeWidth:(CGFloat)strokeWidth
{
    // 创建背景圆环
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = rect;
    // 清空填充色
    layer.fillColor = [UIColor clearColor].CGColor;
    // 设置画笔颜色，即圆环背景色
    layer.strokeColor = strokeColor.CGColor;
    layer.lineWidth = strokeWidth;
    layer.lineCap = kCALineCapRound;
    
    // 设置画笔路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0)
                                                        radius:(rect.size.width / 2.0 - strokeWidth / 2.0)
                                                    startAngle:(degree) * M_PI / 180.f
                                                      endAngle:(degree + 360.f * progress) * M_PI / 180.f
                                                     clockwise:YES];
    // path决定layer将被渲染成何种形状
    layer.path = path.CGPath;
    
    [self.layer addSublayer:layer];
    return layer;
}

- (CAShapeLayer *)fw_addCircleLayer:(CGRect)rect
                            degree:(CGFloat)degree
                          progress:(CGFloat)progress
                     progressColor:(UIColor *)progressColor
                       strokeColor:(UIColor *)strokeColor
                       strokeWidth:(CGFloat)strokeWidth
{
    // 绘制底色圆
    [self fw_addCircleLayer:rect degree:degree progress:1.0 strokeColor:strokeColor strokeWidth:strokeWidth];
    
    // 绘制进度圆
    CAShapeLayer *layer = [self fw_addCircleLayer:rect degree:degree progress:progress strokeColor:progressColor strokeWidth:strokeWidth];
    return layer;
}

- (CALayer *)fw_addCircleLayer:(CGRect)rect
                       degree:(CGFloat)degree
                     progress:(CGFloat)progress
                gradientBlock:(void (^)(CALayer *layer))gradientBlock
                  strokeColor:(UIColor *)strokeColor
                  strokeWidth:(CGFloat)strokeWidth
{
    // 添加渐变容器层
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = rect;
    [self.layer addSublayer:gradientLayer];
    
    // 创建渐变子层，可单个渐变，左右区域，上下区域等
    if (gradientBlock) {
        gradientBlock(gradientLayer);
    }
    
    /*
    // 示例渐变
    CAGradientLayer *subLayer = [CAGradientLayer layer];
    subLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [subLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor redColor] CGColor],(id)[[UIColor blueColor] CGColor], nil]];
    [subLayer setLocations:@[@0, @1]];
    [subLayer setStartPoint:CGPointMake(0, 0)];
    [subLayer setEndPoint:CGPointMake(0, 1)];
    [gradientLayer addSublayer:subLayer];
    */
    
    // 创建遮罩frame，相对于父视图，所以从0开始
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    progressLayer.fillColor = [[UIColor clearColor] CGColor];
    progressLayer.strokeColor = strokeColor.CGColor;
    progressLayer.lineWidth = strokeWidth;
    progressLayer.lineCap = kCALineCapRound;
    
    // 设置贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0)
                                                        radius:(rect.size.width - strokeWidth) / 2.0
                                                    startAngle:(degree) * M_PI / 180.f
                                                      endAngle:(degree + 360.f * progress) * M_PI / 180.f
                                                     clockwise:YES];
    progressLayer.path = path.CGPath;
    
    // 用progressLayer来截取渐变层，从而实现圆形效果
    [gradientLayer setMask:progressLayer];

    // 可用mask实现strokeEnd动画
    return gradientLayer;
}

#pragma mark - Dash

- (CALayer *)fw_addDashLayer:(CGRect)rect
                 lineLength:(CGFloat)lineLength
                lineSpacing:(CGFloat)lineSpacing
                  lineColor:(UIColor *)lineColor
{
    CAShapeLayer *dashLayer = [CAShapeLayer layer];
    dashLayer.frame = rect;
    dashLayer.fillColor = [UIColor clearColor].CGColor;
    dashLayer.strokeColor = lineColor.CGColor;
    
    // 自动根据尺寸计算虚线方向
    BOOL isVertical = (lineLength + lineSpacing > rect.size.width) ? YES : NO;
    dashLayer.lineWidth = isVertical ? CGRectGetWidth(rect) : CGRectGetHeight(rect);
    dashLayer.lineJoin = kCALineJoinRound;
    dashLayer.lineDashPattern = @[@(lineLength), @(lineSpacing)];
    
    // 设置虚线路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (isVertical) {
        [path moveToPoint:CGPointMake(CGRectGetWidth(rect) / 2, 0)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect))];
    } else {
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(rect) / 2)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(rect), CGRectGetHeight(rect) / 2)];
    }
    dashLayer.path = path.CGPath;
    [self.layer addSublayer:dashLayer];
    return dashLayer;
}

@end

#pragma mark - UIView+FWDebugger

@implementation UIView (FWDebugger)

- (NSString *)fw_viewInfo {
    id viewInfo = [self fw_invokeGetter:@"recursiveDescription"];
    return [viewInfo isKindOfClass:[NSString class]] ? viewInfo : @"";
}

- (BOOL)fw_showDebugColor {
    return self.fw_innerShowDebugColor;
}

- (void)setFw_showDebugColor:(BOOL)showDebugColor {
    self.fw_innerShowDebugColor = showDebugColor;
}

- (BOOL)fw_randomDebugColor {
    return self.fw_innerRandomDebugColor;
}

- (void)setFw_randomDebugColor:(BOOL)randomDebugColor {
    self.fw_innerRandomDebugColor = randomDebugColor;
}

- (BOOL)fw_showDebugBorder {
    return self.fw_innerShowDebugBorder;
}

- (void)setFw_showDebugBorder:(BOOL)showDebugBorder {
    self.fw_innerShowDebugBorder = showDebugBorder;
}

- (UIColor *)fw_debugBorderColor {
    return self.fw_innerDebugBorderColor;
}

- (void)setFw_debugBorderColor:(UIColor *)debugBorderColor {
    self.fw_innerDebugBorderColor = debugBorderColor;
}

+ (void)fw_swizzleDebugColor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIView, @selector(layoutSubviews), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.fw_innerShowDebugColor) {
                selfObject.backgroundColor = [selfObject fw_debugColor];
                [selfObject fw_renderDebugColor:selfObject.subviews];
            } else if (objc_getAssociatedObject(selfObject, @selector(fw_innerShowDebugColor))) {
                selfObject.backgroundColor = nil;
                [selfObject fw_renderDebugColor:selfObject.subviews];
            }
        }));
    });
}

- (void)fw_updateDebugColor {
    if (self.fw_showDebugColor) {
        [UIView fw_swizzleDebugColor];
    }
    [self setNeedsLayout];
}

- (void)fw_renderDebugColor:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            [self fw_renderDebugColor:stackView.arrangedSubviews];
        }
        view.fw_showDebugColor = self.fw_showDebugColor;
        view.fw_randomDebugColor = self.fw_randomDebugColor;
        if (view.fw_showDebugColor) {
            view.backgroundColor = [view fw_debugColor];
        } else {
            view.backgroundColor = nil;
        }
    }
}

- (UIColor *)fw_debugColor {
    if (self.fw_randomDebugColor) {
        return [UIColor.fw_randomColor colorWithAlphaComponent:0.3];
    } else {
        return [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.3];
    }
}

+ (void)fw_swizzleDebugBorder {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIView, @selector(layoutSubviews), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.fw_innerShowDebugBorder) {
                selfObject.layer.borderWidth = FWPixelOne;
                selfObject.layer.borderColor = selfObject.fw_innerDebugBorderColor.CGColor;
                [selfObject fw_renderDebugBorder:selfObject.subviews];
            } else if (objc_getAssociatedObject(selfObject, @selector(fw_innerShowDebugBorder))) {
                selfObject.layer.borderWidth = 0;
                selfObject.layer.borderColor = nil;
                [selfObject fw_renderDebugBorder:selfObject.subviews];
            }
        }));
    });
}

- (void)fw_updateDebugBorder {
    if (self.fw_showDebugBorder) {
        [UIView fw_swizzleDebugBorder];
    }
    [self setNeedsLayout];
}

- (void)fw_renderDebugBorder:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            [self fw_renderDebugBorder:stackView.arrangedSubviews];
        }
        view.fw_showDebugBorder = self.fw_showDebugBorder;
        view.fw_debugBorderColor = self.fw_debugBorderColor;
        if (view.fw_showDebugBorder) {
            view.layer.borderWidth = FWPixelOne;
            view.layer.borderColor = view.fw_debugBorderColor.CGColor;
        } else {
            view.layer.borderWidth = 0;
            view.layer.borderColor = nil;
        }
    }
}

- (BOOL)fw_innerShowDebugColor {
    return [objc_getAssociatedObject(self, @selector(fw_innerShowDebugColor)) boolValue];
}

- (void)setFw_innerShowDebugColor:(BOOL)showDebugColor {
    objc_setAssociatedObject(self, @selector(fw_innerShowDebugColor), @(showDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self fw_updateDebugColor];
}

- (BOOL)fw_innerRandomDebugColor {
    return [objc_getAssociatedObject(self, @selector(fw_innerRandomDebugColor)) boolValue];
}

- (void)setFw_innerRandomDebugColor:(BOOL)randomDebugColor {
    objc_setAssociatedObject(self, @selector(fw_innerRandomDebugColor), @(randomDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fw_innerShowDebugBorder {
    return [objc_getAssociatedObject(self, @selector(fw_innerShowDebugBorder)) boolValue];
}

- (void)setFw_innerShowDebugBorder:(BOOL)showDebugBorder {
    objc_setAssociatedObject(self, @selector(fw_innerShowDebugBorder), @(showDebugBorder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self fw_updateDebugBorder];
}

- (UIColor *)fw_innerDebugBorderColor {
    UIColor *color = objc_getAssociatedObject(self, @selector(fw_innerDebugBorderColor));
    return color ?: [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.3];
}

- (void)setFw_innerDebugBorderColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(fw_innerDebugBorderColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
