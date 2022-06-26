/**
 @header     UISwitch+FWApplication.h
 @indexgroup FWApplication
      UISwitch+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/17
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UISwitch (FWApplication)

/**
 切换开关状态
 */
- (void)fw_toggle:(BOOL)animated NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
