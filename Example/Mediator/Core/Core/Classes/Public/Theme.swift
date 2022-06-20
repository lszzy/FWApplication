//
//  CoreModule.swift
//  Core
//
//  Created by wuyong on 2021/1/1.
//

import FWApplication
import UIKit

@objcMembers public class Theme: NSObject {
    @UserDefaultAnnotation("isLargeTitles", defaultValue: false)
    public static var isLargeTitles: Bool
    
    @UserDefaultAnnotation("isBarTranslucent", defaultValue: false)
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
        UIColor.fw.themeLight(.fw.color(hex: 0xFAFAFA), dark: .fw.color(hex: 0x121212))
    }
    public static var tableColor: UIColor {
        UIColor.fw.themeLight(.fw.color(hex: 0xF2F2F2), dark: .fw.color(hex: 0x000000))
    }
    public static var cellColor: UIColor {
        UIColor.fw.themeLight(.fw.color(hex: 0xFFFFFF), dark: .fw.color(hex: 0x1C1C1C))
    }
    public static var borderColor: UIColor {
        UIColor.fw.themeLight(.fw.color(hex: 0xDDDDDD), dark: .fw.color(hex: 0x303030))
    }
    public static var buttonColor: UIColor {
        UIColor.fw.themeLight(.fw.color(hex: 0x017AFF), dark: .fw.color(hex: 0x0A84FF))
    }
    
    public static func largeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage.fw.image(color: Theme.buttonColor), for: .normal)
        button.titleLabel?.font = .fw.boldFont(ofSize: 17)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.fw.setDimension(.width, size: FW.screenWidth - 30)
        button.fw.setDimension(.height, size: 50)
        return button
    }
    
    public static func themeChanged() {
        let defaultAppearance = NavigationBarAppearance()
        defaultAppearance.foregroundColor = Theme.textColor
        defaultAppearance.backgroundColor = Theme.isBarTranslucent ? Theme.barColor.fw.color(alpha: 0.5) : Theme.barColor
        defaultAppearance.isTranslucent = Theme.isBarTranslucent
        let whiteAppearance = NavigationBarAppearance()
        whiteAppearance.foregroundColor = .black
        whiteAppearance.backgroundColor = Theme.isBarTranslucent ? .white.fw.color(alpha: 0.5) : .white
        whiteAppearance.isTranslucent = Theme.isBarTranslucent
        let transparentAppearance = NavigationBarAppearance()
        transparentAppearance.foregroundColor = Theme.textColor
        transparentAppearance.backgroundTransparent = true
        NavigationBarAppearance.setAppearance(defaultAppearance, forStyle: .default)
        NavigationBarAppearance.setAppearance(whiteAppearance, forStyle: .white)
        NavigationBarAppearance.setAppearance(transparentAppearance, forStyle: .transparent)
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
        UITableView.fw.resetTableStyle()
        // 启用返回代理拦截
        UINavigationController.fw.enablePopProxy()
        // 控制器样式设置
        ViewControllerManager.sharedInstance.hookInit = { viewController in
            viewController.edgesForExtendedLayout = Theme.isBarTranslucent ? .all : .bottom
            viewController.extendedLayoutIncludesOpaqueBars = true
            viewController.hidesBottomBarWhenPushed = true
            viewController.fw.navigationBarHidden = false
            viewController.fw.navigationBarStyle = .default
        }
        ViewControllerManager.sharedInstance.hookLoadView = { viewController in
            viewController.view.backgroundColor = Theme.tableColor
        }
        ViewControllerManager.sharedInstance.hookViewDidLoad = { viewController in
            // 长按返回按钮会弹出返回菜单
            // viewController.fw.backBarItem = Icon.backImage
            // 无返回按钮，不会弹出返回菜单
            if (viewController.navigationController?.children.count ?? 0) > 1 {
                viewController.fw.leftBarItem = Icon.backImage
            }
            viewController.navigationController?.navigationBar.prefersLargeTitles = Theme.isLargeTitles
        }
        ViewControllerManager.sharedInstance.hookTableViewController = { viewController in
            viewController.tableView.backgroundColor = Theme.tableColor
        }
    }
    
    private static func setupPlugin() {
        // 吐司等插件设置
        ToastPluginImpl.sharedInstance.defaultLoadingText = {
            return NSAttributedString(string: "加载中...")
        }
        ToastPluginImpl.sharedInstance.defaultProgressText = {
            return NSAttributedString(string: "上传中...")
        }
        ToastPluginImpl.sharedInstance.defaultMessageText = { (style) in
            switch style {
            case .success:
                return NSAttributedString(string: "操作成功")
            case .failure:
                return NSAttributedString(string: "操作失败")
            default:
                return nil
            }
        }
        ToastPluginImpl.sharedInstance.customBlock = { toastView in
            if toastView.type == .indicator {
                if (toastView.attributedTitle?.length ?? 0) < 1 {
                    toastView.contentBackgroundColor = .clear
                    toastView.indicatorColor = Theme.textColor
                }
            }
        }
        EmptyPluginImpl.sharedInstance.customBlock = { (emptyView) in
            emptyView.loadingViewColor = Theme.textColor
        }
        EmptyPluginImpl.sharedInstance.defaultText = {
            return "暂无数据"
        }
        EmptyPluginImpl.sharedInstance.defaultImage = {
            return UIImage.fw.appIconImage()
        }
        EmptyPluginImpl.sharedInstance.defaultAction = {
            return "重新加载"
        }
    }
}
