//
//  UIViewController+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 一、modalPresentationStyle需要在present之前(init之后)设置才会生效，UINavigationController也可设置。
 二、iOS13由于modalPresentationStyle默认值为Automatic(PageSheet)，不会触发父控制器的viewWillDisappear|viewWillAppear等生命周期方法。
 三、modalPresentationCapturesStatusBarAppearance：弹出非UIModalPresentationFullScreen控制器时，该控制器是否控制状态栏样式。默认NO，不控制。
 四、如果ScrollView占不满导航栏，iOS11则需要设置contentInsetAdjustmentBehavior为UIScrollViewContentInsetAdjustmentNever
 */
@interface UIViewController (FWApplication)

#pragma mark - Child

/// 获取当前显示的子控制器，解决不能触发viewWillAppear等的bug
- (nullable UIViewController *)fw_childViewController NS_SWIFT_NAME(__fw_childViewController()) NS_REFINED_FOR_SWIFT;

/// 设置当前显示的子控制器，解决不能触发viewWillAppear等的bug
- (void)fw_setChildViewController:(UIViewController *)viewController NS_REFINED_FOR_SWIFT;

/// 移除子控制器，解决不能触发viewWillAppear等的bug
- (void)fw_removeChildViewController:(UIViewController *)viewController NS_REFINED_FOR_SWIFT;

/// 添加子控制器到当前视图，解决不能触发viewWillAppear等的bug
- (void)fw_addChildViewController:(UIViewController *)viewController NS_REFINED_FOR_SWIFT;

/// 添加子控制器到指定视图，可自定义布局，解决不能触发viewWillAppear等的bug
- (void)fw_addChildViewController:(UIViewController *)viewController inView:(nullable UIView *)view layout:(nullable void (NS_NOESCAPE ^)(UIView *view))layout NS_REFINED_FOR_SWIFT;

#pragma mark - Previous

/// 获取和自身处于同一个UINavigationController里的上一个UIViewController
@property(nullable, nonatomic, weak, readonly) UIViewController *fw_previousViewController NS_SWIFT_NAME(__fw_previousViewController) NS_REFINED_FOR_SWIFT;

/**
 全局适配iOS13默认present样式(系统Automatic)，仅当未自定义modalPresentationStyle时生效
 */
@property (class, nonatomic, assign) UIModalPresentationStyle fw_defaultModalPresentationStyle NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
