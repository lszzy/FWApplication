/*!
 @header     FWAppBundle.h
 @indexgroup FWApplication
 @brief      FWAppBundle
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/4/21
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 框架内置应用Bundle类，应用可替换
 @discussion 如果主应用存在FWApplication.bundle或主Bundle内包含对应图片|多语言，则优先使用；否则使用框架默认实现。
 FWApplication所需本地化翻译如下：完成|关闭|确定|取消|原有，配置同App本地化一致即可，如zh-Hans|en等
 */
@interface FWAppBundle : FWModuleBundle

#pragma mark - Image

/// 图片，导航栏返回，fwNavBack
@property (class, nonatomic, strong, readonly, nullable) UIImage *navBackImage;
/// 图片，导航栏关闭，fwNavClose
@property (class, nonatomic, strong, readonly, nullable) UIImage *navCloseImage;
/// 图片，视频播放大图，fwVideoPlay
@property (class, nonatomic, strong, readonly, nullable) UIImage *videoPlayImage;
/// 图片，视频暂停，fwVideoPause
@property (class, nonatomic, strong, readonly, nullable) UIImage *videoPauseImage;
/// 图片，视频开始，fwVideoStart
@property (class, nonatomic, strong, readonly, nullable) UIImage *videoStartImage;

#pragma mark - String

/// 多语言，取消，fwCancel
@property (class, nonatomic, copy, readonly) NSString *cancelButton;
/// 多语言，确定，fwConfirm
@property (class, nonatomic, copy, readonly) NSString *confirmButton;
/// 多语言，关闭，fwClose
@property (class, nonatomic, copy, readonly) NSString *closeButton;
/// 多语言，完成，fwDone
@property (class, nonatomic, copy, readonly) NSString *doneButton;
/// 多语言，原有，fwOriginal
@property (class, nonatomic, copy, readonly) NSString *originalButton;

@end

NS_ASSUME_NONNULL_END
