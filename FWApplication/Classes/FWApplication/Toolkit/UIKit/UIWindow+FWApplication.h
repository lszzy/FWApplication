//
//  UIWindow+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 2017/6/19.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface FWWindowWrapper (FWApplication)

// 关闭所有弹出控制器，完成时回调。如果没有present控制器，直接回调
- (void)dismissViewControllers:(nullable void (^)(void))completion;

// 选中并获取指定类TabBar根视图控制器，适用于Tabbar包含多个Navigation结构，找不到返回nil
- (nullable __kindof UIViewController *)selectTabBarController:(Class)viewController;

// 选中并获取指定索引TabBar根视图控制器，适用于Tabbar包含多个Navigation结构，找不到返回nil
- (nullable __kindof UIViewController *)selectTabBarIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
