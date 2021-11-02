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

@property(nonatomic, assign) BOOL showsAlbum;

@end

@implementation TestImagePickerViewController

- (void)renderModel {
    FWWeakifySelf();
    [self fwSetRightBarItem:FWIcon.refreshImage block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        self.showsAlbum = !self.showsAlbum;
    }];
}

- (void)renderData {
    [self.tableData addObjectsFromArray:@[
        @"选择单张图片",
        @"选择多张图片",
        @"多选仅图片",
        @"多选仅视频",
    ]];
}

- (void)presentPickerViewControllerWithIndex:(NSInteger)index {
    FWImagePickerController *imagePickerController = [[FWImagePickerController alloc] init];
    imagePickerController.imagePickerControllerDelegate = self;
    imagePickerController.maximumSelectImageCount = MaxSelectedImageCount;
    FWAlbumContentType contentType;
    if (index == 0) {
        imagePickerController.view.tag = SingleImagePickingTag;
        contentType = FWAlbumContentTypeAll;
    } else if (index == 1) {
        imagePickerController.view.tag = MultipleImagePickingTag;
        contentType = FWAlbumContentTypeAll;
    } else if (index == 2) {
        imagePickerController.view.tag = OnlyImagePickingTag;
        imagePickerController.minimumSelectImageCount = 2;
        contentType = FWAlbumContentTypeOnlyPhoto;
    } else {
        imagePickerController.view.tag = OnlyVideoPickingTag;
        contentType = FWAlbumContentTypeOnlyVideo;
    }
    imagePickerController.titleView.accessoryImage = [self accessoryImage];
    if (imagePickerController.view.tag == SingleImagePickingTag) {
        imagePickerController.allowsMultipleSelection = NO;
    }
    [imagePickerController refreshWithContentType:contentType];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)presentAlbumViewControllerWithIndex:(NSInteger)index {
    // 创建一个 QMUIAlbumViewController 实例用于呈现相簿列表
    FWImageAlbumController *albumController = [[FWImageAlbumController alloc] init];
    albumController.albumTableViewCellHeight = 68;
    albumController.albumControllerDelegate = self;
    albumController.pickDefaultAlbumGroup = YES;
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
    if (self.showsAlbum) {
        [self presentAlbumViewControllerWithIndex:indexPath.row];
    } else {
        [self presentPickerViewControllerWithIndex:indexPath.row];
    }
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
    if (albumController.view.tag == OnlyImagePickingTag) {
        imagePickerController.minimumSelectImageCount = 2;
    }
    return imagePickerController;
}

- (void)albumController:(FWImageAlbumController *)albumController customCell:(FWImageAlbumTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    FWAssetGroup *assetsGroup = albumController.albumsArray[indexPath.row];
    cell.albumImageSize = 56;
    cell.albumNameFont = [UIFont systemFontOfSize:17];
    cell.albumNameInsets = UIEdgeInsetsMake(0, 12, 0, 8);
    cell.albumAssetsNumberFont = [UIFont systemFontOfSize:12];
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
    imagePickerPreviewController.showsEditCollectionView = imagePickerController.view.tag != OnlyImagePickingTag;
    imagePickerPreviewController.view.tag = imagePickerController.view.tag;
    return imagePickerPreviewController;
}

- (void)imagePickerController:(FWImagePickerController *)imagePickerController customCell:(FWImagePickerCollectionCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.showsCheckedIndexLabel = imagePickerController.view.tag != OnlyImagePickingTag;
}

- (FWImageAlbumController *)albumControllerForImagePickerController:(FWImagePickerController *)imagePickerController {
    FWImageAlbumController *albumController = [[FWImageAlbumController alloc] init];
    albumController.albumTableViewCellHeight = 68;
    albumController.albumControllerDelegate = self;
    if (imagePickerController.view.tag == SingleImagePickingTag) {
        albumController.contentType = FWAlbumContentTypeAll;
    } else if (imagePickerController.view.tag == MultipleImagePickingTag) {
        albumController.contentType = FWAlbumContentTypeAll;
    } else if (imagePickerController.view.tag == OnlyImagePickingTag) {
        albumController.contentType = FWAlbumContentTypeOnlyPhoto;
    } else {
        albumController.contentType = FWAlbumContentTypeOnlyVideo;
    }
    albumController.modalPresentationStyle = UIModalPresentationFullScreen;
    return albumController;
}

#pragma mark - 业务方法

- (UIImage *)accessoryImage {
    UIBezierPath *bezierPath = [UIBezierPath fwShapeTriangle:CGRectMake(0, 0, 8, 5) direction:UISwipeGestureRecognizerDirectionDown];
    UIImage *accessoryImage = [[bezierPath fwShapeImage:CGSizeMake(8, 5) strokeWidth:0 strokeColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] fillColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return accessoryImage;
}

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
