/**
 @header     UIFont+FWApplication.h
 @indexgroup FWApplication
      UIFont+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/19
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (FWApplication)

#pragma mark - Font

/// 是否是粗体
@property (nonatomic, assign, readonly) BOOL fw_isBold NS_REFINED_FOR_SWIFT;

/// 是否是斜体
@property (nonatomic, assign, readonly) BOOL fw_isItalic NS_REFINED_FOR_SWIFT;

/// 当前字体的粗体字体
@property (nonatomic, strong, readonly) UIFont *fw_boldFont NS_REFINED_FOR_SWIFT;

/// 当前字体的非粗体字体
@property (nonatomic, strong, readonly) UIFont *fw_nonBoldFont NS_REFINED_FOR_SWIFT;

/// 当前字体的斜体字体
@property (nonatomic, strong, readonly) UIFont *fw_italicFont NS_REFINED_FOR_SWIFT;

/// 当前字体的非斜体字体
@property (nonatomic, strong, readonly) UIFont *fw_nonItalicFont NS_REFINED_FOR_SWIFT;

#pragma mark - Height

// 字体空白高度(上下之和)
@property (nonatomic, assign, readonly) CGFloat fw_spaceHeight NS_REFINED_FOR_SWIFT;

// 根据字体计算指定倍数行间距的实际行距值(减去空白高度)，示例：行间距为0.5倍实际高度
- (CGFloat)fw_lineSpacingWithMultiplier:(CGFloat)multiplier NS_REFINED_FOR_SWIFT;

// 根据字体计算指定倍数行高的实际行高值(减去空白高度)，示例：行高为1.5倍实际高度
- (CGFloat)fw_lineHeightWithMultiplier:(CGFloat)multiplier NS_REFINED_FOR_SWIFT;

/// 计算当前字体与指定字体居中对齐的偏移值
- (CGFloat)fw_baselineOffset:(UIFont *)font NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
