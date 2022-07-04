/**
 @header     UIDevice+FWApplication.h
 @indexgroup FWApplication
      UIDevice+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (FWApplication)

#pragma mark - Jailbroken

// 是否越狱
@property (class, nonatomic, assign, readonly) BOOL fw_isJailbroken NS_REFINED_FOR_SWIFT;

#pragma mark - Network

// 本地IP地址
@property (class, nonatomic, copy, readonly, nullable) NSString *fw_ipAddress NS_REFINED_FOR_SWIFT;

// 本地主机名称
@property (class, nonatomic, copy, readonly, nullable) NSString *fw_hostName NS_REFINED_FOR_SWIFT;

// 手机运营商名称
@property (class, nonatomic, copy, readonly, nullable) NSString *fw_carrierName NS_REFINED_FOR_SWIFT;

// 手机蜂窝网络类型，仅区分2G|3G|4G|5G
@property (class, nonatomic, copy, readonly, nullable) NSString *fw_networkType NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
