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

@interface UIView (FWApplication)

@end

@implementation UIView (FWApplication)

- (void)innerDragHandler:(UIPanGestureRecognizer *)sender
{
    // 检查是否能够在拖动区域拖动
    CGPoint locationInView = [sender locationInView:self];
    if (!CGRectContainsPoint(self.fw.dragArea, locationInView) &&
        sender.state == UIGestureRecognizerStateBegan) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint locationInView = [sender locationInView:self];
        CGPoint locationInSuperview = [sender locationInView:self.superview];
        
        self.layer.anchorPoint = CGPointMake(locationInView.x / self.bounds.size.width, locationInView.y / self.bounds.size.height);
        self.center = locationInSuperview;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan && self.fw.dragStartedBlock) {
        self.fw.dragStartedBlock(self);
    }
    
    if (sender.state == UIGestureRecognizerStateChanged && self.fw.dragMovedBlock) {
        self.fw.dragMovedBlock(self);
    }
    
    if (sender.state == UIGestureRecognizerStateEnded && self.fw.dragEndedBlock) {
        self.fw.dragEndedBlock(self);
    }
    
    CGPoint translation = [sender translationInView:[self superview]];
    
    CGFloat newXOrigin = CGRectGetMinX(self.frame) + (([self.fw dragHorizontal]) ? translation.x : 0);
    CGFloat newYOrigin = CGRectGetMinY(self.frame) + (([self.fw dragVertical]) ? translation.y : 0);
    
    CGRect cagingArea = self.fw.dragLimit;
    
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

- (void)innerAnimationDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context
{
    void (^completion)(BOOL finished) = objc_getAssociatedObject(self, @selector(innerAnimationDidStop:finished:context:));
    if (completion) {
        completion([finished boolValue]);
    }
}

@end

@implementation FWViewWrapper (FWApplication)

#pragma mark - Transform

- (CGFloat)scaleX
{
    return self.base.transform.a;
}

- (CGFloat)scaleY
{
    return self.base.transform.d;
}

- (CGFloat)translationX
{
    return self.base.transform.tx;
}

- (CGFloat)translationY
{
    return self.base.transform.ty;
}

#pragma mark - Subview

- (void)removeAllSubviews
{
    [self.base.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIView *)subviewOfClass:(Class)clazz
{
    return [self subviewOfBlock:^BOOL(UIView *view) {
        return [view isKindOfClass:clazz];
    }];
}

- (UIView *)subviewOfBlock:(BOOL (^)(UIView *view))block
{
    if (block(self.base)) {
        return self.base;
    }
    
    /* 如果需要顺序查找所有子视图，失败后再递归查找，参考此代码即可
    for (UIView *subview in self.base.subviews) {
        if (block(subview)) {
            return subview;
        }
    } */
    
    for (UIView *subview in self.base.subviews) {
        UIView *resultView = [subview.fw subviewOfBlock:block];
        if (resultView) {
            return resultView;
        }
    }
    
    return nil;
}

- (void)moveToSuperview:(UIView *)view
{
    if (view) {
        [view addSubview:self.base];
    } else {
        [self.base removeFromSuperview];
    }
}

#pragma mark - Snapshot

- (UIImage *)snapshotImage
{
    return [UIImage.fw imageWithView:self.base];
}

- (NSData *)snapshotPdf
{
    CGRect bounds = self.base.bounds;
    NSMutableData *data = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.base.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

#pragma mark - Drag

- (BOOL)dragEnabled
{
    return self.dragGesture.enabled;
}

- (void)setDragEnabled:(BOOL)dragEnabled
{
    self.dragGesture.enabled = dragEnabled;
}

- (CGRect)dragLimit
{
    return [objc_getAssociatedObject(self.base, @selector(dragLimit)) CGRectValue];
}

- (void)setDragLimit:(CGRect)dragLimit
{
    if (CGRectEqualToRect(dragLimit, CGRectZero) ||
        CGRectContainsRect(dragLimit, self.base.frame)) {
        objc_setAssociatedObject(self.base, @selector(dragLimit), [NSValue valueWithCGRect:dragLimit], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (CGRect)dragArea
{
    return [objc_getAssociatedObject(self.base, @selector(dragArea)) CGRectValue];
}

- (void)setDragArea:(CGRect)dragArea
{
    CGRect relativeFrame = CGRectMake(0, 0, self.base.frame.size.width, self.base.frame.size.height);
    if (CGRectContainsRect(relativeFrame, dragArea)) {
        objc_setAssociatedObject(self.base, @selector(dragArea), [NSValue valueWithCGRect:dragArea], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)dragVertical
{
    NSNumber *value = objc_getAssociatedObject(self.base, @selector(dragVertical));
    return value ? [value boolValue] : YES;
}

- (void)setDragVertical:(BOOL)dragVertical
{
    objc_setAssociatedObject(self.base, @selector(dragVertical), [NSNumber numberWithBool:dragVertical], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dragHorizontal
{
    NSNumber *value = objc_getAssociatedObject(self.base, @selector(dragHorizontal));
    return value ? [value boolValue] : YES;
}

- (void)setDragHorizontal:(BOOL)dragHorizontal
{
    objc_setAssociatedObject(self.base, @selector(dragHorizontal), [NSNumber numberWithBool:dragHorizontal], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void (^)(UIView *))dragStartedBlock
{
    return objc_getAssociatedObject(self.base, @selector(dragStartedBlock));
}

- (void)setDragStartedBlock:(void (^)(UIView *))dragStartedBlock
{
    objc_setAssociatedObject(self.base, @selector(dragStartedBlock), dragStartedBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIView *))dragMovedBlock
{
    return objc_getAssociatedObject(self.base, @selector(dragMovedBlock));
}

- (void)setDragMovedBlock:(void (^)(UIView *))dragMovedBlock
{
    objc_setAssociatedObject(self.base, @selector(dragMovedBlock), dragMovedBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)(UIView *))dragEndedBlock
{
    return objc_getAssociatedObject(self.base, @selector(dragEndedBlock));
}

- (void)setDragEndedBlock:(void (^)(UIView *))dragEndedBlock
{
    objc_setAssociatedObject(self.base, @selector(dragEndedBlock), dragEndedBlock, OBJC_ASSOCIATION_COPY);
}

- (UIPanGestureRecognizer *)dragGesture
{
    UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self.base, _cmd);
    if (!gesture) {
        // 初始化拖动手势，默认禁用
        gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.base action:@selector(innerDragHandler:)];
        gesture.maximumNumberOfTouches = 1;
        gesture.minimumNumberOfTouches = 1;
        gesture.cancelsTouchesInView = NO;
        gesture.enabled = NO;
        self.dragArea = CGRectMake(0, 0, self.base.frame.size.width, self.base.frame.size.height);
        [self.base addGestureRecognizer:gesture];
        
        objc_setAssociatedObject(self.base, _cmd, gesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gesture;
}

@end

#pragma mark - FWViewWrapper+FWAnimation

@implementation FWViewWrapper (FWAnimation)

#pragma mark - Animation

- (void)addAnimationWithBlock:(void (^)(void))block
                     completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:0.25
                          delay:0
                        options:(7<<16)
                     animations:block
                     completion:completion];
}

- (void)addAnimationWithBlock:(void (^)(void))block
                       duration:(NSTimeInterval)duration
                     completion:(void (^)(BOOL finished))completion
{
    // 注意：AutoLayout动画需要调用父视图(如控制器self.view)的layoutIfNeeded更新布局才能生效
    [UIView animateWithDuration:duration
                     animations:block
                     completion:completion];
}

- (void)addAnimationWithCurve:(UIViewAnimationCurve)curve
                     transition:(UIViewAnimationTransition)transition
                       duration:(NSTimeInterval)duration
                     completion:(void (^)(BOOL finished))completion
{
    [UIView beginAnimations:@"FWAnimation" context:NULL];
    [UIView setAnimationCurve:curve];
    // 默认值0.2
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:transition forView:self.base cache:NO];
    
    // 设置完成事件
    if (completion) {
        [UIView setAnimationDelegate:self.base];
        [UIView setAnimationDidStopSelector:@selector(innerAnimationDidStop:finished:context:)];
        objc_setAssociatedObject(self.base, @selector(innerAnimationDidStop:finished:context:), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    [UIView commitAnimations];
}

- (CABasicAnimation *)addAnimationWithKeyPath:(NSString *)keyPath
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
        animation.fw.stopBlock = ^(CAAnimation *animation, BOOL finished) {
            completion(finished);
        };
    }
    
    [self.base.layer addAnimation:animation forKey:@"FWAnimation"];
    return animation;
}

- (void)addTransitionWithOption:(UIViewAnimationOptions)option
                            block:(void (^)(void))block
                         duration:(NSTimeInterval)duration
                       completion:(void (^)(BOOL finished))completion
{
    [UIView transitionWithView:self.base
                      duration:duration
                       options:option
                    animations:block
                    completion:completion];
}

- (void)addTransitionWithOption:(UIViewAnimationOptions)option
                            block:(void (^)(void))block
                         duration:(NSTimeInterval)duration
                animationsEnabled:(BOOL)animationsEnabled
                       completion:(void (^)(BOOL finished))completion
{
    [UIView transitionWithView:self.base
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

- (void)addTransitionToView:(UIView *)toView
                   withOption:(UIViewAnimationOptions)option
                     duration:(NSTimeInterval)duration
                   completion:(void (^)(BOOL finished))completion
{
    [UIView transitionFromView:self.base
                        toView:toView
                      duration:duration
                       options:option
                    completion:completion];
}

- (CATransition *)addTransitionWithType:(NSString *)type
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
        transition.fw.stopBlock = ^(CAAnimation *animation, BOOL finished) {
            completion(finished);
        };
    }
    
    // 所有核心动画和特效都是基于CAAnimation(作用于CALayer)
    [self.base.layer addAnimation:transition forKey:@"FWAnimation"];
    return transition;
}

- (void)removeAnimation
{
    [self.base.layer removeAnimationForKey:@"FWAnimation"];
}

- (void)removeAllAnimations
{
    [self.base.layer removeAllAnimations];
}

#pragma mark - Custom

- (CABasicAnimation *)strokeWithLayer:(CAShapeLayer *)layer
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
        animation.fw.stopBlock = ^(CAAnimation *animation, BOOL finished) {
            completion(finished);
        };
    }
    
    [layer addAnimation:animation forKey:@"FWAnimation"];
    return animation;
}

- (void)shakeWithTimes:(int)times
                   delta:(CGFloat)delta
                duration:(NSTimeInterval)duration
              completion:(void (^)(BOOL finished))completion
{
    [self shakeWithTimes:(times > 0 ? times : 10)
                     delta:(delta > 0 ? delta : 5)
                  duration:(duration > 0 ? duration : 0.03)
                 direction:1
              currentTimes:0
                completion:completion];
}

- (void)shakeWithTimes:(int)times
                   delta:(CGFloat)delta
                duration:(NSTimeInterval)duration
               direction:(NSInteger)direction
            currentTimes:(int)currentTimes
              completion:(void (^)(BOOL finished))completion
{
    // 是否是文本输入框
    BOOL isTextField = [self.base isKindOfClass:[UITextField class]];
    
    [UIView animateWithDuration:duration animations:^{
        if (isTextField) {
            // 水平摇摆
            self.base.transform = CGAffineTransformMakeTranslation(delta * direction, 0);
            // 垂直摇摆
            // self.base.transform = CGAffineTransformMakeTranslation(0, delta * direction);
        } else {
            // 水平摇摆
            self.base.layer.affineTransform = CGAffineTransformMakeTranslation(delta * direction, 0);
            // 垂直摇摆
            // self.base.layer.affineTransform = CGAffineTransformMakeTranslation(0, delta * direction);
        }
    } completion:^(BOOL finished) {
        if (currentTimes >= times) {
            [UIView animateWithDuration:duration animations:^{
                if (isTextField) {
                    self.base.transform = CGAffineTransformIdentity;
                } else {
                    self.base.layer.affineTransform = CGAffineTransformIdentity;
                }
            } completion:^(BOOL finished) {
                if (completion) {
                    completion(finished);
                }
            }];
            return;
        }
        [self shakeWithTimes:(times - 1)
                         delta:delta
                      duration:duration
                     direction:direction * -1
                  currentTimes:currentTimes + 1
                    completion:completion];
    }];
}

- (void)fadeWithAlpha:(float)alpha
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.base.alpha = alpha;
                     }
                     completion:completion];
}

- (void)fadeWithBlock:(void (^)(void))block
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL))completion
{
    [UIView transitionWithView:self.base
                      duration:duration
                       options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction
                    animations:block
                    completion:completion];
}

- (void)rotateWithDegree:(CGFloat)degree
                  duration:(NSTimeInterval)duration
                completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.base.transform = CGAffineTransformRotate(self.base.transform, (degree * M_PI / 180.f));
                     }
                     completion:completion];
}

- (void)scaleWithScaleX:(float)scaleX
                   scaleY:(float)scaleY
                 duration:(NSTimeInterval)duration
               completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.base.transform = CGAffineTransformScale(self.base.transform, scaleX, scaleY);
                     } completion:completion];
}

- (void)moveWithPoint:(CGPoint)point
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.base.frame = CGRectMake(point.x, point.y, self.base.frame.size.width, self.base.frame.size.height);
                     } completion:completion];
}

- (void)moveWithFrame:(CGRect)frame
               duration:(NSTimeInterval)duration
             completion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.base.frame = frame;
                     } completion:completion];
}

@end

@implementation FWViewClassWrapper (FWAnimation)

#pragma mark - Block

- (void)animateNoneWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block
{
    [UIView performWithoutAnimation:block];
}

- (void)animateNoneWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block completion:(nullable __attribute__((noescape)) void (^)(void))completion
{
    [UIView animateWithDuration:0 animations:block completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)animateWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block completion:(nullable __attribute__((noescape)) void (^)(void))completion
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

#pragma mark - FWLayerWrapper+FWLayer

@implementation FWLayerWrapper (FWLayer)

- (void)setShadowColor:(UIColor *)color
                  offset:(CGSize)offset
                  radius:(CGFloat)radius
{
    self.base.shadowColor = color.CGColor;
    self.base.shadowOffset = offset;
    self.base.shadowRadius = radius;
    self.base.shadowOpacity = 1.0;
}

@end

#pragma mark - FWGradientLayerClassWrapper+FWLayer

@implementation FWGradientLayerClassWrapper (FWLayer)

- (CAGradientLayer *)gradientLayer:(CGRect)frame
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

#pragma mark - FWViewWrapper+FWLayer

@implementation FWViewWrapper (FWLayer)

#pragma mark - Effect

- (UIVisualEffectView *)setBlurEffect:(UIBlurEffectStyle)style
{
    // 移除旧毛玻璃视图
    for (UIView *subview in self.base.subviews) {
        if ([subview isKindOfClass:[UIVisualEffectView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    // 设置新毛玻璃效果，清空为-1
    if (((NSInteger)style) > -1) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        [self.base addSubview:effectView];
        [effectView.fw pinEdgesToSuperview];
        return effectView;
    }
    return nil;
}

#pragma mark - Bezier

- (void)drawBezierPath:(UIBezierPath *)bezierPath
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

- (void)drawLinearGradient:(CGRect)rect
                      colors:(NSArray *)colors
                   locations:(const CGFloat *)locations
                   direction:(UISwipeGestureRecognizerDirection)direction
{
    NSArray<NSValue *> *linePoints = [UIBezierPath.fw linePointsWithRect:rect direction:direction];
    CGPoint startPoint = [linePoints.firstObject CGPointValue];
    CGPoint endPoint = [linePoints.lastObject CGPointValue];
    [self drawLinearGradient:rect colors:colors locations:locations startPoint:startPoint endPoint:endPoint];
}

- (void)drawLinearGradient:(CGRect)rect
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

- (CAGradientLayer *)addGradientLayer:(CGRect)frame
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
    
    [self.base.layer addSublayer:gradientLayer];
    return gradientLayer;
}

#pragma mark - Circle

- (CAShapeLayer *)addCircleLayer:(CGRect)rect
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
    
    [self.base.layer addSublayer:layer];
    return layer;
}

- (CAShapeLayer *)addCircleLayer:(CGRect)rect
                            degree:(CGFloat)degree
                          progress:(CGFloat)progress
                     progressColor:(UIColor *)progressColor
                       strokeColor:(UIColor *)strokeColor
                       strokeWidth:(CGFloat)strokeWidth
{
    // 绘制底色圆
    [self addCircleLayer:rect degree:degree progress:1.0 strokeColor:strokeColor strokeWidth:strokeWidth];
    
    // 绘制进度圆
    CAShapeLayer *layer = [self addCircleLayer:rect degree:degree progress:progress strokeColor:progressColor strokeWidth:strokeWidth];
    return layer;
}

- (CALayer *)addCircleLayer:(CGRect)rect
                       degree:(CGFloat)degree
                     progress:(CGFloat)progress
                gradientBlock:(void (^)(CALayer *layer))gradientBlock
                  strokeColor:(UIColor *)strokeColor
                  strokeWidth:(CGFloat)strokeWidth
{
    // 添加渐变容器层
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = rect;
    [self.base.layer addSublayer:gradientLayer];
    
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

- (CALayer *)addDashLayer:(CGRect)rect
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
    [self.base.layer addSublayer:dashLayer];
    return dashLayer;
}

@end
