//
//  UIColor+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIColor {
    
    // MARK: - Color

    /// 以指定模式添加混合颜色
    public func addColor(_ color: UIColor, blendMode: CGBlendMode) -> UIColor {
        return base.__fw.addColor(color, blendMode: blendMode)
    }

    /// 当前颜色的反色。http://stackoverflow.com/questions/5893261/how-to-get-inverse-color-from-uicolor
    public var inverseColor: UIColor {
        return base.__fw.inverseColor
    }
    
    /// 判断当前颜色是否为深色。http://stackoverflow.com/questions/19456288/text-color-based-on-background-image
    public var isDarkColor: Bool {
        return base.__fw.isDarkColor
    }
    
    /// 当前颜色修改亮度比率的颜色
    public func brightnessColor(_ ratio: CGFloat) -> UIColor {
        return base.__fw.brightnessColor(ratio)
    }
    
    // MARK: - Image

    // 从整个图像初始化UIColor
    public static func color(image: UIImage) -> UIColor {
        return Base.__fw.color(with: image)
    }

    // 从图像的某个点初始化UIColor
    public static func color(image: UIImage, point: CGPoint) -> UIColor? {
        return Base.__fw.color(with: image, point: point)
    }

    // MARK: - Gradient

    /**
     创建渐变颜色，支持四个方向，默认向下Down
     
     @param size 渐变尺寸，非渐变边可以设置为1。如CGSizeMake(1, 50)
     @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
     @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
     @param direction 渐变方向，自动计算startPoint和endPoint，支持四个方向，默认向下Down
     @return 渐变色
     */
    public static func gradientColor(size: CGSize, colors: [Any], locations: UnsafePointer<CGFloat>?, direction: UISwipeGestureRecognizer.Direction) -> UIColor {
        return Base.__fw.gradientColor(with: size, colors: colors, locations: locations, direction: direction)
    }

    /**
     创建渐变颜色
     
     @param size 渐变尺寸，非渐变边可以设置为1。如CGSizeMake(1, 50)
     @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
     @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
     @param startPoint 渐变开始点，需要根据rect计算
     @param endPoint 渐变结束点，需要根据rect计算
     @return 渐变色
     */
    public static func gradientColor(size: CGSize, colors: [Any], locations: UnsafePointer<CGFloat>?, startPoint: CGPoint, endPoint: CGPoint) -> UIColor {
        return Base.__fw.gradientColor(with: size, colors: colors, locations: locations, start: startPoint, end: endPoint)
    }
    
}
