//
//  AppWrapper.swift
//  FWApplication
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import UIKit

extension Wrapper where Base: UIView {
    
    /// 通用视图绑定数据，改变时自动触发viewModelChanged和FWView.renderData
    public var viewModel: Any? {
        get { return base.__fw.viewModel }
        set { base.__fw.viewModel = newValue }
    }

    /// 通用视图数据改变句柄钩子，viewData改变时自动调用
    public var viewModelChanged: ((UIView) -> Void)? {
        get { return base.__fw.viewModelChanged }
        set { base.__fw.viewModelChanged = newValue }
    }

    /// 通用事件接收代理，弱引用，Delegate方式
    public weak var viewDelegate: ViewDelegate? {
        get { return base.__fw.viewDelegate }
        set { base.__fw.viewDelegate = newValue }
    }

    /// 通用事件接收句柄，Block方式
    public var eventReceived: ((UIView, Notification) -> Void)? {
        get { return base.__fw.eventReceived }
        set { base.__fw.eventReceived = newValue }
    }

    /// 通用事件完成回调句柄，Block方式
    public var eventFinished: ((UIView, Notification) -> Void)? {
        get { return base.__fw.eventFinished }
        set { base.__fw.eventFinished = newValue }
    }

    /// 发送指定事件，通知代理，支持附带对象和用户信息
    public func sendEvent(_ name: String, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        base.__fw.sendEvent(name, object: object, userInfo: userInfo)
    }

    /// 通知事件完成，自动调用eventFinished句柄和FWView.renderEvent钩子
    public func finishEvent(_ notification: Notification) {
        base.__fw.finishEvent(notification)
    }
    
}
