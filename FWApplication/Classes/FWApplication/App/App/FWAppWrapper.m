/**
 @header     FWAppWrapper.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/4/21
 */

#import "FWAppWrapper.h"

FWDefWrapper(NSMutableAttributedString, FWMutableAttributedStringWrapper, FWMutableAttributedStringClassWrapper);
FWDefWrapper(UIProgressView, FWProgressViewWrapper, FWProgressViewClassWrapper);
FWDefWrapper(UITabBarItem, FWTabBarItemWrapper, FWTabBarItemClassWrapper);
FWDefWrapper(UIActivityIndicatorView, FWActivityIndicatorViewWrapper, FWActivityIndicatorViewClassWrapper);
FWDefWrapper(UICollectionViewFlowLayout, FWCollectionViewFlowLayoutWrapper, FWCollectionViewFlowLayoutClassWrapper);
FWDefWrapper(UIAlertAction, FWAlertActionWrapper, FWAlertActionClassWrapper);
FWDefWrapper(UIAlertController, FWAlertControllerWrapper, FWAlertControllerClassWrapper);
FWDefWrapper(UIImagePickerController, FWImagePickerControllerWrapper, FWImagePickerControllerClassWrapper);
FWDefWrapper(WKWebView, FWWebViewWrapper, FWWebViewClassWrapper);
FWDefWrapper(PHPhotoLibrary, FWPhotoLibraryWrapper, FWPhotoLibraryClassWrapper);
FWDefWrapper(PHPickerViewController, FWPickerViewControllerWrapper, FWPickerViewControllerClassWrapper);
