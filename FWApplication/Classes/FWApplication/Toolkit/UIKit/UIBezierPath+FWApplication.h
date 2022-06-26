/**
 @header     UIBezierPath+FWApplication.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (FWApplication)

// 绘制形状图片，自定义画笔宽度、画笔颜色、填充颜色，填充颜色为nil时不执行填充
- (nullable UIImage *)fw_shapeImage:(CGSize)size
                     strokeWidth:(CGFloat)strokeWidth
                     strokeColor:(UIColor *)strokeColor
                       fillColor:(nullable UIColor *)fillColor NS_REFINED_FOR_SWIFT;

// 绘制形状Layer，自定义画笔宽度、画笔颜色、填充颜色，填充颜色为nil时不执行填充
- (CAShapeLayer *)fw_shapeLayer:(CGRect)rect
                 strokeWidth:(CGFloat)strokeWidth
                 strokeColor:(UIColor *)strokeColor
                   fillColor:(nullable UIColor *)fillColor NS_REFINED_FOR_SWIFT;

#pragma mark - Bezier

// 根据点计算折线路径(NSValue点)
+ (UIBezierPath *)fw_linesWithPoints:(NSArray *)points NS_REFINED_FOR_SWIFT;

// 根据点计算贝塞尔曲线路径
+ (UIBezierPath *)fw_quadCurvedPathWithPoints:(NSArray *)points NS_REFINED_FOR_SWIFT;

// 计算两点的中心点
+ (CGPoint)fw_middlePoint:(CGPoint)p1 withPoint:(CGPoint)p2 NS_REFINED_FOR_SWIFT;

// 计算两点的贝塞尔曲线控制点
+ (CGPoint)fw_controlPoint:(CGPoint)p1 withPoint:(CGPoint)p2 NS_REFINED_FOR_SWIFT;

// 将角度(0~360)转换为弧度，周长为2*M_PI*r
+ (CGFloat)fw_radianWithDegree:(CGFloat)degree NS_REFINED_FOR_SWIFT;

// 将弧度转换为角度(0~360)
+ (CGFloat)fw_degreeWithRadian:(CGFloat)radian NS_REFINED_FOR_SWIFT;

// 根据滑动方向计算rect的线段起点、终点中心点坐标数组(示范：田)。默认从上到下滑动
+ (NSArray<NSValue *> *)fw_linePointsWithRect:(CGRect)rect direction:(UISwipeGestureRecognizerDirection)direction NS_REFINED_FOR_SWIFT;

#pragma mark - Shape

// "🔴" 圆的形状，0~1，degree为起始角度，如-90度
+ (UIBezierPath *)fw_shapeCircle:(CGRect)frame percent:(float)percent degree:(CGFloat)degree NS_REFINED_FOR_SWIFT;

// "❤️" 心的形状
+ (UIBezierPath *)fw_shapeHeart:(CGRect)frame NS_REFINED_FOR_SWIFT;

// "⭐" 星星的形状
+ (UIBezierPath *)fw_shapeStar:(CGRect)frame NS_REFINED_FOR_SWIFT;

// "⭐⭐⭐⭐⭐" 几颗星星的形状
+ (UIBezierPath *)fw_shapeStars:(NSUInteger)count frame:(CGRect)frame spacing:(CGFloat)spacing NS_REFINED_FOR_SWIFT;

// "➕" 加号形状
+ (UIBezierPath *)fw_shapePlus:(CGRect)frame NS_REFINED_FOR_SWIFT;

// "➖" 减号形状
+ (UIBezierPath *)fw_shapeMinus:(CGRect)frame NS_REFINED_FOR_SWIFT;

// "✖" 叉叉形状(错误)
+ (UIBezierPath *)fw_shapeCross:(CGRect)frame NS_REFINED_FOR_SWIFT;

// "✔" 检查形状(正确)
+ (UIBezierPath *)fw_shapeCheck:(CGRect)frame NS_REFINED_FOR_SWIFT;

// "<" 折叠形状，可指定方向
+ (UIBezierPath *)fw_shapeFold:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction NS_REFINED_FOR_SWIFT;

// "⬅" 箭头形状，可指定方向
+ (UIBezierPath *)fw_shapeArrow:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction NS_REFINED_FOR_SWIFT;

// "🔺" 三角形形状，可指定方向
+ (UIBezierPath *)fw_shapeTriangle:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
