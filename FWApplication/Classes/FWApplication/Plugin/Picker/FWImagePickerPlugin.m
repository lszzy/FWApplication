/**
 @header     FWImagePickerPlugin.m
 @indexgroup FWApplication
      FWImagePickerPlugin
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "FWImagePickerPlugin.h"
#import "FWImagePickerPluginImpl.h"
#import <objc/runtime.h>

#pragma mark - FWImagePickerPluginController

@implementation FWViewControllerWrapper (FWImagePickerPluginController)

- (id<FWImagePickerPlugin>)imagePickerPlugin
{
    id<FWImagePickerPlugin> pickerPlugin = objc_getAssociatedObject(self.base, @selector(imagePickerPlugin));
    if (!pickerPlugin) pickerPlugin = [FWPluginManager loadPlugin:@protocol(FWImagePickerPlugin)];
    if (!pickerPlugin) pickerPlugin = FWImagePickerPluginImpl.sharedInstance;
    return pickerPlugin;
}

- (void)setImagePickerPlugin:(id<FWImagePickerPlugin>)imagePickerPlugin
{
    objc_setAssociatedObject(self.base, @selector(imagePickerPlugin), imagePickerPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showImageCameraWithAllowsEditing:(BOOL)allowsEditing
                                completion:(void (^)(UIImage * _Nullable, BOOL))completion
{
    [self showImageCameraWithFilterType:FWImagePickerFilterTypeImage allowsEditing:allowsEditing customBlock:nil completion:^(id  _Nullable object, id  _Nullable result, BOOL cancel) {
        if (completion) completion(object, cancel);
    }];
}

- (void)showImageCameraWithFilterType:(FWImagePickerFilterType)filterType
                          allowsEditing:(BOOL)allowsEditing
                            customBlock:(void (^)(id _Nonnull))customBlock
                             completion:(void (^)(id _Nullable, id _Nullable, BOOL))completion
{
    // 优先调用插件，不存在时使用默认
    id<FWImagePickerPlugin> imagePickerPlugin = self.imagePickerPlugin;
    if (!imagePickerPlugin || ![imagePickerPlugin respondsToSelector:@selector(viewController:showImageCamera:allowsEditing:customBlock:completion:)]) {
        imagePickerPlugin = FWImagePickerPluginImpl.sharedInstance;
    }
    [imagePickerPlugin viewController:self.base showImageCamera:filterType allowsEditing:allowsEditing customBlock:customBlock completion:completion];
}

- (void)showImagePickerWithAllowsEditing:(BOOL)allowsEditing
                                completion:(void (^)(UIImage * _Nullable, BOOL))completion
{
    [self showImagePickerWithSelectionLimit:1 allowsEditing:allowsEditing completion:^(NSArray<UIImage *> * _Nonnull images, NSArray * _Nonnull results, BOOL cancel) {
        if (completion) completion(images.firstObject, cancel);
    }];
}

- (void)showImagePickerWithSelectionLimit:(NSInteger)selectionLimit
                              allowsEditing:(BOOL)allowsEditing
                                 completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray * _Nonnull, BOOL))completion
{
    [self showImagePickerWithFilterType:FWImagePickerFilterTypeImage selectionLimit:selectionLimit allowsEditing:allowsEditing customBlock:nil completion:^(NSArray * _Nonnull objects, NSArray * _Nonnull results, BOOL cancel) {
        if (completion) completion(objects, results, cancel);
    }];
}

- (void)showImagePickerWithFilterType:(FWImagePickerFilterType)filterType
                         selectionLimit:(NSInteger)selectionLimit
                          allowsEditing:(BOOL)allowsEditing
                            customBlock:(void (^)(id _Nonnull))customBlock
                             completion:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull, BOOL))completion
{
    // 优先调用插件，不存在时使用默认
    id<FWImagePickerPlugin> imagePickerPlugin = self.imagePickerPlugin;
    if (!imagePickerPlugin || ![imagePickerPlugin respondsToSelector:@selector(viewController:showImagePicker:selectionLimit:allowsEditing:customBlock:completion:)]) {
        imagePickerPlugin = FWImagePickerPluginImpl.sharedInstance;
    }
    [imagePickerPlugin viewController:self.base showImagePicker:filterType selectionLimit:selectionLimit allowsEditing:allowsEditing customBlock:customBlock completion:completion];
}

@end

@implementation FWViewWrapper (FWImagePickerPluginController)

- (void)showImageCameraWithAllowsEditing:(BOOL)allowsEditing
                                completion:(void (^)(UIImage * _Nullable, BOOL))completion
{
    UIViewController *ctrl = self.base.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showImageCameraWithAllowsEditing:allowsEditing
                                  completion:completion];
}

- (void)showImageCameraWithFilterType:(FWImagePickerFilterType)filterType
                          allowsEditing:(BOOL)allowsEditing
                            customBlock:(void (^)(id _Nonnull))customBlock
                             completion:(void (^)(id _Nullable, id _Nullable, BOOL))completion
{
    UIViewController *ctrl = self.base.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showImageCameraWithFilterType:filterType
                            allowsEditing:allowsEditing
                              customBlock:customBlock
                               completion:completion];
}

- (void)showImagePickerWithAllowsEditing:(BOOL)allowsEditing
                                completion:(void (^)(UIImage * _Nullable, BOOL))completion
{
    UIViewController *ctrl = self.base.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showImagePickerWithAllowsEditing:allowsEditing
                                  completion:completion];
}

- (void)showImagePickerWithSelectionLimit:(NSInteger)selectionLimit
                              allowsEditing:(BOOL)allowsEditing
                                 completion:(void (^)(NSArray<UIImage *> * _Nonnull, NSArray * _Nonnull, BOOL))completion
{
    UIViewController *ctrl = self.base.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showImagePickerWithSelectionLimit:selectionLimit
                                allowsEditing:allowsEditing
                                   completion:completion];
}

- (void)showImagePickerWithFilterType:(FWImagePickerFilterType)filterType
                         selectionLimit:(NSInteger)selectionLimit
                          allowsEditing:(BOOL)allowsEditing
                            customBlock:(void (^)(id _Nonnull))customBlock
                             completion:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull, BOOL))completion
{
    UIViewController *ctrl = self.base.fw.viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showImagePickerWithFilterType:filterType
                           selectionLimit:selectionLimit
                            allowsEditing:allowsEditing
                              customBlock:customBlock
                               completion:completion];
}

@end
