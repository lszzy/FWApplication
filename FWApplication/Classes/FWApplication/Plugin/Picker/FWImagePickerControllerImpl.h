/**
 @header     FWImagePickerControllerImpl.h
 @indexgroup FWApplication
      FWImagePickerControllerImpl
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/7
 */

#import "FWImagePickerPlugin.h"
#import "FWImagePickerController.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWImagePickerControllerImpl

/// 自定义图片选取插件
NS_SWIFT_NAME(ImagePickerControllerImpl)
@interface FWImagePickerControllerImpl : NSObject <FWImagePickerPlugin>

/// 单例模式
@property (class, nonatomic, readonly) FWImagePickerControllerImpl *sharedInstance;

/// 是否显示相册列表控制器，默认为NO，点击titleView切换相册
@property (nonatomic, assign) BOOL showsAlbumController;

/// 自定义相册列表控制器句柄，默认nil时使用自带控制器
@property (nonatomic, copy, nullable) FWImageAlbumController * (^albumControllerBlock)(void);

/// 自定义图片预览控制器句柄，默认nil时使用自带控制器
@property (nonatomic, copy, nullable) FWImagePickerPreviewController * (^previewControllerBlock)(void);

/// 自定义图片选取控制器句柄，默认nil时使用自带控制器
@property (nonatomic, copy, nullable) FWImagePickerController * (^pickerControllerBlock)(void);

/// 自定义图片裁剪控制器句柄，预览控制器未自定义时生效，默认nil时使用自带控制器
@property (nonatomic, copy, nullable) FWImageCropController * (^cropControllerBlock)(UIImage *image);

/// 图片选取全局自定义句柄，show方法自动调用
@property (nonatomic, copy, nullable) void (^customBlock)(FWImagePickerController *pickerController);

@end

NS_ASSUME_NONNULL_END
