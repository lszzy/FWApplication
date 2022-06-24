/**
 @header     FWImagePreviewPlugin.m
 @indexgroup FWApplication
      FWImagePreviewPlugin
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "FWImagePreviewPlugin.h"
#import "FWImagePreviewPluginImpl.h"
#import <objc/runtime.h>

#pragma mark - FWImagePreviewPluginController

@implementation FWViewControllerWrapper (FWImagePreviewPluginController)

- (id<FWImagePreviewPlugin>)imagePreviewPlugin
{
    id<FWImagePreviewPlugin> previewPlugin = objc_getAssociatedObject(self.base, @selector(imagePreviewPlugin));
    if (!previewPlugin) previewPlugin = [FWPluginManager loadPlugin:@protocol(FWImagePreviewPlugin)];
    if (!previewPlugin) previewPlugin = FWImagePreviewPluginImpl.sharedInstance;
    return previewPlugin;
}

- (void)setImagePreviewPlugin:(id<FWImagePreviewPlugin>)imagePreviewPlugin
{
    objc_setAssociatedObject(self.base, @selector(imagePreviewPlugin), imagePreviewPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
{
    [self showImagePreviewWithImageURLs:imageURLs
                               imageInfos:imageInfos
                             currentIndex:currentIndex
                               sourceView:sourceView
                         placeholderImage:nil
                              renderBlock:nil
                              customBlock:nil];
}

- (void)showImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
                       placeholderImage:(UIImage * _Nullable (^)(NSInteger))placeholderImage
                            renderBlock:(void (^)(__kindof UIView * _Nonnull, NSInteger))renderBlock
                            customBlock:(void (^)(id _Nonnull))customBlock
{
    // 优先调用插件，不存在时使用默认
    id<FWImagePreviewPlugin> imagePreviewPlugin = self.imagePreviewPlugin;
    if (!imagePreviewPlugin || ![imagePreviewPlugin respondsToSelector:@selector(viewController:showImagePreview:imageInfos:currentIndex:sourceView:placeholderImage:renderBlock:customBlock:)]) {
        imagePreviewPlugin = FWImagePreviewPluginImpl.sharedInstance;
    }
    [imagePreviewPlugin viewController:self.base showImagePreview:imageURLs imageInfos:imageInfos currentIndex:currentIndex sourceView:sourceView placeholderImage:placeholderImage renderBlock:renderBlock customBlock:customBlock];
}

@end

@implementation FWViewWrapper (FWImagePreviewPluginController)

- (void)showImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showImagePreviewWithImageURLs:imageURLs
                               imageInfos:imageInfos
                             currentIndex:currentIndex
                               sourceView:sourceView];
}

- (void)showImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
                       placeholderImage:(UIImage * _Nullable (^)(NSInteger))placeholderImage
                            renderBlock:(void (^)(__kindof UIView * _Nonnull, NSInteger))renderBlock
                            customBlock:(void (^)(id _Nonnull))customBlock
{
    UIViewController *ctrl = self.base.fw_viewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fw_topPresentedController;
    }
    [ctrl.fw showImagePreviewWithImageURLs:imageURLs
                               imageInfos:imageInfos
                             currentIndex:currentIndex
                               sourceView:sourceView
                         placeholderImage:placeholderImage
                              renderBlock:renderBlock
                              customBlock:customBlock];
}

@end
