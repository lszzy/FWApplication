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
    FWImageAlbumTableCell *appearance = [FWImageAlbumTableCell appearance];
    appearance.albumImageSize = 56;
    appearance.albumNameFont = [UIFont systemFontOfSize:17];
    appearance.albumNameInsets = UIEdgeInsetsMake(0, 12, 0, 8);
    appearance.albumAssetsNumberFont = [UIFont systemFontOfSize:12];
    
    // 创建一个 QMUIAlbumViewController 实例用于呈现相簿列表
    FWImageAlbumController *albumController = [[FWImageAlbumController alloc] init];
    albumController.albumTableViewCellHeight = 68;
    albumController.fwNavigationBarStyle = FWNavigationBarStyleDefault;
    albumController.fwBackBarItem = FWIcon.backImage;
    albumController.albumControllerDelegate = self;
    albumController.pickDefaultAlbumGroup = YES;
    albumController.title = [self.tableData fwObjectAtIndex:index];
    if (index == 0) {
        albumController.view.tag = SingleImagePickingTag;
        albumController.contentType = FWAlbumContentTypeAll;
    } else if (index == 1) {
        albumController.view.tag = MultipleImagePickingTag;
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
    imagePickerController.showsImageCountLabel = albumController.view.tag != OnlyImagePickingTag;
    imagePickerController.view.tag = albumController.view.tag;
    if (albumController.view.tag == SingleImagePickingTag) {
        imagePickerController.allowsMultipleSelection = NO;
    }
    return imagePickerController;
}

- (void)albumController:(FWImageAlbumController *)albumController customCell:(FWImageAlbumTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FWAssetGroup *assetsGroup = albumController.albumsArray[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(assetsGroup.numberOfAssets)];
}

#pragma mark - <QMUIImagePickerViewControllerDelegate>

- (void)imagePickerControllerDidCancel:(FWImagePickerController *)imagePickerController {
    [self fwShowMessageWithText:@"图片选择已取消"];
}

- (void)imagePickerController:(FWImagePickerController *)imagePickerController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<FWAsset *> *)imagesAssetArray {
    [self sendImageWithImagesAssetArray:imagesAssetArray];
}

- (FWImagePickerPreviewController *)imagePickerPreviewControllerForImagePickerController:(FWImagePickerController *)imagePickerController {
    FWImagePickerPreviewController *imagePickerPreviewController = [[FWImagePickerPreviewController alloc] init];
    imagePickerPreviewController.delegate = self;
    imagePickerPreviewController.maximumSelectImageCount = MaxSelectedImageCount;
    imagePickerPreviewController.showsOriginImageCheckboxButton = YES;
    imagePickerPreviewController.showsImageCountLabel = imagePickerController.view.tag != OnlyImagePickingTag;
    imagePickerPreviewController.showsEditCollectionView = imagePickerController.view.tag != OnlyImagePickingTag;
    imagePickerPreviewController.view.tag = imagePickerController.view.tag;
    return imagePickerPreviewController;
}

- (void)imagePickerController:(FWImagePickerController *)imagePickerController customCell:(FWImagePickerCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.showsCheckedIndexLabel = imagePickerController.view.tag != OnlyImagePickingTag;
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
