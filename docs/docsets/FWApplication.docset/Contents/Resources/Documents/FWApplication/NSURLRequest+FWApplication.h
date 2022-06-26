/**
 @header     NSURLRequest+FWApplication.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2022/03/21
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (FWApplication)

/**
 生成对应curl命令，方便调试和测试
 */
- (NSString *)fw_curlCommand NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
