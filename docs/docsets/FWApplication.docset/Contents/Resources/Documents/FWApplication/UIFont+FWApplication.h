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

@interface FWFontWrapper (FWApplication)

#pragma mark - Font

/// 是否是粗体
@property (nonatomic, assign, readonly) BOOL isBold;

/// 是否是斜体
@property (nonatomic, assign, readonly) BOOL isItalic;

/// 当前字体的粗体字体
@property (nonatomic, strong, readonly) UIFont *boldFont;

/// 当前字体的非粗体字体
@property (nonatomic, strong, readonly) UIFont *nonBoldFont;

/// 当前字体的斜体字体
@property (nonatomic, strong, readonly) UIFont *italicFont;

/// 当前字体的非斜体字体
@property (nonatomic, strong, readonly) UIFont *nonItalicFont;

#pragma mark - Height

// 字体空白高度(上下之和)
@property (nonatomic, assign, readonly) CGFloat spaceHeight;

// 根据字体计算指定倍数行间距的实际行距值(减去空白高度)，示例：行间距为0.5倍实际高度
- (CGFloat)lineSpacingWithMultiplier:(CGFloat)multiplier;

// 根据字体计算指定倍数行高的实际行高值(减去空白高度)，示例：行高为1.5倍实际高度
- (CGFloat)lineHeightWithMultiplier:(CGFloat)multiplier;

/// 计算当前字体与指定字体居中对齐的偏移值
- (CGFloat)baselineOffset:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
