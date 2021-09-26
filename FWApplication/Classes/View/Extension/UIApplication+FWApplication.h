/*!
 @header     UIApplication+FWApplication.h
 @indexgroup FWApplication
 @brief      UIApplication+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/17
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief UIApplication+FWApplication
 */
@interface UIApplication (FWApplication)

#pragma mark - App

// 读取应用信息字典
+ (nullable id)fwAppInfo:(NSString *)key;

// 读取应用名称
@property (class, nonatomic, copy, readonly) NSString *fwAppName;

// 读取应用显示名称，未配置时读取名称
@property (class, nonatomic, copy, readonly) NSString *fwAppDisplayName;

// 读取应用主版本号，示例：1.0.0
@property (class, nonatomic, copy, readonly) NSString *fwAppVersion;

// 读取应用构建版本号，示例：1.0.0.1
@property (class, nonatomic, copy, readonly) NSString *fwAppBuildVersion;

// 读取应用标识
@property (class, nonatomic, copy, readonly) NSString *fwAppIdentifier;

#pragma mark - Debug

// 是否是盗版(不是从AppStore安装)
@property (class, nonatomic, assign, readonly) BOOL fwIsPirated;

// 是否是Testflight版本
@property (class, nonatomic, assign, readonly) BOOL fwIsTestflight;

#pragma mark - URL

// 播放内置声音文件
+ (SystemSoundID)fwPlayAlert:(NSString *)file;

// 停止播放内置声音文件
+ (void)fwStopAlert:(SystemSoundID)soundId;

// 中文语音朗读文字
+ (void)fwReadText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
