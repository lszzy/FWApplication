//
//  WebView.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIProgressView {
    
    /// 设置Web加载进度，0和1自动切换隐藏。可设置trackTintColor为clear，隐藏背景色
    public var webProgress: Float {
        get { return base.__fw_webProgress }
        set { base.__fw_webProgress = newValue }
    }
    
}

extension Wrapper where Base: WKWebView {
    
    /// 设置Javascript桥接器强引用属性，防止使用过程中被释放
    public var jsBridge: WebViewJsBridge? {
        get { return base.__fw_jsBridge }
        set { base.__fw_jsBridge = newValue }
    }

    /// 获取当前UserAgent，未自定义时为默认，示例：Mozilla/5.0 (iPhone; CPU OS 14_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
    public var userAgent: String {
        return base.__fw_userAgent
    }
    
    /// 获取默认浏览器UserAgent，包含应用信息，示例：Mozilla/5.0 (iPhone; CPU OS 14_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Safari/605.1.15 Example/1.0.0
    public static var browserUserAgent: String {
        return Base.__fw_browserUserAgent
    }

    /// 获取默认浏览器扩展UserAgent，不含平台信息，可用于applicationNameForUserAgent，示例：Mobile/15E148 Safari/605.1.15 Example/1.0.0
    public static var extensionUserAgent: String {
        return Base.__fw_extensionUserAgent
    }

    /// 获取默认请求UserAgent，可用于网络请求，示例：Example/1.0.0 (iPhone; iOS 14.2; Scale/3.00)
    public static var requestUserAgent: String {
        return Base.__fw_requestUserAgent
    }
    
    /// 清空网页缓存，完成后回调。单个网页请求指定URLRequest.cachePolicy即可
    public static func fw_clearCache(_ completion: (() -> Void)? = nil) {
        Base.__fw_clearCache(completion)
    }
    
}
