//
//  TestImagePickerViewController.m
//  Example
//
//  Created by wuyong on 2018/11/29.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestImagePickerViewController.h"

#define MaxSelectedImageCount 9
#define SingleImagePickingTag 1045
#define MultipleImagePickingTag 1046
#define OnlyImagePickingTag 1047
#define OnlyVideoPickingTag 1048

@interface TestImagePickerViewController () <FWTableViewController, FWImageAlbumControllerDelegate, FWImagePickerControllerDelegate, FWImagePickerPreviewControllerDelegate>

@end

@implementation TestImagePickerViewController

- (void)renderData {
    [self.tableData addObjectsFromArray:@[
        @"选择单张图片",
        @"选择多张图片",
        @"多选仅图片",
        @"多选仅视频",
    ]];
}

- (void)authorizationPresentAlbumViewControllerWithIndex:(NSInteger)index {
    if ([FWAssetManager authorizationStatus] == FWAssetAuthorizationStatusNotDetermined) {
        [FWAssetManager requestAuthorization:^(FWAssetAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentAlbumViewControllerWithIndex:index];
            });
        }];
    } else {
        [self presentAlbumViewControllerWithIndex:index];
    }
}

- (void)presentAlbumViewControllerWithIndex:(NSInteger)index {
    // 创建一个 QMUIAlbumViewController 实例用于呈现相簿列表
    FWImageAlbumController *albumController = [[FWImageAlbumController alloc] init];
    albumController.fwNavigationBarStyle = FWNavigationBarStyleDefault;
    albumController.fwBackBarItem = FWIcon.backImage;
    albumController.albumControllerDelegate = self;
    albumController.title = [self.tableData fwObjectAtIndex:index];
    if (index == 0) {
        albumController.view.tag = SingleImagePickingTag;
        albumController.contentType = FWAlbumContentTypeAll;
    } else if (index == 1) {
        albumController.view.tag = MultipleImagePickingTag;
        albumController.albumTableViewCellHeight = 70;
        albumController.contentType = FWAlbumContentTypeAll;
    } else if (index == 2) {
        albumController.view.tag = OnlyImagePickingTag;
        albumController.contentType = FWAlbumContentTypeOnlyPhoto;
    } else {
        albumController.view.tag = OnlyVideoPickingTag;
        albumController.contentType = FWAlbumContentTypeOnlyVideo;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:albumController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - <QMUITableViewDataSource,QMUITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell fwCellWithTableView:tableView];
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self authorizationPresentAlbumViewControllerWithIndex:indexPath.row];
}

#pragma mark - <QMUIAlbumViewControllerDelegate>

- (FWImagePickerController *)imagePickerControllerForAlbumController:(FWImageAlbumController *)albumController {
    FWImagePickerController *imagePickerController = [[FWImagePickerController alloc] init];
    imagePickerController.imagePickerControllerDelegate = self;
    imagePickerController.maximumSelectImageCount = MaxSelectedImageCount;
    imagePickerController.view.tag = albumController.view.tag;
    if (albumController.view.tag == SingleImagePickingTag) {
        imagePickerController.allowsMultipleSelection = NO;
    }
    return imagePickerController;
}

#pragma mark - <QMUIImagePickerViewControllerDelegate>

- (void)imagePickerController:(FWImagePickerController *)imagePickerController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<FWAsset *> *)imagesAssetArray {
    [self sendImageWithImagesAssetArray:imagesAssetArray];
}

- (FWImagePickerPreviewController *)imagePickerPreviewControllerForImagePickerController:(FWImagePickerController *)imagePickerController {
    FWImagePickerPreviewController *imagePickerPreviewController = [[FWImagePickerPreviewController alloc] init];
    imagePickerPreviewController.delegate = self;
    imagePickerPreviewController.maximumSelectImageCount = MaxSelectedImageCount;
    imagePickerPreviewController.showsOriginImageCheckboxButton = YES;
    imagePickerPreviewController.view.tag = imagePickerController.view.tag;
    return imagePickerPreviewController;
}

#pragma mark - <QMUIImagePickerPreviewViewControllerDelegate>

- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController didCheckImageAtIndex:(NSInteger)index {
    [self updateImageCountLabelForPreviewView:imagePickerPreviewController];
}

- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController didUncheckImageAtIndex:(NSInteger)index {
    [self updateImageCountLabelForPreviewView:imagePickerPreviewController];
}

// 更新选中的图片数量
- (void)updateImageCountLabelForPreviewView:(FWImagePickerPreviewController *)imagePickerPreviewController {
    if (imagePickerPreviewController.view.tag == MultipleImagePickingTag ||
        imagePickerPreviewController.view.tag == OnlyImagePickingTag ||
        imagePickerPreviewController.view.tag == OnlyVideoPickingTag) {
        NSUInteger selectedCount = [imagePickerPreviewController.selectedImageAssetArray count];
        if (selectedCount > 0) {
            imagePickerPreviewController.imageCountLabel.text = [[NSString alloc] initWithFormat:@"%@", @(selectedCount)];
            imagePickerPreviewController.imageCountLabel.hidden = NO;
        } else {
            imagePickerPreviewController.imageCountLabel.hidden = YES;
        }
    }
}

- (void)imagePickerPreviewController:(FWImagePickerPreviewController *)imagePickerPreviewController didFinishPickingImageWithImagesAssetArray:(nonnull NSMutableArray<FWAsset *> *)imagesAssetArray {
    [self sendImageWithImagesAssetArray:imagesAssetArray];
}

#pragma mark - 业务方法

- (void)showTipLabelWithText:(NSString *)text {
    [self fwHideLoading];
    [self fwShowMessageWithText:text];
}

- (void)sendImageWithImagesAssetArray:(NSMutableArray<FWAsset *> *)imagesAssetArray {
    [self fwShowLoading];
    FWWeakifySelf();
    [FWImagePickerController requestImagesAssetArray:imagesAssetArray filterType:0 completion:^(NSArray * _Nonnull objects, NSArray * _Nonnull results) {
        FWStrongifySelf();
        [self fwHideLoading];
        if (objects.count > 0) {
            [self fwShowImagePreviewWithImageURLs:objects currentIndex:0 sourceView:nil];
        }
    }];
}

@end
