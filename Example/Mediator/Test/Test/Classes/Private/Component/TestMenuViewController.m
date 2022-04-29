//
//  TestMenuViewController.m
//  Example
//
//  Created by wuyong on 2019/5/9.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

#import "TestMenuViewController.h"

@interface TestMenuViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TestMenuViewController

- (void)renderInit
{
    self.fw.extendedLayoutEdge = UIRectEdgeTop;
}

- (BOOL)shouldPopController
{
    FWDrawerView *drawerView = self.contentView.fw.drawerView;
    [drawerView setPosition:drawerView.openPosition animated:YES];
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FWWeakifySelf();
    [self.fw setLeftBarItem:@"Menu" block:^(id sender) {
        FWStrongifySelf();
        FWDrawerView *drawerView = self.contentView.fw.drawerView;
        CGFloat position = (drawerView.position == drawerView.openPosition) ? drawerView.closePosition : drawerView.openPosition;
        [drawerView setPosition:position animated:YES];
    }];
    
    [self.fw addRightBarItem:@"相册" target:self action:@selector(onPhotoSheet:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.fw.backgroundTransparent = YES;
}

- (void)renderView
{
    self.view.backgroundColor = [Theme tableColor];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(-FWScreenWidth / 2.0, 0, FWScreenWidth / 2.0, self.view.fw.height)];
    _contentView = contentView;
    contentView.backgroundColor = [UIColor brownColor];
    UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 200, 100, 30)];
    topLabel.text = @"Menu 1";
    [contentView addSubview:topLabel];
    UILabel *middleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 250, 100, 30)];
    middleLabel.text = @"Menu 2";
    [contentView addSubview:middleLabel];
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 300, 100, 30)];
    bottomLabel.text = @"Menu 3";
    [contentView addSubview:bottomLabel];
    UILabel *closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 400, 100, 30)];
    closeLabel.text = @"Back";
    FWWeakifySelf();
    closeLabel.userInteractionEnabled = YES;
    [closeLabel.fw addTapGestureWithBlock:^(id sender) {
        FWStrongifySelf();
        [self.fw closeViewControllerAnimated:YES];
    }];
    [contentView addSubview:closeLabel];
    [self.view addSubview:contentView];
    
    [contentView.fw drawerView:UISwipeGestureRecognizerDirectionRight
                    positions:@[@(-FWScreenWidth / 2.0), @(0)]
               kickbackHeight:25
                     callback:nil];
    
    UIImageView *imageView = [UIImageView new];
    _imageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    imageView.fw.layoutChain.center().size(CGSizeMake(200, 200));
}

- (void)onPhotoSheet:(UIBarButtonItem *)sender
{
    FWWeakifySelf();
    [self.fw showSheetWithTitle:nil message:nil cancel:@"取消" actions:@[@"拍照", @"选取相册"] actionBlock:^(NSInteger index) {
        FWStrongifySelf();
        if (index == 0) {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self.fw showAlertWithTitle:@"未检测到您的摄像头" message:nil cancel:nil cancelBlock:nil];
                return;
            }
            
            [self.fw showImageCameraWithAllowsEditing:YES completion:^(UIImage * _Nullable image, BOOL cancel) {
                FWStrongifySelf();
                [self onPickerResult:image cancelled:cancel];
            }];
        } else {
            [self.fw showImagePickerWithAllowsEditing:YES completion:^(UIImage * _Nullable image, BOOL cancel) {
                FWStrongifySelf();
                [self onPickerResult:image cancelled:cancel];
            }];
        }
    }];
}

- (void)onPickerResult:(UIImage *)image cancelled:(BOOL)cancelled
{
    self.imageView.image = cancelled ? nil : image;
    if (!self.imageView.image.CGImage) return;
    
    if (@available(iOS 13.0, *)) {
        [UIApplication.fw recognizeTextIn:self.imageView.image.CGImage completion:^(NSArray<FWOcrObject *> *results) {
            NSMutableString *string = [NSMutableString string];
            for (FWOcrObject *object in results) {
                [string appendFormat:@"text: %@\nconfidence: %@\n", object.text, @(object.confidence)];
            }
            NSString *message = string.length > 0 ? string.copy : @"识别结果为空";
            [UIWindow.fw.mainWindow.fw showAlertWithTitle:@"扫描结果" message:message];
        }];
    }
}

@end
