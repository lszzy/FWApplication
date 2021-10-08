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

/// 多语言，取消
@property (class, nonatomic, copy, readonly) NSString *cancelButton;
/// 多语言，确定
@property (class, nonatomic, copy, readonly) NSString *confirmButton;
/// 多语言，关闭
@property (class, nonatomic, copy, readonly) NSString *closeButton;
/// 多语言，完成
@property (class, nonatomic, copy, readonly) NSString *doneButton;
/// 多语言，原有
@property (class, nonatomic, copy, readonly) NSString *originalButton;

@end

NS_ASSUME_NONNULL_END
