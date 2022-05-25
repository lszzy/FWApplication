//
//  NavigationStyle.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit

extension Wrapper where Base: UIViewController {
    
    /// 状态栏样式，默认UIStatusBarStyleDefault，设置后才会生效
    public var statusBarStyle: UIStatusBarStyle {
        get { return base.__fw.statusBarStyle }
        set { base.__fw.statusBarStyle = newValue }
    }

    /// 状态栏是否隐藏，默认NO，设置后才会生效
    public var statusBarHidden: Bool {
        get { return base.__fw.statusBarHidden }
        set { base.__fw.statusBarHidden = newValue }
    }

    /// 当前导航栏设置，优先级高于style，设置后会在viewWillAppear:自动应用生效
    public var navigationBarAppearance: NavigationBarAppearance? {
        get { return base.__fw.navigationBarAppearance }
        set { base.__fw.navigationBarAppearance = newValue }
    }

    /// 当前导航栏样式，默认Default，设置后才会在viewWillAppear:自动应用生效
    public var navigationBarStyle: NavigationBarStyle {
        get { return base.__fw.navigationBarStyle }
        set { base.__fw.navigationBarStyle = newValue }
    }

    /// 导航栏是否隐藏，默认NO，设置后才会在viewWillAppear:自动应用生效
    public var navigationBarHidden: Bool {
        get { return base.__fw.navigationBarHidden }
        set { base.__fw.navigationBarHidden = newValue }
    }

    /// 动态隐藏导航栏，如果当前已经viewWillAppear:时立即执行
    public func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        base.__fw.setNavigationBarHidden(hidden, animated: animated)
    }

    /// 标签栏是否隐藏，默认为NO，立即生效。如果tabBar一直存在，则用tabBar包裹navBar；如果tabBar只存在主界面，则用navBar包裹tabBar
    public var tabBarHidden: Bool {
        get { return base.__fw.tabBarHidden }
        set { base.__fw.tabBarHidden = newValue }
    }
    
    /// 工具栏是否隐藏，默认为YES。需设置toolbarItems，立即生效
    public var toolBarHidden: Bool {
        get { return base.__fw.toolBarHidden }
        set { base.__fw.toolBarHidden = newValue }
    }
    
    /// 动态隐藏工具栏。需设置toolbarItems，立即生效
    public func setToolBarHidden(_ hidden: Bool, animated: Bool) {
        base.__fw.setToolBarHidden(hidden, animated: animated)
    }

    /// 设置视图布局Bar延伸类型，None为不延伸(Bar不覆盖视图)，Top|Bottom为顶部|底部延伸，All为全部延伸
    public var extendedLayoutEdge: UIRectEdge {
        get { return base.__fw.extendedLayoutEdge }
        set { base.__fw.extendedLayoutEdge = newValue }
    }
    
}
