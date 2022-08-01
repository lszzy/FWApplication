//
//  TestSwiftUIViewController.swift
//  Test
//
//  Created by wuyong on 2022/7/26.
//

#if canImport(SwiftUI)
import SwiftUI
import FWApplication
import Core

// 继承UIViewController
@available(iOS 13.0, *)
class TestSwiftUIViewController: TestViewController, TestSwiftUIViewDelegate {
    
    override func renderView() {
        fw.navigationBarHidden = [true, false].randomElement()!
        
        let hostingView = TestSwiftUIContent()
            .configure { $0.delegate = self }
            .viewContext(self)
            .navigationBarConfigure(
                leading: Icon.backImage,
                title: "TestSwiftUIViewController",
                background: UIColor.fw.randomColor
            )
            .wrappedHostingView()
        view.addSubview(hostingView)
        hostingView.fw.layoutChain.edges()
    }
    
    // MARK: - TestSwiftUIViewDelegate
    func openWeb(completion: @escaping () -> Void) {
        Router.openURL("https://www.baidu.com")
        completion()
    }
    
}

protocol TestSwiftUIViewDelegate {
    func openWeb(completion: @escaping () -> Void)
}

// 继承HostingController
@available(iOS 13.0, *)
class SwiftUIViewController: HostingController, TestSwiftUIViewDelegate {
    
    // MARK: - Accessor
    var mode: Int = [0, 1, 2].randomElement()!
    
    // MARK: - Subviews
    var stateView: some View {
        StateView { view in
            LoadingView()
                .onAppear {
                    view.state = .loading
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let success = [true, false].randomElement()!
                        if success {
                            view.state = .success
                        } else {
                            view.state = .failure
                        }
                    }
                }
        } content: { view in
            TestSwiftUIContent()
                .configure { $0.delegate = self }
        } failure: { view in
            Button("出错啦") {
                view.state = .success
            }
        }
    }
    
    // MARK: - Lifecycle
    override func setupNavbar() {
        hidesBottomBarWhenPushed = true
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.hidesBackButton = true
        if mode != 2 {
            fw.navigationBarHidden = [true, false].randomElement()!
        }
    }
    
    override func setupSubviews() {
        rootView = stateView
            .viewContext(self)
            .then(mode == 2, body: { view in
                view.navigationBarBackButtonHidden(true)
                    .navigationBarHidden([true, false].randomElement()!)
            })
            .navigationBarConfigure(
                leading: Button(action: {
                    UIWindow.fw.close()
                }, label: {
                    HStack {
                        Spacer()
                        Image(uiImage: Icon.backImage?.fw.image(tintColor: Theme.textColor) ?? UIImage())
                        Spacer()
                    }
                }),
                title: Text("SwiftUIViewController - \(mode)"),
                background: Color(UIColor.fw.randomColor)
            )
            .eraseToAnyView()
    }
    
    // MARK: - TestSwiftUIViewDelegate
    func openWeb(completion: @escaping () -> Void) {
        Router.openURL("https://www.baidu.com")
        completion()
    }
    
}

@available(iOS 13.0, *)
struct TestSwiftUIContent: View {
    
    @Environment(\.viewContext) var viewContext: ViewContext
    
    weak var delegate: (NSObject & TestSwiftUIViewDelegate)?
    
    @State var isEmpty: Bool = false
    @State var topSize: CGSize = .zero
    @State var contentOffset: CGPoint = .zero
    
    @State var buttonRemovable: Bool = false
    @State var buttonVisible: Bool = true
    
    @State var showingAlert: Bool = false
    @State var showingEmpty: Bool = false
    @State var showingLoading: Bool = false
    @State var showingProgress: Bool = false
    @State var showingMessage: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            List {
                VStack(alignment: .center, spacing: 16) {
                    Text("contentOffset: \(Int(contentOffset.y))")
                    
                    VStack {
                        HStack(alignment: .center, spacing: 50) {
                            ImageView(url: "https://ww4.sinaimg.cn/bmiddle/eaeb7349jw1ewbhiu69i2g20b4069e86.gif")
                                .placeholder(TestBundle.imageNamed("test.gif"))
                                .contentMode(.scaleAspectFill)
                                .clipped()
                                .cornerRadius(50)
                                .frame(width: 100, height: 100)
                            
                            WebImageView("http://kvm.wuyong.site/images/images/animation.png")
                                .resizable()
                                .clipped()
                                .frame(width: 100, height: 100)
                        }
                        
                        Text("width: \(Int(topSize.width)) height: \(Int(topSize.height))")
                    }
                    .padding(.top, 16)
                    .captureSize(in: $topSize)
                    
                    HStack(alignment: .center, spacing: 16) {
                        Button {
                            viewContext.viewController?.fw.close()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Close")
                                Spacer()
                            }
                        }
                        .frame(width: (FW.screenWidth - 64) / 3, height: 40)
                        .border(Color.gray, cornerRadius: 20)
                        
                        Button {
                            buttonVisible.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Visible")
                                Spacer()
                            }
                        }
                        .frame(width: (FW.screenWidth - 64) / 3, height: 40)
                        .border(Color.gray, cornerRadius: 20)
                        .removable(buttonRemovable)
                        
                        Button {
                            buttonRemovable.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Removable")
                                Spacer()
                            }
                        }
                        .frame(width: (FW.screenWidth - 64) / 3, height: 40)
                        .border(Color.gray, cornerRadius: 20)
                        .visible(buttonVisible)
                    }
                }
                .captureContentOffset(proxy: proxy)
                
                Button("Open Router") {
                    delegate?.openWeb(completion: {
                        showingEmpty = true
                    })
                }
                
                Button("Push SwiftUI") {
                    let viewController = TestSwiftUIViewController()
                    UIWindow.fw.topNavigationController?.pushViewController(viewController, animated: true)
                }
                
                Button("Push HostingController") {
                    let viewController = SwiftUIViewController()
                    viewContext.viewController?.fw.open(viewController)
                }
                
                Button("Present HostingController") {
                    let viewController = SwiftUIViewController()
                    viewContext.viewController?.present(viewController, animated: true)
                }
                
                Button("Show Alert") {
                    showingAlert = true
                }
                
                Button("Show Loading") {
                    showingLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingLoading = false
                    }
                }
                
                Button("Show Progress") {
                    showingProgress = true
                }
                
                Button("Show Message") {
                    showingMessage = true
                }
                
                Button("Show Empty") {
                    showingEmpty = true
                }
            }
            .captureContentOffset(in: $contentOffset)
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
        .removable(isEmpty)
        .showAlert($showingAlert) { viewController in
            viewController.fw.showAlert(title: "我是标题", message: "我是内容")
        }
        .showEmpty(showingEmpty) { viewController in
            isEmpty = true
            viewController.fw.showEmptyView(text: "我是标题", detail: "我是详细信息我是提示信息我是提示信息我是提示信息我是提示信息我是提示信息我是提示信息", image: UIImage.fw.appIconImage(), action: "刷新") { _ in
                showingEmpty = false
                isEmpty = false
            }
        }
        .showLoading(showingLoading)
        .showProgress(showingProgress, customize: { viewController in
            TestViewController.mockProgress { progress, finished in
                if finished {
                    showingProgress = false
                } else {
                    viewController.fw.showProgress(progress, text: "上传中(\(Int(progress * 100)))")
                }
            }
        })
        .showMessage($showingMessage, customize: { viewController in
            viewController.fw.showMessage(text: "我是提示信息我是提示信息我是提示信息我是提示信息我是提示信息我是提示信息我是提示信息")
        })
    }
    
}

#endif
