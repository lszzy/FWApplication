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
@import FWFramework;

#pragma mark - FWImagePreviewPluginController

@implementation UIViewController (FWImagePreviewPluginController)

- (void)fwShowImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
{
    [self fwShowImagePreviewWithImageURLs:imageURLs
                               imageInfos:imageInfos
                             currentIndex:currentIndex
                               sourceView:sourceView
                         placeholderImage:nil
                              renderBlock:nil
                              customBlock:nil];
}

- (void)fwShowImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
                       placeholderImage:(UIImage * _Nullable (^)(NSInteger))placeholderImage
                            renderBlock:(void (^)(__kindof UIView * _Nonnull, NSInteger))renderBlock
                            customBlock:(void (^)(id _Nonnull))customBlock
{
    // 优先调用插件，不存在时使用默认
    id<FWImagePreviewPlugin> imagePreviewPlugin = [FWPluginManager loadPlugin:@protocol(FWImagePreviewPlugin)];
    if (!imagePreviewPlugin || ![imagePreviewPlugin respondsToSelector:@selector(fwViewController:showImagePreview:imageInfos:currentIndex:sourceView:placeholderImage:renderBlock:customBlock:)]) {
        imagePreviewPlugin = FWImagePreviewPluginImpl.sharedInstance;
    }
    [imagePreviewPlugin fwViewController:self showImagePreview:imageURLs imageInfos:imageInfos currentIndex:currentIndex sourceView:sourceView placeholderImage:placeholderImage renderBlock:renderBlock customBlock:customBlock];
}

@end

@implementation UIView (FWImagePreviewPluginController)

- (void)fwShowImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
{
    UIViewController *ctrl = self.fwViewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fwMainWindow.fwTopPresentedController;
    }
    [ctrl fwShowImagePreviewWithImageURLs:imageURLs
                               imageInfos:imageInfos
                             currentIndex:currentIndex
                               sourceView:sourceView];
}

- (void)fwShowImagePreviewWithImageURLs:(NSArray *)imageURLs
                             imageInfos:(NSArray *)imageInfos
                           currentIndex:(NSInteger)currentIndex
                             sourceView:(id  _Nullable (^)(NSInteger))sourceView
                       placeholderImage:(UIImage * _Nullable (^)(NSInteger))placeholderImage
                            renderBlock:(void (^)(__kindof UIView * _Nonnull, NSInteger))renderBlock
                            customBlock:(void (^)(id _Nonnull))customBlock
{
    UIViewController *ctrl = self.fwViewController;
    if (!ctrl || ctrl.presentedViewController) {
        ctrl = UIWindow.fwMainWindow.fwTopPresentedController;
    }
    [ctrl fwShowImagePreviewWithImageURLs:imageURLs
                               imageInfos:imageInfos
                             currentIndex:currentIndex
                               sourceView:sourceView
                         placeholderImage:placeholderImage
                              renderBlock:renderBlock
                              customBlock:customBlock];
}

@end
