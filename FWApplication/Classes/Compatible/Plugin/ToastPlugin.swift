//
//  ToastPlugin.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIView {
    
    /// 自定义吐司插件，未设置时自动从插件池加载
    public var toastPlugin: ToastPlugin? {
        get { return base.__fw_toastPlugin }
        set { base.__fw_toastPlugin = newValue }
    }
    
    /// 设置吐司外间距，默认zero
    public var toastInsets: UIEdgeInsets {
        get { return base.__fw_toastInsets }
        set { base.__fw_toastInsets = newValue }
    }

    /// 显示加载吐司，需手工隐藏，支持String和AttributedString
    public func showLoading(text: Any? = nil) {
        base.__fw_showLoading(withText: text)
    }

    /// 隐藏加载吐司
    public func hideLoading() {
        base.__fw_hideLoading()
    }

    /// 显示进度条吐司，需手工隐藏，支持String和AttributedString
    public func showProgress(_ progress: CGFloat, text: String? = nil) {
        base.__fw_showProgress(withText: text, progress: progress)
    }

    /// 隐藏进度条吐司
    public func hideProgress() {
        base.__fw_hideProgress()
    }

    /// 显示指定样式消息吐司，自动隐藏，支持String和AttributedString
    public func showMessage(text: Any?, style: ToastStyle = .default) {
        base.__fw_showMessage(withText: text, style: style)
    }

    /// 显示指定样式消息吐司，自动隐藏，自动隐藏完成后回调，支持String和AttributedString
    public func showMessage(text: Any?, style: ToastStyle, completion: (() -> Void)?) {
        base.__fw_showMessage(withText: text, style: style, completion: completion)
    }

    /// 显示指定样式消息吐司，可设置自动隐藏，自动隐藏完成后回调，支持String和AttributedString
    public func showMessage(text: Any?, style: ToastStyle, autoHide: Bool, completion: (() -> Void)?) {
        base.__fw_showMessage(withText: text, style: style, autoHide: autoHide, completion: completion)
    }

    /// 隐藏消息吐司
    public func hideMessage() {
        base.__fw_hideMessage()
    }
    
}

extension Wrapper where Base: UIViewController {
    
    /// 设置吐司外间距，默认zero
    public var toastInsets: UIEdgeInsets {
        get { return base.__fw_toastInsets }
        set { base.__fw_toastInsets = newValue }
    }

    /// 显示加载吐司，需手工隐藏，支持String和AttributedString
    public func showLoading(text: Any? = nil) {
        base.__fw_showLoading(withText: text)
    }

    /// 隐藏加载吐司
    public func hideLoading() {
        base.__fw_hideLoading()
    }

    /// 显示进度条吐司，需手工隐藏，支持String和AttributedString
    public func showProgress(_ progress: CGFloat, text: String? = nil) {
        base.__fw_showProgress(withText: text, progress: progress)
    }

    /// 隐藏进度条吐司
    public func hideProgress() {
        base.__fw_hideProgress()
    }

    /// 显示指定样式消息吐司，自动隐藏，支持String和AttributedString
    public func showMessage(text: Any?, style: ToastStyle = .default) {
        base.__fw_showMessage(withText: text, style: style)
    }

    /// 显示指定样式消息吐司，自动隐藏，自动隐藏完成后回调，支持String和AttributedString
    public func showMessage(text: Any?, style: ToastStyle, completion: (() -> Void)?) {
        base.__fw_showMessage(withText: text, style: style, completion: completion)
    }

    /// 显示指定样式消息吐司，可设置自动隐藏，自动隐藏完成后回调，支持String和AttributedString
    public func showMessage(text: Any?, style: ToastStyle, autoHide: Bool, completion: (() -> Void)?) {
        base.__fw_showMessage(withText: text, style: style, autoHide: autoHide, completion: completion)
    }

    /// 隐藏消息吐司
    public func hideMessage() {
        base.__fw_hideMessage()
    }
    
}

extension Wrapper where Base: UIWindow {
    
    /// 设置吐司外间距，默认zero
    public static var toastInsets: UIEdgeInsets {
        get { return Base.__fw_toastInsets }
        set { Base.__fw_toastInsets = newValue }
    }

    /// 显示加载吐司，需手工隐藏，支持String和AttributedString
    public static func showLoading(text: Any? = nil) {
        Base.__fw_showLoading(withText: text)
    }

    /// 隐藏加载吐司
    public static func hideLoading() {
        Base.__fw_hideLoading()
    }

    /// 显示进度条吐司，需手工隐藏，支持String和AttributedString
    public static func showProgress(_ progress: CGFloat, text: String? = nil) {
        Base.__fw_showProgress(withText: text, progress: progress)
    }

    /// 隐藏进度条吐司
    public static func hideProgress() {
        Base.__fw_hideProgress()
    }

    /// 显示指定样式消息吐司，自动隐藏，支持String和AttributedString
    public static func showMessage(text: Any?, style: ToastStyle = .default) {
        Base.__fw_showMessage(withText: text, style: style)
    }

    /// 显示指定样式消息吐司，自动隐藏，自动隐藏完成后回调，支持String和AttributedString
    public static func showMessage(text: Any?, style: ToastStyle, completion: (() -> Void)?) {
        Base.__fw_showMessage(withText: text, style: style, completion: completion)
    }

    /// 显示指定样式消息吐司，可设置自动隐藏，自动隐藏完成后回调，支持String和AttributedString
    public static func showMessage(text: Any?, style: ToastStyle, autoHide: Bool, completion: (() -> Void)?) {
        Base.__fw_showMessage(withText: text, style: style, autoHide: autoHide, completion: completion)
    }

    /// 隐藏消息吐司
    public static func hideMessage() {
        Base.__fw_hideMessage()
    }
    
}
