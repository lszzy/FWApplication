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

- (void)fwSetSize:(CGSize)size
{
    CGFloat height = self.bounds.size.height;
    if (height <= 0) {
        height = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].height;
        if (height <= 0) height = 31;
    }
    CGFloat scale = size.height / height;
    self.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)fwToggle:(BOOL)animated
{
    [self setOn:!self.isOn animated:animated];
}

@end
