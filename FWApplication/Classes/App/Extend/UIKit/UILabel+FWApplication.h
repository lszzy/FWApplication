/*!
 @header     UILabel+FWApplication.h
 @indexgroup FWApplication
 @brief      UILabel+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/10/22
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief UILabel+FWApplication
 @discussion 注意UILabel的lineBreakMode默认值为TruncatingTail，如设置numberOfLines为0时，需显示修改lineBreakMode值；
    自动布局时，可设置preferredMaxLayoutWidth，从而通过intrinsicContentSize获取多行Label的高度
 */
@interface UILabel (FWApplication)

// 快速设置标签，不设置传nil即可
- (void)fwSetFont:(nullable UIFont *)font textColor:(nullable UIColor *)textColor text:(nullable NSString *)text;

// 快速创建标签，不初始化传nil即可
+ (instancetype)fwLabelWithFont:(nullable UIFont *)font textColor:(nullable UIColor *)textColor text:(nullable NSString *)text;

#pragma mark - Size

// 计算当前文本所占尺寸，需frame或者宽度布局完整
@property (nonatomic, assign, readonly) CGSize fwTextSize;

// 计算当前属性文本所占尺寸，需frame或者宽度布局完整，attributedText需指定字体
@property (nonatomic, assign, readonly) CGSize fwAttributedTextSize;

@end

NS_ASSUME_NONNULL_END
