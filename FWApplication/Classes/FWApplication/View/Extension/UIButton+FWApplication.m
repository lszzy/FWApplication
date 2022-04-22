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

- (void)countDown:(NSInteger)timeout title:(NSString *)title waitTitle:(NSString *)waitTitle
{
    // 倒计时时间，每秒执行
    __block NSInteger countdown = timeout;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0);
    
    __weak UIButton *weakBase = self.base;
    __block BOOL isTimeout = NO;
    __block BOOL hasWindow = NO;
    dispatch_source_set_event_handler(_timer, ^{
        // 倒计时时间
        isTimeout = countdown <= 0;
        if (isTimeout) {
            dispatch_source_cancel(_timer);
        } else {
            countdown--;
        }
        
        // 主线程更新按钮
        dispatch_async(dispatch_get_main_queue(), ^{
            // 按钮从window移除时自动cancel倒计时
            if (!hasWindow && weakBase.window) {
                hasWindow = YES;
            } else if (hasWindow && !weakBase.window) {
                hasWindow = NO;
                isTimeout = YES;
                dispatch_source_cancel(_timer);
            }
            
            if (isTimeout) {
                // 先设置titleLabel，再设置title，防止闪烁，下同
                weakBase.titleLabel.text = title;
                [weakBase setTitle:title forState:UIControlStateNormal];
                weakBase.enabled = YES;
            } else {
                // 时间+1，防止倒计时显示0秒
                NSString *waitText = [NSString stringWithFormat:waitTitle, (countdown + 1)];
                weakBase.titleLabel.text = waitText;
                [weakBase setTitle:waitText forState:UIControlStateNormal];
                weakBase.enabled = NO;
            }
        });
    });
    dispatch_resume(_timer);
}

@end
