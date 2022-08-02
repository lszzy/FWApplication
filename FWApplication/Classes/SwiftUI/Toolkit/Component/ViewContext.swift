//
//  ViewContext.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/26.
//

#if canImport(SwiftUI)
import SwiftUI

/// 视图上下文
@available(iOS 13.0, *)
public struct ViewContext {
    
    public weak var viewController: UIViewController?
    
    public weak var view: UIView? {
        return viewController?.view
    }
    
    public weak var navigationController: UINavigationController? {
        return viewController?.navigationController
    }
    
    public init(_ viewController: UIViewController?) {
        self.viewController = viewController
    }
    
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    
    /// 视图上下文Key
    private struct ViewContextKey: EnvironmentKey {
        static var defaultValue: ViewContext {
            return ViewContext(nil)
        }
    }
    
    /// 访问视图上下文
    public var viewContext: ViewContext {
        get { return self[ViewContextKey.self] }
        set { self[ViewContextKey.self] = newValue }
    }
    
}

@available(iOS 13.0, *)
extension View {
    
    /// 设置视图上下文
    public func viewContext(_ viewController: UIViewController?) -> some View {
        return environment(\.viewContext, ViewContext(viewController))
    }
    
    /// 快速包装视图到上下文控制器
    public func wrappedContextController() -> UIHostingController<AnyView> {
        let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
        hostingController.rootView = AnyView(viewContext(hostingController))
        return hostingController
    }
    
}

@available(iOS 13.0, *)
extension UIHostingController where Content == AnyView {
    
    /// 快速创建视图上下文控制器
    public static func contextController<T: View>(@ViewBuilder _ builder: () -> T) -> UIHostingController<AnyView> {
        let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
        hostingController.rootView = AnyView(builder().viewContext(hostingController))
        return hostingController
    }
    
}

#endif
