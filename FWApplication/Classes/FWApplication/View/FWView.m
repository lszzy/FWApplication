/**
 @header     FWView.m
 @indexgroup FWApplication
      FWView
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/12/27
 */

#import "FWView.h"
#import <objc/runtime.h>

@implementation FWViewWrapper (FWView)

- (id)viewModel
{
    return objc_getAssociatedObject(self.base, @selector(viewModel));
}

- (void)setViewModel:(id)viewModel
{
    // 仅当值发生改变才触发KVO，下同
    if (viewModel != [self viewModel]) {
        objc_setAssociatedObject(self.base, @selector(viewModel), viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (id<FWViewDelegate>)viewDelegate
{
    FWWeakObject *value = objc_getAssociatedObject(self.base, @selector(viewDelegate));
    return value.object;
}

- (void)setViewDelegate:(id<FWViewDelegate>)viewDelegate
{
    // 仅当值发生改变才触发KVO，下同
    if (viewDelegate != [self viewDelegate]) {
        objc_setAssociatedObject(self.base, @selector(viewDelegate), [[FWWeakObject alloc] initWithObject:viewDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void (^)(__kindof UIView *, NSNotification *))eventReceived
{
    return objc_getAssociatedObject(self.base, @selector(eventReceived));
}

- (void)setEventReceived:(void (^)(__kindof UIView *, NSNotification *))eventReceived
{
    objc_setAssociatedObject(self.base, @selector(eventReceived), eventReceived, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(NSNotification *))eventFinished
{
    return objc_getAssociatedObject(self.base, @selector(eventFinished));
}

- (void)setEventFinished:(void (^)(NSNotification *))eventFinished
{
    objc_setAssociatedObject(self.base, @selector(eventFinished), eventFinished, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)sendEvent:(NSString *)name
{
    [self sendEvent:name object:nil];
}

- (void)sendEvent:(NSString *)name object:(id)object
{
    [self sendEvent:name object:object userInfo:nil];
}

- (void)sendEvent:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    NSNotification *notification = [NSNotification notificationWithName:name object:object userInfo:userInfo];
    if (self.eventReceived) {
        self.eventReceived(self.base, notification);
    }
    if (self.viewDelegate && [self.viewDelegate respondsToSelector:@selector(eventReceived:withNotification:)]) {
        [self.viewDelegate eventReceived:self.base withNotification:notification];
    }
}

- (void)eventFinished:(NSNotification *)notification
{
    if (self.eventFinished) {
        self.eventFinished(notification);
    }
}

@end
