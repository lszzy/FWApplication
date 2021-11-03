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

@interface FWImagePickerControllerImpl () <FWImagePickerControllerDelegate, FWImageAlbumControllerDelegate>

@end

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
        FWImageAlbumController *albumController;
        if (self.albumControllerBlock) {
            albumController = self.albumControllerBlock();
        } else {
            albumController = [[FWImageAlbumController alloc] init];
            albumController.pickDefaultAlbumGroup = YES;
        }
        albumController.albumControllerDelegate = self;
        albumController.contentType = [self contentTypeForFilterType:filterType];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:navigationController animated:YES completion:NULL];
    } else {
        FWImagePickerController *pickerController;
        if (self.pickerControllerBlock) {
            pickerController = self.pickerControllerBlock();
        } else {
            pickerController = [[FWImagePickerController alloc] init];
        }
        pickerController.imagePickerControllerDelegate = self;
        pickerController.allowsMultipleSelection = selectionLimit != 1;
        pickerController.maximumSelectImageCount = selectionLimit > 0 ? selectionLimit : INT_MAX;
        if (self.customBlock) self.customBlock(pickerController);
        if (customBlock) customBlock(pickerController);
        [pickerController refreshWithContentType:[self contentTypeForFilterType:filterType]];

        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pickerController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [viewController presentViewController:navigationController animated:YES completion:nil];
    }
}

- (FWAlbumContentType)contentTypeForFilterType:(FWImagePickerFilterType)filterType
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
