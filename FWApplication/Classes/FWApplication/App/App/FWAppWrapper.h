/**
 @header     FWAppWrapper.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/4/21
 */

@import FWFramework;
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

FWWrapperCompatible(UIAlertAction, FWAlertActionWrapper, FWObjectWrapper, FWAlertActionClassWrapper, FWClassWrapper);
FWWrapperCompatible(UIAlertController, FWAlertControllerWrapper, FWViewControllerWrapper, FWAlertControllerClassWrapper, FWViewControllerClassWrapper);
FWWrapperCompatible(PHPhotoLibrary, FWPhotoLibraryWrapper, FWObjectWrapper, FWPhotoLibraryClassWrapper, FWClassWrapper);

NS_ASSUME_NONNULL_END
