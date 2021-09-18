/*!
 @header     NSTimer+FWApplication.m
 @indexgroup FWApplication
 @brief      NSTimer分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-09-11
 */

#import "NSTimer+FWApplication.h"

@implementation NSTimer (FWApplication)

- (void)fwPauseTimer
{
    if (![self isValid]) {
        return;
    }
    
    [self setFireDate:[NSDate distantFuture]];
}

- (void)fwResumeTimer
{
    if (![self isValid]) {
        return;
    }
    
    [self setFireDate:[NSDate date]];
}

- (void)fwResumeTimerAfterDelay:(NSTimeInterval)delay
{
    if (![self isValid]) {
        return;
    }
    
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]];
}

@end
