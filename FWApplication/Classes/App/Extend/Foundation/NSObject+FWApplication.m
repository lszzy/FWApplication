/*!
 @header     NSObject+FWApplication.h
 @indexgroup FWApplication
 @brief      NSObject分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-05-15
 */

#import "NSObject+FWApplication.h"
#import <objc/runtime.h>

@implementation NSObject (FWApplication)

#pragma mark - Lock

- (void)fwLockCreate
{
    [self fwLockSemaphore];
}

- (void)fwLock
{
    dispatch_semaphore_wait([self fwLockSemaphore], DISPATCH_TIME_FOREVER);
}

- (void)fwUnlock
{
    dispatch_semaphore_signal([self fwLockSemaphore]);
}

- (dispatch_semaphore_t)fwLockSemaphore
{
    dispatch_semaphore_t semaphore = objc_getAssociatedObject(self, _cmd);
    if (!semaphore) {
        @synchronized (self) {
            semaphore = objc_getAssociatedObject(self, _cmd);
            if (!semaphore) {
                semaphore = dispatch_semaphore_create(1);
                objc_setAssociatedObject(self, _cmd, semaphore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
    }
    return semaphore;
}

#pragma mark - Archive

- (id)fwArchiveCopy
{
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

@end
