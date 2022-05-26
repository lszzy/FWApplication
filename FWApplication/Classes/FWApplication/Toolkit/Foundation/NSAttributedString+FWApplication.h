/**
 @header     NSAttributedString+FWApplication.h
 @indexgroup FWApplication
      NSAttributedString+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/12/25
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWAttributedOption

/**
 NSAttributedString属性封装器
 */
NS_SWIFT_NAME(AttributedOption)
@interface FWAttributedOption : NSObject <NSCopying>

#pragma mark - Attribute

// 设置字体
@property (nullable, nonatomic, strong) UIFont *font;

// 设置文本段落排版格式
@property (nullable, nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;

// 设置字体颜色
@property (nullable, nonatomic, strong) UIColor *foregroundColor;

// 设置字体所在区域背景颜色
@property (nullable, nonatomic, strong) UIColor *backgroundColor;

// 设置连体属性，@0表示没有连体字符，@1表示使用默认的连体字符
@property (nullable, nonatomic, strong) NSNumber *ligature;

// 设置字符间距，正值间距加宽，负值间距变窄
@property (nullable, nonatomic, strong) NSNumber *kern;

// 设置删除线
@property (nullable, nonatomic, strong) NSNumber *strikethroughStyle;

// 设置删除线颜色
@property (nullable, nonatomic, strong) UIColor *strikethroughColor;

// 设置下划线
@property (nullable, nonatomic, strong) NSNumber *underlineStyle;

// 设置下划线颜色
@property (nullable, nonatomic, strong) UIColor *underlineColor;

// 设置笔画宽度，负值填充效果，正值中空效果
@property (nullable, nonatomic, strong) NSNumber *strokeWidth;

// 设置填充颜色
@property (nullable, nonatomic, strong) UIColor *strokeColor;

// 设置阴影属性
@property (nullable, nonatomic, strong) NSShadow *shadow;

// 设置文本特殊效果，目前只有图版印刷效果可用
@property (nullable, nonatomic, copy) NSTextEffectStyle textEffect;

// 设置基线偏移值，正值上偏，负值下偏
@property (nullable, nonatomic, strong) NSNumber *baselineOffset;

// 设置字形倾斜度，正值右倾，负值左倾
@property (nullable, nonatomic, strong) NSNumber *obliqueness;

// 设置文本横向拉伸属性，正值横向拉伸文本，负值横向压缩文本
@property (nullable, nonatomic, strong) NSNumber *expansion;

// 设置文字书写方向，从左向右书写或者从右向左书写
@property (nullable, nonatomic, strong) NSNumber *writingDirection;

// 设置文字排版方向，@0表示横排文本，@1表示竖排文本，iOS只支持@0
@property (nullable, nonatomic, strong) NSNumber *verticalGlyphForm;

// 设置链接属性，点击后调用浏览器打开指定URL地址，NSString或NSURL对象，仅UITextView支持
@property (nullable, nonatomic, copy) NSURL *link;

// 设置文本附件，常用于文字图片混排
@property (nullable, nonatomic, strong) NSTextAttachment *attachment;

#pragma mark - Public

// 设置行高倍数，需指定font生效，优先级低，默认0，示例：行高为1.5倍实际高度
@property (nonatomic, assign) CGFloat lineHeightMultiplier;

// 设置行间距倍数，需指定font生效，优先级低，默认0，示例：行间距为0.5倍实际高度
@property (nonatomic, assign) CGFloat lineSpacingMultiplier;

// Appearance，统一设置样式
@property (class, nonatomic, readonly) FWAttributedOption *appearance;

// 转换为属性字典
- (NSDictionary<NSAttributedStringKey, id> *)toDictionary;

@end

#pragma mark - FWAttributedStringClassWrapper+FWApplication

@class FWThemeObject<__covariant ObjectType>;

/**
 注意iOS在后台运行时，如果调用NSAttributedString解析html会导致崩溃(如动态切换深色模式时在后台解析html)。解决方法是提前在前台解析好或者后台异步到下一个主线程RunLoop
 */
@interface FWAttributedStringClassWrapper (FWApplication)

#pragma mark - Convert

/// 快速创建NSAttributedString，自定义字体
- (__kindof NSAttributedString *)attributedString:(NSString *)string withFont:(nullable UIFont *)font;

/// 快速创建NSAttributedString，自定义字体和颜色
- (__kindof NSAttributedString *)attributedString:(NSString *)string withFont:(nullable UIFont *)font textColor:(nullable UIColor *)textColor;

#pragma mark - Html

/// html字符串转换为NSAttributedString对象，可设置默认系统字体和颜色(附加CSS方式)
- (nullable __kindof NSAttributedString *)attributedStringWithHtmlString:(NSString *)htmlString defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

/// html字符串转换为NSAttributedString主题对象，可设置默认系统字体和动态颜色，详见FWThemeObject
- (FWThemeObject<NSAttributedString *> *)themeObjectWithHtmlString:(NSString *)htmlString defaultAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes;

// 获取颜色对应CSS字符串(rgb|rgba格式)
- (NSString *)CSSStringWithColor:(UIColor *)color;

// 获取系统字体对应CSS字符串(family|style|weight|size)
- (NSString *)CSSStringWithFont:(UIFont *)font;

#pragma mark - Option

// 快速创建NSAttributedString，自定义选项
- (__kindof NSAttributedString *)attributedString:(NSString *)string withOption:(nullable FWAttributedOption *)option;

@end

NS_ASSUME_NONNULL_END
