//
//  RefreshPlugin.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIScrollView {
    
    /// 自定义刷新插件，未设置时自动从插件池加载
    public var refreshPlugin: RefreshPlugin? {
        get { return base.__fw.refreshPlugin }
        set { base.__fw.refreshPlugin = newValue }
    }

    // MARK: - Refreshing

    /// 是否正在刷新中
    public var isRefreshing: Bool {
        return base.__fw.isRefreshing
    }

    /// 是否显示刷新组件
    public var shouldRefreshing: Bool {
        get { return base.__fw.shouldRefreshing }
        set { base.__fw.shouldRefreshing = newValue }
    }

    /// 配置下拉刷新句柄
    public func setRefreshing(block: @escaping () -> Void) {
        base.__fw.setRefreshingBlock(block)
    }

    /// 配置下拉刷新事件
    public func setRefreshing(target: Any, action: Selector) {
        base.__fw.setRefreshingTarget(target, action: action)
    }

    /// 开始下拉刷新
    public func beginRefreshing() {
        base.__fw.beginRefreshing()
    }

    /// 结束下拉刷新
    public func endRefreshing() {
        base.__fw.endRefreshing()
    }

    // MARK: - Loading

    /// 是否正在追加中
    public var isLoading: Bool {
        return base.__fw.isLoading
    }

    /// 是否显示追加组件
    public var shouldLoading: Bool {
        get { return base.__fw.shouldLoading }
        set { base.__fw.shouldLoading = newValue }
    }

    /// 配置上拉追加句柄
    public func setLoading(block: @escaping () -> Void) {
        base.__fw.setLoading(block)
    }

    /// 配置上拉追加事件
    public func setLoading(target: Any, action: Selector) {
        base.__fw.setLoadingTarget(target, action: action)
    }

    /// 开始上拉追加
    public func beginLoading() {
        base.__fw.beginLoading()
    }

    /// 结束上拉追加
    public func endLoading() {
        base.__fw.endLoading()
    }
    
}

extension Wrapper where Base: UIScrollView {
    
    public func addPullRefresh(block: @escaping () -> Void) {
        base.__fw.addPullRefresh(block)
    }
    
    public func addPullRefresh(target: Any, action: Selector) {
        base.__fw.addPullRefresh(withTarget: target, action: action)
    }
    
    public func triggerPullRefresh() {
        base.__fw.triggerPullRefresh()
    }

    public var pullRefreshView: PullRefreshView? {
        return base.__fw.pullRefreshView
    }
    
    public var pullRefreshHeight: CGFloat {
        get { return base.__fw.pullRefreshHeight }
        set { base.__fw.pullRefreshHeight = newValue }
    }
    
    public var showPullRefresh: Bool {
        get { return base.__fw.showPullRefresh }
        set { base.__fw.showPullRefresh = newValue }
    }
    
    public func addInfiniteScroll(block: @escaping () -> Void) {
        base.__fw.addInfiniteScroll(block)
    }
    
    public func addInfiniteScroll(target: Any, action: Selector) {
        base.__fw.addInfiniteScroll(withTarget: target, action: action)
    }
    
    public func triggerInfiniteScroll() {
        base.__fw.triggerInfiniteScroll()
    }

    public var infiniteScrollView: InfiniteScrollView? {
        return base.__fw.infiniteScrollView
    }
    
    public var infiniteScrollHeight: CGFloat {
        get { return base.__fw.infiniteScrollHeight }
        set { base.__fw.infiniteScrollHeight = newValue }
    }
    
    public var showInfiniteScroll: Bool {
        get { return base.__fw.showInfiniteScroll }
        set { base.__fw.showInfiniteScroll = newValue }
    }
    
}
