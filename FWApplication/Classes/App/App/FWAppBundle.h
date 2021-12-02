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
/// 图片，相册多选，fwPickerCheck
@property (class, nonatomic, strong, readonly, nullable) UIImage *pickerCheckImage;
/// 图片，相册选中，fwPickerChecked
@property (class, nonatomic, strong, readonly, nullable) UIImage *pickerCheckedImage;

#pragma mark - String

/// 多语言，取消，fwCancel
@property (class, nonatomic, copy, readonly) NSString *cancelButton;
/// 多语言，确定，fwConfirm
@property (class, nonatomic, copy, readonly) NSString *confirmButton;
/// 多语言，关闭，fwClose
@property (class, nonatomic, copy, readonly) NSString *closeButton;
/// 多语言，完成，fwDone
@property (class, nonatomic, copy, readonly) NSString *doneButton;
/// 多语言，编辑，fwEdit
@property (class, nonatomic, copy, readonly) NSString *editButton;
/// 多语言，预览，fwPreview
@property (class, nonatomic, copy, readonly) NSString *previewButton;
/// 多语言，原图，fwOriginal
@property (class, nonatomic, copy, readonly) NSString *originalButton;

/// 多语言，相册，fwPickerAlbum
@property (class, nonatomic, copy, readonly) NSString *pickerAlbumTitle;
/// 多语言，无照片，fwPickerEmpty
@property (class, nonatomic, copy, readonly) NSString *pickerEmptyTitle;
/// 多语言，无权限，fwPickerDenied
@property (class, nonatomic, copy, readonly) NSString *pickerDeniedTitle;
/// 多语言，超出数量，fwPickerExceed
@property (class, nonatomic, copy, readonly) NSString *pickerExceedTitle;

@end

NS_ASSUME_NONNULL_END
