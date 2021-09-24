//
//  FWAlertControllerImpl.h
//  FWApplication
//
//  Created by wuyong on 2020/4/25.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

#import "FWAlertPluginImpl.h"
#import "FWAlertController.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWAlertControllerPlugin

@interface FWAlertControllerPlugin : NSObject <FWAlertPlugin>

/*! @brief 单例模式 */
@property (class, nonatomic, readonly) FWAlertControllerPlugin *sharedInstance;

/// 弹窗自定义句柄，show方法自动调用
@property (nonatomic, copy, nullable) void (^customBlock)(FWAlertController *alertController);

/// 显示自定义视图弹窗，无默认按钮
- (void)fwViewController:(UIViewController *)viewController
               showAlert:(UIAlertControllerStyle)style
              headerView:(UIView *)headerView
                  cancel:(nullable id)cancel
                 actions:(nullable NSArray *)actions
             actionBlock:(nullable void (^)(NSInteger index))actionBlock
             cancelBlock:(nullable void (^)(void))cancelBlock
             customBlock:(nullable void (^)(id alertController))customBlock
                priority:(FWAlertPriority)priority;

@end

NS_ASSUME_NONNULL_END