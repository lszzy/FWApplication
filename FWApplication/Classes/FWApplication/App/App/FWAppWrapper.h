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

NS_ASSUME_NONNULL_BEGIN

FWWrapperCompatible(UIAlertAction, FWAlertActionWrapper, FWObjectWrapper, FWAlertActionClassWrapper, FWClassWrapper);
FWWrapperCompatible(UIAlertController, FWAlertControllerWrapper, FWViewControllerWrapper, FWAlertControllerClassWrapper, FWViewControllerClassWrapper);
FWWrapperCompatible(UIActivityIndicatorView, FWActivityIndicatorViewWrapper, FWViewWrapper, FWActivityIndicatorViewClassWrapper, FWViewClassWrapper);
FWWrapperCompatible(PHPhotoLibrary, FWPhotoLibraryWrapper, FWObjectWrapper, FWPhotoLibraryClassWrapper, FWClassWrapper);
FWWrapperCompatible(UIImagePickerController, FWImagePickerControllerWrapper, FWViewControllerWrapper, FWImagePickerControllerClassWrapper, FWViewControllerClassWrapper);
FWWrapperCompatibleAvailable(14.0, PHPickerViewController, FWPickerViewControllerWrapper, FWViewControllerWrapper, FWPickerViewControllerClassWrapper, FWViewControllerClassWrapper);

NS_ASSUME_NONNULL_END
