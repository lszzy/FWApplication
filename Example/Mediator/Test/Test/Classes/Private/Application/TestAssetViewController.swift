//
//  TestAssetViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestAssetViewController: TestViewController, TableViewControllerProtocol {
    var albums: [AssetGroup] = []
    var photos: [Asset] = []
    var isAlbum: Bool = false
    var album: AssetGroup = AssetGroup()
    
    override func renderModel() {
        if isAlbum {
            loadPhotos()
        } else {
            loadAlbums()
        }
    }
    
    private func loadAlbums() {
        __fw.showLoading()
        DispatchQueue.global().async {
            AssetManager.sharedInstance.enumerateAllAlbums(with: .all) { [weak self] group in
                if let album = group {
                    self?.albums.append(album)
                } else {
                    DispatchQueue.main.async {
                        self?.__fw.hideLoading()
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func loadPhotos() {
        __fw.showLoading()
        DispatchQueue.global().async { [weak self] in
            self?.album.enumerateAssets(withOptions: .reverse, using: { asset in
                if let photo = asset {
                    self?.photos.append(photo)
                } else {
                    DispatchQueue.main.async {
                        self?.__fw.hideLoading()
                        self?.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isAlbum ? photos.count : albums.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.fw.cell(tableView: tableView, style: .subtitle)
        cell.selectionStyle = .none
        
        if isAlbum {
            cell.accessoryType = .none
            
            let photo = photos[indexPath.row]
            cell.fw.tempObject = photo.identifier
            photo.requestThumbnailImage(with: CGSize(width: 88, height: 88)) { image, info, finished in
                if cell.fw.tempObject.safeString == photo.identifier {
                    cell.imageView?.image = image?.fw.image(scaleSize: CGSize(width: 88, height: 88), contentMode: .scaleAspectFill)
                } else {
                    cell.imageView?.image = nil
                }
            }
            photo.assetSize { size in
                if cell.fw.tempObject.safeString == photo.identifier {
                    cell.textLabel?.text = String.fw.sizeString(UInt(size))
                } else {
                    cell.textLabel?.text = nil
                }
            }
            
            if photo.assetType == .video {
                cell.detailTextLabel?.text = Date.fw.formatDuration(photo.duration(), hasHour: false)
            } else if photo.assetType == .audio {
                cell.detailTextLabel?.text = "audio"
            } else if photo.assetSubType == .livePhoto {
                cell.detailTextLabel?.text = "livePhoto"
            } else if photo.assetSubType == .GIF {
                cell.detailTextLabel?.text = "gif"
            } else {
                cell.detailTextLabel?.text = nil
            }
        } else {
            cell.accessoryType = .disclosureIndicator
            
            let album = albums[indexPath.row]
            cell.textLabel?.text = album.name()
            let image = album.posterImage(with: CGSize(width: 88, height: 88))
            cell.imageView?.image = image?.fw.image(scaleSize: CGSize(width: 88, height: 88), contentMode: .scaleAspectFill)
            cell.detailTextLabel?.text = "\(album.numberOfAssets())"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAlbum {
            __fw.showImagePreview(withImageURLs: photos, imageInfos:nil, currentIndex: indexPath.row) { [weak self] index in
                let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0))
                return cell?.imageView
            } placeholderImage: { index in
                return nil
            } renderBlock: { [weak self] view, index in
                guard let photo = self?.photos[index] else { return }
                if let zoomImageView = view as? ZoomImageView {
                    if photo.assetSubType == .GIF {
                        zoomImageView.progress = 0.01
                        photo.requestImageData { data, info, _, _ in
                            zoomImageView.progress = 1
                            zoomImageView.image = UIImage.__fw.image(with:data)
                        }
                    } else if photo.assetSubType == .livePhoto {
                        zoomImageView.progress = 0.01
                        photo.requestLivePhoto { livePhoto, info, finished in
                            zoomImageView.progress = 1
                            zoomImageView.livePhoto = livePhoto
                        } withProgressHandler: { progress, error, stop, info in
                            DispatchQueue.main.async {
                                zoomImageView.progress = CGFloat(progress)
                            }
                        }
                    } else if photo.assetType == .video {
                        zoomImageView.progress = 0.01
                        photo.requestPlayerItem { playerItem, info in
                            zoomImageView.progress = 1
                            zoomImageView.videoPlayerItem = playerItem
                        } withProgressHandler: { progress, error, stop, info in
                            DispatchQueue.main.async {
                                zoomImageView.progress = CGFloat(progress)
                            }
                        }
                    } else {
                        zoomImageView.progress = 0.01
                        photo.requestPreviewImage { image, info, finished in
                            zoomImageView.progress = 1
                            zoomImageView.image = image
                        } withProgressHandler: { progress, error, stop, info in
                            DispatchQueue.main.async {
                                zoomImageView.progress = CGFloat(progress)
                            }
                        }
                    }
                }
            } customBlock: { [weak self] preview in
                if let previewController = preview as? ImagePreviewController {
                    // 注意此处需要weak引用previewController，否则会产生循环引用
                    previewController.pageIndexChanged = { [weak previewController] (index) in
                        guard let controller = previewController else { return }
                        var titleLabel: UILabel? = controller.view.viewWithTag(100) as? UILabel
                        if titleLabel == nil {
                            let label = UILabel.fw.label(font: FW.font(16), textColor: UIColor.white)
                            label.tag = 100
                            titleLabel = label
                            controller.view.addSubview(label)
                            label.fw.layoutChain.centerX().top(toSafeArea: (44.0 - FW.font(16).lineHeight) / 2)
                        }
                        
                        guard let photo = self?.photos[index] else { return }
                        var title = "image"
                        if photo.assetType == .video {
                            title = "video"
                        } else if photo.assetType == .image {
                            if photo.assetSubType == .livePhoto {
                                title = "livePhoto"
                            } else if photo.assetSubType == .GIF {
                                title = "gif"
                            }
                        }
                        titleLabel?.text = title
                    }
                }
            }
        } else {
            let album = albums[indexPath.row]
            let viewController = TestAssetViewController()
            viewController.navigationItem.title = album.name()
            viewController.album = album
            viewController.isAlbum = true
            fw.open(viewController, animated: true)
        }
    }
}
