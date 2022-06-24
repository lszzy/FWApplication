//
//  TestVersionViewController.m
//  Example
//
//  Created by wuyong on 2019/4/2.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

#import "TestVersionViewController.h"

@interface TestVersionViewController ()

@end

@implementation TestVersionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *deviceText = [NSString stringWithFormat:@"Device UUID: \n%@", [UIDevice.fw deviceUUID]];
    UILabel *textLabel = [UILabel fw_labelWithFont:[UIFont fw_fontOfSize:15] textColor:[Theme textColor] text:deviceText];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    [self.view addSubview:textLabel];
    [textLabel fw_alignCenterToSuperview];
    [textLabel fw_pinHorizontalToSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 数据更新
    FWWeakifySelf();
    [[FWVersionManager sharedInstance] checkDataVersion:@"1.2.1" migrator:^{
        FWStrongifySelf();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fw_showAlertWithTitle:nil message:@"数据更新至1.2.1版本" cancel:nil cancelBlock:nil];
        });
    }];
    [[FWVersionManager sharedInstance] checkDataVersion:@"1.0.0" migrator:^{
        FWStrongifySelf();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fw_showAlertWithTitle:nil message:@"数据更新至1.0.0版本" cancel:nil cancelBlock:nil];
        });
    }];
    [[FWVersionManager sharedInstance] migrateData:^{
        FWStrongifySelf();
        [self fw_showAlertWithTitle:nil message:@"数据更新完毕" cancel:nil cancelBlock:nil];
    }];
    
    // 版本更新
    [FWVersionManager sharedInstance].appId = @"414478124";
    [FWVersionManager sharedInstance].countryCode = @"cn";
    [[FWVersionManager sharedInstance] checkVersion:0 completion:^() {
        FWStrongifySelf();
        NSLog(@"version status: %@", @([FWVersionManager sharedInstance].status));
        
        if ([FWVersionManager sharedInstance].status == FWVersionStatusAuditing) {
            [self fw_showAlertWithTitle:nil message:@"当前版本正在审核中" style:FWAlertStyleDefault cancel:nil actions:nil actionBlock:nil cancelBlock:nil];
        } else if ([FWVersionManager sharedInstance].status == FWVersionStatusUpdating) {
            BOOL isForce = NO;
            if (isForce) {
                // 强制更新
                NSString *title = [NSString stringWithFormat:@"%@的新版本可用。请立即更新到%@版本。", @"微信", [FWVersionManager sharedInstance].latestVersion];
                [self fw_showAlertWithTitle:title message:[FWVersionManager sharedInstance].releaseNotes style:FWAlertStyleDefault cancel:@"更新" actions:nil actionBlock:nil cancelBlock:^{
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apps.apple.com/app/id%@", [FWVersionManager sharedInstance].appId]];
                    [UIApplication fw_openURL:url completionHandler:^(BOOL success) {
                        if (success) {
                            exit(EXIT_SUCCESS);
                        }
                    }];
                }];
            } else {
                // 非强制更新
                NSString *title = [NSString stringWithFormat:@"%@的新版本可用。请立即更新到%@版本。", @"微信", [FWVersionManager sharedInstance].latestVersion];
                [self fw_showConfirmWithTitle:title message:[FWVersionManager sharedInstance].releaseNotes cancel:@"取消" confirm:@"更新" confirmBlock:^{
                    [[FWVersionManager sharedInstance] openAppStore];
                } cancelBlock:nil];
            }
        }
    }];
}

@end
