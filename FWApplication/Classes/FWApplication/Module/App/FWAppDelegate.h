/**
 @header     FWAppDelegate.h
 @indexgroup FWApplication
      FWAppDelegate
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/5/14
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 AppDelegate基类
 */
NS_SWIFT_NAME(AppResponder)
@interface FWAppDelegate : UIResponder <UIApplicationDelegate>

/// 应用主window
@property (nullable, nonatomic, strong) UIWindow *window;

#pragma mark - Protected

/// 初始化应用配置，子类重写
- (void)setupApplication:(UIApplication *)application options:(nullable NSDictionary<UIApplicationLaunchOptionsKey,id> *)options;

/// 初始化根控制器，子类重写
- (void)setupController;

@end

NS_ASSUME_NONNULL_END
