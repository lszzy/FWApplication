/*!
 @header     NSObject+FWApplication.h
 @indexgroup FWApplication
 @brief      NSObject分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-05-15
 */

#import "NSObject+FWApplication.h"

@implementation NSObject (FWApplication)

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
