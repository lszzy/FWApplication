//
//  FWAppConfig.m
//  FWApplication
//
//  Created by wuyong on 2022/6/10.
//

#import "FWAppConfig.h"
#import "FWApplication.h"

@implementation FWAppConfig

@end

@implementation FWAppConfigDefaultTemplate

- (void)applyConfiguration {
    // 启用全局导航栏返回拦截
    // [UINavigationController.fw enablePopProxy];
    // 启用全局导航栏转场优化
    // [UINavigationController.fw enableBarTransition];
    // 设置默认导航栏样式
    // FWNavigationBarAppearance *defaultAppearance = [FWNavigationBarAppearance new];
    // defaultAppearance.foregroundColor = [UIColor.fw colorWithHex:0x111111];
    // 1. 指定导航栏背景色
    // defaultAppearance.backgroundColor = UIColor.whiteColor;
    // 2. 设置导航栏样式全透明
    // defaultAppearance.backgroundTransparent = YES;
    // defaultAppearance.shadowColor = nil;
    // [FWNavigationBarAppearance setAppearance:defaultAppearance forStyle:FWNavigationBarStyleDefault];
    
    // iOS15 UITableView兼容
    // if (@available(iOS 15.0, *)) {
    //    UITableView.appearance.sectionHeaderTopPadding = 0;
    // }
}

@end
