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
    
    @FWUserDefaultAnnotation("isExtendedBottom", defaultValue: true)
    public static var isExtendedBottom: Bool
    
    @FWUserDefaultAnnotation("isInsetNever", defaultValue: false)
    public static var isInsetNever: Bool
    
    public static var backgroundColor: UIColor {
        UIColor.fwThemeLight(.white, dark: .black)
    }
    public static var textColor: UIColor {
        UIColor.fwThemeLight(.black, dark: .white)
    }
    public static var detailColor: UIColor {
        UIColor.fwThemeLight(UIColor.black.withAlphaComponent(0.5), dark: UIColor.white.withAlphaComponent(0.5))
    }
    public static var barColor: UIColor {
        UIColor.fwThemeLight(.fwColor(withHex: 0xFAFAFA), dark: .fwColor(withHex: 0x121212))
    }
    public static var tableColor: UIColor {
        UIColor.fwThemeLight(.fwColor(withHex: 0xF2F2F2), dark: .fwColor(withHex: 0x000000))
    }
    public static var cellColor: UIColor {
        UIColor.fwThemeLight(.fwColor(withHex: 0xFFFFFF), dark: .fwColor(withHex: 0x1C1C1C))
    }
    public static var borderColor: UIColor {
        UIColor.fwThemeLight(.fwColor(withHex: 0xDDDDDD), dark: .fwColor(withHex: 0x303030))
    }
    public static var buttonColor: UIColor {
        UIColor.fwThemeLight(.fwColor(withHex: 0x017AFF), dark: .fwColor(withHex: 0x0A84FF))
    }
    
    public static func largeButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage.fwImage(with: Theme.buttonColor), for: .normal)
        button.titleLabel?.font = .fwBoldFont(ofSize: 17)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.fwSetDimension(.width, toSize: FWScreenWidth - 30)
        button.fwSetDimension(.height, toSize: 50)
        return button
    }
    
    public static func themeChanged() {
        let defaultAppearance = FWNavigationBarAppearance()
        defaultAppearance.foregroundColor = Theme.textColor
        defaultAppearance.backgroundColor = Theme.isBarTranslucent ? Theme.barColor.fwColor(withAlpha: 0.5) : Theme.barColor
        defaultAppearance.isTranslucent = Theme.isBarTranslucent
        let whiteAppearance = FWNavigationBarAppearance()
        whiteAppearance.foregroundColor = .black
        whiteAppearance.backgroundColor = Theme.isBarTranslucent ? .white.fwColor(withAlpha: 0.5) : .white
        whiteAppearance.isTranslucent = Theme.isBarTranslucent
        let transparentAppearance = FWNavigationBarAppearance()
        transparentAppearance.foregroundColor = Theme.textColor
        transparentAppearance.isTransparent = true
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
            viewController.edgesForExtendedLayout = Theme.isExtendedBottom ? .bottom : []
            viewController.extendedLayoutIncludesOpaqueBars = true
            viewController.hidesBottomBarWhenPushed = true
            viewController.fwNavigationBarStyle = .default
            viewController.fwForcePopGesture = true
        }
        FWViewControllerManager.sharedInstance.hookLoadView = { viewController in
            viewController.view.backgroundColor = Theme.tableColor
        }
        FWViewControllerManager.sharedInstance.hookViewDidLoad = { viewController in
            viewController.fwBackBarItem = FWIcon.backImage
            viewController.navigationController?.navigationBar.prefersLargeTitles = Theme.isLargeTitles
        }
        
        FWViewControllerManager.sharedInstance.hookScrollViewController = { viewController in
            viewController.edgesForExtendedLayout = Theme.isBarTranslucent ? .all : (Theme.isExtendedBottom ? .bottom : [])
            viewController.scrollView.contentInsetAdjustmentBehavior = Theme.isInsetNever ? .never : .automatic
        }
        FWViewControllerManager.sharedInstance.hookTableViewController = { viewController in
            viewController.edgesForExtendedLayout = Theme.isBarTranslucent ? .all : (Theme.isExtendedBottom ? .bottom : [])
            viewController.tableView.contentInsetAdjustmentBehavior = Theme.isInsetNever ? .never : .automatic
            viewController.tableView.backgroundColor = Theme.tableColor
        }
        FWViewControllerManager.sharedInstance.hookCollectionViewController = { viewController in
            viewController.edgesForExtendedLayout = Theme.isBarTranslucent ? .all : (Theme.isExtendedBottom ? .bottom : [])
            viewController.collectionView.contentInsetAdjustmentBehavior = Theme.isInsetNever ? .never : .automatic
        }
        FWViewControllerManager.sharedInstance.hookWebViewController = { viewController in
            viewController.edgesForExtendedLayout = Theme.isBarTranslucent ? .all : (Theme.isExtendedBottom ? .bottom : [])
            viewController.webView.scrollView.contentInsetAdjustmentBehavior = Theme.isInsetNever ? .never : .automatic
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
