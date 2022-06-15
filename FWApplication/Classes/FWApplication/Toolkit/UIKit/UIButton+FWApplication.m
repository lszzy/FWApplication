/**
 @header     UIButton+FWApplication.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import "UIButton+FWApplication.h"

@implementation FWButtonWrapper (FWApplication)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    UIImage *image = nil;
    if (backgroundColor) {
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
        CGContextFillRect(context, rect);
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    [self.base setBackgroundImage:image forState:state];
}

- (dispatch_source_t)startCountDown:(NSInteger)seconds title:(NSString *)title waitTitle:(NSString *)waitTitle
{
    __weak UIButton *weakBase = self.base;
    return [self startCountDown:seconds block:^(NSInteger countDown) {
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
