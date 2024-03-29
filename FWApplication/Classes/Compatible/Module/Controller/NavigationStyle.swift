//
//  NavigationStyle.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
import FWFramework
#endif

extension Wrapper where Base: UINavigationBar {
    
    /// 应用指定导航栏配置
    public func applyBarAppearance(_ appearance: NavigationBarAppearance) {
        base.__fw_apply(appearance)
    }
    
    /// 应用指定导航栏样式
    public func applyBarStyle(_ style: NavigationBarStyle) {
        base.__fw_applyBarStyle(style)
    }
    
}

extension Wrapper where Base: UIViewController {
    
    /// 状态栏样式，默认UIStatusBarStyleDefault，设置后才会生效
    public var statusBarStyle: UIStatusBarStyle {
        get { return base.__fw_statusBarStyle }
        set { base.__fw_statusBarStyle = newValue }
    }

    /// 状态栏是否隐藏，默认NO，设置后才会生效
    public var statusBarHidden: Bool {
        get { return base.__fw_statusBarHidden }
        set { base.__fw_statusBarHidden = newValue }
    }

    /// 当前导航栏设置，优先级高于style，设置后会在viewWillAppear:自动应用生效
    public var navigationBarAppearance: NavigationBarAppearance? {
        get { return base.__fw_navigationBarAppearance }
        set { base.__fw_navigationBarAppearance = newValue }
    }

    /// 当前导航栏样式，默认Default，设置后才会在viewWillAppear:自动应用生效
    public var navigationBarStyle: NavigationBarStyle {
        get { return base.__fw_navigationBarStyle }
        set { base.__fw_navigationBarStyle = newValue }
    }

    /// 导航栏是否隐藏，默认NO，设置后才会在viewWillAppear:自动应用生效
    public var navigationBarHidden: Bool {
        get { return base.__fw_navigationBarHidden }
        set { base.__fw_navigationBarHidden = newValue }
    }

    /// 动态隐藏导航栏，如果当前已经viewWillAppear:时立即执行
    public func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        base.__fw_setNavigationBarHidden(hidden, animated: animated)
    }
    
    /// 是否允许child控制器修改导航栏样式，默认false
    public var allowsChildNavigation: Bool {
        get { return base.__fw_allowsChildNavigation }
        set { base.__fw_allowsChildNavigation = newValue }
    }

    /// 标签栏是否隐藏，默认为NO，立即生效。如果tabBar一直存在，则用tabBar包裹navBar；如果tabBar只存在主界面，则用navBar包裹tabBar
    public var tabBarHidden: Bool {
        get { return base.__fw_tabBarHidden }
        set { base.__fw_tabBarHidden = newValue }
    }
    
    /// 工具栏是否隐藏，默认为YES。需设置toolbarItems，立即生效
    public var toolBarHidden: Bool {
        get { return base.__fw_toolBarHidden }
        set { base.__fw_toolBarHidden = newValue }
    }
    
    /// 动态隐藏工具栏。需设置toolbarItems，立即生效
    public func setToolBarHidden(_ hidden: Bool, animated: Bool) {
        base.__fw_setToolBarHidden(hidden, animated: animated)
    }

    /// 设置视图布局Bar延伸类型，None为不延伸(Bar不覆盖视图)，Top|Bottom为顶部|底部延伸，All为全部延伸
    public var extendedLayoutEdge: UIRectEdge {
        get { return base.__fw_extendedLayoutEdge }
        set { base.__fw_extendedLayoutEdge = newValue }
    }
    
}
