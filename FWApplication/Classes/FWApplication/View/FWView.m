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

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIView, @selector(initWithFrame:), FWSwizzleReturn(UIView *), FWSwizzleArgs(CGRect frame), FWSwizzleCode({
            UIView *view = FWSwizzleOriginal(frame);
            if ([view conformsToProtocol:@protocol(FWView)]) {
                [FWViewWrapper hookInit:(UIView<FWView> *)view];
            }
            return view;
        }));
        
        FWSwizzleClass(UIView, @selector(initWithCoder:), FWSwizzleReturn(UIView *), FWSwizzleArgs(NSCoder *coder), FWSwizzleCode({
            UIView *view = FWSwizzleOriginal(coder);
            if (view && [view conformsToProtocol:@protocol(FWView)]) {
                [FWViewWrapper hookInit:(UIView<FWView> *)view];
            }
            return view;
        }));
    });
}

+ (void)hookInit:(UIView<FWView> *)view {
    // 1. 视图renderInit
    if ([view respondsToSelector:@selector(renderInit)]) {
        [view renderInit];
    }
    
    // 2. 视图renderView
    if ([view respondsToSelector:@selector(renderView)]) {
        [view renderView];
    }
    
    // 3. 视图renderLayout
    if ([view respondsToSelector:@selector(renderLayout)]) {
        [view renderLayout];
    }
    
    // 4. 视图renderData
    if ([view respondsToSelector:@selector(renderData)]) {
        [view renderData];
    }
}

- (id)viewData {
    return objc_getAssociatedObject(self.base, @selector(viewData));
}

- (void)setViewData:(id)viewData {
    if (viewData != self.viewData) {
        objc_setAssociatedObject(self.base, @selector(viewData), viewData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (self.viewDataChanged) {
            self.viewDataChanged(self.base);
        }
        
        if ([self.base respondsToSelector:@selector(renderData)]) {
            [(id<FWView>)self.base renderData];
        }
    }
}

- (void (^)(__kindof UIView *))viewDataChanged {
    return objc_getAssociatedObject(self.base, @selector(viewDataChanged));
}

- (void)setViewDataChanged:(void (^)(__kindof UIView *))viewDataChanged {
    objc_setAssociatedObject(self.base, @selector(viewDataChanged), viewDataChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
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

- (void (^)(__kindof UIView *, NSNotification *))eventFinished
{
    return objc_getAssociatedObject(self.base, @selector(eventFinished));
}

- (void)setEventFinished:(void (^)(__kindof UIView *, NSNotification *))eventFinished
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

- (void)finishEvent:(NSNotification *)notification
{
    if (self.eventFinished) {
        self.eventFinished(self.base, notification);
    }
    if ([self.base respondsToSelector:@selector(renderEvent:)]) {
        [(id<FWView>)self.base renderEvent:notification];
    }
}

@end
