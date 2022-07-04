/**
 @header     UILabel+FWApplication.h
 @indexgroup FWApplication
      UILabel+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/10/22
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 注意UILabel的lineBreakMode默认值为TruncatingTail，如设置numberOfLines为0时，需显示修改lineBreakMode值；
    自动布局时，可设置preferredMaxLayoutWidth，从而通过intrinsicContentSize获取多行Label的高度
 */
@interface UILabel (FWApplication)

#pragma mark - Size

// 计算当前文本所占尺寸，需frame或者宽度布局完整
@property (nonatomic, assign, readonly) CGSize fw_textSize NS_REFINED_FOR_SWIFT;

// 计算当前属性文本所占尺寸，需frame或者宽度布局完整，attributedText需指定字体
@property (nonatomic, assign, readonly) CGSize fw_attributedTextSize NS_REFINED_FOR_SWIFT;

@end

#pragma mark - UILabel+FWDebugger

@interface UILabel (FWDebugger)

/**
 调试功能，打开后会在 label 第一行文字里把 descender、xHeight、capHeight、lineHeight 所在的位置以线条的形式标记出来。
 对这些属性的解释可以看这篇文章 https://www.rightpoint.com/rplabs/ios-tracking-typography
 */
@property (nonatomic, assign) BOOL fw_showPrincipalLines NS_REFINED_FOR_SWIFT;

/**
 当打开 showPrincipalLines 时，通过这个属性控制线条的颜色，默认为 半透明红色
 */
@property (nonatomic, strong) UIColor *fw_principalLineColor NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
