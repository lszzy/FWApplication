/**
 @header     UILocalNotification+FWApplication.h
 @indexgroup FWApplication
      UILocalNotification+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/9/4
 */

#import "FWAppWrapper.h"
@import UserNotifications;

NS_ASSUME_NONNULL_BEGIN

@interface FWUserNotificationCenterClassWrapper (FWApplication)

// 创建本地通知，badge为0时不显示(nil时不修改)，soundName为default时为默认声音
- (UNMutableNotificationContent *)localNotificationWithTitle:(nullable NSString *)title subtitle:(nullable NSString *)subtitle body:(nullable NSString *)body userInfo:(nullable NSDictionary *)userInfo category:(nullable NSString *)category badge:(nullable NSNumber *)badge soundName:(nullable NSString *)soundName block:(nullable void (NS_NOESCAPE ^)(UNMutableNotificationContent *content))block;

// 注册本地通知，trigger为nil时立即触发，iOS10+
- (void)registerLocalNotification:(NSString *)identifier content:(UNNotificationContent *)content trigger:(nullable UNNotificationTrigger *)trigger;

// 删除未发出的本地通知，iOS10+
- (void)removePendingNotification:(NSArray<NSString *> *)identifiers;

// 删除所有未发出的本地通知，iOS10+
- (void)removeAllPendingNotifications;

// 删除已发出的本地通知，iOS10+
- (void)removeDeliveredNotification:(NSArray<NSString *> *)identifiers;

// 删除所有已发出的本地通知，iOS10+
- (void)removeAllDeliveredNotifications;

@end

NS_ASSUME_NONNULL_END
