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

@available(iOS 13.0, *)
class SwiftUIViewController: HostingController {
    
    override func setupSubviews() {
        hidesBottomBarWhenPushed = true
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.hidesBackButton = true
        fw.navigationBarHidden = [true, false].randomElement()!
        
        rootView = TestSwiftUIView()
            .viewContext(self)
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
                title: Text("SwiftUIViewController"),
                background: Color(UIColor.fw.randomColor)
            )
            .eraseToAnyView()
    }
    
}

@available(iOS 13.0, *)
class TestSwiftUIViewController: TestViewController {
    
    override func renderView() {
        fw.navigationBarHidden = [true, false].randomElement()!
        
        let hostingView = TestSwiftUIView()
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
    
}

@available(iOS 13.0, *)
struct TestSwiftUIView: View {
    
    @Environment(\.viewContext) var viewContext: ViewContext
    
    @State var isEmpty: Bool = false
    @State var topSize: CGSize = .zero
    
    @State var buttonRemovable: Bool = false
    @State var buttonVisible: Bool = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
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
            
            List {
                Button("Open Router") {
                    Router.openURL("https://www.baidu.com")
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
                    viewContext.viewController?.fw.showAlert(title: "我是标题", message: "我是内容")
                }
                
                Button("Show Loading") {
                    viewContext.viewController?.fw.showLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        viewContext.viewController?.fw.hideLoading()
                    }
                }
                
                Button("Show Progress") {
                    TestViewController.mockProgress { progress, finished in
                        if finished {
                            viewContext.viewController?.fw.hideProgress()
                        } else {
                            viewContext.viewController?.fw.showProgress(progress, text: "上传中(\(Int(progress * 100)))")
                        }
                    }
                }
                
                Button("Show Message") {
                    viewContext.viewController?.fw.showMessage(text: "我是提示信息")
                }
                
                Button("Show Empty") {
                    isEmpty = true
                    viewContext.viewController?.fw.showEmptyView(text: "我是标题", detail: "我是详细信息", image: UIImage.fw.appIconImage(), action: "刷新", block: { _ in
                        viewContext.viewController?.fw.hideEmptyView()
                        isEmpty = false
                    })
                }
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
        .hidden(isEmpty)
    }
    
}

#endif
