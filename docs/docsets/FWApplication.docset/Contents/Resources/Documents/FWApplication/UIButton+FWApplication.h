/**
 @header     UIButton+FWApplication.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/18
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface FWButtonWrapper (FWApplication)

/// 设置背景色
- (void)setBackgroundColor:(nullable UIColor *)backgroundColor forState:(UIControlState)state;

/// 设置按钮倒计时，从window移除时自动取消。等待时按钮disabled，非等待时enabled。时间支持格式化，示例：重新获取(%lds)
- (void)countDown:(NSInteger)timeout title:(NSString *)title waitTitle:(NSString *)waitTitle;

@end

NS_ASSUME_NONNULL_END
