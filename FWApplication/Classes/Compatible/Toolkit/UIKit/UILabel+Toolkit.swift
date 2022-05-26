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
        return base.__fw.textSize
    }

    // 计算当前属性文本所占尺寸，需frame或者宽度布局完整，attributedText需指定字体
    public var attributedTextSize: CGSize {
        return base.__fw.attributedTextSize
    }
    
}
