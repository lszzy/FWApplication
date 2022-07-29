//
//  NavigationBar.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/29.
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - NavigationBarConfigurator
/// 导航栏样式配置
///
/// [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX)
@available(iOS 13.0, *)
struct NavigationBarConfigurator<Leading: View, Center: View, Trailing: View>: UIViewControllerRepresentable {
    class UIViewControllerType: UIViewController {
        var leading: Leading?
        var center: Center?
        var trailing: Trailing?
        var largeTrailingAlignment: VerticalAlignment?
        var displayMode: NavigationBarItem.TitleDisplayMode?
        
        var hasMovedToParentOnce: Bool = false
        var isVisible: Bool = false
        
        override func willMove(toParent parent: UIViewController?) {
            if !hasMovedToParentOnce {
                updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
                
                hasMovedToParentOnce = true
            }
            
            super.willMove(toParent: parent)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            isVisible = true
            
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController
            )
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            isVisible = false
            
            updateNavigationBar(viewController: parent?.navigationController?.visibleViewController)
        }
        
        func updateNavigationBar(viewController: UIViewController?) {
            guard let parent = viewController else {
                return
            }
            
            if let displayMode = displayMode {
                switch displayMode {
                    case .automatic:
                        parent.navigationItem.largeTitleDisplayMode = .automatic
                    case .inline:
                        parent.navigationItem.largeTitleDisplayMode = .never
                    case .large:
                        parent.navigationItem.largeTitleDisplayMode = .always
                    @unknown default:
                        parent.navigationItem.largeTitleDisplayMode = .automatic
                }
            }
            
            if let leading = leading {
                if !(leading is EmptyView) {
                    if parent.navigationItem.leftBarButtonItem == nil {
                        parent.navigationItem.leftBarButtonItem = .init(customView: HostingView(rootView: leading))
                    } else if let view = parent.navigationItem.leftBarButtonItem?.customView as? HostingView<Leading> {
                        view.rootView = leading
                    } else {
                        parent.navigationItem.leftBarButtonItem?.customView = HostingView(rootView: leading)
                    }
                }
            } else {
                parent.navigationItem.leftBarButtonItem = nil
            }
            
            if let center = center {
                if !(center is EmptyView) {
                    if let view = parent.navigationItem.titleView as? HostingView<Center> {
                        view.rootView = center
                    } else {
                        parent.navigationItem.titleView = HostingView(rootView: center)
                    }
                }
            } else {
                parent.navigationItem.titleView = nil
            }
            
            if let trailing = trailing {
                if !(trailing is EmptyView) {
                    if parent.navigationItem.rightBarButtonItem == nil {
                        parent.navigationItem.rightBarButtonItem = .init(customView: HostingView(rootView: trailing))
                    } else if let view = parent.navigationItem.rightBarButtonItem?.customView as? HostingView<Trailing> {
                        view.rootView = trailing
                    } else {
                        parent.navigationItem.rightBarButtonItem?.customView = HostingView(rootView: trailing)
                    }
                }
            } else {
                parent.navigationItem.rightBarButtonItem = nil
            }
            
            parent.navigationItem.leftBarButtonItem?.customView?.sizeToFit()
            parent.navigationItem.titleView?.sizeToFit()
            parent.navigationItem.rightBarButtonItem?.customView?.sizeToFit()
        }
    }
    
    let leading: Leading
    let center: Center
    let trailing: Trailing
    let displayMode: NavigationBarItem.TitleDisplayMode?
    
    init(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode?
    ) {
        self.leading = leading
        self.center = center
        self.trailing = trailing
        self.displayMode = displayMode
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init()
    }
    
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.displayMode = displayMode
        viewController.leading = leading
        viewController.center = center
        viewController.trailing = trailing
        
        viewController.updateNavigationBar(viewController: viewController.navigationController?.topViewController)
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewControllerType, coordinator: Coordinator) {
        uiViewController.largeTrailingAlignment = nil
        
        uiViewController.updateNavigationBar(viewController: uiViewController.navigationController?.topViewController)
    }
}

// MARK: - View+NavigationBar
@available(iOS 13.0, *)
extension View {
    
    public func navigationBarAppearance(_ block: @escaping () -> NavigationBarAppearance) -> some View {
        return introspectNavigationBar { navigationBar in
            navigationBar.fw.applyBarAppearance(block())
        }
    }
    
    public func navigationBarStyle(_ style: NavigationBarStyle) -> some View {
        return introspectNavigationBar { navigationBar in
            navigationBar.fw.applyBarStyle(style)
        }
    }
    
    public func navigationBarItems<Leading: View, Center: View, Trailing: View>(
        leading: Leading,
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode? = .automatic
    ) -> some View {
        background(
            NavigationBarConfigurator(
                leading: leading,
                center: center,
                trailing: trailing,
                displayMode: displayMode
            )
        )
    }
        
    public func navigationBarItems<Leading: View, Center: View>(
        leading: Leading,
        center: Center,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(
            leading: leading,
            center: center,
            trailing: EmptyView(),
            displayMode: displayMode
        )
    }
    
    public func navigationBarTitleView<V: View>(
        _ center: V,
        displayMode: NavigationBarItem.TitleDisplayMode
    ) -> some View {
        navigationBarItems(
            leading: EmptyView(),
            center: center,
            trailing: EmptyView(),
            displayMode: displayMode
        )
    }
    
    public func navigationBarItems<Center: View, Trailing: View>(
        center: Center,
        trailing: Trailing,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        navigationBarItems(
            leading: EmptyView(),
            center: center,
            trailing: trailing,
            displayMode: displayMode
        )
    }
    
}

#endif
