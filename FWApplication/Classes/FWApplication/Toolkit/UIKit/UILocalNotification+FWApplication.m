/**
 @header     UILocalNotification+FWApplication.m
 @indexgroup FWApplication
      UILocalNotification+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/9/4
 */

#import "UILocalNotification+FWApplication.h"

@implementation UNUserNotificationCenter (FWApplication)

+ (UNMutableNotificationContent *)fw_localNotificationWithTitle:(NSString *)title subtitle:(NSString *)subtitle body:(NSString *)body userInfo:(NSDictionary *)userInfo category:(NSString *)category badge:(NSNumber *)badge soundName:(NSString *)soundName block:(void (NS_NOESCAPE ^)(UNMutableNotificationContent *))block
{
    UNMutableNotificationContent *notification = [[UNMutableNotificationContent alloc] init];
    if (title) notification.title = title;
    if (subtitle) notification.subtitle = subtitle;
    if (body) notification.body = body;
    if (userInfo) notification.userInfo = userInfo;
    if (category) notification.categoryIdentifier = category;
    notification.badge = badge;
    if (soundName) notification.sound = [@"default" isEqualToString:soundName] ? [UNNotificationSound defaultSound] : [UNNotificationSound soundNamed:soundName];
    if (block) block(notification);
    return notification;
}

+ (void)fw_registerLocalNotification:(NSString *)identifier content:(UNNotificationContent *)content trigger:(UNNotificationTrigger *)trigger
{
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

+ (void)fw_removePendingNotification:(NSArray<NSString *> *)identifiers
{
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:identifiers];
}

+ (void)fw_removeAllPendingNotifications
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}

+ (void)fw_removeDeliveredNotification:(NSArray<NSString *> *)identifiers
{
    [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:identifiers];
}

+ (void)fw_removeAllDeliveredNotifications
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
}

@end
