//
//  TestSwiftUIViewController.swift
//  Test
//
//  Created by wuyong on 2022/7/26.
//

#if canImport(SwiftUI)
import SwiftUI
import FWApplication

@available(iOS 13.0, *)
class SwiftUIViewController: UIHostingController<AnyView> {
    
    // MARK: - Lifecyecle
    init() {
        super.init(rootView: AnyView(EmptyView()))
        hidesBottomBarWhenPushed = true
        extendedLayoutIncludesOpaqueBars = true
        
        setupSubviews()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: AnyView(EmptyView()))
        hidesBottomBarWhenPushed = true
        extendedLayoutIncludesOpaqueBars = true
        
        setupSubviews()
    }
    
    deinit {
        NSLog("%@ did dealloc", NSStringFromClass(self.classForCoder))
    }
    
    // MARK: - Subviews
    func setupSubviews() {
        rootView = AnyView(
            TestSwiftUIView()
                .viewContext(self)
                .navigationBarHidden([true, false].randomElement()!)
        )
    }
    
}

@available(iOS 13.0, *)
class TestSwiftUIViewController: TestViewController {
    
    override func renderView() {
        let childVC = UIHostingController.contextController {
            TestSwiftUIView()
        }
        fw.addChildViewController(childVC) { view in
            view.fw.layoutChain
                .edges(excludingEdge: .top)
                .top(toSafeArea: .zero)
        }
    }
    
    override func renderNavbar() {
        navigationItem.title = "SwiftUIViewController"
    }
    
}

@available(iOS 13.0, *)
struct TestSwiftUIView: View {
    
    @Environment(\.viewContext) var viewContext: ViewContext
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center, spacing: 50) {
                ImageView(url: "https://ww4.sinaimg.cn/bmiddle/eaeb7349jw1ewbhiu69i2g20b4069e86.gif")
                    .placeholder(TestBundle.imageNamed("test.gif"))
                    .contentMode(.scaleAspectFill)
                    .clipped()
                    .cornerRadius(50)
                    .frame(width: 100, height: 100)
                
                WebImage("http://kvm.wuyong.site/images/images/animation.png")
                    .resizable()
                    .clipped()
                    .frame(width: 100, height: 100)
            }
            
            Text("Hello world")
            
            List {
                Button("Open Router") {
                    Router.openURL("https://www.baidu.com")
                }
                
                Button("Open SwiftUI") {
                    let viewController = TestSwiftUIViewController()
                    Router.push(viewController, animated: true)
                }
                
                Button("Open HostingController") {
                    let viewController = SwiftUIViewController()
                    Router.push(viewController, animated: true)
                }
                
                Button("Show Loading") {
                    UIWindow.fw.topViewController?.fw.showLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        UIWindow.fw.topViewController?.fw.hideLoading()
                    }
                }
                
                Button("Show Alert") {
                    viewContext.viewController?.fw.showAlert(title: "我是标题", message: "我是内容")
                }
                
                TestSwiftUIToast()
            }
            .introspectTableView { tableView in
                tableView.fw.setRefreshing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        tableView.fw.endRefreshing()
                    }
                }
                
                tableView.fw.setLoading {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        tableView.fw.endLoading()
                    }
                }
            }
        }
    }
    
}

@available(iOS 13.0, *)
struct TestSwiftUIToast: View {
    
    @Environment(\.viewContext) var viewContext: ViewContext
    
    var body: some View {
        Button("Show Toast") {
            viewContext.viewController?.fw.showMessage(text: "我是提示信息")
        }
    }
    
}

#endif
