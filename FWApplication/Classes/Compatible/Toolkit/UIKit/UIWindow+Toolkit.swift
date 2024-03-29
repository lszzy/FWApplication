//
//  UIWindow+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIWindow {
    
    /// 关闭所有弹出控制器，完成时回调。如果没有present控制器，直接回调
    public func dismissViewControllers(_ completion: (() -> Void)? = nil) {
        base.__fw_dismissViewControllers(completion)
    }
    
    /// 选中并获取指定索引TabBar根视图控制器，适用于Tabbar包含多个Navigation结构，找不到返回nil
    @discardableResult
    public func selectTabBarIndex(_ index: UInt) -> UIViewController? {
        return base.__fw_selectTabBarIndex(index)
    }

    /// 选中并获取指定类TabBar根视图控制器，适用于Tabbar包含多个Navigation结构，找不到返回nil
    @discardableResult
    public func selectTabBarController(_ viewController: AnyClass) -> UIViewController? {
        return base.__fw_selectTabBarController(viewController)
    }

    /// 选中并获取指定条件TabBar根视图控制器，适用于Tabbar包含多个Navigation结构，找不到返回nil
    @discardableResult
    public func selectTabBarBlock(_ block: (UIViewController) -> Bool) -> UIViewController? {
        return base.__fw_selectTabBarBlock(block)
    }
    
}
