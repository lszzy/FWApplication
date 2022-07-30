//
//  NavigationBar.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/29.
//

#if canImport(SwiftUI)
import SwiftUI
import FWFramework
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
import FWApplicationCompatible
#endif

// MARK: - NavigationBarConfiguration
/// 导航栏配置，兼容AnyView和UIKit对象
///
/// [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX)
@available(iOS 13.0, *)
public struct NavigationBarConfiguration {
    public var leading: Any?
    public var title: Any?
    public var trailing: Any?
    public var background: Any?
    public var style: NavigationBarStyle?
    public var appearance: (() -> NavigationBarAppearance)?
    public var customize: ((UIViewController) -> Void)?
    
    public init(
        leading: Any? = nil,
        title: Any? = nil,
        trailing: Any? = nil,
        background: Any? = nil,
        style: NavigationBarStyle? = nil,
        appearance: (() -> NavigationBarAppearance)? = nil,
        customize: ((UIViewController) -> Void)? = nil
    ) {
        self.leading = leading
        self.title = title
        self.trailing = trailing
        self.background = background
        self.style = style
        self.appearance = appearance
        self.customize = customize
    }
}

// MARK: - NavigationBarConfigurator
@available(iOS 13.0, *)
struct NavigationBarConfigurator: UIViewControllerRepresentable {
    // MARK: - Private
    class UIViewControllerType: UIViewController {
        var configuration: NavigationBarConfiguration?
        private var movedToParent: Bool = false
        
        override func willMove(toParent parent: UIViewController?) {
            if !movedToParent {
                movedToParent = true
                updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
            }
            super.willMove(toParent: parent)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController
            )
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
        }
        
        func updateNavigationBar(viewController: UIViewController?) {
            guard let parent = viewController else { return }
            
            if let leading = configuration?.leading as? AnyView {
                if parent.navigationItem.leftBarButtonItem == nil {
                    parent.navigationItem.leftBarButtonItem = .init(customView: HostingView(rootView: leading))
                } else if let view = parent.navigationItem.leftBarButtonItem?.customView as? HostingView<AnyView> {
                    view.rootView = leading
                } else {
                    parent.navigationItem.leftBarButtonItem?.customView = HostingView(rootView: leading)
                }
            } else if let leading = configuration?.leading {
                parent.fw.leftBarItem = leading
            }
            
            if let title = configuration?.title as? AnyView {
                if let view = parent.navigationItem.titleView as? HostingView<AnyView> {
                    view.rootView = title
                } else {
                    parent.navigationItem.titleView = HostingView(rootView: title)
                }
            } else if let title = configuration?.title {
                if let titleView = title as? UIView {
                    parent.navigationItem.titleView = titleView
                } else if let titleString = title as? String {
                    parent.navigationItem.title = titleString
                }
            }
            
            if let trailing = configuration?.trailing as? AnyView {
                if parent.navigationItem.rightBarButtonItem == nil {
                    parent.navigationItem.rightBarButtonItem = .init(customView: HostingView(rootView: trailing))
                } else if let view = parent.navigationItem.rightBarButtonItem?.customView as? HostingView<AnyView> {
                    view.rootView = trailing
                } else {
                    parent.navigationItem.rightBarButtonItem?.customView = HostingView(rootView: trailing)
                }
            } else if let trailing = configuration?.trailing {
                parent.fw.rightBarItem = trailing
            }
            
            parent.navigationItem.leftBarButtonItem?.customView?.sizeToFit()
            parent.navigationItem.titleView?.sizeToFit()
            parent.navigationItem.rightBarButtonItem?.customView?.sizeToFit()
            
            if let appearance = configuration?.appearance {
                parent.fw.navigationBarAppearance = appearance()
            } else if let style = configuration?.style {
                parent.fw.navigationBarStyle = style
            } else if let color = configuration?.background as? Color {
                parent.navigationController?.navigationBar.fw.backgroundColor = color.toUIColor()
            } else if let uiColor = configuration?.background as? UIColor {
                parent.navigationController?.navigationBar.fw.backgroundColor = uiColor
            }
            
            configuration?.customize?(parent)
        }
    }
    
    // MARK: - Lifecycle
    let configuration: NavigationBarConfiguration?
    
    init(configuration: NavigationBarConfiguration?) {
        self.configuration = configuration
    }
    
    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init()
    }
    
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.configuration = configuration
        viewController.updateNavigationBar(viewController: viewController.navigationController?.topViewController)
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {
        uiViewController.updateNavigationBar(viewController: uiViewController.navigationController?.topViewController)
    }
}

// MARK: - View+NavigationBar
@available(iOS 13.0, *)
extension View {
    
    /// 配置导航栏，兼容AnyView和UIKit对象
    public func navigationBarConfigure(
        _ configuration: NavigationBarConfiguration
    ) -> some View {
        background(
            NavigationBarConfigurator(configuration: configuration)
        )
    }
    
    /// 配置导航栏通用左侧、标题、右侧内容和可选背景
    public func navigationBarConfigure(
        leading: Any?,
        title: Any?,
        trailing: Any? = nil,
        background: Any? = nil
    ) -> some View {
        navigationBarConfigure(NavigationBarConfiguration(
            leading: leading,
            title: title,
            trailing: trailing,
            background: background
        ))
    }
    
    /// 配置导航栏SwiftUI左侧、标题、右侧视图和可选背景色
    public func navigationBarConfigure<Leading: View, Title: View, Trailing: View>(
        leading: Leading,
        title: Title,
        trailing: Trailing,
        background: Color? = nil
    ) -> some View {
        navigationBarConfigure(NavigationBarConfiguration(
            leading: AnyView(leading),
            title: AnyView(title),
            trailing: AnyView(trailing),
            background: background
        ))
    }
        
    /// 配置导航栏SwiftUI左侧、标题视图和可选背景色
    public func navigationBarConfigure<Leading: View, Title: View>(
        leading: Leading,
        title: Title,
        background: Color? = nil
    ) -> some View {
        navigationBarConfigure(NavigationBarConfiguration(
            leading: AnyView(leading),
            title: AnyView(title),
            background: background
        ))
    }
    
    /// 配置导航栏SwiftUI标题视图和可选背景色
    public func navigationBarConfigure<Title: View>(
        title: Title,
        background: Color? = nil
    ) -> some View {
        navigationBarConfigure(NavigationBarConfiguration(
            title: AnyView(title),
            background: background
        ))
    }
    
    /// 配置导航栏SwiftUI标题、右侧视图和可选背景色
    public func navigationBarConfigure<Title: View, Trailing: View>(
        title: Title,
        trailing: Trailing,
        background: Color? = nil
    ) -> some View {
        navigationBarConfigure(NavigationBarConfiguration(
            title: AnyView(title),
            trailing: AnyView(trailing),
            background: background
        ))
    }
    
}

#endif
