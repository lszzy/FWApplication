/**
 @header     UIApplication+FWApplication.h
 @indexgroup FWApplication
      UIApplication+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/17
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (FWApplication)

#pragma mark - App

// 读取应用信息字典
+ (nullable id)fw_appInfo:(NSString *)key NS_REFINED_FOR_SWIFT;

// 读取应用名称
@property (class, nonatomic, copy, readonly) NSString *fw_appName NS_REFINED_FOR_SWIFT;

// 读取应用显示名称，未配置时读取名称
@property (class, nonatomic, copy, readonly) NSString *fw_appDisplayName NS_REFINED_FOR_SWIFT;

// 读取应用主版本号，示例：1.0.0
@property (class, nonatomic, copy, readonly) NSString *fw_appVersion NS_REFINED_FOR_SWIFT;

// 读取应用构建版本号，示例：1.0.0.1
@property (class, nonatomic, copy, readonly) NSString *fw_appBuildVersion NS_REFINED_FOR_SWIFT;

// 读取应用标识
@property (class, nonatomic, copy, readonly) NSString *fw_appIdentifier NS_REFINED_FOR_SWIFT;

#pragma mark - Debug

// 是否是盗版(不是从AppStore安装)
@property (class, nonatomic, assign, readonly) BOOL fw_isPirated NS_REFINED_FOR_SWIFT;

// 是否是Testflight版本
@property (class, nonatomic, assign, readonly) BOOL fw_isTestflight NS_REFINED_FOR_SWIFT;

#pragma mark - URL

// 播放内置声音文件
+ (SystemSoundID)fw_playAlert:(NSString *)file NS_REFINED_FOR_SWIFT;

// 停止播放内置声音文件
+ (void)fw_stopAlert:(SystemSoundID)soundId NS_REFINED_FOR_SWIFT;

// 播放内置震动
+ (void)fw_playVibrate NS_REFINED_FOR_SWIFT;

// 语音朗读文字，可指定语言(如zh-CN)
+ (void)fw_readText:(NSString *)text withLanguage:(nullable NSString *)languageCode NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
