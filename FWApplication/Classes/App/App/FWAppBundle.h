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

#pragma mark - FWAppBundle

/**
 @brief 框架内置Bundle类，应用可替换
 @discussion 如果应用主Bundle内存在FWApplication.bundle，则优先使用。默认使用框架内置FWApplication.bundle
 */
@interface FWAppBundle : FWModuleBundle

@end

NS_ASSUME_NONNULL_END
