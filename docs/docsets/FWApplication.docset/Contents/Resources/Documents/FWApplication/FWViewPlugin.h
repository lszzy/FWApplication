/**
 @header     FWViewPlugin.h
 @indexgroup FWApplication
      FWViewPlugin
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWProgressViewPlugin

/// 进度条视图样式枚举，可扩展
typedef NSInteger FWProgressViewStyle NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(ProgressViewStyle);
/// 默认进度条样式，用于框架Toast等
static const FWProgressViewStyle FWProgressViewStyleDefault = 0;

/// 自定义进度条视图插件
NS_SWIFT_NAME(ProgressViewPlugin)
@protocol FWProgressViewPlugin <NSObject>
@required

/// 设置或获取进度条当前颜色
@property (nonatomic, strong) UIColor *color;
/// 设置或获取进度条大小
@property (nonatomic, assign) CGSize size;
/// 设置或获取进度条当前进度
@property (nonatomic, assign) CGFloat progress;
/// 设置进度条当前进度，支持动画
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end

#pragma mark - FWIndicatorViewPlugin

/// 指示器视图样式枚举，可扩展
typedef NSInteger FWIndicatorViewStyle NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(IndicatorViewStyle);
/// 默认指示器样式，用于框架Empty|Toast等
static const FWIndicatorViewStyle FWIndicatorViewStyleDefault = 0;
/// 刷新指示器样式，用于框架Refresh等
static const FWIndicatorViewStyle FWIndicatorViewStyleRefresh = 1;

/// 自定义指示器视图协议
NS_SWIFT_NAME(IndicatorViewPlugin)
@protocol FWIndicatorViewPlugin <NSObject>
@required

/// 设置或获取指示器当前颜色
@property (nonatomic, strong) UIColor *color;
/// 设置或获取指示器大小
@property (nonatomic, assign) CGSize size;
/// 当前是否正在执行动画
@property (nonatomic, assign, readonly) BOOL isAnimating;
/// 开始加载动画
- (void)startAnimating;
/// 停止加载动画
- (void)stopAnimating;

@end

#pragma mark - FWViewPlugin

/// 视图插件协议
NS_SWIFT_NAME(ViewPlugin)
@protocol FWViewPlugin <NSObject>
@optional

/// 进度视图工厂方法
- (UIView<FWProgressViewPlugin> *)progressViewWithStyle:(FWProgressViewStyle)style;

/// 指示器视图工厂方法
- (UIView<FWIndicatorViewPlugin> *)indicatorViewWithStyle:(FWIndicatorViewStyle)style;

@end

#pragma mark - FWViewWrapper+FWViewPlugin

/// UIView视图插件分类
@interface FWViewWrapper (FWViewPlugin)

/// 自定义视图插件，未设置时自动从插件池加载
@property (nonatomic, strong, nullable) id<FWViewPlugin> viewPlugin;

/// 统一进度视图工厂方法
- (UIView<FWProgressViewPlugin> *)progressViewWithStyle:(FWProgressViewStyle)style;

/// 统一指示器视图工厂方法
- (UIView<FWIndicatorViewPlugin> *)indicatorViewWithStyle:(FWIndicatorViewStyle)style;

@end

@interface FWViewClassWrapper (FWViewPlugin)

/// 统一进度视图工厂方法
- (UIView<FWProgressViewPlugin> *)progressViewWithStyle:(FWProgressViewStyle)style;

/// 统一指示器视图工厂方法
- (UIView<FWIndicatorViewPlugin> *)indicatorViewWithStyle:(FWIndicatorViewStyle)style;

@end

NS_ASSUME_NONNULL_END
