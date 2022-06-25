/**
 @header     UIControl+FWApplication.m
 @indexgroup FWApplication
      UIControl+FWApplication
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/6/21
 */

#import "UIControl+FWApplication.h"
#import <objc/runtime.h>

@implementation UIControl (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIControl, @selector(sendAction:to:forEvent:), FWSwizzleReturn(void), FWSwizzleArgs(SEL action, id target, UIEvent *event), FWSwizzleCode({
            // 仅拦截Touch事件，且配置了间隔时间的Event
            if (event.type == UIEventTypeTouches && event.subtype == UIEventSubtypeNone && selfObject.fw_touchEventInterval > 0) {
                if ([[NSDate date] timeIntervalSince1970] - selfObject.fw_touchEventTimestamp < selfObject.fw_touchEventInterval) {
                    return;
                }
                selfObject.fw_touchEventTimestamp = [[NSDate date] timeIntervalSince1970];
            }
            
            FWSwizzleOriginal(action, target, event);
        }));
    });
}

- (NSTimeInterval)fw_touchEventInterval
{
    return [objc_getAssociatedObject(self, @selector(fw_touchEventInterval)) doubleValue];
}

- (void)setFw_touchEventInterval:(NSTimeInterval)interval
{
    objc_setAssociatedObject(self, @selector(fw_touchEventInterval), @(interval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)fw_touchEventTimestamp
{
    return [objc_getAssociatedObject(self, @selector(fw_touchEventTimestamp)) doubleValue];
}

- (void)setFw_touchEventTimestamp:(NSTimeInterval)timestamp
{
    objc_setAssociatedObject(self, @selector(fw_touchEventTimestamp), @(timestamp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
