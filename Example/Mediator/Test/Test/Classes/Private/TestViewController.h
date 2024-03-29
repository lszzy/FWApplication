/*!
 @header     TestViewController.h
 @indexgroup Example
 @brief      TestViewController
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/21
 */

#import "TestModule.h"
@import Core;

NS_ASSUME_NONNULL_BEGIN

@interface TestViewController : UIViewController <FWViewController>

+ (void)mockProgress:(void (^)(double progress, BOOL finished))block;

@end

NS_ASSUME_NONNULL_END
