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

NS_ASSUME_NONNULL_BEGIN

FWWrapperCompatible(NSMutableAttributedString, FWMutableAttributedStringWrapper, FWAttributedStringWrapper, FWMutableAttributedStringClassWrapper, FWAttributedStringClassWrapper);
FWWrapperCompatible(UIProgressView, FWProgressViewWrapper, FWViewWrapper, FWProgressViewClassWrapper, FWViewClassWrapper);
FWWrapperCompatible(UITabBarItem, FWTabBarItemWrapper, FWBarItemWrapper, FWTabBarItemClassWrapper, FWBarItemClassWrapper);
FWWrapperCompatible(UIActivityIndicatorView, FWActivityIndicatorViewWrapper, FWViewWrapper, FWActivityIndicatorViewClassWrapper, FWViewClassWrapper);
FWWrapperCompatible(UICollectionViewFlowLayout, FWCollectionViewFlowLayoutWrapper, FWObjectWrapper, FWCollectionViewFlowLayoutClassWrapper, FWClassWrapper);
FWWrapperCompatible(UIAlertAction, FWAlertActionWrapper, FWObjectWrapper, FWAlertActionClassWrapper, FWClassWrapper);
FWWrapperCompatible(UIAlertController, FWAlertControllerWrapper, FWViewControllerWrapper, FWAlertControllerClassWrapper, FWViewControllerClassWrapper);
FWWrapperCompatible(UIImagePickerController, FWImagePickerControllerWrapper, FWViewControllerWrapper, FWImagePickerControllerClassWrapper, FWViewControllerClassWrapper);
FWWrapperCompatible(WKWebView, FWWebViewWrapper, FWViewWrapper, FWWebViewClassWrapper, FWViewClassWrapper);
FWWrapperCompatible(PHPhotoLibrary, FWPhotoLibraryWrapper, FWObjectWrapper, FWPhotoLibraryClassWrapper, FWClassWrapper);
FWWrapperCompatibleAvailable(14.0, PHPickerViewController, FWPickerViewControllerWrapper, FWViewControllerWrapper, FWPickerViewControllerClassWrapper, FWViewControllerClassWrapper);

NS_ASSUME_NONNULL_END
