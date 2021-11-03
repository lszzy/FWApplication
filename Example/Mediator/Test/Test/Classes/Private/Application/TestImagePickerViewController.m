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

- (UIImage *)accessoryImage {
    UIBezierPath *bezierPath = [UIBezierPath fwShapeTriangle:CGRectMake(0, 0, 8, 5) direction:UISwipeGestureRecognizerDirectionDown];
    UIImage *accessoryImage = [[bezierPath fwShapeImage:CGSizeMake(8, 5) strokeWidth:0 strokeColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] fillColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return accessoryImage;
}

- (void)renderModel {
    FWWeakifySelf();
    [self fwSetRightBarItem:FWIcon.refreshImage block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        [self fwShowSheetWithTitle:nil message:nil cancel:@"取消" actions:@[@"切换选取插件", @"切换选取样式"] actionBlock:^(NSInteger index) {
            FWStrongifySelf();
            if (index == 0) {
                id<FWImagePickerPlugin> pickerPlugin = [FWPluginManager loadPlugin:@protocol(FWImagePickerPlugin)];
                if (pickerPlugin) {
                    [FWPluginManager unloadPlugin:@protocol(FWImagePickerPlugin)];
                    [FWPluginManager unregisterPlugin:@protocol(FWImagePickerPlugin)];
                } else {
                    [FWPluginManager registerPlugin:@protocol(FWImagePickerPlugin) withObject:[FWImagePickerControllerImpl class]];
                    FWImagePickerControllerImpl.sharedInstance.showLoadingBlock = ^(UIViewController * _Nonnull viewController, BOOL finished) {
                        if (!finished) {
                            [viewController fwShowLoading];
                        } else {
                            [viewController fwHideLoading];
                        }
                    };
                    FWImagePickerControllerImpl.sharedInstance.customBlock = ^(FWImagePickerController * _Nonnull pickerController) {
                        FWStrongifySelf();
                        pickerController.titleAccessoryImage = [self accessoryImage];
                    };
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
    UITableViewCell *cell = [UITableViewCell fwCellWithTableView:tableView];
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger index = indexPath.row;
    FWWeakifySelf();
    [self fwShowImagePickerWithFilterType:index == 2 ? FWImagePickerFilterTypeImage : (index == 3 ? FWImagePickerFilterTypeVideo : 0)
                           selectionLimit:index == 0 ? 1 : 9
                            allowsEditing:index == 2 ? NO : YES
                              customBlock:nil
                               completion:^(NSArray * _Nonnull objects, NSArray * _Nonnull results, BOOL cancel) {
        FWStrongifySelf();
        if (cancel) {
            [self fwShowMessageWithText:@"已取消"];
        } else {
            [self fwShowImagePreviewWithImageURLs:objects currentIndex:0 sourceView:nil];
        }
    }];
}

@end
