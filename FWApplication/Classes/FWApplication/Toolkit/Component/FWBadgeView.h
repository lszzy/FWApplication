//
//  FWBadgeView.h
//  FWApplication
//
//  Created by wuyong on 2017/4/10.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FWAppWrapper.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWBadgeView

/// 自带提醒灯样式
typedef NS_ENUM(NSInteger, FWBadgeStyle) {
    /// 小红点，(10)*(10)
    FWBadgeStyleDot = 1,
    /// 小提醒灯，同系统标签，(18+)*(18)，12号字体
    FWBadgeStyleSmall,
    /// 大提醒灯，同系统桌面，(24+)*(24)，14号字体
    FWBadgeStyleBig,
} NS_SWIFT_NAME(BadgeStyle);

/// 提醒灯视图，默认禁用userInteractionEnabled
NS_SWIFT_NAME(BadgeView)
@interface FWBadgeView : UIView

/// 提醒灯样式，默认0自定义
@property (nonatomic, readonly) FWBadgeStyle badgeStyle;
/// 提醒灯文本标签。可自定义样式
@property (nullable, nonatomic, readonly) UILabel *badgeLabel;
/// 提醒灯右上偏移值
@property (nonatomic, readonly) CGPoint badgeOffset;

/// 初始化自带样式提醒灯。宽高自动布局，其它手工布局
- (instancetype)initWithBadgeStyle:(FWBadgeStyle)badgeStyle;

/// 初始化自定义提醒灯。宽高自动布局，其它手工布局
- (instancetype)initWithBadgeHeight:(CGFloat)badgeHeight
                        badgeOffset:(CGPoint)badgeOffset
                          textInset:(CGFloat)textInset
                           fontSize:(CGFloat)fontSize;

@end

#pragma mark - FWViewWrapper+FWBadge

@interface FWViewWrapper (FWBadge)

/// 显示右上角提醒灯，上右偏移指定距离
- (void)showBadgeView:(FWBadgeView *)badgeView badgeValue:(nullable NSString *)badgeValue;

/// 隐藏提醒灯
- (void)hideBadgeView;

@end

#pragma mark - FWBarItemWrapper+FWBadge

@interface FWBarItemWrapper (FWBadge)

/// 获取UIBarItem(UIBarButtonItem、UITabBarItem)内部的view，通常对于navigationItem和tabBarItem而言，需要在设置为item后并且在bar可见时(例如 viewDidAppear:及之后)获取fwView才有值
@property (nullable, nonatomic, weak, readonly) UIView *view;

/// 当item内的view生成后就会调用一次这个block，仅对UIBarButtonItem、UITabBarItem有效
@property (nullable, nonatomic, copy) void (^viewLoadedBlock)(__kindof UIBarItem *item, UIView *view);

@end

#pragma mark - FWBarButtonItemWrapper+FWBadge

@interface FWBarButtonItemWrapper (FWBadge)

/// 显示右上角提醒灯，上右偏移指定距离
- (void)showBadgeView:(FWBadgeView *)badgeView badgeValue:(nullable NSString *)badgeValue;

/// 隐藏提醒灯
- (void)hideBadgeView;

@end

#pragma mark - FWTabBarItemWrapper+FWBadge

@interface FWTabBarItemWrapper (FWBadge)

/// 获取一个UITabBarItem内显示图标的UIImageView，如果找不到则返回nil
@property (nullable, nonatomic, weak, readonly) UIImageView *imageView;

/// 显示右上角提醒灯，上右偏移指定距离
- (void)showBadgeView:(FWBadgeView *)badgeView badgeValue:(nullable NSString *)badgeValue;

/// 隐藏提醒灯
- (void)hideBadgeView;

@end

NS_ASSUME_NONNULL_END
