/**
 @header     UIButton+FWApplication.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "UIButton+FWApplication.h"

@implementation UIButton (FWApplication)

- (dispatch_source_t)fw_startCountDown:(NSInteger)seconds title:(NSString *)title waitTitle:(NSString *)waitTitle
{
    __weak UIButton *weakBase = self;
    return [self fw_startCountDown:seconds block:^(NSInteger countDown) {
        // 先设置titleLabel，再设置title，防止闪烁
        if (countDown <= 0) {
            weakBase.titleLabel.text = title;
            [weakBase setTitle:title forState:UIControlStateNormal];
            weakBase.enabled = YES;
        } else {
            NSString *waitText = [NSString stringWithFormat:waitTitle, countDown];
            weakBase.titleLabel.text = waitText;
            [weakBase setTitle:waitText forState:UIControlStateNormal];
            weakBase.enabled = NO;
        }
    }];
}

@end
