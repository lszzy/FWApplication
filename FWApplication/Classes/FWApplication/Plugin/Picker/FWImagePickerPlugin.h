/**
 @header     FWImagePickerPlugin.h
 @indexgroup FWApplication
      FWImagePickerPlugin
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWImagePickerPlugin

/// 图片选择插件过滤类型
typedef NS_OPTIONS(NSUInteger, FWImagePickerFilterType) {
    FWImagePickerFilterTypeImage      = 1 << 0,
    FWImagePickerFilterTypeLivePhoto  = 1 << 1,
    FWImagePickerFilterTypeVideo      = 1 << 2,
} NS_SWIFT_NAME(ImagePickerFilterType);

/// 图片选取插件协议，应用可自定义图片选取插件实现
NS_SWIFT_NAME(ImagePickerPlugin)
@protocol FWImagePickerPlugin <NSObject>
@optional

/// 从Camera选取单张图片插件方法
/// @param viewController 当前视图控制器
/// @param filterType 过滤类型，默认0同系统
/// @param allowsEditing 是否允许编辑
/// @param customBlock 自定义配置句柄，默认nil
/// @param completion 完成回调，主线程。参数1为对象(UIImage|PHLivePhoto|NSURL)，2为结果信息，3为是否取消
- (void)viewController:(UIViewController *)viewController
         showImageCamera:(FWImagePickerFilterType)filterType
           allowsEditing:(BOOL)allowsEditing
             customBlock:(nullable void (^)(id imagePicker))customBlock
              completion:(void (^)(id _Nullable object, id _Nullable result, BOOL cancel))completion;

/// 从图片库选取多张图片插件方法
/// @param viewController 当前视图控制器
/// @param filterType 过滤类型，默认0同系统
/// @param selectionLimit 最大选择数量
/// @param allowsEditing 是否允许编辑
/// @param customBlock 自定义配置句柄，默认nil
/// @param completion 完成回调，主线程。参数1为对象数组(UIImage|PHLivePhoto|NSURL)，2位结果数组，3为是否取消
- (void)viewController:(UIViewController *)viewController
         showImagePicker:(FWImagePickerFilterType)filterType
          selectionLimit:(NSInteger)selectionLimit
           allowsEditing:(BOOL)allowsEditing
             customBlock:(nullable void (^)(id imagePicker))customBlock
              completion:(void (^)(NSArray *objects, NSArray *results, BOOL cancel))completion;

@end

#pragma mark - FWImagePickerPluginController

/// 图片选取插件控制器协议，使用图片选取插件
NS_REFINED_FOR_SWIFT
@protocol FWImagePickerPluginController <NSObject>
@required

/// 从Camera选取单张图片(简单版)
/// @param allowsEditing 是否允许编辑
/// @param completion 完成回调，主线程。参数1为图片，2为是否取消
- (void)showImageCameraWithAllowsEditing:(BOOL)allowsEditing
                                completion:(void (^)(UIImage * _Nullable image, BOOL cancel))completion;

/// 从Camera选取单张图片(详细版)
/// @param filterType 过滤类型，默认0同系统
/// @param allowsEditing 是否允许编辑
/// @param customBlock 自定义配置句柄，默认nil
/// @param completion 完成回调，主线程。参数1为对象(UIImage|PHLivePhoto|NSURL)，2为结果信息，3为是否取消
- (void)showImageCameraWithFilterType:(FWImagePickerFilterType)filterType
                          allowsEditing:(BOOL)allowsEditing
                            customBlock:(nullable void (^)(id imagePicker))customBlock
                             completion:(void (^)(id _Nullable object, id _Nullable result, BOOL cancel))completion;

/// 从图片库选取单张图片(简单版)
/// @param allowsEditing 是否允许编辑
/// @param completion 完成回调，主线程。参数1为图片，2为是否取消
- (void)showImagePickerWithAllowsEditing:(BOOL)allowsEditing
                                completion:(void (^)(UIImage * _Nullable image, BOOL cancel))completion;

/// 从图片库选取多张图片(简单版)
/// @param selectionLimit 最大选择数量
/// @param allowsEditing 是否允许编辑
/// @param completion 完成回调，主线程。参数1为图片数组，2为结果数组，3为是否取消
- (void)showImagePickerWithSelectionLimit:(NSInteger)selectionLimit
                              allowsEditing:(BOOL)allowsEditing
                                 completion:(void (^)(NSArray<UIImage *> *images, NSArray *results, BOOL cancel))completion;

/// 从图片库选取多张图片(详细版)
/// @param filterType 过滤类型，默认0同系统
/// @param selectionLimit 最大选择数量
/// @param allowsEditing 是否允许编辑
/// @param customBlock 自定义配置句柄，默认nil
/// @param completion 完成回调，主线程。参数1为对象数组(UIImage|PHLivePhoto|NSURL)，2位结果数组，3为是否取消
- (void)showImagePickerWithFilterType:(FWImagePickerFilterType)filterType
                         selectionLimit:(NSInteger)selectionLimit
                          allowsEditing:(BOOL)allowsEditing
                            customBlock:(nullable void (^)(id imagePicker))customBlock
                             completion:(void (^)(NSArray *objects, NSArray *results, BOOL cancel))completion;

@end

/// UIViewController使用图片选取插件，全局可使用UIWindow.fw.topPresentedController
@interface FWViewControllerWrapper (FWImagePickerPluginController) <FWImagePickerPluginController>

/// 自定义图片选取插件，未设置时自动从插件池加载
@property (nonatomic, strong, nullable) id<FWImagePickerPlugin> imagePickerPlugin;

@end

/// UIView使用图片选取插件，内部使用UIView.fw.viewController
@interface FWViewWrapper (FWImagePickerPluginController) <FWImagePickerPluginController>

@end

NS_ASSUME_NONNULL_END
