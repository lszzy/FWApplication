/**
 @header     FWView.h
 @indexgroup FWApplication
      FWView
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/12/27
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 定义类事件名称
 
 @param name 事件名称
 */
#define FWEvent( name ) \
    @property (nonatomic, readonly) NSString * name; \
    - (NSString *)name; \
    + (NSString *)name;

/**
 定义类事件名称实现
 
 @param name 事件名称
 */
#define FWDefEvent( name ) \
    @dynamic name; \
    - (NSString *)name { return [[self class] name]; } \
    + (NSString *)name { return [NSString stringWithFormat:@"%@.%@.%s", @"event", NSStringFromClass([self class]), #name]; }

/**
 视图挂钩协议，可覆写
 */
@protocol FWView <NSObject>

@optional

/// 渲染初始化方法，init自动调用，默认未实现
- (void)renderInit;

/// 渲染视图方法，init自动调用，默认未实现
- (void)renderView;

/// 渲染布局方法，init自动调用，默认未实现
- (void)renderLayout;

/// 渲染数据方法，init和viewData改变时自动调用，默认未实现
- (void)renderData;

/// 渲染事件方法，事件完成时自动调用，默认未实现
- (void)renderEvent:(NSNotification *)notification;

@end

/// 通用视图事件代理
@protocol FWViewDelegate <NSObject>

@optional

/// 通用事件代理方法，通知名称即为事件名称
- (void)eventReceived:(__kindof UIView *)view withNotification:(NSNotification *)notification;

@end

@interface FWViewWrapper (FWView)

/// 通用视图绑定数据，改变时自动触发viewDataChanged和FWView.renderData
@property (nullable, nonatomic, strong) id viewData;

/// 通用视图数据改变句柄钩子，viewData改变时自动调用
@property (nullable, nonatomic, copy) void (^viewDataChanged)(__kindof UIView *view);

/// 通用事件接收代理，弱引用，Delegate方式
@property (nonatomic, weak, nullable) id<FWViewDelegate> viewDelegate;

/// 通用事件接收句柄，Block方式
@property (nonatomic, copy, nullable) void (^eventReceived)(__kindof UIView *view, NSNotification *notification);

/// 通用事件完成回调句柄，Block方式
@property (nonatomic, copy, nullable) void (^eventFinished)(__kindof UIView *view, NSNotification *notification);

/// 发送指定事件，通知代理，支持附带对象和用户信息
- (void)sendEvent:(NSString *)name;
- (void)sendEvent:(NSString *)name object:(nullable id)object;
- (void)sendEvent:(NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;

/// 通知事件完成，自动调用eventFinished句柄和FWView.renderEvent钩子
- (void)finishEvent:(NSNotification *)notification;

@end

NS_ASSUME_NONNULL_END
