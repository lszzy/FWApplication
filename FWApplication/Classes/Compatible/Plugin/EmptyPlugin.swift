//
//  EmptyPlugin.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit

extension Wrapper where Base: UIView {
    
    /// 自定义空界面插件，未设置时自动从插件池加载
    public var emptyPlugin: EmptyPlugin? {
        get { return base.__fw.emptyPlugin }
        set { base.__fw.emptyPlugin = newValue }
    }
    
    /// 设置空界面外间距，默认zero
    public var emptyInsets: UIEdgeInsets {
        get { return base.__fw.emptyInsets }
        set { base.__fw.emptyInsets = newValue }
    }

    /// 是否显示空界面
    public var hasEmptyView: Bool {
        return base.__fw.hasEmptyView
    }

    /// 显示空界面
    public func showEmptyView() {
        base.__fw.showEmpty()
    }

    /// 显示空界面加载视图
    public func showEmptyLoading() {
        base.__fw.showEmptyLoading()
    }

    /// 显示空界面，指定文本和详细文本
    public func showEmptyView(text: String?, detail: String? = nil) {
        base.__fw.showEmpty(withText: text, detail: detail)
    }

    /// 显示空界面，指定文本、详细文本和图片
    public func showEmptyView(text: String?, detail: String?, image: UIImage?) {
        base.__fw.showEmpty(withText: text, detail: detail, image: image)
    }

    /// 显示空界面，指定文本、详细文本、图片和动作按钮
    public func showEmptyView(text: String?, detail: String?, image: UIImage?, action: String?, block: ((Any) -> Void)?) {
        base.__fw.showEmpty(withText: text, detail: detail, image: image, action: action, block: block)
    }

    /// 显示空界面，指定文本、详细文本、图片、是否显示加载视图和动作按钮
    public func showEmptyView(text: String?, detail: String?, image: UIImage?, loading: Bool, action: String?, block: ((Any) -> Void)?) {
        base.__fw.showEmpty(withText: text, detail: detail, image: image, loading: loading, action: action, block: block)
    }

    /// 隐藏空界面
    public func hideEmptyView() {
        base.__fw.hideEmpty()
    }
    
}

extension Wrapper where Base: UIViewController {
    
    /// 设置空界面外间距，默认zero
    public var emptyInsets: UIEdgeInsets {
        get { return base.__fw.emptyInsets }
        set { base.__fw.emptyInsets = newValue }
    }

    /// 是否显示空界面
    public var hasEmptyView: Bool {
        return base.__fw.hasEmptyView
    }

    /// 显示空界面
    public func showEmptyView() {
        base.__fw.showEmpty()
    }

    /// 显示空界面加载视图
    public func showEmptyLoading() {
        base.__fw.showEmptyLoading()
    }

    /// 显示空界面，指定文本和详细文本
    public func showEmptyView(text: String?, detail: String? = nil) {
        base.__fw.showEmpty(withText: text, detail: detail)
    }

    /// 显示空界面，指定文本、详细文本和图片
    public func showEmptyView(text: String?, detail: String?, image: UIImage?) {
        base.__fw.showEmpty(withText: text, detail: detail, image: image)
    }

    /// 显示空界面，指定文本、详细文本、图片和动作按钮
    public func showEmptyView(text: String?, detail: String?, image: UIImage?, action: String?, block: ((Any) -> Void)?) {
        base.__fw.showEmpty(withText: text, detail: detail, image: image, action: action, block: block)
    }

    /// 显示空界面，指定文本、详细文本、图片、是否显示加载视图和动作按钮
    public func showEmptyView(text: String?, detail: String?, image: UIImage?, loading: Bool, action: String?, block: ((Any) -> Void)?) {
        base.__fw.showEmpty(withText: text, detail: detail, image: image, loading: loading, action: action, block: block)
    }

    /// 隐藏空界面
    public func hideEmptyView() {
        base.__fw.hideEmpty()
    }
    
}

extension Wrapper where Base: UIScrollView {
    
    /// 空界面代理，默认nil
    public weak var emptyViewDelegate: EmptyViewDelegate? {
        get { return base.__fw.emptyViewDelegate }
        set { base.__fw.emptyViewDelegate = newValue }
    }

    /// 刷新空界面
    public func reloadEmptyView() {
        base.__fw.reloadEmptyView()
    }
    
    /// 滚动视图自定义浮层，用于显示空界面等，兼容UITableView|UICollectionView
    public var overlayView: UIView {
        return base.__fw.overlayView
    }

    /// 是否显示自定义浮层
    public var hasOverlayView: Bool {
        return base.__fw.hasOverlayView
    }

    /// 显示自定义浮层，默认不执行渐变动画，自动添加到滚动视图顶部、表格视图底部
    public func showOverlayView(animated: Bool = false) {
        base.__fw.showOverlayView(animated: animated)
    }

    /// 隐藏自定义浮层，自动从滚动视图移除
    public func hideOverlayView() {
        base.__fw.hideOverlayView()
    }
    
}
