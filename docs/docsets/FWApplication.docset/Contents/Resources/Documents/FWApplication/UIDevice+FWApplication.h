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

@interface FWDeviceClassWrapper (FWApplication)

#pragma mark - UUID

/// 获取或设置设备UUID，自动keychain持久化。默认获取IDFV(未使用IDFA，避免额外权限)，失败则随机生成一个
@property (nonatomic, copy) NSString *deviceUUID;

#pragma mark - Jailbroken

// 是否越狱
@property (nonatomic, assign, readonly) BOOL isJailbroken;

#pragma mark - Network

// 本地IP地址
@property (nonatomic, copy, readonly, nullable) NSString *ipAddress;

// 本地主机名称
@property (nonatomic, copy, readonly, nullable) NSString *hostName;

// 手机运营商名称
@property (nonatomic, copy, readonly, nullable) NSString *carrierName;

// 手机蜂窝网络类型，仅区分2G|3G|4G|5G
@property (nonatomic, copy, readonly, nullable) NSString *networkType;

@end

NS_ASSUME_NONNULL_END
