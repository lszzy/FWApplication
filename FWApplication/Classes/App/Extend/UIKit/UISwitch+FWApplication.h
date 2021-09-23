/*!
 @header     UISwitch+FWApplication.h
 @indexgroup FWApplication
 @brief      UISwitch+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/17
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief UISwitch+FWApplication
 */
@interface UISwitch (FWApplication)

/// 自定义尺寸大小，默认{51,31}
- (void)fwSetSize:(CGSize)size;

/*!
 @brief 切换开关状态
 */
- (void)fwToggle:(BOOL)animated;

@end

#pragma mark - UISlider+FWApplication

/*!
 @brief UISlider+FWApplication
 */
@interface UISlider (FWApplication)

/// 中间圆球的大小，默认zero
@property (nonatomic, assign) CGSize fwThumbSize UI_APPEARANCE_SELECTOR;

/// 中间圆球的颜色，默认nil
@property (nonatomic, strong, nullable) UIColor *fwThumbColor UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
