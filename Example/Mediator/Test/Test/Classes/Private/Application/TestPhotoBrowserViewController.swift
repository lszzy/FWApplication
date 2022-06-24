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
            self?.__fw.showSheet(withTitle: nil, message: nil, cancel: nil, actions: ["浏览已选图片", allowsEditing ? "切换不可编辑" : "切换可编辑", ImagePickerPluginImpl.sharedInstance.cropControllerEnabled ? "切换系统裁剪" : "切换自定义裁剪", isFullscreen ? "默认弹出样式" : "全屏弹出样式", ImagePickerPluginImpl.sharedInstance.photoPickerDisabled ? "启用PHPicker" : "禁用PHPicker"], actionBlock: { index in
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
            __fw.showMessage(withText: "请选择照片")
            return
        }
        
        __fw.showImagePreview(withImageURLs: results, imageInfos: nil, currentIndex: 0, sourceView: nil)
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
            __fw.showImagePicker(with: .image, selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 1:
            __fw.showImagePicker(with: .livePhoto, selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 2:
            __fw.showImagePicker(with: .video, selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 3:
            __fw.showImagePicker(with: [], selectionLimit: 9, allowsEditing: allowsEditing, customBlock: nil) { [weak self] objects, results, cancel in
                self?.showData(objects)
            }
            break
        case 4:
            __fw.showImageCamera(with: .image, allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        case 5:
            __fw.showImageCamera(with: .livePhoto, allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        case 6:
            __fw.showImageCamera(with: .video, allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        case 7:
            __fw.showImageCamera(with: [], allowsEditing: allowsEditing, customBlock: nil) { [weak self] object, info, cancel in
                self?.showData(object != nil ? [object!] : [])
            }
            break
        default:
            break
        }
    }
}
