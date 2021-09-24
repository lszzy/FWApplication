/*!
 @header     NSObject+FWRuntime.m
 @indexgroup FWApplication
 @brief      NSObject运行时分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-05-18
 */

#import "NSObject+FWRuntime.h"
#import <objc/message.h>

@implementation NSObject (FWRuntime)

- (BOOL)fwHasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass
{
    return [NSObject fwHasOverrideMethod:selector forClass:self.class ofSuperclass:superclass];
}

+ (BOOL)fwHasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass
{
    if (![aClass isSubclassOfClass:superclass]) {
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(aClass, selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
}

@end