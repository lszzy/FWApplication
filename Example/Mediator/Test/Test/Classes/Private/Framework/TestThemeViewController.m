//
//  TestThemeViewController.m
//  Example
//
//  Created by wuyong on 2020/8/14.
//  Copyright © 2020 site.wuyong. All rights reserved.
//

#import "TestThemeViewController.h"
#import "TestTabBarViewController.h"

@implementation TestThemeViewController

/*
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            FWThemeManager.sharedInstance.overrideWindow = YES;
        });
    });
}
*/

- (void)renderInit
{
    [self fw_observeNotification:FWThemeChangedNotification block:^(NSNotification * _Nonnull notification) {
        NSLog(@"主题改变通知：%@", @(FWThemeManager.sharedInstance.style));
    }];
    
    // iOS13以下named方式不支持动态颜色和图像，可手工注册之
    if (@available(iOS 13.0, *)) { } else {
        [UIColor fw_setThemeColor:[UIColor fw_themeLight:[UIColor blackColor] dark:[UIColor whiteColor]] forName:@"theme_color"];
        [UIImage fw_setThemeImage:[UIImage fw_themeLight:[TestBundle imageNamed:@"theme_image_light"] dark:[TestBundle imageNamed:@"theme_image_dark"]] forName:@"theme_image"];
    }
}

- (void)renderView
{
    self.view.backgroundColor = [UIColor fw_themeLight:[UIColor whiteColor] dark:[UIColor blackColor]];
    
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 50, 50)];
    colorView.backgroundColor = [UIColor fw_themeLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    [self.view addSubview:colorView];
    
    colorView = [[UIView alloc] initWithFrame:CGRectMake(90, 20, 50, 50)];
    colorView.backgroundColor = [UIColor fw_themeNamed:@"theme_color" bundle:TestBundle.bundle];
    [self.view addSubview:colorView];
    
    UIView *colorView1 = [[UIView alloc] initWithFrame:CGRectMake(160, 20, 50, 50)];
    [UIColor fw_setThemeColor:[UIColor fw_themeLight:[UIColor blackColor] dark:[UIColor whiteColor]] forName:@"dynamic_color"];
    UIColor *dynamicColor = [UIColor fw_themeNamed:@"dynamic_color"];
    colorView1.backgroundColor = [dynamicColor fw_colorForStyle:FWThemeManager.sharedInstance.style];
    FWWeakify(colorView1);
    [colorView1 fw_addThemeListener:^(FWThemeStyle style) {
        FWStrongify(colorView1);
        colorView1.backgroundColor = [dynamicColor fw_colorForStyle:style];
    }];
    [self.view addSubview:colorView1];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 90, 50, 50)];
    UIImage *themeImage = [UIImage fw_themeLight:[TestBundle imageNamed:@"theme_image_light"] dark:[TestBundle imageNamed:@"theme_image_dark"]];
    imageView1.image = themeImage.fw_image;
    FWWeakify(imageView1);
    [imageView1 fw_addThemeListener:^(FWThemeStyle style) {
        FWStrongify(imageView1);
        imageView1.image = themeImage.fw_image;
    }];
    [self.view addSubview:imageView1];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, 90, 50, 50)];
    imageView.fw_themeImage = [UIImage fw_themeNamed:@"theme_image" bundle:TestBundle.bundle];
    [self.view addSubview:imageView];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(160, 90, 50, 50)];
    UIImage *reverseImage = [UIImage fw_themeNamed:@"theme_image" bundle:TestBundle.bundle];
    imageView2.image = [reverseImage fw_imageForStyle:FWThemeManager.sharedInstance.style];
    FWWeakify(imageView2);
    [imageView2 fw_addThemeListener:^(FWThemeStyle style) {
        FWStrongify(imageView2);
        imageView2.image = [reverseImage fw_imageForStyle:style];
    }];
    [self.view addSubview:imageView2];
    
    CALayer *layer1 = [CALayer new];
    layer1.frame = CGRectMake(20, 160, 50, 50);
    UIColor *themeColor = [UIColor fw_themeLight:[UIColor blackColor] dark:[UIColor whiteColor]];
    layer1.backgroundColor = [themeColor fw_colorForStyle:FWThemeManager.sharedInstance.style].CGColor;
    layer1.fw_themeContext = self;
    FWWeakify(layer1);
    [layer1 fw_addThemeListener:^(FWThemeStyle style) {
        FWStrongify(layer1);
        layer1.backgroundColor = [themeColor fw_colorForStyle:style].CGColor;
    }];
    [self.view.layer addSublayer:layer1];
    
    CALayer *layer = [CALayer new];
    layer.frame = CGRectMake(90, 160, 50, 50);
    layer.fw_themeContext = self.view;
    layer.fw_themeBackgroundColor = [UIColor fw_themeColor:^UIColor * _Nonnull(FWThemeStyle style) {
        return style == FWThemeStyleDark ? [UIColor whiteColor] : [UIColor blackColor];
    }];
    [self.view.layer addSublayer:layer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer new];
    gradientLayer.frame = CGRectMake(160, 160, 50, 50);
    gradientLayer.fw_themeContext = self;
    gradientLayer.fw_themeColors = @[[UIColor fw_themeNamed:@"theme_color" bundle:TestBundle.bundle], [UIColor fw_themeNamed:@"theme_color" bundle:TestBundle.bundle]];
    [self.view.layer addSublayer:gradientLayer];
    
    CALayer *layer2 = [CALayer new];
    layer2.frame = CGRectMake(20, 230, 50, 50);
    UIImage *layerImage = [UIImage fw_themeLight:[TestBundle imageNamed:@"theme_image_light"] dark:[TestBundle imageNamed:@"theme_image_dark"]];
    layer2.contents = (id)layerImage.fw_image.CGImage;
    layer2.fw_themeContext = self.view;
    FWWeakify(layer2);
    [layer2 fw_addThemeListener:^(FWThemeStyle style) {
        FWStrongify(layer2);
        layer2.contents = (id)layerImage.fw_image.CGImage;
    }];
    [self.view.layer addSublayer:layer2];
    
    layer = [CALayer new];
    layer.frame = CGRectMake(90, 230, 50, 50);
    layer.fw_themeContext = self;
    layer.fw_themeContents = [UIImage fw_themeImage:^UIImage * _Nonnull(FWThemeStyle style) {
        return style == FWThemeStyleDark ? [TestBundle imageNamed:@"theme_image_dark"] : [TestBundle imageNamed:@"theme_image_light"];
    }];
    [self.view.layer addSublayer:layer];
    
    layer = [CALayer new];
    layer.frame = CGRectMake(160, 230, 50, 50);
    layer.fw_themeContext = self.view;
    layer.fw_themeContents = [UIImage fw_themeNamed:@"theme_image" bundle:TestBundle.bundle];
    [self.view.layer addSublayer:layer];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 300, 50, 50)];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage.fw_themeImageColor = Theme.textColor;
    });
    imageView.fw_themeImage = [TestBundle imageNamed:@"tabbar_settings"].fw_themeImage;
    [self.view addSubview:imageView];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, 300, 50, 50)];
    UIImage *colorImage = [UIImage fw_themeLight:[TestBundle imageNamed:@"tabbar_settings"] dark:[TestBundle imageNamed:@"tabbar_test"]];
    imageView.fw_themeImage = [colorImage fw_themeImageWithColor:Theme.textColor];
    [self.view addSubview:imageView];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(160, 300, 50, 50)];
    imageView.fw_themeImage = [[TestBundle imageNamed:@"tabbar_settings"] fw_themeImageWithColor:[UIColor redColor]];
    [self.view addSubview:imageView];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 370, 50, 50)];
    imageView.fw_themeAsset = [UIImageAsset fw_themeLight:[TestBundle imageNamed:@"tabbar_settings"] dark:[[TestBundle imageNamed:@"tabbar_settings"] fw_imageWithTintColor:[UIColor whiteColor]]];
    [self.view addSubview:imageView];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(90, 370, 50, 50)];
    imageView.fw_themeAsset = [UIImageAsset fw_themeAsset:^UIImage * (FWThemeStyle style) {
        return style == FWThemeStyleDark ? [[TestBundle imageNamed:@"tabbar_settings"] fw_imageWithTintColor:[UIColor yellowColor]] : [TestBundle imageNamed:@"tabbar_settings"];
    }];
    [self.view addSubview:imageView];
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(160, 370, 50, 50)];
    [UIImage fw_setThemeImage:[UIImage fw_themeLight:[TestBundle imageNamed:@"tabbar_settings"] dark:[[TestBundle imageNamed:@"tabbar_settings"] fw_imageWithTintColor:[UIColor redColor]]] forName:@"dynamic_image"];
    UIImage *dynamicImage = [UIImage fw_themeNamed:@"dynamic_image"];
    imageView3.image = [dynamicImage fw_imageForStyle:FWThemeManager.sharedInstance.style];
    FWWeakify(imageView3);
    [imageView3 fw_addThemeListener:^(FWThemeStyle style) {
        FWStrongify(imageView3);
        imageView3.image = [dynamicImage fw_imageForStyle:style];
    }];
    [self.view addSubview:imageView3];
    
    UILabel *colorLabel = [UILabel new];
    colorLabel.frame = CGRectMake(0, 440, FWScreenWidth, 25);
    colorLabel.textAlignment = NSTextAlignmentCenter;
    colorLabel.font = FWFontSize(16).fw_boldFont;
    colorLabel.textColor = Theme.textColor;
    UIColor *lightColor = [Theme.textColor fw_colorForStyle:FWThemeStyleLight];
    UIColor *darkColor = [Theme.textColor fw_colorForStyle:FWThemeStyleDark];
    colorLabel.text = [NSString stringWithFormat:@"Light: %@ Dark: %@", lightColor.fw_hexString, darkColor.fw_hexString];
    [self.view addSubview:colorLabel];
    
    UILabel *themeLabel = [UILabel new];
    themeLabel.frame = CGRectMake(0, 475, FWScreenWidth, 25);
    themeLabel.textAlignment = NSTextAlignmentCenter;
    themeLabel.attributedText = [NSAttributedString fw_attributedString:@"我是AttributedString" withFont:FWFontSize(16).fw_boldFont textColor:[UIColor fw_themeLight:[UIColor blackColor] dark:[UIColor whiteColor]]];
    [self.view addSubview:themeLabel];
    
    UIButton *themeButton = [UIButton new];
    themeButton.frame = CGRectMake(0, 510, FWScreenWidth, 50);
    themeButton.titleLabel.font = FWFontRegular(16);
    [themeButton setTitleColor:[UIColor fw_themeLight:[UIColor blackColor] dark:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    UIImage *buttonImage = [UIImage fw_themeLight:(FWThemeManager.sharedInstance.style == FWThemeStyleLight ? nil : [TestBundle imageNamed:@"theme_image_light"]) dark:(FWThemeManager.sharedInstance.style == FWThemeStyleDark ? nil : [TestBundle imageNamed:@"theme_image_dark"])];
    FWThemeObject<NSAttributedString *> *themeString = [NSAttributedString fw_themeObjectWithHtmlString:@"我是<span style='color:red;'>红色</span>AttributedString" defaultAttributes:@{
        NSFontAttributeName: FWFontBold(16),
        NSForegroundColorAttributeName: [UIColor fw_themeLight:[UIColor blackColor] dark:[UIColor whiteColor]],
    }];
    
    [themeButton setImage:buttonImage.fw_image forState:UIControlStateNormal];
    [themeButton setAttributedTitle:themeString.object forState:UIControlStateNormal];
    [themeLabel fw_addThemeListener:^(FWThemeStyle style) {
        [themeButton setImage:buttonImage.fw_image forState:UIControlStateNormal];
        [themeButton setAttributedTitle:themeString.object forState:UIControlStateNormal];
    }];
    [self.view addSubview:themeButton];
}

- (void)renderModel
{
    FWThemeMode mode = FWThemeManager.sharedInstance.mode;
    NSString *title = mode == FWThemeModeSystem ? @"系统" : (mode == FWThemeModeDark ? @"深色" : @"浅色");
    FWWeakifySelf();
    [self fw_setRightBarItem:title block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        
        NSMutableArray *actions = [NSMutableArray arrayWithArray:@[@"系统", @"浅色", @"深色"]];
        [self fw_showSheetWithTitle:nil message:nil cancel:@"取消" actions:actions actionBlock:^(NSInteger index) {
            FWStrongifySelf();
            
            FWThemeManager.sharedInstance.mode = index;
            [self renderModel];
            [TestTabBarViewController refreshController];
        }];
    }];
}

@end
