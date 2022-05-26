//
//  UIImageView+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIImageView {
    
    // MARK: - Mode

    /// 设置图片模式为ScaleAspectFill，自动拉伸不变形，超过区域隐藏。可通过appearance统一设置
    public func setContentModeAspectFill() {
        base.__fw.setContentModeAspectFill()
    }

    /// 设置指定图片模式，超过区域隐藏。可通过appearance统一设置
    public func setContentMode(_ contentMode: UIView.ContentMode) {
        base.__fw.setContentMode(contentMode)
    }

    // MARK: - Face

    /// 优化图片人脸显示，参考：https://github.com/croath/UIImageView-BetterFace
    public func faceAware() {
        base.__fw.faceAware()
    }

    // MARK: - Reflect

    /// 倒影效果
    public func reflect() {
        base.__fw.reflect()
    }

    // MARK: - Watermark

    /// 图片水印
    public func setImage(_ image: UIImage, watermarkImage: UIImage, in rect: CGRect) {
        base.__fw.setImage(image, watermarkImage: watermarkImage, in: rect)
    }

    /// 文字水印，指定区域
    public func setImage(_ image: UIImage, watermarkString: NSAttributedString, in rect: CGRect) {
        base.__fw.setImage(image, watermarkString: watermarkString, in: rect)
    }

    /// 文字水印，指定坐标
    public func setImage(_ image: UIImage, watermarkString: NSAttributedString, at point: CGPoint) {
        base.__fw.setImage(image, watermarkString: watermarkString, at: point)
    }
    
}
