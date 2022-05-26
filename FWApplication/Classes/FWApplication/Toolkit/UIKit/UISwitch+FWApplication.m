/**
 @header     UISwitch+FWApplication.m
 @indexgroup FWApplication
      UISwitch+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/17
 */

#import "UISwitch+FWApplication.h"

@implementation FWSwitchWrapper (FWApplication)

- (void)toggle:(BOOL)animated
{
    [self.base setOn:!self.base.isOn animated:animated];
}

@end
