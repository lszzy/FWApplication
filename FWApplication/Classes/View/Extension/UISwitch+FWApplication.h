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

/*!
 @brief 切换开关状态
 */
- (void)fwToggle:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
