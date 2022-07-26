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
    
    public var userInfo: [AnyHashable: Any]?
    
    public init(_ viewController: UIViewController?, userInfo: [AnyHashable: Any]? = nil) {
        self.viewController = viewController
        self.userInfo = userInfo
    }
    
}

/// 视图上下文Key
@available(iOS 13.0, *)
public struct ViewContextKey: EnvironmentKey {
    
    public static var defaultValue: ViewContext {
        return ViewContext(nil)
    }
    
}

@available(iOS 13.0, *)
extension EnvironmentValues {
    
    /// 访问视图上下文
    public var viewContext: ViewContext {
        get { return self[ViewContextKey.self] }
        set { self[ViewContextKey.self] = newValue }
    }
    
}

@available(iOS 13.0, *)
extension View {
    
    /// 设置视图上下文
    public func viewContext(_ viewController: UIViewController?, userInfo: [AnyHashable: Any]? = nil) -> some View {
        return environment(\.viewContext, ViewContext(viewController, userInfo: userInfo))
    }
    
}

#endif
