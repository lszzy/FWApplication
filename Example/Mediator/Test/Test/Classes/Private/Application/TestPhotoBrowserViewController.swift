//
//  TestPhotoBrowserViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestPhotoBrowserViewController: TestViewController, TableViewControllerProtocol {
    private var results: [Any] = []
    private var allowsEditing: Bool = false
    private var isFullscreen: Bool = false
    
    override func renderModel() {
        fw.setRightBarItem(Icon.refreshImage) { [weak self] sender in
            let allowsEditing = self?.allowsEditing ?? false
            let isFullscreen = self?.isFullscreen ?? false
            self?.fw.showSheet(title: nil, message: nil, cancel: nil, actions: ["浏览已选图片", allowsEditing ? "切换不可编辑" : "切换可编辑", ImagePickerPluginImpl.sharedInstance.cropControllerEnabled ? "切换系统裁剪" : "切换自定义裁剪", isFullscreen ? "默认弹出样式" : "全屏弹出样式", ImagePickerPluginImpl.sharedInstance.photoPickerDisabled ? "启用PHPicker" : "禁用PHPicker"], currentIndex: -1, actionBlock: { index in
                if index == 0 {
                    self?.showData(self?.results ?? [])
                } else if index == 1 {
                    self?.allowsEditing = !allowsEditing
                } else if index == 2 {
                    ImagePickerPluginImpl.sharedInstance.cropControllerEnabled = !ImagePickerPluginImpl.sharedInstance.cropControllerEnabled;
                } else if index == 3 {
                    self?.isFullscreen = !isFullscreen
                    if self?.isFullscreen ?? false {
                        ImagePickerPluginImpl.sharedInstance.customBlock = { viewController in
                            viewController.modalPresentationStyle = .fullScreen
                        }
                    } else {
                        ImagePickerPluginImpl.sharedInstance.customBlock = nil
                    }
                } else {
                    ImagePickerPluginImpl.sharedInstance.photoPickerDisabled = !ImagePickerPluginImpl.sharedInstance.photoPickerDisabled;
                }
            })
        }
    }
    
    override func renderData() {
        tableData.addObjects(from: [
            "照片选择器(图片)",
            "照片选择器(LivePhoto)",
            "照片选择器(视频)",
            "照片选择器(默认)",
            "照相机(图片)",
            "照相机(LivePhoto)",
            "照相机(视频)",
            "照相机(默认)",
        ])
    }
    
    private func showData(_ results: [Any]) {
        self.results = results
        if results.count < 1 {
            fw.showMessage(text: "请选择照片")
            return
        }
        
        fw.showImagePreview(imageURLs: results, imageInfos: nil, currentIndex: 0, sourceView: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.fw.cell(tableView: tableView)
        let value = tableData.object(at: indexPath.row) as? String
        cell.textLabel?.text = value
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            fw.showImagePicker(filterType: .image, selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 1:
            fw.showImagePicker(filterType: .livePhoto, selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 2:
            fw.showImagePicker(filterType: .video, selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 3:
            fw.showImagePicker(filterType: [], selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 4:
            fw.showImageCamera(filterType: .image, allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        case 5:
            fw.showImageCamera(filterType: .livePhoto, allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        case 6:
            fw.showImageCamera(filterType: .video, allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        case 7:
            fw.showImageCamera(filterType: [], allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        default:
            break
        }
    }
}
