/**
 @header     FWAppWrapper.m
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/4/21
 */

#import "FWAppWrapper.h"

FWDefWrapper(UIAlertAction, FWAlertActionWrapper, FWAlertActionClassWrapper);
FWDefWrapper(UIAlertController, FWAlertControllerWrapper, FWAlertControllerClassWrapper);
FWDefWrapper(PHPhotoLibrary, FWPhotoLibraryWrapper, FWPhotoLibraryClassWrapper);
FWDefWrapper(UIImagePickerController, FWImagePickerControllerWrapper, FWImagePickerControllerClassWrapper);
FWDefWrapper(PHPickerViewController, FWPickerViewControllerWrapper, FWPickerViewControllerClassWrapper);
