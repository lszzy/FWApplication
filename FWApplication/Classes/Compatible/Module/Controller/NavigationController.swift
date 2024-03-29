//
//  NavigationController.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UINavigationController {
    
    /// 自定义转场过程中containerView的背景色，默认透明
    public var containerBackgroundColor: UIColor {
        get { return base.__fw_containerBackgroundColor }
        set { base.__fw_containerBackgroundColor = newValue }
    }
    
    /// 全局启用NavigationBar转场。启用后各个ViewController管理自己的导航栏样式，在viewDidLoad或viewViewAppear中设置即可
    public static func enableBarTransition() {
        Base.__fw_enableBarTransition()
    }
    
    /// 是否启用导航栏全屏返回手势，默认NO。启用时系统返回手势失效，禁用时还原系统手势。如果只禁用系统手势，设置interactivePopGestureRecognizer.enabled即可
    public var fullscreenPopGestureEnabled: Bool {
        get { return base.__fw_fullscreenPopGestureEnabled }
        set { base.__fw_fullscreenPopGestureEnabled = newValue }
    }

    /// 导航栏全屏返回手势对象
    public var fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        return base.__fw_fullscreenPopGestureRecognizer
    }
    
    /// 判断手势是否是全局返回手势对象
    public static func isFullscreenPopGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return Base.__fw_isFullscreenPop(gestureRecognizer)
    }
    
}

extension Wrapper where Base: UIViewController {
    
    /// 转场动画自定义判断标识，不相等才会启用转场。默认nil启用转场。可重写或者push前设置生效
    public var barTransitionIdentifier: Any? {
        get { return base.__fw_barTransitionIdentifier }
        set { base.__fw_barTransitionIdentifier = newValue }
    }
    
    /// 视图控制器是否禁用全屏返回手势，默认NO
    public var fullscreenPopGestureDisabled: Bool {
        get { return base.__fw_fullscreenPopGestureDisabled }
        set { base.__fw_fullscreenPopGestureDisabled = newValue }
    }

    /// 视图控制器全屏手势距离左侧最大距离，默认0，无限制
    public var fullscreenPopGestureDistance: CGFloat {
        get { return base.__fw_fullscreenPopGestureDistance }
        set { base.__fw_fullscreenPopGestureDistance = newValue }
    }
    
}

extension Wrapper where Base: UINavigationBar {
    
    /// 导航栏背景视图，显示背景色和背景图片等
    public var backgroundView: UIView? {
        return base.__fw_backgroundView
    }
    
}
