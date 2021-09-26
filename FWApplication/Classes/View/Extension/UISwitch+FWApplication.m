/*!
 @header     UISwitch+FWApplication.m
 @indexgroup FWApplication
 @brief      UISwitch+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/17
 */

#import "UISwitch+FWApplication.h"

@implementation UISwitch (FWApplication)

- (void)fwToggle:(BOOL)animated
{
    [self setOn:!self.isOn animated:animated];
}

@end
