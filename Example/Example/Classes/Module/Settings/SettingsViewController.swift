//
//  SettingsViewController.swift
//  Example
//
//  Created by wuyong on 2021/3/19.
//  Copyright © 2021 site.wuyong. All rights reserved.
//

import Foundation
#if DEBUG
import FWDebug
import FWFramework
#endif

class SettingsViewController: UIViewController, FWTableViewController {
    private lazy var loginButton: UIButton = {
        let button = Theme.largeButton()
        button.fw.addTouchTarget(self, action: #selector(onMediator))
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        renderData()
    }
    
    // MARK: - Protected
    func renderTableStyle() -> UITableView.Style {
        return .grouped
    }
    
    func renderTableView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: FW.screenWidth, height: 90))
        tableView.tableFooterView = footerView
        
        footerView.addSubview(loginButton)
        loginButton.fw.layoutChain.center()
    }
    
    func renderData() {
        fw.barTitle = FW.localized("settingTitle")
        
        #if DEBUG
        fw.setRightBarItem(FW.localized("debugButton")) { (sender) in
            if FWDebugManager.sharedInstance().isHidden {
                FWDebugManager.sharedInstance().show()
            } else {
                FWDebugManager.sharedInstance().hide()
            }
        }
        #endif
        
        if Mediator.userModule.isLogin() {
            loginButton.setTitle(FW.localized("mediatorLogout"), for: .normal)
        } else {
            loginButton.setTitle(FW.localized("mediatorLogin"), for: .normal)
        }
        
        tableData.removeAllObjects()
        tableData.add([FW.localized("languageTitle"), "onLanguage"])
        tableData.add([FW.localized("themeTitle"), "onTheme"])
        tableData.add([FW.localized("rootTitle"), "onRoot"])
        tableData.add([FW.localized("optionTitle"), "onOption"])
        tableView.reloadData()
    }
    
    // MARK: - Action
    @objc func onMediator() {
        if Mediator.userModule.isLogin() {
            onLogout()
        } else {
            onLogin()
        }
    }
    
    @objc func onLogin() {
        Mediator.userModule.login { [weak self] in
            self?.renderData()
        }
    }
    
    @objc func onLogout() {
        fw.showConfirm(withTitle: FW.localized("logoutConfirm"), message: nil, cancel: nil, confirm: nil) { [weak self] in
            Mediator.userModule.logout {
                self?.renderData()
            }
        }
    }
    
    @objc func onLanguage() {
        fw.showSheet(withTitle: FW.localized("languageTitle"), message: nil, cancel: FW.localized("取消"), actions: [FW.localized("systemTitle"), "中文", "English", FW.localized("changeTitle")]) { [weak self] (index) in
            if index < 3 {
                let language: String? = index == 1 ? "zh-Hans" : (index == 2 ? "en" : nil)
                Bundle.fw.localizedLanguage = language
                UITabBarController.refreshController()
            } else {
                let localized = Bundle.fw.localizedLanguage
                let language: String? = localized == nil ? "zh-Hans" : (localized!.hasPrefix("zh") ? "en" : nil)
                Bundle.fw.localizedLanguage = language
                self?.renderData()
            }
        }
    }
    
    @objc func onTheme() {
        var actions = [FW.localized("systemTitle"), FW.localized("themeLight")]
        if #available(iOS 13.0, *) {
            actions.append(FW.localized("themeDark"))
        }
        actions.append(FW.localized("changeTitle"))
        
        fw.showSheet(withTitle: FW.localized("themeTitle"), message: nil, cancel: FW.localized("取消"), actions: actions) { (index) in
            var mode = FWThemeMode(index)
            if index > actions.count - 2 {
                let currentMode = FWThemeManager.sharedInstance.mode
                mode = currentMode == .system ? .light : (currentMode == .light && actions.count > 3 ? .dark : .system)
            }
            FWThemeManager.sharedInstance.mode = mode
            UITabBarController.refreshController()
        }
    }
    
    @objc func onRoot() {
        fw.showSheet(withTitle: FW.localized("rootTitle"), message: nil, cancel: FW.localized("取消"), actions: ["UITabBar+Navigation", "FWTabBar+Navigation", "Navigation+UITabBar", "Navigation+FWTabBar"]) { (index) in
            switch index {
            case 0:
                AppConfig.isRootNavigation = false
                AppConfig.isRootCustom = false
            case 1:
                AppConfig.isRootNavigation = false
                AppConfig.isRootCustom = true
            case 2:
                AppConfig.isRootNavigation = true
                AppConfig.isRootCustom = false
            case 3:
                AppConfig.isRootNavigation = true
                AppConfig.isRootCustom = true
            default:
                break
            }
            UITabBarController.refreshController()
        }
    }
    
    @objc func onOption() {
        fw.showSheet(withTitle: FW.localized("optionTitle"), message: nil, cancel: FW.localized("取消"), actions: [AppConfig.isRootLogin ? FW.localized("loginOptional") : FW.localized("loginRequired"), Theme.isLargeTitles ? FW.localized("normalTitles") : FW.localized("largeTitles"), Theme.isBarTranslucent ? FW.localized("defaultTitles") : FW.localized("translucentTitles")]) { (index) in
            switch index {
            case 0:
                AppConfig.isRootLogin = !AppConfig.isRootLogin
            case 1:
                Theme.isLargeTitles = !Theme.isLargeTitles
            case 2:
                Theme.isBarTranslucent = !Theme.isBarTranslucent
            default:
                break
            }
            Theme.themeChanged()
            UITabBarController.refreshController()
        }
    }
}

extension SettingsViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.fw.cell(with: tableView, style: .value1)
        cell.accessoryType = .disclosureIndicator
        
        let rowData = tableData[indexPath.row] as! NSArray
        let text = FW.safeValue(rowData[0] as? String)
        let action = FW.safeValue(rowData[1] as? String)
        cell.textLabel?.text = text
        
        if "onLanguage" == action {
            var language = FW.localized("systemTitle")
            if let localized = Bundle.fw.localizedLanguage, localized.count > 0 {
                language = localized.hasPrefix("zh") ? "中文" : "English"
            } else {
                language = language.appending("(\(FW.safeString(Bundle.fw.systemLanguage)))")
            }
            cell.detailTextLabel?.text = language
        } else if "onTheme" == action {
            let mode = FWThemeManager.sharedInstance.mode
            let theme = mode == .system ? FW.localized("systemTitle").appending(FWThemeManager.sharedInstance.style == .dark ? "(\(FW.localized("themeDark")))" : "(\(FW.localized("themeLight")))") : (mode == .dark ? FW.localized("themeDark") : FW.localized("themeLight"))
            cell.detailTextLabel?.text = theme
        } else if "onRoot" == action {
            var root: String?
            if AppConfig.isRootNavigation {
                root = AppConfig.isRootCustom ? "Navigation+FWTabBar" : "Navigation+UITabBar"
            } else {
                root = AppConfig.isRootCustom ? "FWTabBar+Navigation" : "UITabBar+Navigation"
            }
            cell.detailTextLabel?.text = root
        } else if "onOption" == action {
            cell.detailTextLabel?.text = Theme.isBarTranslucent ? FW.localized("translucentTitles") : FW.localized("defaultTitles")
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowData = tableData[indexPath.row] as! NSArray
        let action = FW.safeValue(rowData[1] as? String)
        fw.invokeMethod(Selector(action))
    }
}
