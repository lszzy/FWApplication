/**
 @header     FWSceneDelegate.h
 @indexgroup FWApplication
      FWSceneDelegate
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/12
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 SceneDelegate基类
 */
API_AVAILABLE(ios(13.0))
NS_SWIFT_NAME(SceneResponder)
@interface FWSceneDelegate : UIResponder <UIWindowSceneDelegate>

/// 场景主window
@property (nullable, nonatomic, strong) UIWindow * window;

/// 初始化根控制器，子类重写
- (void)setupController;

@end

NS_ASSUME_NONNULL_END
