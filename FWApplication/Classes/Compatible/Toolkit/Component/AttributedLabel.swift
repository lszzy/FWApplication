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
        get { return base.__fw.textColor }
        set { base.__fw.textColor = newValue }
    }
    
    public func setTextColor(_ color: UIColor, range: NSRange) {
        base.__fw.setTextColor(color, range: range)
    }

    public var font: UIFont? {
        get { return base.__fw.font }
        set { base.__fw.font = newValue }
    }
    
    public func setFont(_ font: UIFont, range: NSRange) {
        base.__fw.setFont(font, range: range)
    }

    public func setUnderlineStyle(_ style: CTUnderlineStyle, modifier: CTUnderlineStyleModifiers) {
        base.__fw.setUnderlineStyle(style, modifier: modifier)
    }
    
    public func setUnderlineStyle(_ style: CTUnderlineStyle, modifier: CTUnderlineStyleModifiers, range: NSRange) {
        base.__fw.setUnderlineStyle(style, modifier: modifier, range: range)
    }
    
}
