//
//  HostingController.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/28.
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - HostingController
/// SwiftUI控制器包装类，可将View事件用delegate代理到VC
///
/// Controller在MVVM中也为View的角色，可持有ViewModel，负责生命周期和界面跳转
@available(iOS 13.0, *)
open class HostingController: UIHostingController<AnyView> {
    
    // MARK: - Lifecyecle
    public init() {
        super.init(rootView: AnyView(EmptyView()))
        setupNavbar()
        setupSubviews()
    }
    
    @MainActor required dynamic public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AnyView(EmptyView()))
        setupNavbar()
        setupSubviews()
    }
    
    #if DEBUG
    deinit {
        NSLog("%@ did dealloc", NSStringFromClass(self.classForCoder))
    }
    #endif
    
    // MARK: - Setup
    /// 初始化导航栏，子类重写
    open func setupNavbar() {}
    
    /// 初始化子视图，子类重写，可结合StateView实现状态机
    open func setupSubviews() {}
    
}

#endif
