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

@implementation UIView (FWView)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIView, @selector(initWithFrame:), FWSwizzleReturn(UIView *), FWSwizzleArgs(CGRect frame), FWSwizzleCode({
            UIView *view = FWSwizzleOriginal(frame);
            if ([view conformsToProtocol:@protocol(FWView)]) {
                [UIView fw_hookInit:(UIView<FWView> *)view];
            }
            return view;
        }));
        
        FWSwizzleClass(UIView, @selector(initWithCoder:), FWSwizzleReturn(UIView *), FWSwizzleArgs(NSCoder *coder), FWSwizzleCode({
            UIView *view = FWSwizzleOriginal(coder);
            if (view && [view conformsToProtocol:@protocol(FWView)]) {
                [UIView fw_hookInit:(UIView<FWView> *)view];
            }
            return view;
        }));
    });
}

+ (void)fw_hookInit:(UIView<FWView> *)view {
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

- (id)fw_viewModel {
    return objc_getAssociatedObject(self, @selector(fw_viewModel));
}

- (void)setFw_viewModel:(id)viewModel {
    if (viewModel != self.fw_viewModel) {
        objc_setAssociatedObject(self, @selector(fw_viewModel), viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (self.fw_viewModelChanged) {
            self.fw_viewModelChanged(self);
        }
        
        if ([self conformsToProtocol:@protocol(FWView)] &&
            [self respondsToSelector:@selector(renderData)]) {
            [(UIView<FWView> *)self renderData];
        }
    }
}

- (void (^)(__kindof UIView *))fw_viewModelChanged {
    return objc_getAssociatedObject(self, @selector(fw_viewModelChanged));
}

- (void)setFw_viewModelChanged:(void (^)(__kindof UIView *))viewModelChanged {
    objc_setAssociatedObject(self, @selector(fw_viewModelChanged), viewModelChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (id<FWViewDelegate>)fw_viewDelegate
{
    FWWeakObject *value = objc_getAssociatedObject(self, @selector(fw_viewDelegate));
    return value.object;
}

- (void)setFw_viewDelegate:(id<FWViewDelegate>)viewDelegate
{
    // 仅当值发生改变才触发KVO，下同
    if (viewDelegate != [self fw_viewDelegate]) {
        objc_setAssociatedObject(self, @selector(fw_viewDelegate), [[FWWeakObject alloc] initWithObject:viewDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void (^)(__kindof UIView *, NSNotification *))fw_eventReceived
{
    return objc_getAssociatedObject(self, @selector(fw_eventReceived));
}

- (void)setFw_eventReceived:(void (^)(__kindof UIView *, NSNotification *))eventReceived
{
    objc_setAssociatedObject(self, @selector(fw_eventReceived), eventReceived, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView *, NSNotification *))fw_eventFinished
{
    return objc_getAssociatedObject(self, @selector(fw_eventFinished));
}

- (void)setFw_eventFinished:(void (^)(__kindof UIView *, NSNotification *))eventFinished
{
    objc_setAssociatedObject(self, @selector(fw_eventFinished), eventFinished, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)fw_sendEvent:(NSString *)name
{
    [self fw_sendEvent:name object:nil];
}

- (void)fw_sendEvent:(NSString *)name object:(id)object
{
    [self fw_sendEvent:name object:object userInfo:nil];
}

- (void)fw_sendEvent:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    NSNotification *notification = [NSNotification notificationWithName:name object:object userInfo:userInfo];
    if (self.fw_eventReceived) {
        self.fw_eventReceived(self, notification);
    }
    if (self.fw_viewDelegate && [self.fw_viewDelegate respondsToSelector:@selector(eventReceived:withNotification:)]) {
        [self.fw_viewDelegate eventReceived:self withNotification:notification];
    }
}

- (void)fw_finishEvent:(NSNotification *)notification
{
    if (self.fw_eventFinished) {
        self.fw_eventFinished(self, notification);
    }
    if ([self conformsToProtocol:@protocol(FWView)] &&
        [self respondsToSelector:@selector(renderEvent:)]) {
        [(UIView<FWView> *)self renderEvent:notification];
    }
}

@end
