//
//  UIFont+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIFont {
    
    // MARK: - Font

    /// 是否是粗体
    public var isBold: Bool {
        return base.__fw.isBold
    }

    /// 是否是斜体
    public var isItalic: Bool {
        return base.__fw.isItalic
    }

    /// 当前字体的粗体字体
    public var boldFont: UIFont {
        return base.__fw.boldFont
    }
    
    /// 当前字体的非粗体字体
    public var nonBoldFont: UIFont {
        return base.__fw.nonBoldFont
    }
    
    /// 当前字体的斜体字体
    public var italicFont: UIFont {
        return base.__fw.italicFont
    }
    
    /// 当前字体的非斜体字体
    public var nonItalicFont: UIFont {
        return base.__fw.nonItalicFont
    }
    
    // MARK: - Height

    // 字体空白高度(上下之和)
    public var spaceHeight: CGFloat {
        return base.__fw.spaceHeight
    }

    // 根据字体计算指定倍数行间距的实际行距值(减去空白高度)，示例：行间距为0.5倍实际高度
    public func lineSpacing(multiplier: CGFloat) -> CGFloat {
        return base.__fw.lineSpacing(withMultiplier: multiplier)
    }

    // 根据字体计算指定倍数行高的实际行高值(减去空白高度)，示例：行高为1.5倍实际高度
    public func lineHeight(multiplier: CGFloat) -> CGFloat {
        return base.__fw.lineHeight(withMultiplier: multiplier)
    }

    /// 计算当前字体与指定字体居中对齐的偏移值
    public func baselineOffset(_ font: UIFont) -> CGFloat {
        return base.__fw.baselineOffset(font)
    }
    
}
