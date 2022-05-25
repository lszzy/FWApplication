//
//  AppMediator.swift
//  Example
//
//  Created by wuyong on 2021/2/8.
//  Copyright © 2021 site.wuyong. All rights reserved.
//

import Foundation
#if DEBUG
import FWDebug
#endif

@objc protocol AppService: ModuleProtocol {}

@objc extension Autoloader {
    func loadAppModule() {
        Mediator.registerService(AppService.self, withModule: AppModule.self)
    }
}

class AppModule: NSObject, AppService {
    private static let sharedModule = AppModule()
    
    public static func sharedInstance() -> Self {
        return sharedModule as! Self
    }
    
    func setup() {
        #if DEBUG
        FWDebugManager.sharedInstance().openUrl = { (url) in
            if let scheme = URL.fw.url(string: url)?.scheme, scheme.count > 0 {
                Router.openURL(url)
                return true
            }
            return false
        }
        #endif
        
        DispatchQueue.main.async {
            ThemeManager.sharedInstance.overrideWindow = true
        }
    }
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NotificationManager.sharedInstance.clearNotificationBadges()
        if let remoteNotification = launchOptions?[.remoteNotification] {
            NotificationManager.sharedInstance.handleRemoteNotification(remoteNotification)
        }
        
        NotificationManager.sharedInstance.registerNotificationHandler()
        NotificationManager.sharedInstance.requestAuthorize(nil)
        NotificationManager.sharedInstance.remoteNotificationHandler = { (userInfo, notification) in
            NotificationManager.sharedInstance.clearNotificationBadges()
            
            var title: String?
            if let response = notification as? UNNotificationResponse {
                title = response.notification.request.content.title
            }
            UIWindow.fw.showMessage(text: "收到远程通知：\(title ?? "")\n\(userInfo ?? [:])")
        }
        NotificationManager.sharedInstance.localNotificationHandler = { (userInfo, notification) in
            NotificationManager.sharedInstance.clearNotificationBadges()
            
            var title: String?
            if let response = notification as? UNNotificationResponse {
                title = response.notification.request.content.title
            }
            UIWindow.fw.showMessage(text: "收到本地通知：\(title ?? "")\n\(userInfo ?? [:])")
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        UIDevice.fw.setDeviceTokenData(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UIDevice.fw.setDeviceTokenData(nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationManager.sharedInstance.handleRemoteNotification(userInfo)
        completionHandler(.newData)
    }
}
