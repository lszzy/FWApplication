/**
 @header     FWAppWrapper.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/4/21
 */

@import FWFramework;
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <WebKit/WebKit.h>
@import UserNotifications;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Macro

/// 快速声明自定义应用包装器宏
///
/// 自定义fw为任意名称(如app)，结合FWFramework使用示例：
/// h文件声明：
/// FWWrapperCustomizable(app)
/// FWAppWrapperCustomizable(app)
/// m文件实现：
/// FWDefWrapperCustomizable(app)
/// FWDefAppWrapperCustomizable(app)
/// 使用示例：
/// NSString.app.UUIDString
#define FWAppWrapperCustomizable(ext) \
    FWWrapperApplication_(FWWrapperExtendable, ext);

/// 快速实现自定义应用包装器宏
#define FWDefAppWrapperCustomizable(ext) \
    FWDefWrapperApplication_(FWDefWrapperExtendable, ext);

/// 内部快速声明所有应用包装器宏
#define FWWrapperApplication_(macro, fw) \
    macro(NSMutableAttributedString, fw, FWMutableAttributedStringWrapper, FWAttributedStringWrapper, FWMutableAttributedStringClassWrapper, FWAttributedStringClassWrapper); \
    macro(UIProgressView, fw, FWProgressViewWrapper, FWViewWrapper, FWProgressViewClassWrapper, FWViewClassWrapper); \
    macro(UIPanGestureRecognizer, fw, FWPanGestureRecognizerWrapper, FWGestureRecognizerWrapper, FWPanGestureRecognizerClassWrapper, FWGestureRecognizerClassWrapper); \
    macro(UITabBarItem, fw, FWTabBarItemWrapper, FWBarItemWrapper, FWTabBarItemClassWrapper, FWBarItemClassWrapper); \
    macro(UIActivityIndicatorView, fw, FWActivityIndicatorViewWrapper, FWViewWrapper, FWActivityIndicatorViewClassWrapper, FWViewClassWrapper); \
    macro(UICollectionViewFlowLayout, fw, FWCollectionViewFlowLayoutWrapper, FWObjectWrapper, FWCollectionViewFlowLayoutClassWrapper, FWClassWrapper); \
    macro(UIAlertAction, fw, FWAlertActionWrapper, FWObjectWrapper, FWAlertActionClassWrapper, FWClassWrapper); \
    macro(UIAlertController, fw, FWAlertControllerWrapper, FWViewControllerWrapper, FWAlertControllerClassWrapper, FWViewControllerClassWrapper); \
    macro(UIImagePickerController, fw, FWImagePickerControllerWrapper, FWNavigationControllerWrapper, FWImagePickerControllerClassWrapper, FWNavigationControllerClassWrapper); \
    macro(WKWebView, fw, FWWebViewWrapper, FWViewWrapper, FWWebViewClassWrapper, FWViewClassWrapper); \
    macro(UNUserNotificationCenter, fw, FWUserNotificationCenterWrapper, FWObjectWrapper, FWUserNotificationCenterClassWrapper, FWClassWrapper); \
    macro(PHPhotoLibrary, fw, FWPhotoLibraryWrapper, FWObjectWrapper, FWPhotoLibraryClassWrapper, FWClassWrapper); \
    fw_macro_concat(macro, Available)(14.0, PHPickerViewController, fw, FWPickerViewControllerWrapper, FWViewControllerWrapper, FWPickerViewControllerClassWrapper, FWViewControllerClassWrapper);

/// 内部快速实现所有应用包装器宏
#define FWDefWrapperApplication_(macro, fw) \
    macro(NSMutableAttributedString, fw, FWMutableAttributedStringWrapper, FWMutableAttributedStringClassWrapper); \
    macro(UIProgressView, fw, FWProgressViewWrapper, FWProgressViewClassWrapper); \
    macro(UIPanGestureRecognizer, fw, FWPanGestureRecognizerWrapper, FWPanGestureRecognizerClassWrapper); \
    macro(UITabBarItem, fw, FWTabBarItemWrapper, FWTabBarItemClassWrapper); \
    macro(UIActivityIndicatorView, fw, FWActivityIndicatorViewWrapper, FWActivityIndicatorViewClassWrapper); \
    macro(UICollectionViewFlowLayout, fw, FWCollectionViewFlowLayoutWrapper, FWCollectionViewFlowLayoutClassWrapper); \
    macro(UIAlertAction, fw, FWAlertActionWrapper, FWAlertActionClassWrapper); \
    macro(UIAlertController, fw, FWAlertControllerWrapper, FWAlertControllerClassWrapper); \
    macro(UIImagePickerController, fw, FWImagePickerControllerWrapper, FWImagePickerControllerClassWrapper); \
    macro(WKWebView, fw, FWWebViewWrapper, FWWebViewClassWrapper); \
    macro(UNUserNotificationCenter, fw, FWUserNotificationCenterWrapper, FWUserNotificationCenterClassWrapper); \
    macro(PHPhotoLibrary, fw, FWPhotoLibraryWrapper, FWPhotoLibraryClassWrapper); \
    macro(PHPickerViewController, fw, FWPickerViewControllerWrapper, FWPickerViewControllerClassWrapper);

#pragma mark - FWWrapperExtended

FWWrapperApplication_(FWWrapperExtended, fw);

NS_ASSUME_NONNULL_END
