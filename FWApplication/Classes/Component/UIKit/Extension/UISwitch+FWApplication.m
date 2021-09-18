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

- (void)fwToggle
{
    [self setOn:!self.isOn animated:YES];
}

@end
