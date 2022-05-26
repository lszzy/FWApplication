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

@interface UIControl (FWApplication)

@end

@implementation UIControl (FWApplication)

- (NSTimeInterval)innerTouchEventInterval
{
    return [objc_getAssociatedObject(self, @selector(innerTouchEventInterval)) doubleValue];
}

- (void)setInnerTouchEventInterval:(NSTimeInterval)interval
{
    objc_setAssociatedObject(self, @selector(innerTouchEventInterval), @(interval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)innerTouchEventTimestamp
{
    return [objc_getAssociatedObject(self, @selector(innerTouchEventTimestamp)) doubleValue];
}

- (void)setInnerTouchEventTimestamp:(NSTimeInterval)timestamp
{
    objc_setAssociatedObject(self, @selector(innerTouchEventTimestamp), @(timestamp), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation FWControlWrapper (FWApplication)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIControl, @selector(sendAction:to:forEvent:), FWSwizzleReturn(void), FWSwizzleArgs(SEL action, id target, UIEvent *event), FWSwizzleCode({
            // 仅拦截Touch事件，且配置了间隔时间的Event
            if (event.type == UIEventTypeTouches && event.subtype == UIEventSubtypeNone && selfObject.innerTouchEventInterval > 0) {
                if ([[NSDate date] timeIntervalSince1970] - selfObject.innerTouchEventTimestamp < selfObject.innerTouchEventInterval) {
                    return;
                }
                selfObject.innerTouchEventTimestamp = [[NSDate date] timeIntervalSince1970];
            }
            
            FWSwizzleOriginal(action, target, event);
        }));
    });
}

- (NSTimeInterval)touchEventInterval
{
    return self.base.innerTouchEventInterval;
}

- (void)setTouchEventInterval:(NSTimeInterval)interval
{
    self.base.innerTouchEventInterval = interval;
}

@end
