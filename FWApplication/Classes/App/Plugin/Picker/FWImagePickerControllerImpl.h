/*!
 @header     FWImagePickerControllerImpl.h
 @indexgroup FWApplication
 @brief      FWImagePickerControllerImpl
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/7
 */

#import "FWImagePickerPlugin.h"
#import "FWImagePickerController.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWImagePickerControllerImpl

/// 自定义图片选取插件
@interface FWImagePickerControllerImpl : NSObject <FWImagePickerPlugin>

/// 单例模式
@property (class, nonatomic, readonly) FWImagePickerControllerImpl *sharedInstance;

/// 自定义图片选取控制器句柄，默认nil时使用自带控制器
@property (nonatomic, copy, nullable) __kindof FWImagePickerController * (^pickerControllerBlock)(void);

/// 图片选取全局自定义句柄，show方法自动调用
@property (nonatomic, copy, nullable) void (^customBlock)(FWImagePickerController *pickerController);

@end

NS_ASSUME_NONNULL_END
