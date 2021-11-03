/*!
 @header     FWImagePickerControllerImpl.h
 @indexgroup FWApplication
 @brief      FWImagePickerControllerImpl
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/9/7
 */

#import "FWImagePickerControllerImpl.h"

#pragma mark - FWImagePickerControllerImpl

@implementation FWImagePickerControllerImpl

+ (FWImagePickerControllerImpl *)sharedInstance
{
    static FWImagePickerControllerImpl *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWImagePickerControllerImpl alloc] init];
    });
    return instance;
}

- (void)fwViewController:(UIViewController *)viewController
         showImagePicker:(FWImagePickerFilterType)filterType
          selectionLimit:(NSInteger)selectionLimit
           allowsEditing:(BOOL)allowsEditing
             customBlock:(void (^)(id _Nonnull))customBlock
              completion:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull, BOOL))completion
{
    if (self.showsAlbumController) {
        FWImageAlbumController *albumController = [self albumControllerWithFilterType:filterType];
        __weak __typeof__(self) self_weak_ = self;
        albumController.pickerControllerBlock = ^FWImagePickerController * _Nonnull{
            __typeof__(self) self = self_weak_;
            return [self pickerControllerWithViewController:viewController filterType:filterType selectionLimit:selectionLimit allowsEditing:allowsEditing customBlock:customBlock completion:completion];
        };
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:navigationController animated:YES completion:NULL];
    } else {
        FWImagePickerController *pickerController = [self pickerControllerWithViewController:viewController filterType:filterType selectionLimit:selectionLimit allowsEditing:allowsEditing customBlock:customBlock completion:completion];
        __weak __typeof__(self) self_weak_ = self;
        pickerController.albumControllerBlock = ^FWImageAlbumController * _Nonnull{
            __typeof__(self) self = self_weak_;
            return [self albumControllerWithFilterType:filterType];
        };
        [pickerController refreshWithContentType:[self contentTypeWithFilterType:filterType]];

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pickerController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (FWImagePickerController *)pickerControllerWithViewController:(UIViewController *)viewController
                                                     filterType:(FWImagePickerFilterType)filterType
                                                 selectionLimit:(NSInteger)selectionLimit
                                                  allowsEditing:(BOOL)allowsEditing
                                                    customBlock:(void (^)(id _Nonnull))customBlock
                                                     completion:(void (^)(NSArray * _Nonnull, NSArray * _Nonnull, BOOL))completion
{
    FWImagePickerController *pickerController;
    if (self.pickerControllerBlock) {
        pickerController = self.pickerControllerBlock();
    } else {
        pickerController = [[FWImagePickerController alloc] init];
    }
    pickerController.allowsMultipleSelection = selectionLimit != 1;
    pickerController.maximumSelectImageCount = selectionLimit > 0 ? selectionLimit : INT_MAX;
    if (self.customBlock) self.customBlock(pickerController);
    if (customBlock) customBlock(pickerController);
    
    __weak __typeof__(self) self_weak_ = self;
    pickerController.previewControllerBlock = ^FWImagePickerPreviewController * _Nonnull{
        __typeof__(self) self = self_weak_;
        return [self previewControllerWithAllowsEditing:allowsEditing];
    };
    pickerController.didFinishPicking = ^(NSArray<FWAsset *> * _Nonnull imagesAssetArray) {
        __typeof__(self) self = self_weak_;
        if (imagesAssetArray.count < 1) {
            if (completion) completion(@[], @[], YES);
            return;
        }
        
        if (self.showLoadingBlock) self.showLoadingBlock(viewController, NO);
        [FWImagePickerController requestImagesAssetArray:imagesAssetArray filterType:filterType completion:^(NSArray * _Nonnull objects, NSArray * _Nonnull results) {
            __typeof__(self) self = self_weak_;
            if (self.showLoadingBlock) self.showLoadingBlock(viewController, YES);
            if (completion) completion(objects, results, objects.count < 1);
        }];
    };
    pickerController.didCancelPicking = ^{
        if (completion) completion(@[], @[], YES);
    };
    return pickerController;
}

- (FWImageAlbumController *)albumControllerWithFilterType:(FWImagePickerFilterType)filterType
{
    FWImageAlbumController *albumController;
    if (self.albumControllerBlock) {
        albumController = self.albumControllerBlock();
    } else {
        albumController = [[FWImageAlbumController alloc] init];
        albumController.pickDefaultAlbumGroup = YES;
    }
    albumController.contentType = [self contentTypeWithFilterType:filterType];
    return albumController;
}

- (FWImagePickerPreviewController *)previewControllerWithAllowsEditing:(BOOL)allowsEditing
{
    FWImagePickerPreviewController *previewController;
    if (self.previewControllerBlock) {
        previewController = self.previewControllerBlock();
    } else {
        previewController = [[FWImagePickerPreviewController alloc] init];
    }
    previewController.showsEditButton = allowsEditing;
    previewController.cropControllerBlock = self.cropControllerBlock;
    return previewController;
}

- (FWAlbumContentType)contentTypeWithFilterType:(FWImagePickerFilterType)filterType
{
    FWAlbumContentType contentType = filterType < 1 ? FWAlbumContentTypeAll : FWAlbumContentTypeOnlyPhoto;
    if (filterType & FWImagePickerFilterTypeVideo) {
        if (filterType & FWImagePickerFilterTypeImage ||
            filterType & FWImagePickerFilterTypeLivePhoto) {
            contentType = FWAlbumContentTypeAll;
        } else {
            contentType = FWAlbumContentTypeOnlyVideo;
        }
    }
    return contentType;
}

@end
