//
//  CoreModule.swift
//  Core
//
//  Created by wuyong on 2021/1/1.
//

import FWApplication

@objcMembers public class Theme: NSObject {
    @FWUserDefaultAnnotation("isLargeTitles", defaultValue: false)
    public static var isLargeTitles: Bool
    
    @FWUserDefaultAnnotation("isBarTranslucent", defaultValue: false)
    public static var isBarTranslucent: Bool
    
    public static var backgroundColor: UIColor {
        UIColor.fw.themeLight(.white, dark: .black)
    }
    public static var textColor: UIColor {
        UIColor.fw.themeLight(.black, dark: .white)
    }
    public static var detailColor: UIColor {
        UIColor.fw.themeLight(UIColor.black.withAlphaComponent(0.5), dark: UIColor.white.withAlphaComponent(0.5))
    }
    public static var barColor: UIColor {
        UIColor.fw.themeLight(.fw.color(withHex: 0xFAFAFA), dark: .fw.color(withHex: 0x121212))
    }
    public static var tableColor: UIColor {
        UIColor.fw.themeLight(.fw.color(withHex: 0xF2F2F2), dark: .fw.color(withHex: 0x000000))
    }
    public static var cellColor: UIColor {
        UIColor.fw.themeLight(.fw.color(withHex: 0xFFFFFF), dark: .fw.color(withHex: 0x1C1C1C))
    }
    public static var borderColor: UIColor {
        UIColor.fw.themeLight(.fw.color(withHex: 0xDDDDDD), dark: .fw.color(withHex: 0x303030))
    }
    public static var buttonColor: UIColor {
        UIColor.fw.themeLight(.fw.color(withHex: 0x017AFF), dark: .fw.color(withHex: 0x0A84FF))
    }
    
    public static func largeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage.fw.image(with: Theme.buttonColor), for: .normal)
        button.titleLabel?.font = .fw.boldFont(ofSize: 17)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.fw.setDimension(.width, toSize: FWScreenWidth - 30)
        button.fw.setDimension(.height, toSize: 50)
        return button
    }
    
    public static func themeChanged() {
        let defaultAppearance = FWNavigationBarAppearance()
        defaultAppearance.foregroundColor = Theme.textColor
        defaultAppearance.backgroundColor = Theme.isBarTranslucent ? Theme.barColor.fw.color(withAlpha: 0.5) : Theme.barColor
        defaultAppearance.isTranslucent = Theme.isBarTranslucent
        let whiteAppearance = FWNavigationBarAppearance()
        whiteAppearance.foregroundColor = .black
        whiteAppearance.backgroundColor = Theme.isBarTranslucent ? .white.fw.color(withAlpha: 0.5) : .white
        whiteAppearance.isTranslucent = Theme.isBarTranslucent
        let transparentAppearance = FWNavigationBarAppearance()
        transparentAppearance.foregroundColor = Theme.textColor
        transparentAppearance.backgroundTransparent = true
        FWNavigationBarAppearance.setAppearance(defaultAppearance, forStyle: .default)
        FWNavigationBarAppearance.setAppearance(whiteAppearance, forStyle: .white)
        FWNavigationBarAppearance.setAppearance(transparentAppearance, forStyle: .transparent)
    }
}

extension Theme {
    static func setupTheme() {
        setupAppearance()
        setupPlugin()
    }
    
    private static func setupAppearance() {
        // 导航栏样式设置
        themeChanged()
        
        // iOS15兼容设置
        UITableView.fwResetTableStyle()
        // 控制器样式设置
        FWViewControllerManager.sharedInstance.hookInit = { viewController in
            viewController.edgesForExtendedLayout = Theme.isBarTranslucent ? .all : .bottom
            viewController.extendedLayoutIncludesOpaqueBars = true
            viewController.hidesBottomBarWhenPushed = true
            viewController.fw.navigationBarHidden = false
            viewController.fw.navigationBarStyle = .default
            viewController.fw.forcePopGesture = true
        }
        FWViewControllerManager.sharedInstance.hookLoadView = { viewController in
            viewController.view.backgroundColor = Theme.tableColor
        }
        FWViewControllerManager.sharedInstance.hookViewDidLoad = { viewController in
            viewController.fw.backBarItem = FWIcon.backImage
            viewController.navigationController?.navigationBar.prefersLargeTitles = Theme.isLargeTitles
        }
        FWViewControllerManager.sharedInstance.hookTableViewController = { viewController in
            viewController.tableView.backgroundColor = Theme.tableColor
        }
    }
    
    private static func setupPlugin() {
        // 吐司等插件设置
        FWToastPluginImpl.sharedInstance.defaultLoadingText = {
            return NSAttributedString(string: "加载中...")
        }
        FWToastPluginImpl.sharedInstance.defaultProgressText = {
            return NSAttributedString(string: "上传中...")
        }
        FWToastPluginImpl.sharedInstance.defaultMessageText = { (style) in
            switch style {
            case .success:
                return NSAttributedString(string: "操作成功")
            case .failure:
                return NSAttributedString(string: "操作失败")
            default:
                return nil
            }
        }
        FWEmptyPluginImpl.sharedInstance.customBlock = { (emptyView) in
            emptyView.loadingViewColor = Theme.textColor
        }
        FWEmptyPluginImpl.sharedInstance.defaultText = {
            return "暂无数据"
        }
        FWEmptyPluginImpl.sharedInstance.defaultImage = {
            return UIImage.fwImageWithAppIcon()
        }
        FWEmptyPluginImpl.sharedInstance.defaultAction = {
            return "重新加载"
        }
    }
}
