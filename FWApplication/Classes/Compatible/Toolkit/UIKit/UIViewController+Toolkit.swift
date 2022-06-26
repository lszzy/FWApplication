//
//  UIViewController+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/**
 一、modalPresentationStyle需要在present之前(init之后)设置才会生效，UINavigationController也可设置。
 二、iOS13由于modalPresentationStyle默认值为Automatic(PageSheet)，不会触发父控制器的viewWillDisappear|viewWillAppear等生命周期方法。
 三、modalPresentationCapturesStatusBarAppearance：弹出非UIModalPresentationFullScreen控制器时，该控制器是否控制状态栏样式。默认NO，不控制。
 四、如果ScrollView占不满导航栏，iOS11则需要设置contentInsetAdjustmentBehavior为UIScrollViewContentInsetAdjustmentNever
 */
extension Wrapper where Base: UIViewController {
    
    // MARK: - Child

    /// 获取当前显示的子控制器，解决不能触发viewWillAppear等的bug
    public func childViewController() -> UIViewController? {
        return base.__fw_childViewController()
    }

    /// 设置当前显示的子控制器，解决不能触发viewWillAppear等的bug
    public func setChildViewController(_ viewController: UIViewController) {
        base.__fw_setChildViewController(viewController)
    }

    /// 移除子控制器，解决不能触发viewWillAppear等的bug
    public func removeChildViewController(_ viewController: UIViewController) {
        base.__fw_removeChildViewController(viewController)
    }

    /// 添加子控制器到当前视图，解决不能触发viewWillAppear等的bug
    public func addChildViewController(_ viewController: UIViewController) {
        base.__fw_addChildViewController(viewController)
    }

    /// 添加子控制器到指定视图，解决不能触发viewWillAppear等的bug
    public func addChildViewController(_ viewController: UIViewController, in view: UIView) {
        base.__fw_addChildViewController(viewController, in: view)
    }

    // MARK: - Previous

    /// 获取和自身处于同一个UINavigationController里的上一个UIViewController
    public weak var previousViewController: UIViewController? {
        return base.__fw_previousViewController
    }
    
    // MARK: - Style
    
    /// 全局适配iOS13默认present样式(系统Automatic)，仅当未自定义modalPresentationStyle时生效
    public static var defaultModalPresentationStyle: UIModalPresentationStyle {
        get { return Base.__fw_defaultModalPresentationStyle }
        set { Base.__fw_defaultModalPresentationStyle = newValue }
    }
    
}
