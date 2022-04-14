//
//  TestAnnotationViewController.swift
//  Example
//
//  Created by wuyong on 2020/12/2.
//  Copyright © 2020 site.wuyong. All rights reserved.
//

import UIKit

// MARK: - FWPluginAnnotation

@objc protocol TestPluginProtocol {
    func pluginMethod()
}

@objc class TestPluginImpl: NSObject, TestPluginProtocol {
    func pluginMethod() {
        UIWindow.fw.showMessage(withText: "TestPluginImpl")
    }
}

class TestPluginManager {
    @FWPluginAnnotation(TestPluginProtocol.self)
    static var testPlugin: TestPluginProtocol
}

// MARK: - FWRouterAnnotation

class TestRouter {
    @FWRouterAnnotation(TestRouter.pluginRouter(_:))
    static var pluginUrl: String = "app://plugin/:id"
    
    static func pluginRouter(_ context: FWRouterContext) -> Any? {
        let pluginId = FWSafeString(context.urlParameters["id"])
        UIWindow.fw.showMessage(withText: "plugin - \(pluginId)")
        return nil
    }
}

// MARK: - TestAnnotationViewController

@objcMembers class TestAnnotationViewController: TestViewController {
    var pluginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("插件注解", for: .normal)
        return button
    }()
    
    var routerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("路由注解", for: .normal)
        return button
    }()
    
    override func renderView() {
        view.addSubview(pluginButton)
        view.addSubview(routerButton)
        pluginButton.fw.layoutChain.centerX().top(50).size(CGSize(width: 100, height: 50))
        routerButton.fw.layoutChain.centerX().top(150).size(CGSize(width: 100, height: 50))
    }
    
    override func renderData() {
        TestPluginManager.testPlugin = TestPluginImpl()
        pluginButton.fw.addTouch { (sender) in
            TestPluginManager.testPlugin.pluginMethod()
        }
        
        routerButton.fw.addTouch { (sender) in
            FWRouter.openURL(FWRouter.generateURL(TestRouter.pluginUrl, parameters: 1))
        }
    }
}
