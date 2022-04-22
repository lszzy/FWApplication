/**
 @header     NSURLRequest+FWApplication.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2022/03/21
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface FWURLRequestWrapper (FWApplication)

/**
 生成对应curl命令，方便调试和测试
 */
- (NSString *)curlCommand;

@end

NS_ASSUME_NONNULL_END
