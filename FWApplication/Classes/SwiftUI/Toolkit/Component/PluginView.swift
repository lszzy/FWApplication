//
//  PluginIntrospect.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/28.
//

#if canImport(SwiftUI)
import SwiftUI
#if FWMacroSPM
import FWApplication
import FWApplicationCompatible
#endif

@available(iOS 13.0, *)
extension View {
    
    /// 显示通用控制器插件，自动切换
    public func showPlugin(_ isShowing: Binding<Bool>, customize: @escaping (UIViewController) -> Void) -> some View {
        return then(isShowing.wrappedValue) { view in
            view.viewControllerConfigure { viewController in
                isShowing.wrappedValue = false
                customize(viewController)
            }
        }
    }
    
    /// 显示控制器弹窗插件，自动切换
    public func showAlert(_ isShowing: Binding<Bool>, customize: @escaping (UIViewController) -> Void) -> some View {
        return showPlugin(isShowing, customize: customize)
    }
    
    /// 显示控制器消息吐司插件，自动切换
    public func showMessage(_ isShowing: Binding<Bool>, customize: @escaping (UIViewController) -> Void) -> some View {
        return showPlugin(isShowing, customize: customize)
    }
    
    /// 显示控制器空界面插件，需手工切换
    public func showEmpty(_ isShowing: Bool, customize: ((UIViewController) -> Void)? = nil) -> some View {
        return viewControllerConfigure { viewController in
            if isShowing {
                if let customize = customize {
                    customize(viewController)
                } else {
                    viewController.fw.showEmptyView()
                }
            } else {
                viewController.fw.hideEmptyView()
            }
        }
    }
    
    /// 显示控制器加载吐司插件，需手工切换
    public func showLoading(_ isShowing: Bool, customize: ((UIViewController) -> Void)? = nil) -> some View {
        return viewControllerConfigure { viewController in
            if isShowing {
                if let customize = customize {
                    customize(viewController)
                } else {
                    viewController.fw.showLoading()
                }
            } else {
                viewController.fw.hideLoading()
            }
        }
    }
    
    /// 显示控制器进度吐司插件，需手工切换
    public func showProgress(_ isShowing: Bool, customize: @escaping (UIViewController) -> Void) -> some View {
        return viewControllerConfigure { viewController in
            if isShowing {
                customize(viewController)
            } else {
                viewController.fw.hideProgress()
            }
        }
    }
    
}

#endif
