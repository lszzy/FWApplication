/**
 @header     UIView+FWApplication.h
 @indexgroup FWApplication
      UIView+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 事件穿透实现方法：重写-hitTest:withEvent:方法，当为指定视图(如self)时返回nil排除即可
 */
@interface FWViewWrapper (FWApplication)

#pragma mark - Transform

// 获取当前view的transform scale x
@property (nonatomic, assign, readonly) CGFloat scaleX;

// 获取当前view的transform scale y
@property (nonatomic, assign, readonly) CGFloat scaleY;

// 获取当前view的transform translation x
@property (nonatomic, assign, readonly) CGFloat translationX;

// 获取当前view的transform translation y
@property (nonatomic, assign, readonly) CGFloat translationY;

#pragma mark - Subview

// 移除所有子视图
- (void)removeAllSubviews;

// 递归查找指定子类的第一个视图
- (nullable __kindof UIView *)subviewOfClass:(Class)clazz;

// 递归查找指定条件的第一个视图
- (nullable __kindof UIView *)subviewOfBlock:(BOOL (^)(UIView *view))block;

// 添加到父视图，nil时为从父视图移除
- (void)moveToSuperview:(nullable UIView *)view;

#pragma mark - Snapshot

// 图片截图
@property (nonatomic, readonly, nullable) UIImage *snapshotImage;

// Pdf截图
@property (nonatomic, readonly, nullable) NSData *snapshotPdf;

#pragma mark - Drag

// 是否启用拖动，默认NO
@property (nonatomic, assign) BOOL dragEnabled;

// 拖动手势，延迟加载
@property (nonatomic, readonly) UIPanGestureRecognizer *dragGesture;

// 设置拖动限制区域，默认CGRectZero，无限制
@property (nonatomic, assign) CGRect dragLimit;

// 设置拖动动作有效区域，默认self.frame
@property (nonatomic, assign) CGRect dragArea;

// 是否允许横向拖动(X)，默认YES
@property (nonatomic, assign) BOOL dragHorizontal;

// 是否允许纵向拖动(Y)，默认YES
@property (nonatomic, assign) BOOL dragVertical;

// 开始拖动回调
@property (nullable, nonatomic, copy) void (^dragStartedBlock)(UIView *);

// 拖动移动回调
@property (nullable, nonatomic, copy) void (^dragMovedBlock)(UIView *);

// 结束拖动回调
@property (nullable, nonatomic, copy) void (^dragEndedBlock)(UIView *);

@end

#pragma mark - FWViewWrapper+FWAnimation

@interface FWViewWrapper (FWAnimation)

#pragma mark - Animation

/**
 添加UIView动画，使用默认动画参数
 @note 如果动画过程中需要获取进度，可通过添加CADisplayLink访问self.layer.presentationLayer获取，下同
 
 @param block      动画代码块
 @param completion 完成事件
 */
- (void)addAnimationWithBlock:(void (^)(void))block
                     completion:(nullable void (^)(BOOL finished))completion;

/**
 添加UIView动画
 
 @param block      动画代码块
 @param duration   持续时间
 @param completion 完成事件
 */
- (void)addAnimationWithBlock:(void (^)(void))block
                       duration:(NSTimeInterval)duration
                     completion:(nullable void (^)(BOOL finished))completion;

/**
 添加UIView动画
 
 @param curve      动画速度
 @param transition 动画类型
 @param duration   持续时间，默认0.2
 @param completion 完成事件
 */
- (void)addAnimationWithCurve:(UIViewAnimationCurve)curve
                     transition:(UIViewAnimationTransition)transition
                       duration:(NSTimeInterval)duration
                     completion:(nullable void (^)(BOOL finished))completion;

/**
 添加CABasicAnimation动画
 
 @param keyPath    动画路径
 @param fromValue  开始值
 @param toValue    结束值
 @param duration   持续时间，0为默认(0.25秒)
 @param completion 完成事件
 @return CABasicAnimation
 */
- (CABasicAnimation *)addAnimationWithKeyPath:(NSString *)keyPath
                                      fromValue:(id)fromValue
                                        toValue:(id)toValue
                                       duration:(CFTimeInterval)duration
                                     completion:(nullable void (^)(BOOL finished))completion;

/**
 添加转场动画
 
 @param option     动画选项
 @param block      动画代码块
 @param duration   持续时间
 @param completion 完成事件
 */
- (void)addTransitionWithOption:(UIViewAnimationOptions)option
                            block:(void (^)(void))block
                         duration:(NSTimeInterval)duration
                       completion:(nullable void (^)(BOOL finished))completion;

/**
 添加转场动画，可指定animationsEnabled，一般用于window切换rootViewController
 
 @param option     动画选项
 @param block      动画代码块
 @param duration   持续时间
 @param animationsEnabled 是否启用动画
 @param completion 完成事件
 */
- (void)addTransitionWithOption:(UIViewAnimationOptions)option
                            block:(void (^)(void))block
                         duration:(NSTimeInterval)duration
                animationsEnabled:(BOOL)animationsEnabled
                       completion:(nullable void (^)(BOOL finished))completion;

/**
 添加转场动画
 
 @param toView     目标视图
 @param option     动画选项
 @param duration   持续时间
 @param completion 完成事件
 */
- (void)addTransitionToView:(UIView *)toView
                   withOption:(UIViewAnimationOptions)option
                     duration:(NSTimeInterval)duration
                   completion:(nullable void (^)(BOOL finished))completion;

/**
 添加CATransition转场动画
 备注：移除动画可调用[self fwRemoveAnimation]
 
 @param type           动画类型
 @param subtype        子类型
 @param timingFunction 动画速度
 @param duration       持续时间，0为默认(0.25秒)
 @param completion     完成事件
 @return CATransition
 */
- (CATransition *)addTransitionWithType:(NSString *)type
                                  subtype:(nullable NSString *)subtype
                           timingFunction:(nullable NSString *)timingFunction
                                 duration:(CFTimeInterval)duration
                               completion:(nullable void (^)(BOOL finished))completion;

/**
 移除单个框架视图动画
 */
- (void)removeAnimation;

/**
 移除所有视图动画
 */
- (void)removeAllAnimations;

#pragma mark - Custom

/**
 *  绘制动画
 *
 *  @param layer      CAShapeLayer层
 *  @param duration   持续时间
 *  @param completion 完成回调
 *  @return CABasicAnimation
 */
- (CABasicAnimation *)strokeWithLayer:(CAShapeLayer *)layer
                               duration:(NSTimeInterval)duration
                             completion:(nullable void (^)(BOOL finished))completion;

/**
 *  水平摇摆动画
 *
 *  @param times      摇摆次数，默认10
 *  @param delta      摇摆宽度，默认5
 *  @param duration   单次时间，默认0.03
 *  @param completion 完成回调
 */
- (void)shakeWithTimes:(int)times
                   delta:(CGFloat)delta
                duration:(NSTimeInterval)duration
              completion:(nullable void (^)(BOOL finished))completion;

/**
 *  渐显隐动画
 *
 *  @param alpha      透明度
 *  @param duration   持续时长
 *  @param completion 完成回调
 */
- (void)fadeWithAlpha:(float)alpha
               duration:(NSTimeInterval)duration
             completion:(nullable void (^)(BOOL finished))completion;

/**
 *  渐变代码块动画
 *
 *  @param block      动画代码块，比如调用imageView.setImage:方法
 *  @param duration   持续时长，建议0.5
 *  @param completion 完成回调
 */
- (void)fadeWithBlock:(void (^)(void))block
               duration:(NSTimeInterval)duration
             completion:(nullable void (^)(BOOL finished))completion;

/**
 *  旋转动画
 *
 *  @param degree     旋转度数，备注：逆时针需设置-179.99。使用CAAnimation无此问题
 *  @param duration   持续时长
 *  @param completion 完成回调
 */
- (void)rotateWithDegree:(CGFloat)degree
                  duration:(NSTimeInterval)duration
                completion:(nullable void (^)(BOOL finished))completion;

/**
 *  缩放动画
 *
 *  @param scaleX     X轴缩放率
 *  @param scaleY     Y轴缩放率
 *  @param duration   持续时长
 *  @param completion 完成回调
 */
- (void)scaleWithScaleX:(float)scaleX
                   scaleY:(float)scaleY
                 duration:(NSTimeInterval)duration
               completion:(nullable void (^)(BOOL finished))completion;

/**
 *  移动动画
 *
 *  @param point      目标点
 *  @param duration   持续时长
 *  @param completion 完成回调
 */
- (void)moveWithPoint:(CGPoint)point
               duration:(NSTimeInterval)duration
             completion:(nullable void (^)(BOOL finished))completion;

/**
 *  移动变化动画
 *
 *  @param frame      目标区域
 *  @param duration   持续时长
 *  @param completion 完成回调
 */
- (void)moveWithFrame:(CGRect)frame
               duration:(NSTimeInterval)duration
             completion:(nullable void (^)(BOOL finished))completion;

@end

@interface FWViewClassWrapper (FWAnimation)

#pragma mark - Block

/**
 取消动画效果执行block
 
 @param block 动画代码块
 */
- (void)animateNoneWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block;

/**
 取消动画效果执行block
 
 @param block 动画代码块
 @param completion 完成事件
 */
- (void)animateNoneWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block completion:(nullable __attribute__((noescape)) void (^)(void))completion;

/**
 执行block动画完成后执行指定回调
 
 @param block 动画代码块
 @param completion 完成事件
 */
- (void)animateWithBlock:(nonnull __attribute__((noescape)) void (^)(void))block completion:(nullable __attribute__((noescape)) void (^)(void))completion;

@end

#pragma mark - FWGradientView

/**
 渐变View，无需设置渐变Layer的frame等，支持自动布局
 */
@interface FWGradientView : UIView

@property (nonatomic, strong, readonly) CAGradientLayer *gradientLayer;

@property (nullable, copy) NSArray *colors;

@property (nullable, copy) NSArray<NSNumber *> *locations;

@property CGPoint startPoint;

@property CGPoint endPoint;

- (instancetype)initWithColors:(nullable NSArray<UIColor *> *)colors locations:(nullable NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (void)setColors:(nullable NSArray<UIColor *> *)colors locations:(nullable NSArray<NSNumber *> *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

@end

#pragma mark - FWLayerWrapper+FWLayer

@interface FWLayerWrapper (FWLayer)

// 设置阴影颜色、偏移和半径
- (void)setShadowColor:(nullable UIColor *)color
                  offset:(CGSize)offset
                  radius:(CGFloat)radius;

@end

#pragma mark - FWGradientLayerClassWrapper+FWLayer

@interface FWGradientLayerClassWrapper (FWLayer)

/**
 *  创建渐变层，需手工addLayer
 *
 *  @param frame      渐变区域
 *  @param colors     渐变颜色，CGColor数组，如[黑，白，黑]
 *  @param locations  渐变位置，0~1，如[0.25, 0.5, 0.75]对应颜色为[0-0.25黑,0.25-0.5黑渐变白,0.5-0.75白渐变黑,0.75-1黑]
 *  @param startPoint 渐变开始点，设置渐变方向，左上点为(0,0)，右下点为(1,1)
 *  @param endPoint   渐变结束点
 *  @return 渐变Layer
 */
- (CAGradientLayer *)gradientLayer:(CGRect)frame
                              colors:(NSArray *)colors
                           locations:(nullable NSArray<NSNumber *> *)locations
                          startPoint:(CGPoint)startPoint
                            endPoint:(CGPoint)endPoint;

@end

#pragma mark - FWViewWrapper+FWLayer

@interface FWViewWrapper (FWLayer)

#pragma mark - Effect

/**
 *  设置毛玻璃效果，使用UIVisualEffectView。内容需要添加到UIVisualEffectView.contentView
 *
 *  @param style 毛玻璃效果样式
 */
- (nullable UIVisualEffectView *)setBlurEffect:(UIBlurEffectStyle)style;

#pragma mark - Bezier

/**
 绘制形状路径，需要在drawRect中调用
 
 @param bezierPath 绘制路径
 @param strokeWidth 绘制宽度
 @param strokeColor 绘制颜色
 @param fillColor 填充颜色
 */
- (void)drawBezierPath:(UIBezierPath *)bezierPath
             strokeWidth:(CGFloat)strokeWidth
             strokeColor:(UIColor *)strokeColor
               fillColor:(nullable UIColor *)fillColor;

#pragma mark - Gradient

/**
 绘制渐变颜色，需要在drawRect中调用，支持四个方向，默认向下Down
 
 @param rect 绘制区域
 @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
 @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
 @param direction 渐变方向，自动计算startPoint和endPoint，支持四个方向，默认向下Down
 */
- (void)drawLinearGradient:(CGRect)rect
                      colors:(NSArray *)colors
                   locations:(nullable const CGFloat *)locations
                   direction:(UISwipeGestureRecognizerDirection)direction;

/**
 绘制渐变颜色，需要在drawRect中调用
 
 @param rect 绘制区域
 @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
 @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
 @param startPoint 渐变开始点，需要根据rect计算
 @param endPoint 渐变结束点，需要根据rect计算
 */
- (void)drawLinearGradient:(CGRect)rect
                      colors:(NSArray *)colors
                   locations:(nullable const CGFloat *)locations
                  startPoint:(CGPoint)startPoint
                    endPoint:(CGPoint)endPoint;

/**
 *  添加渐变Layer
 *
 *  @param frame      渐变区域
 *  @param colors     渐变颜色，CGColor数组，如[黑，白，黑]
 *  @param locations  渐变位置，0~1，如[0.25, 0.5, 0.75]对应颜色为[0-0.25黑,0.25-0.5黑渐变白,0.5-0.75白渐变黑,0.75-1黑]
 *  @param startPoint 渐变开始点，设置渐变方向，左上点为(0,0)，右下点为(1,1)
 *  @param endPoint   渐变结束点
 *  @return 渐变Layer
 */
- (CAGradientLayer *)addGradientLayer:(CGRect)frame
                                 colors:(NSArray *)colors
                              locations:(nullable NSArray<NSNumber *> *)locations
                             startPoint:(CGPoint)startPoint
                               endPoint:(CGPoint)endPoint;

#pragma mark - Circle

// 添加进度圆形Layer，可设置绘制颜色和宽度，返回进度CAShapeLayer用于动画，degree为起始角度，如-90
- (CAShapeLayer *)addCircleLayer:(CGRect)rect
                            degree:(CGFloat)degree
                          progress:(CGFloat)progress
                       strokeColor:(UIColor *)strokeColor
                       strokeWidth:(CGFloat)strokeWidth;

// 添加进度圆形Layer，可设置绘制底色和进度颜色，返回进度CAShapeLayer用于动画，degree为起始角度，如-90
- (CAShapeLayer *)addCircleLayer:(CGRect)rect
                            degree:(CGFloat)degree
                          progress:(CGFloat)progress
                     progressColor:(UIColor *)progressColor
                       strokeColor:(UIColor *)strokeColor
                       strokeWidth:(CGFloat)strokeWidth;

// 添加渐变进度圆形Layer，返回渐变Layer容器，添加strokeEnd动画请使用layer.mask即可
- (CALayer *)addCircleLayer:(CGRect)rect
                       degree:(CGFloat)degree
                     progress:(CGFloat)progress
                gradientBlock:(nullable void (^)(CALayer *layer))gradientBlock
                  strokeColor:(UIColor *)strokeColor
                  strokeWidth:(CGFloat)strokeWidth;

#pragma mark - Dash

/**
 添加虚线Layer
 
 @param rect 虚线区域，从中心绘制
 @param lineLength 虚线的宽度
 @param lineSpacing 虚线的间距
 @param lineColor 虚线的颜色
 @return 虚线Layer
 */
- (CALayer *)addDashLayer:(CGRect)rect
                 lineLength:(CGFloat)lineLength
                lineSpacing:(CGFloat)lineSpacing
                  lineColor:(UIColor *)lineColor;

@end

NS_ASSUME_NONNULL_END
