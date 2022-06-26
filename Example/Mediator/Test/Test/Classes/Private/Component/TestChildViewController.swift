//
//  TestChildViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestChildViewController: TestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("父控制器viewDidLoad")
        
        let label = UILabel()
        label.textColor = Theme.textColor
        label.text = "我是父控制器"
        view.addSubview(label)
        label.fw.layoutChain.center()
        
        let childController = TestChildSubViewController()
        fw.addChildViewController(childController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("父控制器viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("父控制器viewDidAppear")
    }
}

@objcMembers class TestChildSubViewController: TestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("子控制器viewDidLoad")
        
        let label = UILabel()
        label.textColor = Theme.textColor
        label.text = "我是子控制器"
        view.addSubview(label)
        label.fw.layoutChain.center()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("子控制器viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("子控制器viewDidAppear")
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        NSLog("子控制器willMoveToParent")
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        NSLog("子控制器didMoveToParent")
    }
}
