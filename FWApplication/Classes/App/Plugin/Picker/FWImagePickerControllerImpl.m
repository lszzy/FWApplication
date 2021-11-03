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
            FWImagePickerController *pickerController = [self pickerControllerWithFilterType:filterType selectionLimit:selectionLimit customBlock:customBlock completion:^(NSArray<FWAsset *> *imagesAssetArray) {
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
            }];
            pickerController.previewControllerBlock = ^FWImagePickerPreviewController * _Nonnull{
                __typeof__(self) self = self_weak_;
                FWImagePickerPreviewController *previewController = [self previewControllerWithAllowsEditing:allowsEditing];
                previewController.cropControllerBlock = self.cropControllerBlock;
                return previewController;
            };
            return pickerController;
        };
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:navigationController animated:YES completion:NULL];
    } else {
        __weak __typeof__(self) self_weak_ = self;
        FWImagePickerController *pickerController = [self pickerControllerWithFilterType:filterType selectionLimit:selectionLimit customBlock:customBlock completion:^(NSArray<FWAsset *> *imagesAssetArray) {
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
        }];
        pickerController.albumControllerBlock = ^FWImageAlbumController * _Nonnull{
            __typeof__(self) self = self_weak_;
            FWImageAlbumController *albumController = [self albumControllerWithFilterType:filterType];
            return albumController;
        };
        pickerController.previewControllerBlock = ^FWImagePickerPreviewController * _Nonnull{
            __typeof__(self) self = self_weak_;
            FWImagePickerPreviewController *previewController = [self previewControllerWithAllowsEditing:allowsEditing];
            previewController.cropControllerBlock = self.cropControllerBlock;
            return previewController;
        };
        [pickerController refreshWithContentType:[self contentTypeWithFilterType:filterType]];

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pickerController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (FWImagePickerController *)pickerControllerWithFilterType:(FWImagePickerFilterType)filterType
                                             selectionLimit:(NSInteger)selectionLimit
                                                customBlock:(void (^)(id _Nonnull))customBlock
                                                 completion:(void (^)(NSArray<FWAsset *> * _Nonnull))completion
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
    
    pickerController.didFinishPicking = ^(NSArray<FWAsset *> * _Nonnull imagesAssetArray) {
        if (completion) completion(imagesAssetArray);
    };
    pickerController.didCancelPicking = ^{
        if (completion) completion(@[]);
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
