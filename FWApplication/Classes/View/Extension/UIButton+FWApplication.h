/**
 @header     UIButton+FWApplication.h
 @indexgroup FWApplication
      UIButton+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UIButton+FWApplication
 */
@interface UIButton (FWApplication)

/// 设置背景色
- (void)fwSetBackgroundColor:(nullable UIColor *)backgroundColor forState:(UIControlState)state;

/// 设置按钮倒计时。等待时按钮disabled，非等待时enabled。时间支持格式化，示例：重新获取(%lds)
- (void)fwCountDown:(NSInteger)timeout title:(NSString *)title waitTitle:(NSString *)waitTitle;

@end

NS_ASSUME_NONNULL_END
