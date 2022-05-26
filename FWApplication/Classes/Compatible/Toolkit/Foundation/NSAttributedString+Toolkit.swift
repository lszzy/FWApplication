//
//  NSAttributedString+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/18.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/// 注意iOS在后台运行时，如果调用NSAttributedString解析html会导致崩溃(如动态切换深色模式时在后台解析html)。解决方法是提前在前台解析好或者后台异步到下一个主线程RunLoop
extension Wrapper where Base: NSAttributedString {
    
    // MARK: - Convert
    /// 快速创建NSAttributedString，自定义字体和颜色
    public static func attributedString(_ string: String, font: UIFont?, textColor: UIColor? = nil) -> Base {
        return Base.__fw.attributedString(string, with: font, textColor: textColor) as! Base
    }
    
    // MARK: - Html
    /// html字符串转换为NSAttributedString对象，可设置默认系统字体和颜色(附加CSS方式)
    public static func attributedString(htmlString: String, defaultAttributes: [NSAttributedString.Key: Any]?) -> Base? {
        return Base.__fw.attributedString(withHtmlString: htmlString, defaultAttributes: defaultAttributes) as? Base
    }

    /// html字符串转换为NSAttributedString主题对象，可设置默认系统字体和动态颜色，详见FWThemeObject
    public static func themeObject(htmlString: String, defaultAttributes: [NSAttributedString.Key: Any]?) -> ThemeObject<NSAttributedString> {
        return Base.__fw.themeObject(withHtmlString: htmlString, defaultAttributes: defaultAttributes)
    }

    /// 获取颜色对应CSS字符串(rgb|rgba格式)
    public static func cssString(color: UIColor) -> String {
        return Base.__fw.cssString(with: color)
    }

    /// 获取系统字体对应CSS字符串(family|style|weight|size)
    public static func cssString(font: UIFont) -> String {
        return Base.__fw.cssString(with: font)
    }
    
    // MARK: - Option
    /// 快速创建NSAttributedString，自定义选项
    public static func attributedString(_ string: String, option: AttributedOption?) -> Base {
        return Base.__fw.attributedString(string, with: option) as! Base
    }
    
}
