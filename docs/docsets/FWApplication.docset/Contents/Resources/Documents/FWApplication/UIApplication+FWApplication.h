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

@interface FWApplicationClassWrapper (FWApplication)

#pragma mark - App

// 读取应用信息字典
- (nullable id)appInfo:(NSString *)key;

// 读取应用名称
@property (nonatomic, copy, readonly) NSString *appName;

// 读取应用显示名称，未配置时读取名称
@property (nonatomic, copy, readonly) NSString *appDisplayName;

// 读取应用主版本号，示例：1.0.0
@property (nonatomic, copy, readonly) NSString *appVersion;

// 读取应用构建版本号，示例：1.0.0.1
@property (nonatomic, copy, readonly) NSString *appBuildVersion;

// 读取应用标识
@property (nonatomic, copy, readonly) NSString *appIdentifier;

#pragma mark - Debug

// 是否是盗版(不是从AppStore安装)
@property (nonatomic, assign, readonly) BOOL isPirated;

// 是否是Testflight版本
@property (nonatomic, assign, readonly) BOOL isTestflight;

#pragma mark - URL

// 播放内置声音文件
- (SystemSoundID)playAlert:(NSString *)file;

// 停止播放内置声音文件
- (void)stopAlert:(SystemSoundID)soundId;

// 播放内置震动
- (void)playVibrate;

// 语音朗读文字，可指定语言(如zh-CN)
- (void)readText:(NSString *)text withLanguage:(nullable NSString *)languageCode;

@end

NS_ASSUME_NONNULL_END
