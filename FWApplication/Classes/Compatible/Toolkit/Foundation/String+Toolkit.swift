//
//  String+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base == String {
    
    // MARK: - Pinyin

    /// 中文转拼音
    public var pinyinString: String {
        return (base as NSString).__fw.pinyinString
    }

    /**
     *  中文转拼音并进行比较
     *
     *  @param string 中文字符串
     */
    public func pinyinCompare(_ string: String) -> ComparisonResult {
        return (base as NSString).__fw.pinyinCompare(string)
    }

    // MARK: - Regex

    /**
     *  安全截取字符串。解决末尾半个Emoji问题(半个Emoji调UTF8String为NULL，导致MD5签名等失败)
     *
     *  @param index 目标索引
     */
    public func emojiSubstring(_ index: UInt) -> String {
        return (base as NSString).__fw.emojiSubstring(index)
    }

    /**
     *  正则搜索子串
     *
     *  @param regex 正则表达式
     */
    public func regexSubstring(_ regex: String) -> String? {
        return (base as NSString).__fw.regexSubstring(regex)
    }

    /**
     *  正则替换字符串
     *
     *  @param regex  正则表达式
     *  @param string 替换模板，如"头部$1中部$2尾部"
     *
     *  @return 替换后的字符串
     */
    public func regexReplace(_ regex: String, string: String) -> String {
        return (base as NSString).__fw.regexReplace(regex, with: string)
    }

    /**
     *  正则匹配回调
     *
     *  @param regex 正则表达式
     *  @param block 回调句柄。range从大至小，方便replace
     */
    public func regexMatches(_ regex: String, block: @escaping (NSRange) -> Void) {
        return (base as NSString).__fw.regexMatches(regex, with: block)
    }

    // MARK: - Html

    /// 转义Html，如"a<"转义为"a&lt;"
    public var escapeHtml: String {
        return (base as NSString).__fw.escapeHtml
    }
    
    // MARK: - UUID
    
    /// 创建一个UUID字符串，示例："D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"。也可调用NSUUID.UUID.UUIDString
    public static var uuidString: String {
        return NSString.__fw.uuidString
    }
    
}

extension Wrapper where Base == String {
    
    /**
     *  是否符合正则表达式
     *  示例：用户名：^[a-zA-Z][a-zA-Z0-9_]{4,13}$
     *       密码：^[a-zA-Z0-9_]{6,20}$
     *       昵称：^[a-zA-Z0-9_\u4e00-\u9fa5]{4,14}$
     *
     *  @param regex 正则表达式
     */
    public func isFormatRegex(_ regex: String) -> Bool {
        return (base as NSString).__fw.isFormatRegex(regex)
    }

    /**
     *  是否是手机号
     */
    public func isFormatMobile() -> Bool {
        return (base as NSString).__fw.isFormatMobile()
    }

    /**
     *  是否是座机号
     */
    public func isFormatTelephone() -> Bool {
        return (base as NSString).__fw.isFormatTelephone()
    }
    
    /**
     *  是否是整数
     */
    public func isFormatInteger() -> Bool {
        return (base as NSString).__fw.isFormatInteger()
    }
    
    /**
     *  是否是数字
     */
    public func isFormatNumber() -> Bool {
        return (base as NSString).__fw.isFormatNumber()
    }
    
    /**
     *  是否是合法金额，两位小数点
     */
    public func isFormatMoney() -> Bool {
        return (base as NSString).__fw.isFormatMoney()
    }
    
    /**
     *  是否是身份证号
     */
    public func isFormatIdcard() -> Bool {
        return (base as NSString).__fw.isFormatIdcard()
    }
    
    /**
     *  是否是银行卡号
     */
    public func isFormatBankcard() -> Bool {
        return (base as NSString).__fw.isFormatBankcard()
    }
    
    /**
     *  是否是车牌号
     */
    public func isFormatCarno() -> Bool {
        return (base as NSString).__fw.isFormatCarno()
    }
    
    /**
     *  是否是邮政编码
     */
    public func isFormatPostcode() -> Bool {
        return (base as NSString).__fw.isFormatPostcode()
    }
    
    /**
     *  是否是工商税号
     */
    public func isFormatTaxno() -> Bool {
        return (base as NSString).__fw.isFormatTaxno()
    }
    
    /**
     *  是否是邮箱
     */
    public func isFormatEmail() -> Bool {
        return (base as NSString).__fw.isFormatEmail()
    }
    
    /**
     *  是否是URL
     */
    public func isFormatUrl() -> Bool {
        return (base as NSString).__fw.isFormatUrl()
    }
    
    /**
     *  是否是HTML
     */
    public func isFormatHtml() -> Bool {
        return (base as NSString).__fw.isFormatHtml()
    }
    
    /**
     *  是否是IP
     */
    public func isFormatIp() -> Bool {
        return (base as NSString).__fw.isFormatIp()
    }
    
    /**
     *  是否全是中文
     */
    public func isFormatChinese() -> Bool {
        return (base as NSString).__fw.isFormatChinese()
    }
    
    /**
     *  是否是合法时间，格式：yyyy-MM-dd HH:mm:ss
     */
    public func isFormatDatetime() -> Bool {
        return (base as NSString).__fw.isFormatDatetime()
    }
    
    /**
     *  是否是合法时间戳，格式：1301234567
     */
    public func isFormatTimestamp() -> Bool {
        return (base as NSString).__fw.isFormatTimestamp()
    }
    
    /**
     *  是否是坐标点字符串，格式：latitude,longitude
     */
    public func isFormatCoordinate() -> Bool {
        return (base as NSString).__fw.isFormatCoordinate()
    }
    
}
