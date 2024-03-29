/**
 @header     UIApplication+FWApplication.m
 @indexgroup FWApplication
      UIApplication+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/17
 */

#import "UIApplication+FWApplication.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark - UIApplication+FWApplication

@implementation UIApplication (FWApplication)

#pragma mark - App

+ (id)fw_appInfo:(NSString *)key
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];
}

#pragma mark - Debug

+ (BOOL)fw_isPirated
{
#if TARGET_OS_SIMULATOR
    return YES;
#else
    // root权限
    if (getgid() <= 10) {
        return YES;
    }
    
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"]) {
        return YES;
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [bundlePath stringByAppendingPathComponent:@"_CodeSignature"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    path = [bundlePath stringByAppendingPathComponent:@"SC_Info"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES;
    }
    
    // 这方法可以运行时被替换掉，可以通过加密代码、修改方法名等提升检察性
    return NO;
#endif
}

+ (BOOL)fw_isTestflight
{
    return [[NSBundle mainBundle].appStoreReceiptURL.path containsString:@"sandboxReceipt"];
}

#pragma mark - URL

+ (SystemSoundID)fw_playAlert:(NSString *)file
{
    // 参数是否正确
    if (file.length < 1) {
        return 0;
    }
    
    // 文件是否存在
    NSString *soundFile = file;
    if (![file isAbsolutePath]) {
        soundFile = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:soundFile]) {
        return 0;
    }
    
    // 播放内置声音
    NSURL *soundUrl = [NSURL fileURLWithPath:soundFile];
    SystemSoundID soundId = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl, &soundId);
    AudioServicesPlaySystemSound(soundId);
    // 播放震动
    // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // 兼容9.0
    // AudioServicesPlayAlertSoundWithCompletion(soundId, ^{});
    // AudioServicesRemoveSystemSoundCompletion(soundId, ^{});
    return soundId;
}

+ (void)fw_stopAlert:(SystemSoundID)soundId
{
    if (soundId == 0) {
        return;
    }
    
    // 注销播放完成回调函数
    AudioServicesRemoveSystemSoundCompletion(soundId);
    // 释放SystemSoundID
    AudioServicesDisposeSystemSoundID(soundId);
}

+ (void)fw_playVibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

+ (void)fw_readText:(NSString *)text withLanguage:(nullable NSString *)languageCode
{
    AVSpeechUtterance *speechUtterance = [[AVSpeechUtterance alloc] initWithString:text];
    speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    speechUtterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:languageCode];
    AVSpeechSynthesizer *speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    [speechSynthesizer speakUtterance:speechUtterance];
}

@end
