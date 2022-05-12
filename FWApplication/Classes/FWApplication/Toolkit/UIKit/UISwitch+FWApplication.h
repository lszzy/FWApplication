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

@interface FWSwitchWrapper (FWApplication)

/**
 切换开关状态
 */
- (void)toggle:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
