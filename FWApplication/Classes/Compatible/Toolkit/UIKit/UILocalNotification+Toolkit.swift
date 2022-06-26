//
//  UILocalNotification+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
import UserNotifications
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UNUserNotificationCenter {
    
    /// 创建本地通知，badge为0时不显示(nil时不修改)，soundName为default时为默认声音
    public static func localNotification(title: String?, subtitle: String?, body: String?, userInfo: [AnyHashable : Any]?, category: String?, badge: NSNumber?, soundName: String?, block: ((UNMutableNotificationContent) -> Void)? = nil) -> UNMutableNotificationContent {
        return Base.__fw_localNotification(withTitle: title, subtitle: subtitle, body: body, userInfo: userInfo, category: category, badge: badge, soundName: soundName, block: block)
    }

    /// 注册本地通知，trigger为nil时立即触发，iOS10+
    public static func registerLocalNotification(_ identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger?) {
        Base.__fw_registerLocalNotification(identifier, content: content, trigger: trigger)
    }

    /// 删除未发出的本地通知，iOS10+
    public static func removePendingNotification(_ identifiers: [String]) {
        Base.__fw_removePendingNotification(identifiers)
    }

    /// 删除所有未发出的本地通知，iOS10+
    public static func removeAllPendingNotifications() {
        Base.__fw_removeAllPendingNotifications()
    }

    /// 删除已发出的本地通知，iOS10+
    public static func removeDeliveredNotification(_ identifiers: [String]) {
        Base.__fw_removeDeliveredNotification(identifiers)
    }

    /// 删除所有已发出的本地通知，iOS10+
    public static func removeAllDeliveredNotifications() {
        Base.__fw_removeAllDeliveredNotifications()
    }
    
}
