/*!
 @header     UIControl+FWApplication.h
 @indexgroup FWApplication
 @brief      UIControl+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/6/21
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief UIControl+FWApplication
 @discussion 防重复点击可以手工控制enabled或userInteractionEnabled，如request开始时禁用，结束时启用等
 */
@interface UIControl (FWApplication)

// 设置Touch事件触发间隔，防止短时间多次触发事件，默认0
@property (nonatomic, assign) NSTimeInterval fwTouchEventInterval UI_APPEARANCE_SELECTOR;

@end

NS_ASSUME_NONNULL_END
