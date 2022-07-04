//
//  UILabel+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/// 注意UILabel的lineBreakMode默认值为TruncatingTail，如设置numberOfLines为0时，需显示修改lineBreakMode值；
/// 自动布局时，可设置preferredMaxLayoutWidth，从而通过intrinsicContentSize获取多行Label的高度
extension Wrapper where Base: UILabel {
    
    // MARK: - Size

    // 计算当前文本所占尺寸，需frame或者宽度布局完整
    public var textSize: CGSize {
        return base.__fw_textSize
    }

    // 计算当前属性文本所占尺寸，需frame或者宽度布局完整，attributedText需指定字体
    public var attributedTextSize: CGSize {
        return base.__fw_attributedTextSize
    }
    
}

extension Wrapper where Base: UILabel {
    
    /**
     调试功能，打开后会在 label 第一行文字里把 descender、xHeight、capHeight、lineHeight 所在的位置以线条的形式标记出来。
     对这些属性的解释可以看这篇文章 https://www.rightpoint.com/rplabs/ios-tracking-typography
     */
    public var showPrincipalLines: Bool {
        get { return base.__fw_showPrincipalLines }
        set { base.__fw_showPrincipalLines = newValue }
    }

    /**
     当打开 showPrincipalLines 时，通过这个属性控制线条的颜色，默认为 半透明红色
     */
    public var principalLineColor: UIColor {
        get { return base.__fw_principalLineColor }
        set { base.__fw_principalLineColor = newValue }
    }
    
}
