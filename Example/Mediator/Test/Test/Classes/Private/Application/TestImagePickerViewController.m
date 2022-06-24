//
//  TestImagePickerViewController.m
//  Example
//
//  Created by wuyong on 2018/11/29.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestImagePickerViewController.h"

@interface TestImagePickerViewController () <FWTableViewController>

@end

@implementation TestImagePickerViewController

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupPlugin];
    });
}

+ (void)setupPlugin {
    [FWPluginManager registerPlugin:@protocol(FWImagePickerPlugin) withObject:[FWImagePickerControllerImpl class]];
    FWImagePickerControllerImpl.sharedInstance.pickerControllerBlock = ^FWImagePickerController * _Nonnull{
        FWImagePickerController *pickerController = [[FWImagePickerController alloc] init];
        UIBezierPath *bezierPath = [UIBezierPath.fw shapeTriangle:CGRectMake(0, 0, 8, 5) direction:UISwipeGestureRecognizerDirectionDown];
        UIImage *accessoryImage = [[bezierPath.fw shapeImage:CGSizeMake(8, 5) strokeWidth:0 strokeColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] fillColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        pickerController.titleAccessoryImage = accessoryImage;
        
        BOOL showsCheckedIndexLabel = [@[@YES, @NO].fw_randomObject fw_safeBool];
        pickerController.customCellBlock = ^(FWImagePickerCollectionCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath) {
            cell.showsCheckedIndexLabel = showsCheckedIndexLabel;
            cell.editedIconImage = [FWIconImage(@"fa-picture-o", 12) fw_imageWithTintColor:[UIColor whiteColor]];
        };
        return pickerController;
    };
    FWImagePickerControllerImpl.sharedInstance.albumControllerBlock = ^FWImageAlbumController * _Nonnull{
        FWImageAlbumController *albumController = [[FWImageAlbumController alloc] init];
        albumController.customCellBlock = ^(FWImageAlbumTableCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath) {
            cell.checkedMaskColor = [UIColor fw_colorWithHex:0xFFFFFF alpha:0.1];
        };
        return albumController;
    };
    FWImagePickerControllerImpl.sharedInstance.previewControllerBlock = ^FWImagePickerPreviewController * _Nonnull{
        FWImagePickerPreviewController *previewController = [[FWImagePickerPreviewController alloc] init];
        previewController.showsOriginImageCheckboxButton = [@[@YES, @NO].fw_randomObject fw_safeBool];
        previewController.showsEditButton = [@[@YES, @NO].fw_randomObject fw_safeBool];
        previewController.customCellBlock = ^(FWImagePickerPreviewCollectionCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath) {
            cell.editedIconImage = [FWIconImage(@"fa-picture-o", 12) fw_imageWithTintColor:[UIColor whiteColor]];
        };
        return previewController;
    };
    FWImagePickerControllerImpl.sharedInstance.cropControllerBlock = ^FWImageCropController * _Nonnull(UIImage * _Nonnull image) {
        FWImageCropController *cropController = [[FWImageCropController alloc] initWithImage:image];
        cropController.aspectRatioPickerButtonHidden = YES;
        cropController.cropView.backgroundColor = UIColor.blackColor;
        cropController.toolbar.tintColor = UIColor.whiteColor;
        [cropController.toolbar.cancelTextButton fw_setImage:FWIconImage(@"ion-android-close", 22)];
        [cropController.toolbar.cancelTextButton setTitle:nil forState:UIControlStateNormal];
        [cropController.toolbar.doneTextButton fw_setImage:FWIconImage(@"ion-android-done", 22)];
        [cropController.toolbar.doneTextButton setTitle:nil forState:UIControlStateNormal];
        return cropController;
    };
}

- (void)renderModel {
    FWWeakifySelf();
    [self fw_setRightBarItem:FWIcon.refreshImage block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        [self fw_showSheetWithTitle:nil message:nil cancel:@"取消" actions:@[@"切换选取插件", @"切换选取样式"] actionBlock:^(NSInteger index) {
            FWStrongifySelf();
            if (index == 0) {
                id<FWImagePickerPlugin> pickerPlugin = [FWPluginManager loadPlugin:@protocol(FWImagePickerPlugin)];
                if (pickerPlugin) {
                    [FWPluginManager unloadPlugin:@protocol(FWImagePickerPlugin)];
                    [FWPluginManager unregisterPlugin:@protocol(FWImagePickerPlugin)];
                } else {
                    [self.class setupPlugin];
                }
            } else {
                id<FWImagePickerPlugin> pickerPlugin = [FWPluginManager loadPlugin:@protocol(FWImagePickerPlugin)];
                if (pickerPlugin) {
                    FWImagePickerControllerImpl.sharedInstance.showsAlbumController = !FWImagePickerControllerImpl.sharedInstance.showsAlbumController;
                } else {
                    FWImagePickerPluginImpl.sharedInstance.photoPickerDisabled = !FWImagePickerPluginImpl.sharedInstance.photoPickerDisabled;
                }
            }
        }];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell fw_cellWithTableView:tableView];
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger index = indexPath.row;
    FWWeakifySelf();
    [self fw_showImagePickerWithFilterType:index == 2 ? FWImagePickerFilterTypeImage : (index == 3 ? FWImagePickerFilterTypeVideo : 0)
                           selectionLimit:index == 0 ? 1 : 9
                            allowsEditing:index == 2 ? NO : YES
                              customBlock:nil
                               completion:^(NSArray * _Nonnull objects, NSArray * _Nonnull results, BOOL cancel) {
        FWStrongifySelf();
        if (cancel || objects.count < 1) {
            [self.fw showMessageWithText:@"已取消"];
        } else {
            [self.fw showImagePreviewWithImageURLs:objects imageInfos:nil currentIndex:0 sourceView:nil];
        }
    }];
}

@end
