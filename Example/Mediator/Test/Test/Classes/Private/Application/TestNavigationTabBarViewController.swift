//
//  TestNavigationTabBarViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

class TestNavigationTabBarChildController: TestViewController {
    private lazy var navigationView: ToolbarView = {
        let result = ToolbarView(type: .navBar)
        result.backgroundColor = Theme.barColor
        result.tintColor = Theme.textColor
        result.menuView.leftButton = ToolbarButton(object: Icon.backImage, block: { sender in
            Router.closeViewController(animated: true)
        })
        return result
    }()
    
    override var title: String? {
        didSet {
            navigationView.menuView.title = title
        }
    }
    
    override func renderView() {
        fw.navigationBarHidden = true
        
        view.backgroundColor = UIColor.fw.randomColor
        view.addSubview(navigationView)
        navigationView.fw.layoutChain.left().right().top()
        view.fw.addTapGesture { [weak self] sender in
            let viewController = TestNavigationTabBarChildController()
            var title = FW.safeString(self?.title)
            if let index = title.firstIndex(of: "-") {
                let count = Int(title.suffix(from: title.index(index, offsetBy: 1))) ?? 0
                title = "\(title.prefix(upTo: index))-\(count + 1)"
            } else {
                title = "\(title)-1"
            }
            viewController.title = title
            Router.push(viewController, animated: true)
        }
    }
}

@objcMembers class TestNavigationTabBarViewController: TestViewController {
    private lazy var childView: UIView = {
        let result = UIView()
        return result
    }()
    
    private lazy var tabBarView: ToolbarView = {
        let result = ToolbarView(type: .tabBar)
        result.backgroundColor = Theme.barColor
        result.tintColor = Theme.textColor
        result.menuView.leftButton = homeButton
        result.menuView.centerButton = testButton
        result.menuView.rightButton = settingsButton
        return result
    }()
    
    private lazy var homeButton: ToolbarButton = {
        let result = ToolbarButton(image: TestBundle.imageNamed("tabbar_home"), title: "首页")
        result.titleLabel?.font = FW.font(10)
        result.fw.addTouch(target: self, action: #selector(onButtonClicked(_:)))
        result.tag = 1
        return result
    }()
    
    private lazy var testButton: ToolbarButton = {
        let result = ToolbarButton(image: TestBundle.imageNamed("tabbar_test"), title: "测试")
        result.titleLabel?.font = FW.font(10)
        result.fw.addTouch(target: self, action: #selector(onButtonClicked(_:)))
        result.tag = 2
        return result
    }()
    
    private lazy var settingsButton: ToolbarButton = {
        let result = ToolbarButton(image: TestBundle.imageNamed("tabbar_settings"), title: "设置")
        result.titleLabel?.font = FW.font(10)
        result.fw.addTouch(target: self, action: #selector(onButtonClicked(_:)))
        result.tag = 3
        return result
    }()
    
    private lazy var homeController: UIViewController = {
        let result = TestNavigationTabBarChildController()
        result.title = "首页"
        return result
    }()
    
    private lazy var testController: UIViewController = {
        let result = TestNavigationTabBarChildController()
        result.title = "测试"
        return result
    }()
    
    private lazy var settingsController: UIViewController = {
        let result = TestNavigationTabBarChildController()
        result.title = "设置"
        return result
    }()
    
    private var childController: UIViewController?
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        homeButton.contentEdgeInsets = UIEdgeInsets(top: FW.isLandscape ? 2 : 8, left: 8, bottom: FW.isLandscape ? 2 : 8, right: 8)
        homeButton.fw.setImageEdge(FW.isLandscape ? .left : .top, spacing: FW.isLandscape ? 4 : 2)
        testButton.contentEdgeInsets = homeButton.contentEdgeInsets
        testButton.fw.setImageEdge(FW.isLandscape ? .left : .top, spacing: FW.isLandscape ? 4 : 2)
        settingsButton.contentEdgeInsets = homeButton.contentEdgeInsets
        settingsButton.fw.setImageEdge(FW.isLandscape ? .left : .top, spacing: FW.isLandscape ? 4 : 2)
    }
    
    override func renderView() {
        view.addSubview(childView)
        view.addSubview(tabBarView)
        childView.fw.layoutChain.left().right().top()
        tabBarView.fw.layoutChain.left().right().bottom().top(toViewBottom: childView)
    }
    
    override func renderData() {
        fw.navigationBarHidden = true
        onButtonClicked(homeButton)
    }
    
    @objc func onButtonClicked(_ sender: UIButton) {
        if let child = childController {
            __fw.removeChildViewController(child)
        }
        
        var child: UIViewController
        if sender.tag == 1 {
            homeButton.tintColor = Theme.textColor
            testButton.tintColor = Theme.textColor.withAlphaComponent(0.6)
            settingsButton.tintColor = Theme.textColor.withAlphaComponent(0.6)
            
            child = homeController
        } else if sender.tag == 2 {
            homeButton.tintColor = Theme.textColor.withAlphaComponent(0.6)
            testButton.tintColor = Theme.textColor
            settingsButton.tintColor = Theme.textColor.withAlphaComponent(0.6)
            
            child = testController
        } else {
            homeButton.tintColor = Theme.textColor.withAlphaComponent(0.6)
            testButton.tintColor = Theme.textColor.withAlphaComponent(0.6)
            settingsButton.tintColor = Theme.textColor
            
            child = settingsController
        }
        __fw.addChildViewController(child, in: childView)
    }
}
