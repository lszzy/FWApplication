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
    
    var hidesNavbar = false
    
    override func setupSubviews() {
        hidesBottomBarWhenPushed = true
        extendedLayoutIncludesOpaqueBars = true
        
        rootView = TestSwiftUIView()
            .viewContext(self, userInfo: ["hidesNavbar": hidesNavbar])
            .navigationBarHidden(hidesNavbar)
            .navigationBarBackButtonHidden(true)
            .navigationBarStyle(.default)
            .navigationBarItems(leading: Button(action: {
                UIWindow.fw.close()
            }, label: {
                HStack {
                    Spacer()
                    Image(uiImage: Icon.backImage?.fw.image(tintColor: Theme.textColor) ?? UIImage())
                    Spacer()
                }
            }), center: Text("SwiftUIViewController"))
            .eraseToAnyView()
    }
    
}

@available(iOS 13.0, *)
class TestSwiftUIViewController: TestViewController {
    
    var hidesNavbar = false
    
    override func renderView() {
        fw.navigationBarHidden = hidesNavbar
        
        let hostingView = TestSwiftUIView()
            .viewContext(self, userInfo: ["hidesNavbar": hidesNavbar])
            .navigationBarItems(leading: Button(action: { [weak self] in
                self?.fw.close()
            }, label: {
                HStack {
                    Spacer()
                    Image(uiImage: Icon.backImage?.fw.image(tintColor: Theme.textColor) ?? UIImage())
                    Spacer()
                }
            }), center: Text("TestSwiftUIViewController"))
            .wrappedHostingView()
        view.addSubview(hostingView)
        hostingView.fw.layoutChain.edges()
    }
    
}

@available(iOS 13.0, *)
struct TestSwiftUIView: View {
    
    @Environment(\.viewContext) var viewContext: ViewContext
    
    @State var isEmpty: Bool = false
    
    @State var buttonRemovable: Bool = false
    @State var buttonVisible: Bool = true
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
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
            .padding(.top, 16)
            
            HStack(alignment: .center, spacing: 16) {
                Button {
                    buttonVisible.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Text("Visible")
                        Spacer()
                    }
                }
                .frame(width: (FW.screenWidth - 48) / 2, height: 40)
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
                .frame(width: (FW.screenWidth - 48) / 2, height: 40)
                .border(Color.gray, cornerRadius: 20)
                .visible(buttonVisible)
            }
            
            List {
                Button("Open Router") {
                    Router.openURL("https://www.baidu.com")
                }
                
                Button("Open SwiftUI") {
                    let viewController = TestSwiftUIViewController()
                    let userInfo = viewContext.userInfo ?? [:]
                    viewController.hidesNavbar = !userInfo["hidesNavbar"].safeBool
                    Router.push(viewController, animated: true)
                }
                
                Button("Open HostingController") {
                    let viewController = SwiftUIViewController()
                    let userInfo = viewContext.userInfo ?? [:]
                    viewController.hidesNavbar = !userInfo["hidesNavbar"].safeBool
                    UIWindow.fw.topNavigationController?.pushViewController(viewController, animated: true)
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
