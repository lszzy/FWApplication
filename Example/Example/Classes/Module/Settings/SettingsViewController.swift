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
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: FWScreenWidth, height: 90))
        tableView.tableFooterView = footerView
        
        footerView.addSubview(loginButton)
        loginButton.fw.layoutChain.center()
    }
    
    func renderData() {
        fw.barTitle = FWLocalizedString("settingTitle")
        
        #if DEBUG
        fw.setRightBarItem(FWLocalizedString("debugButton")) { (sender) in
            if FWDebugManager.sharedInstance().isHidden {
                FWDebugManager.sharedInstance().show()
            } else {
                FWDebugManager.sharedInstance().hide()
            }
        }
        #endif
        
        if Mediator.userModule.isLogin() {
            loginButton.setTitle(FWLocalizedString("mediatorLogout"), for: .normal)
        } else {
            loginButton.setTitle(FWLocalizedString("mediatorLogin"), for: .normal)
        }
        
        tableData.removeAllObjects()
        tableData.add([FWLocalizedString("languageTitle"), "onLanguage"])
        tableData.add([FWLocalizedString("themeTitle"), "onTheme"])
        tableData.add([FWLocalizedString("rootTitle"), "onRoot"])
        tableData.add([FWLocalizedString("optionTitle"), "onOption"])
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
        fw.showConfirm(withTitle: FWLocalizedString("logoutConfirm"), message: nil, cancel: nil, confirm: nil) { [weak self] in
            Mediator.userModule.logout {
                self?.renderData()
            }
        }
    }
    
    @objc func onLanguage() {
        fw.showSheet(withTitle: FWLocalizedString("languageTitle"), message: nil, cancel: FWLocalizedString("取消"), actions: [FWLocalizedString("systemTitle"), "中文", "English", FWLocalizedString("changeTitle")]) { [weak self] (index) in
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
        var actions = [FWLocalizedString("systemTitle"), FWLocalizedString("themeLight")]
        if #available(iOS 13.0, *) {
            actions.append(FWLocalizedString("themeDark"))
        }
        actions.append(FWLocalizedString("changeTitle"))
        
        fw.showSheet(withTitle: FWLocalizedString("themeTitle"), message: nil, cancel: FWLocalizedString("取消"), actions: actions) { (index) in
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
        fw.showSheet(withTitle: FWLocalizedString("rootTitle"), message: nil, cancel: FWLocalizedString("取消"), actions: ["UITabBar+Navigation", "FWTabBar+Navigation", "Navigation+UITabBar", "Navigation+FWTabBar"]) { (index) in
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
        fw.showSheet(withTitle: FWLocalizedString("optionTitle"), message: nil, cancel: FWLocalizedString("取消"), actions: [AppConfig.isRootLogin ? FWLocalizedString("loginOptional") : FWLocalizedString("loginRequired"), Theme.isLargeTitles ? FWLocalizedString("normalTitles") : FWLocalizedString("largeTitles"), Theme.isBarTranslucent ? FWLocalizedString("defaultTitles") : FWLocalizedString("translucentTitles")]) { (index) in
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
        let text = FWSafeValue(rowData[0] as? String)
        let action = FWSafeValue(rowData[1] as? String)
        cell.textLabel?.text = text
        
        if "onLanguage" == action {
            var language = FWLocalizedString("systemTitle")
            if let localized = Bundle.fw.localizedLanguage, localized.count > 0 {
                language = localized.hasPrefix("zh") ? "中文" : "English"
            } else {
                language = language.appending("(\(FWSafeString(Bundle.fw.systemLanguage)))")
            }
            cell.detailTextLabel?.text = language
        } else if "onTheme" == action {
            let mode = FWThemeManager.sharedInstance.mode
            let theme = mode == .system ? FWLocalizedString("systemTitle").appending(FWThemeManager.sharedInstance.style == .dark ? "(\(FWLocalizedString("themeDark")))" : "(\(FWLocalizedString("themeLight")))") : (mode == .dark ? FWLocalizedString("themeDark") : FWLocalizedString("themeLight"))
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
            cell.detailTextLabel?.text = Theme.isBarTranslucent ? FWLocalizedString("translucentTitles") : FWLocalizedString("defaultTitles")
        } else {
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowData = tableData[indexPath.row] as! NSArray
        let action = FWSafeValue(rowData[1] as? String)
        fw.invokeMethod(Selector(action))
    }
}
