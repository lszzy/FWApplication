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
    
}

@end
