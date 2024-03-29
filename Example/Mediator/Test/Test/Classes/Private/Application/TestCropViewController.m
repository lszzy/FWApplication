//
//  TestCropViewController.m
//  Example
//
//  Created by wuyong on 2020/6/22.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

#import "TestCropViewController.h"

@interface TestCropViewController () <FWImageCropControllerDelegate>

@property (nonatomic, strong) UIImage *image;           // The image we'll be cropping
@property (nonatomic, strong) UIImageView *imageView;   // The image view to present the cropped image

@property (nonatomic, assign) FWImageCropCroppingStyle croppingStyle; //The cropping style
@property (nonatomic, assign) CGRect croppedFrame;
@property (nonatomic, assign) NSInteger angle;

@end

@implementation TestCropViewController

#pragma mark - Gesture Recognizer -

- (FWImageCropController *)createCropController
{
    FWImageCropController *cropController = [[FWImageCropController alloc] initWithCroppingStyle:self.croppingStyle image:self.image];
    cropController.delegate = self;
    cropController.aspectRatioPickerButtonHidden = YES;
    cropController.rotateButtonsHidden = YES;
    //cropController.toolbarHeight = 56.f;
    //cropController.toolbar.buttonInsetPadding = 12;
    cropController.toolbar.backgroundView.backgroundColor = [UIColor fw_colorWithHex:0x121212];
    [cropController.toolbar.cancelTextButton fw_setImage:FWIconImage(@"ion-android-close", 22)];
    [cropController.toolbar.cancelTextButton setTitle:nil forState:UIControlStateNormal];
    [cropController.toolbar.doneTextButton fw_setImage:FWIconImage(@"ion-android-done", 22)];
    [cropController.toolbar.doneTextButton setTitle:nil forState:UIControlStateNormal];
    //[cropController.toolbar.resetButton fwSetImage:nil];
    //[cropController.toolbar.resetButton setTitle:@"撤销" forState:UIControlStateNormal];
    return cropController;
}

- (void)didTapImageView
{
    FWImageCropController *cropController = [self createCropController];
    [self presentViewController:cropController animated:YES completion:nil];
}

#pragma mark - Cropper Delegate -
- (void)cropController:(FWImageCropController *)cropController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropController];
}

- (void)cropController:(FWImageCropController *)cropController didCropToCircularImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    self.croppedFrame = cropRect;
    self.angle = angle;
    [self updateImageViewWithImage:image fromCropViewController:cropController];
}

- (void)updateImageViewWithImage:(UIImage *)image fromCropViewController:(FWImageCropController *)cropViewController
{
    self.imageView.image = image;
    [self layoutImageView];
    self.imageView.hidden = NO;
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image Layout -
- (void)layoutImageView
{
    if (self.imageView.image == nil)
        return;
    
    CGFloat padding = 20.0f;
    
    CGRect viewFrame = self.view.bounds;
    viewFrame.size.width -= (padding * 2.0f);
    viewFrame.size.height -= ((padding * 2.0f));
    
    CGRect imageFrame = CGRectZero;
    imageFrame.size = self.imageView.image.size;
    
    if (self.imageView.image.size.width > viewFrame.size.width ||
        self.imageView.image.size.height > viewFrame.size.height)
    {
        CGFloat scale = MIN(viewFrame.size.width / imageFrame.size.width, viewFrame.size.height / imageFrame.size.height);
        imageFrame.size.width *= scale;
        imageFrame.size.height *= scale;
        imageFrame.origin.x = (CGRectGetWidth(self.view.bounds) - imageFrame.size.width) * 0.5f;
        imageFrame.origin.y = (CGRectGetHeight(self.view.bounds) - imageFrame.size.height) * 0.5f;
        self.imageView.frame = imageFrame;
    }
    else {
        self.imageView.frame = imageFrame;
        self.imageView.center = (CGPoint){CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)};
    }
}

#pragma mark - Bar Button Items -
- (void)showCropViewController
{
    FWWeakifySelf();
    [self fw_showSheetWithTitle:nil message:nil cancel:nil actions:@[@"Crop Image", @"Make Profile"] actionBlock:^(NSInteger index) {
        FWStrongifySelf();
        self.croppingStyle = index == 0 ? FWImageCropCroppingStyleDefault : FWImageCropCroppingStyleCircular;
        [self fw_showImagePickerWithAllowsEditing:NO completion:^(UIImage * _Nullable image, BOOL cancel) {
            FWStrongifySelf();
            if (image) {
                self.image = image;
                [self didTapImageView];
            }
        }];
    }];
}

- (void)sharePhoto:(id)sender
{
    if (self.imageView.image == nil)
        return;
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[self.imageView.image] applicationActivities:nil];
    activityController.modalPresentationStyle = UIModalPresentationPopover;
    activityController.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - View Creation/Lifecycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"FWImageCropController", @"");
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self fw_addRightBarItem:[[FWToolbarButton alloc] initWithImage:FWIcon.addImage] target:self action:@selector(showCropViewController)];
    [self fw_addRightBarItem:[[FWToolbarButton alloc] initWithImage:FWIcon.actionImage] target:self action:@selector(sharePhoto:)];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    self.imageView.accessibilityIgnoresInvertColors = YES;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView)];
    [self.imageView addGestureRecognizer:tapRecognizer];
    
    self.image = [TestBundle imageNamed:@"public_sunset"];
    self.imageView.image = self.image;
    [self layoutImageView];
    self.imageView.hidden = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutImageView];
}

@end
