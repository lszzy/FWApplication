//
//  TabBarController.swift
//  Example
//
//  Created by wuyong on 2021/3/19.
//  Copyright © 2021 site.wuyong. All rights reserved.
//

import FWApplication

extension UITabBarController: UITabBarControllerDelegate {
    // MARK: - Static
    static func setupController() -> UIViewController {
        let tabBarController = AppConfig.isRootCustom ? TabBarController() : UITabBarController()
        tabBarController.setupController()
        if !AppConfig.isRootNavigation { return tabBarController }
        
        let navigationController = UINavigationController(rootViewController: tabBarController)
        navigationController.isNavigationBarHidden = true
        return navigationController
    }
    
    static func refreshController() {
        if #available(iOS 13.0, *) {
            if let sceneDelegate = UIWindow.fw.mainScene?.delegate as? FWApplication.SceneDelegate {
                sceneDelegate.setupController()
            }
        } else {
            if let appDelegate = UIApplication.shared.delegate as? FWApplication.AppDelegate {
                appDelegate.setupController()
            }
        }
    }
    
    // MARK: - Private
    private func setupController() {
        delegate = self
        tabBar.fw.isTranslucent = Theme.isBarTranslucent
        tabBar.fw.shadowColor = nil
        tabBar.fw.foregroundColor = Theme.textColor
        tabBar.fw.backgroundColor = Theme.isBarTranslucent ? Theme.barColor.fw.color(alpha: 0.5) : Theme.barColor
        
        let homeController = HomeViewController()
        homeController.hidesBottomBarWhenPushed = false
        let homeNav = UINavigationController(rootViewController: homeController)
        homeNav.tabBarItem.image = FW.iconImage("fa-home", 26)
        homeNav.tabBarItem.title = FW.localized("homeTitle")
        homeNav.tabBarItem.__fw.show(FWBadgeView(badgeStyle: .small), badgeValue: "1")
        
        let testController = Mediator.testModule.testViewController()
        testController.hidesBottomBarWhenPushed = false
        let testNav = UINavigationController(rootViewController: testController)
        testNav.tabBarItem.image = Icon.iconImage("fa-file-text", size: 26)
        testNav.tabBarItem.title = FW.localized("testTitle")
        
        let settingsControlelr = SettingsViewController()
        settingsControlelr.hidesBottomBarWhenPushed = false
        let settingsNav = UINavigationController(rootViewController: settingsControlelr)
        if AppConfig.isRootCustom {
            let tabBarItem = TabBarItem()
            tabBarItem.contentView.highlightTextColor = Theme.textColor
            tabBarItem.contentView.highlightIconColor = Theme.textColor
            settingsNav.tabBarItem = tabBarItem
            settingsNav.tabBarItem.badgeValue = ""
        } else {
            let badgeView = FWBadgeView(badgeStyle: .dot)
            settingsNav.tabBarItem.__fw.show(badgeView, badgeValue: nil)
        }
        settingsNav.tabBarItem.image = FW.icon("fa-wrench", 26)?.image
        settingsNav.tabBarItem.title = FW.localized("settingTitle")
        viewControllers = [homeNav, testNav, settingsNav]
        
        fw.observeNotification(NSNotification.Name.LanguageChanged) { (notification) in
            homeNav.tabBarItem.title = FW.localized("homeTitle")
            testNav.tabBarItem.title = FW.localized("testTitle")
            settingsNav.tabBarItem.title = FW.localized("settingTitle")
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController), index == 1 {
            if AppConfig.isRootLogin && !Mediator.userModule.isLogin() {
                Mediator.userModule.login { [weak self] in
                    if self?.viewControllers?.contains(viewController) ?? false {
                        self?.selectedViewController = viewController
                    }
                }
                return false
            }
        }
        
        return true
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        animation.duration = 0.3 * 2
        animation.calculationMode = .cubic
        
        var animationView = viewController.tabBarItem.__fw.imageView
        if let tabBarItem = viewController.tabBarItem as? TabBarItem {
            animationView = tabBarItem.contentView.imageView
        }
        animationView?.layer.add(animation, forKey: nil)
    }
}
