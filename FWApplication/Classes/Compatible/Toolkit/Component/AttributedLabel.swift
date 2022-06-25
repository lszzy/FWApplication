//
//  AttributedLabel.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/18.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: NSMutableAttributedString {
    
    public var textColor: UIColor? {
        get { return base.__fw_textColor }
        set { base.__fw_textColor = newValue }
    }
    
    public func setTextColor(_ color: UIColor, range: NSRange) {
        base.__fw_setTextColor(color, range: range)
    }

    public var font: UIFont? {
        get { return base.__fw_font }
        set { base.__fw_font = newValue }
    }
    
    public func setFont(_ font: UIFont, range: NSRange) {
        base.__fw_setFont(font, range: range)
    }

    public func setUnderlineStyle(_ style: CTUnderlineStyle, modifier: CTUnderlineStyleModifiers) {
        base.__fw_setUnderlineStyle(style, modifier: modifier)
    }
    
    public func setUnderlineStyle(_ style: CTUnderlineStyle, modifier: CTUnderlineStyleModifiers, range: NSRange) {
        base.__fw_setUnderlineStyle(style, modifier: modifier, range: range)
    }
    
}
