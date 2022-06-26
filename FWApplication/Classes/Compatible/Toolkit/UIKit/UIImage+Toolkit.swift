//
//  UIImage+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/// 注意CGContextDrawImage如果图片尺寸太大会导致内存不足闪退(如高斯模糊效果)，建议先压缩再调用
extension Wrapper where Base: UIImage {
    
    // MARK: - Color

    /// 获取灰度图
    public var grayImage: UIImage? {
        return base.__fw_gray
    }

    /// 取图片某一点的颜色
    public func color(atPoint point: CGPoint) -> UIColor? {
        return base.__fw_color(at: point)
    }

    /// 取图片某一像素的颜色
    public func color(atPixel pixel: CGPoint) -> UIColor? {
        return base.__fw_color(atPixel: pixel)
    }

    /// 获取图片的平均颜色
    public var averageColor: UIColor {
        return base.__fw_averageColor
    }

    // MARK: - Effect

    /// 倒影图片
    public func image(reflectScale: CGFloat) -> UIImage? {
        return base.__fw_image(withReflectScale: reflectScale)
    }

    /// 倒影图片
    public func image(reflectScale: CGFloat, gap: CGFloat, alpha: CGFloat) -> UIImage? {
        return base.__fw_image(withReflectScale: reflectScale, gap: gap, alpha: alpha)
    }

    /// 阴影图片
    public func image(shadowColor: UIColor, offset: CGSize, blur: CGFloat) -> UIImage? {
        return base.__fw_image(withShadowColor: shadowColor, offset: offset, blur: blur)
    }

    /// 获取装饰图片
    public var maskImage: UIImage {
        return base.__fw_mask
    }

    /// 高斯模糊图片，默认模糊半径为10，饱和度为1
    public func image(blurRadius: CGFloat, saturationDelta: CGFloat, tintColor: UIColor?, maskImage: UIImage?) -> UIImage? {
        return base.__fw_image(withBlurRadius: blurRadius, saturationDelta: saturationDelta, tintColor: tintColor, maskImage: maskImage)
    }

    // MARK: - Alpha

    /// 如果没有透明通道，增加透明通道
    public var alphaImage: UIImage {
        return base.__fw_alpha
    }

    // MARK: - Album

    /// 保存图片到相册，保存成功时error为nil
    public func saveImage(completion: ((Error?) -> Void)? = nil) {
        base.__fw_saveImage(completion: completion)
    }
    
    // MARK: - View

    /// 截取View所有视图，包括旋转缩放效果
    public static func image(view: UIView, limitWidth: CGFloat) -> UIImage? {
        return Base.__fw_image(with: view, limitWidth: limitWidth)
    }

    // MARK: - Icon

    /// 获取AppIcon图片
    public static func appIconImage() -> UIImage? {
        return Base.__fw_imageWithAppIcon()
    }

    /// 获取AppIcon指定尺寸图片，名称格式：AppIcon60x60
    public static func appIconImage(size: CGSize) -> UIImage? {
        return Base.__fw_image(withAppIcon: size)
    }

    // MARK: - Pdf

    /// 从Pdf数据或者路径创建指定大小UIImage
    public static func image(pdf path: Any, size: CGSize = .zero) -> UIImage? {
        return Base.__fw_image(withPdf: path, size: size)
    }

    // MARK: - Emoji

    /// 从Emoji字符串创建指定大小UIImage
    public static func image(emoji: String, size: CGFloat) -> UIImage? {
        return Base.__fw_image(withEmoji: emoji, size: size)
    }

    // MARK: - Gradient

    /**
     创建渐变颜色UIImage，支持四个方向，默认向下Down
     
     @param size 图片大小
     @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
     @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
     @param direction 渐变方向，自动计算startPoint和endPoint，支持四个方向，默认向下Down
     @return 渐变颜色UIImage
     */
    public static func gradientImage(size: CGSize, colors: [Any], locations: UnsafePointer<CGFloat>?, direction: UISwipeGestureRecognizer.Direction) -> UIImage? {
        return Base.__fw_gradientImage(with: size, colors: colors, locations: locations, direction: direction)
    }

    /**
     创建渐变颜色UIImage
     
     @param size 图片大小
     @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
     @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
     @param startPoint 渐变开始点，需要根据rect计算
     @param endPoint 渐变结束点，需要根据rect计算
     @return 渐变颜色UIImage
     */
    public static func gradientImage(size: CGSize, colors: [Any], locations: UnsafePointer<CGFloat>?, startPoint: CGPoint, endPoint: CGPoint) -> UIImage? {
        return Base.__fw_gradientImage(with: size, colors: colors, locations: locations, start: startPoint, end: endPoint)
    }

    // MARK: - Album

    /// 保存视频到相册，保存成功时error为nil。如果视频地址为NSURL，需使用NSURL.path
    public static func saveVideo(_ videoPath: String, completion: ((Error?) -> Void)? = nil) {
        Base.__fw_saveVideo(videoPath, withCompletion: completion)
    }
    
}
