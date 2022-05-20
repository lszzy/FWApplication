//
//  UIBezierPath+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
import FWFramework

extension Wrapper where Base: UIBezierPath {
    
    // 绘制形状图片，自定义画笔宽度、画笔颜色、填充颜色，填充颜色为nil时不执行填充
    public func shapeImage(_ size: CGSize, strokeWidth: CGFloat, strokeColor: UIColor, fillColor: UIColor?) -> UIImage? {
        return base.__fw.shapeImage(size, strokeWidth: strokeWidth, stroke: strokeColor, fill: fillColor)
    }

    // 绘制形状Layer，自定义画笔宽度、画笔颜色、填充颜色，填充颜色为nil时不执行填充
    public func shapeLayer(_ rect: CGRect, strokeWidth: CGFloat, strokeColor: UIColor, fillColor: UIColor?) -> CAShapeLayer {
        return base.__fw.shapeLayer(rect, strokeWidth: strokeWidth, stroke: strokeColor, fill: fillColor)
    }
    
    // MARK: - Bezier

    // 根据点计算折线路径(NSValue点)
    public static func lines(points: [NSValue]) -> UIBezierPath {
        return Base.__fw.lines(withPoints: points)
    }

    // 根据点计算贝塞尔曲线路径
    public static func quadCurvedPath(points: [NSValue]) -> UIBezierPath {
        return Base.__fw.quadCurvedPath(withPoints: points)
    }
    
    // 计算两点的中心点
    public static func middlePoint(_ p1: CGPoint, with p2: CGPoint) -> CGPoint {
        return Base.__fw.middlePoint(p1, with: p2)
    }

    // 计算两点的贝塞尔曲线控制点
    public static func controlPoint(_ p1: CGPoint, with p2: CGPoint) -> CGPoint {
        return Base.__fw.controlPoint(p1, with: p2)
    }
    
    // 将角度(0~360)转换为弧度，周长为2*M_PI*r
    public static func radian(degree: CGFloat) -> CGFloat {
        return Base.__fw.radian(withDegree: degree)
    }
    
    // 将弧度转换为角度(0~360)
    public static func degree(radian: CGFloat) -> CGFloat {
        return Base.__fw.degree(withRadian: radian)
    }
    
    // 根据滑动方向计算rect的线段起点、终点中心点坐标数组(示范：田)。默认从上到下滑动
    public static func linePoints(rect: CGRect, direction: UISwipeGestureRecognizer.Direction) -> [NSValue] {
        return Base.__fw.linePoints(with: rect, direction: direction)
    }

    // MARK: - Shape

    // "🔴" 圆的形状，0~1，degree为起始角度，如-90度
    public static func shapeCircle(_ frame: CGRect, percent: Float, degree: CGFloat) -> UIBezierPath {
        return Base.__fw.shapeCircle(frame, percent: percent, degree: degree)
    }

    // "❤️" 心的形状
    public static func shapeHeart(_ frame: CGRect) -> UIBezierPath {
        return Base.__fw.shapeHeart(frame)
    }
    
    // "⭐" 星星的形状
    public static func shapeStar(_ frame: CGRect) -> UIBezierPath {
        return Base.__fw.shapeStar(frame)
    }
    
    // "⭐⭐⭐⭐⭐" 几颗星星的形状
    public static func shapeStars(_ count: UInt, frame: CGRect, spacing: CGFloat) -> UIBezierPath {
        return Base.__fw.shapeStars(count, frame: frame, spacing: spacing)
    }
    
    // "➕" 加号形状
    public static func shapePlus(_ frame: CGRect) -> UIBezierPath {
        return Base.__fw.shapePlus(frame)
    }
    
    // "➖" 减号形状
    public static func shapeMinus(_ frame: CGRect) -> UIBezierPath {
        return Base.__fw.shapeMinus(frame)
    }
    
    // "✖" 叉叉形状(错误)
    public static func shapeCross(_ frame: CGRect) -> UIBezierPath {
        return Base.__fw.shapeCross(frame)
    }
    
    // "✔" 检查形状(正确)
    public static func shapeCheck(_ frame: CGRect) -> UIBezierPath {
        return Base.__fw.shapeCheck(frame)
    }
    
    // "<" 折叠形状，可指定方向
    public static func shapeFold(_ frame: CGRect, direction: UISwipeGestureRecognizer.Direction) -> UIBezierPath {
        return Base.__fw.shapeFold(frame, direction: direction)
    }
    
    // "⬅" 箭头形状，可指定方向
    public static func shapeArrow(_ frame: CGRect, direction: UISwipeGestureRecognizer.Direction) -> UIBezierPath {
        return Base.__fw.shapeArrow(frame, direction: direction)
    }
    
    // "🔺" 三角形形状，可指定方向
    public static func shapeTriangle(_ frame: CGRect, direction: UISwipeGestureRecognizer.Direction) -> UIBezierPath {
        return Base.__fw.shapeTriangle(frame, direction: direction)
    }
    
}
