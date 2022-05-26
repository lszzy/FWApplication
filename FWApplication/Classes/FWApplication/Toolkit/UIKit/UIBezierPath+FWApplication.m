/**
 @header     UIBezierPath+FWApplication.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "UIBezierPath+FWApplication.h"

@implementation FWBezierPathWrapper (FWApplication)

- (UIImage *)shapeImage:(CGSize)size
              strokeWidth:(CGFloat)strokeWidth
              strokeColor:(UIColor *)strokeColor
                fillColor:(UIColor *)fillColor
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    
    CGContextSetLineWidth(context, strokeWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    [strokeColor setStroke];
    CGContextAddPath(context, self.base.CGPath);
    CGContextStrokePath(context);
    
    if (fillColor) {
        [fillColor setFill];
        CGContextAddPath(context, self.base.CGPath);
        CGContextFillPath(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CAShapeLayer *)shapeLayer:(CGRect)rect
                   strokeWidth:(CGFloat)strokeWidth
                   strokeColor:(UIColor *)strokeColor
                     fillColor:(UIColor *)fillColor
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = rect;
    layer.lineWidth = strokeWidth;
    layer.lineCap = kCALineCapRound;
    layer.strokeColor = strokeColor.CGColor;
    if (fillColor) {
        layer.fillColor = fillColor.CGColor;
    }
    layer.path = self.base.CGPath;
    return layer;
}

@end

@implementation FWBezierPathClassWrapper (FWApplication)

#pragma mark - Bezier

- (UIBezierPath *)linesWithPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
    }
    return path;
}

- (UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = [self middlePoint:p1 withPoint:p2];
        [path addQuadCurveToPoint:midPoint controlPoint:[self controlPoint:midPoint withPoint:p1]];
        [path addQuadCurveToPoint:p2 controlPoint:[self controlPoint:midPoint withPoint:p2]];
        
        p1 = p2;
    }
    return path;
}

- (CGPoint)middlePoint:(CGPoint)p1 withPoint:(CGPoint)p2
{
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

- (CGPoint)controlPoint:(CGPoint)p1 withPoint:(CGPoint)p2
{
    CGPoint controlPoint = [self middlePoint:p1 withPoint:p2];
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

- (CGFloat)radianWithDegree:(CGFloat)degree
{
    return (M_PI * degree) / 180.f;
}

- (CGFloat)degreeWithRadian:(CGFloat)radian
{
    return (180.f * radian) / M_PI;
}

- (NSArray<NSValue *> *)linePointsWithRect:(CGRect)rect direction:(UISwipeGestureRecognizerDirection)direction
{
    CGPoint startPoint;
    CGPoint endPoint;
    switch (direction) {
        // 从左到右
        case UISwipeGestureRecognizerDirectionRight: {
            startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
            endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
            break;
        }
        // 从下到上
        case UISwipeGestureRecognizerDirectionUp: {
            startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
            endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
            break;
        }
        // 从右到左
        case UISwipeGestureRecognizerDirectionLeft: {
            startPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
            endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
            break;
        }
        // 从上到下
        case UISwipeGestureRecognizerDirectionDown:
        default: {
            startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
            endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
            break;
        }
    }
    return [NSArray arrayWithObjects:[NSValue valueWithCGPoint:startPoint], [NSValue valueWithCGPoint:endPoint], nil];
}

#pragma mark - Shape

- (CGRect)innerSquareFrame:(CGRect)frame;
{
    CGFloat a = MIN(frame.size.width, frame.size.height);
    return CGRectMake(frame.origin.x + frame.size.width / 2 - a / 2, frame.origin.y + frame.size.height / 2 - a / 2, a, a);
}

- (UIBezierPath *)shapeCircle:(CGRect)aFrame percent:(float)percent degree:(CGFloat)degree
{
    CGRect frame = [self innerSquareFrame:aFrame];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.origin.x + frame.size.width / 2.0, frame.origin.y + frame.size.height / 2.0)
                                                              radius:frame.size.width / 2.0
                                                          startAngle:(degree) * M_PI / 180.f
                                                            endAngle:(degree + 360.f * percent) * M_PI / 180.f
                                                           clockwise:YES];
    return bezierPath;
}

- (UIBezierPath *)shapeHeart:(CGRect)aFrame
{
    CGRect frame = [self innerSquareFrame:aFrame];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74182 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04948 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.49986 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.24129 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.64732 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05022 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.55044 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.11201 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.33067 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.06393 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.46023 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.14682 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.39785 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.08864 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.25304 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05011 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.30516 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05454 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.27896 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04999 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.00841 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.36081 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.12805 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05067 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.00977 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15998 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.29627 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70379 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.00709 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55420 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.18069 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62648 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50061 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.92498 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.40835 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77876 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.48812 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88133 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.70195 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.70407 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.50990 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.88158 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.59821 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.77912 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.99177 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.35870 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.81539 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.62200 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.99308 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.55208 * CGRectGetHeight(frame))];
    [bezierPath addCurveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.74182 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04948 * CGRectGetHeight(frame)) controlPoint1: CGPointMake(CGRectGetMinX(frame) + 0.99040 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.15672 * CGRectGetHeight(frame)) controlPoint2: CGPointMake(CGRectGetMinX(frame) + 0.86824 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.04848 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    bezierPath.miterLimit = 4;
    
    return bezierPath;
}

- (UIBezierPath *)shapeStar:(CGRect)aFrame
{
    CGRect frame = [self innerSquareFrame:aFrame];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.05000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.67634 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30729 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.97553 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39549 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.78532 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64271 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.79389 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95451 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.50000 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.85000 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.20611 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.95451 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.21468 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.64271 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.02447 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.39549 * CGRectGetHeight(frame))];
    [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 0.32366 * CGRectGetWidth(frame), CGRectGetMinY(frame) + 0.30729 * CGRectGetHeight(frame))];
    [bezierPath closePath];
    
    return bezierPath;
}

- (UIBezierPath *)shapeStars:(NSUInteger)count frame:(CGRect)aFrame spacing:(CGFloat)spacing
{
    CGFloat width = (aFrame.size.width - spacing * (count - 1)) / count;
    CGRect babyFrame = CGRectMake(aFrame.origin.x, aFrame.origin.y, width, aFrame.size.height);
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    for (int i = 0; i < count; i++) {
        UIBezierPath *startPath = [self shapeStar:babyFrame];
        [startPath applyTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, i * (width + spacing), 0)];
        [bezierPath appendPath:startPath];
    }
    return bezierPath;
}

- (UIBezierPath *)shapePlus:(CGRect)frame
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
    return bezierPath;
}

- (UIBezierPath *)shapeMinus:(CGRect)frame
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
    return bezierPath;
}

- (UIBezierPath *)shapeCross:(CGRect)frame
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];
    return bezierPath;
}

- (UIBezierPath *)shapeCheck:(CGRect)frame
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame) / sqrt(2.0) / 2.f, CGRectGetMaxY(frame))];
    [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
    return bezierPath;
}

- (UIBezierPath *)shapeFold:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionUp: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
            break;
        }
        case UISwipeGestureRecognizerDirectionDown: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
            break;
        }
        case UISwipeGestureRecognizerDirectionRight: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];
            break;
        }
        default:
            break;
    }
    return bezierPath;
}

- (UIBezierPath *)shapeArrow:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionUp: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
            break;
        }
        case UISwipeGestureRecognizerDirectionDown: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
            [bezierPath moveToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
            break;
        }
        case UISwipeGestureRecognizerDirectionRight: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
            [bezierPath moveToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
            break;
        }
        default:
            break;
    }
    return bezierPath;
}

- (UIBezierPath *)shapeTriangle:(CGRect)frame direction:(UISwipeGestureRecognizerDirection)direction
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    switch (direction) {
        case UISwipeGestureRecognizerDirectionUp: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
            [bezierPath closePath];
            break;
        }
        case UISwipeGestureRecognizerDirectionDown: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
            [bezierPath closePath];
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame))];
            [bezierPath closePath];
            break;
        }
        case UISwipeGestureRecognizerDirectionRight: {
            [bezierPath moveToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))];
            [bezierPath addLineToPoint:CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame))];
            [bezierPath closePath];
            break;
        }
        default:
            break;
    }
    return bezierPath;
}

@end
