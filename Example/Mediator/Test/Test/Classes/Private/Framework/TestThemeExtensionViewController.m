//
//  TestThemeExtensionViewController.m
//  Example
//
//  Created by wuyong on 2020/9/16.
//  Copyright © 2020 site.wuyong. All rights reserved.
//

#import "TestThemeExtensionViewController.h"
#import "TestTabBarViewController.h"

static const FWThemeStyle FWThemeStyleRed = 3;

@interface TestThemeExtensionViewController ()

@end

@implementation TestThemeExtensionViewController

- (void)renderView
{
    self.view.backgroundColor = [UIColor fw_themeColor:^UIColor * _Nonnull(FWThemeStyle style) {
        if (style == FWThemeStyleDark) {
            return [UIColor blackColor];
        } else if (style == FWThemeStyleLight) {
            return [UIColor whiteColor];
        } else {
            return [UIColor whiteColor];
        }
    }];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    colorView.backgroundColor = [UIColor fw_themeColor:^UIColor * _Nonnull(FWThemeStyle style) {
        if (style == FWThemeStyleDark) {
            return [UIColor whiteColor];
        } else if (style == FWThemeStyleLight) {
            return [UIColor blackColor];
        } else {
            return [UIColor redColor];
        }
    }];
    [self.view addSubview:colorView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 90, 50, 50)];
    imageView.fw_themeImage = [UIImage fw_themeImage:^UIImage *(FWThemeStyle style) {
        if (style == FWThemeStyleDark) {
            return [TestBundle imageNamed:@"theme_image_dark"];
        } else if (style == FWThemeStyleLight) {
            return [TestBundle imageNamed:@"theme_image_light"];
        } else {
            return [[TestBundle imageNamed:@"theme_image_dark"].fw imageWithTintColor:[UIColor redColor]];
        }
    }];
    [self.view addSubview:imageView];
    
    UIImageView *assetView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 160, 50, 50)];
    assetView.fw_themeAsset = [UIImageAsset fw_themeAsset:^UIImage * _Nullable(FWThemeStyle style) {
        if (style == FWThemeStyleDark) {
            return [TestBundle imageNamed:@"theme_image_dark"];
        } else if (style == FWThemeStyleLight) {
            return [TestBundle imageNamed:@"theme_image_light"];
        } else {
            return [[TestBundle imageNamed:@"theme_image_dark"].fw imageWithTintColor:[UIColor redColor]];
        }
    }];
    [self.view addSubview:assetView];
    
    CALayer *layer = [CALayer new];
    layer.frame = CGRectMake(20, 230, 50, 50);
    layer.fw_themeContext = self.view;
    layer.fw_themeBackgroundColor = [UIColor fw_themeColor:^UIColor * _Nonnull(FWThemeStyle style) {
        if (style == FWThemeStyleDark) {
            return [UIColor whiteColor];
        } else if (style == FWThemeStyleLight) {
            return [UIColor blackColor];
        } else {
            return [UIColor redColor];
        }
    }];
    [self.view.layer addSublayer:layer];
    
    UILabel *themeLabel = [UILabel new];
    themeLabel.frame = CGRectMake(20, 300, FWScreenWidth, 50);
    UIColor *textColor = [UIColor fw_themeColor:^UIColor * _Nonnull(FWThemeStyle style) {
        if (style == FWThemeStyleDark) {
            return [UIColor whiteColor];
        } else if (style == FWThemeStyleLight) {
            return [UIColor blackColor];
        } else {
            return [UIColor redColor];
        }
    }];
    themeLabel.attributedText = [NSAttributedString.fw attributedString:@"我是AttributedString" withFont:FWFontSize(16).fw.boldFont textColor:textColor];
    [self.view addSubview:themeLabel];
}

- (void)renderModel
{
    FWThemeMode mode = FWThemeManager.sharedInstance.mode;
    NSMutableArray *themes = [NSMutableArray arrayWithArray:@[@"系统", @"浅色", @"深色"]];
    NSString *title = mode < themes.count ? [themes objectAtIndex:mode] : @"红色";
    [themes addObject:@"红色"];
    FWWeakifySelf();
    [self.fw setRightBarItem:title block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        
        [self.fw showSheetWithTitle:nil message:nil cancel:@"取消" actions:themes actionBlock:^(NSInteger index) {
            FWStrongifySelf();
            
            FWThemeManager.sharedInstance.mode = (index == themes.count - 1) ? FWThemeStyleRed : index;
            [self renderModel];
            [TestTabBarViewController refreshController];
        }];
    }];
}

@end
