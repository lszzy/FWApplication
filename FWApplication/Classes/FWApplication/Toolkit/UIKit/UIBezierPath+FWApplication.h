/**
 @header     UIBezierPath+FWApplication.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface FWBezierPathWrapper (FWApplication)

// 绘制形状图片，自定义画笔宽度、画笔颜色、填充颜色，填充颜色为nil时不执行填充
- (nullable UIImage *)shapeImage:(CGSize)size
                     strokeWidth:(CGFloat)strokeWidth
                     strokeColor:(UIColor *)strokeColor
                       fillColor:(nullable UIColor *)fillColor;

// 绘制形状Layer，自定义画笔宽度、画笔颜色、填充颜色，填充颜色为nil时不执行填充
- (CAShapeLayer *)shapeLayer:(CGRect)rect
                 strokeWidth:(CGFloat)strokeWidth
                 strokeColor:(UIColor *)strokeColor
                   fillColor:(nullable UIColor *)fillColor;

@end

@interface FWBezierPathClassWrapper (FWApplication)

#pragma mark - Bezier

// 根据点计算折线路径(NSValue点)
- (UIBezierPath *)linesWithPoints:(NSArray *)points;

// 根据点计算贝塞尔曲线路径
- (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points;

// 计算两点的中心点
- (CGPoint)middlePoint:(CGPoint)p1 withPoint:(CGPoint)p2;

// 计算两点的贝塞尔曲线控制点
- (CGPoint)controlPoint:(CGPoint)p1 withPoint:(CGPoint)p2;

// 将角度(0~360)转换为弧度，周长为2*M_PI*r
- (CGFloat)radianWithDegree:(CGFloat)degree;

// 将弧度转换为角度(0~360)
- (CGFloat)degreeWithRadian:(CGFloat)radian;

// 根据滑动方向计算rect的线段起点、终点中心点坐标数组(示范：田)。默认从上到下滑动
- (NSArray<NSValue *> *)linePointsWithRect:(CGRect)rect direction:(UISwipeGestureRecognizerDirection)direction;

#pragma mark - Shape

// "🔴" 圆的形状，0~1，degree为起始角度，如-90度
- (UIBezierPath *)shapeCircle:(CGRect)frame percent:(float)percent degree:(CGFloat)degree;

// "❤️" 心的形状
- (UIBezierPath *)shapeHeart:(CGRect)frame;

// "⭐" 星星的形状
- (UIBezierPath *)shapeStar:(CGRect)frame;

// "⭐⭐⭐⭐⭐" 几颗星星的形状
- (UIBezierPath *)shapeStars:(NSUInteger)count frame:(CGRect)frame spacing:(CGFloat)spacing;

// "➕" 加号形状
- (UIBezierPath *)shapePlus:(CGRect)frame;

// "➖" 减号形状
- (UIBezierPath *)shapeMinus:(CGRect)frame;

// "✖" 叉叉形状(错误)
- (UIBezierPath *)shapeCross:(CGRect)frame;

// "✔" 检查形状(正确)
- (UIBezierPath *)shapeCheck:(CGRect)frame;

// "<" 折叠形状，可指定方向
- (UIBezierPath *)shapeFold:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction;

// "⬅" 箭头形状，可指定方向
- (UIBezierPath *)shapeArrow:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction;

// "🔺" 三角形形状，可指定方向
- (UIBezierPath *)shapeTriangle:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction;

@end

NS_ASSUME_NONNULL_END
