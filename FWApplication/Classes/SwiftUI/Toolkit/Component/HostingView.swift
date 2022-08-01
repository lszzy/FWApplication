//
//  HostingView.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/28.
//

#if canImport(SwiftUI)
import SwiftUI
import FWFramework

// MARK: - HostingView
/// SwiftUI视图包装类
///
/// [SwiftUIX](https://github.com/SwiftUIX/SwiftUIX)
@available(iOS 13.0, *)
open class HostingView<Content: View>: UIView {
    
    // MARK: - Accessor
    public var rootView: Content {
        get { contentHostingController.rootView.content }
        set { contentHostingController.rootView.content = newValue }
    }
    
    private let contentHostingController: ContentHostingController
    
    struct ContentContainer: View {
        weak var parent: ContentHostingController?
        
        var content: Content
        
        var body: some View {
            content
        }
    }
    
    class ContentHostingController: UIHostingController<ContentContainer> {
        weak var _navigationController: UINavigationController?
        
        override var navigationController: UINavigationController? {
            super.navigationController ?? _navigationController
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            view.backgroundColor = .clear
        }
    }
    
    // MARK: - Lifecycle
    public required init(rootView: Content) {
        self.contentHostingController = .init(rootView: .init(parent: nil, content: rootView))
        self.contentHostingController.rootView.parent = contentHostingController
        super.init(frame: .zero)
                
        addSubview(contentHostingController.view)
        contentHostingController.view.backgroundColor = .clear
        contentHostingController.view.fw.pinEdges()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)
        
        let viewController = superview?.fw.viewController
        contentHostingController._navigationController = viewController?.navigationController ?? (viewController as? UINavigationController)
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let viewController = superview?.fw.viewController
        contentHostingController._navigationController = viewController?.navigationController ?? (viewController as? UINavigationController)
    }
    
    open override var frame: CGRect {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    open override var bounds: CGRect {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override open var intrinsicContentSize: CGSize {
        contentHostingController.view.intrinsicContentSize
    }
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentHostingController.view.intrinsicContentSize
    }
    
}

// MARK: - StateView
/// SwiftUI视图状态枚举
@available(iOS 13.0, *)
public enum ViewState: Int {
    case ready = 0
    case loading = 1
    case success = 2
    case failure = 3
}

/// SwiftUI状态视图
@available(iOS 13.0, *)
public struct StateView<Ready: View, Loading: View, Content: View, Failure: View>: View {
    
    @State public var state: ViewState
    
    @ViewBuilder var ready: (Self) -> Ready
    @ViewBuilder var loading: (Self) -> Loading
    @ViewBuilder var content: (Self) -> Content
    @ViewBuilder var failure: (Self) -> Failure
    
    public init(
        @ViewBuilder content: @escaping (Self) -> Content
    ) where Ready == EmptyView, Loading == EmptyView, Failure == EmptyView {
        self.ready = { _ in EmptyView() }
        self.loading = { _ in EmptyView() }
        self.content = content
        self.failure = { _ in EmptyView() }
        self.state = .success
    }
    
    public init(
        @ViewBuilder loading: @escaping (Self) -> Loading,
        @ViewBuilder content: @escaping (Self) -> Content,
        @ViewBuilder failure: @escaping (Self) -> Failure
    ) where Ready == EmptyView {
        self.ready = { _ in EmptyView() }
        self.loading = loading
        self.content = content
        self.failure = failure
        self.state = .loading
    }
    
    public init(
        @ViewBuilder ready: @escaping (Self) -> Ready,
        @ViewBuilder loading: @escaping (Self) -> Loading,
        @ViewBuilder content: @escaping (Self) -> Content,
        @ViewBuilder failure: @escaping (Self) -> Failure
    ) {
        self.ready = ready
        self.loading = loading
        self.content = content
        self.failure = failure
        self.state = .ready
    }
    
    public var body: some View {
        Group {
            switch state {
            case .ready:
                ready(self)
            case .loading:
                loading(self)
            case .success:
                content(self)
            case .failure:
                failure(self)
            }
        }
    }
    
}

// MARK: - HostingController
/// SwiftUI控制器包装类，可将View事件用delegate代理到VC实现解耦
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

// MARK: - View+HostingView
@available(iOS 13.0, *)
extension View {
    
    /// 快速包装到HostingView
    public func wrappedHostingView() -> HostingView<AnyView> {
        return HostingView(rootView: AnyView(self))
    }
    
}

#endif
