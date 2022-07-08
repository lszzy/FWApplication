//
//  HomeViewController.swift
//  Example
//
//  Created by wuyong on 2021/3/19.
//  Copyright © 2021 site.wuyong. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController, ViewControllerProtocol {
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 20, width: FW.screenWidth, height: 30)
        button.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: hotfix
        view.addSubview(loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: feature
        renderData()
    }
    
    func renderData() {
        #if RELEASE
        let envTitle = FW.localized("envProduction")
        #elseif STAGING
        let envTitle = FW.localized("envStaging")
        #elseif TESTING
        let envTitle = FW.localized("envTesting")
        #else
        let envTitle = FW.localized("envDevelopment")
        #endif
        fw.title = "\(FW.localized("homeTitle")) - \(envTitle)"
        
        if Mediator.userModule.isLogin() {
            loginButton.setTitle(FW.localized("backTitle"), for: .normal)
        } else {
            loginButton.setTitle(FW.localized("welcomeTitle"), for: .normal)
        }
    }
    
    // MARK: - Action
    @objc func onLogin() {
        if Mediator.userModule.isLogin() { return }
        
        Mediator.userModule.login { [weak self] in
            self?.renderData()
        }
    }
}
