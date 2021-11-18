//
//  TestAssetViewController.swift
//  Example
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import FWApplication

@objcMembers class TestAssetViewController: TestViewController, FWTableViewController {
    var albums: [FWAssetGroup] = []
    var photos: [FWAsset] = []
    var isAlbum: Bool = false
    var album: FWAssetGroup = FWAssetGroup()
    
    override func renderModel() {
        if isAlbum {
            loadPhotos()
        } else {
            loadAlbums()
        }
    }
    
    private func loadAlbums() {
        fwShowLoading()
        DispatchQueue.global().async {
            FWAssetManager.sharedInstance.enumerateAllAlbums(with: .all) { [weak self] group in
                if let album = group {
                    self?.albums.append(album)
                } else {
                    DispatchQueue.main.async {
                        self?.fwHideLoading()
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func loadPhotos() {
        fwSetRightBarItem("切换") { sender in
            let plugin = FWPluginManager.loadPlugin(FWImagePreviewPlugin.self)
            if plugin != nil {
                FWPluginManager.unloadPlugin(FWImagePreviewPlugin.self)
                FWPluginManager.unregisterPlugin(FWImagePreviewPlugin.self)
            } else {
                FWPluginManager.registerPlugin(FWImagePreviewPlugin.self, with: FWPhotoBrowserPlugin.self)
            }
        }
        
        fwShowLoading()
        DispatchQueue.global().async { [weak self] in
            self?.album.enumerateAssets(withOptions: .reverse, using: { asset in
                if let photo = asset {
                    self?.photos.append(photo)
                } else {
                    DispatchQueue.main.async {
                        self?.fwHideLoading()
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
        let cell = UITableViewCell.fwCell(with: tableView, style: .subtitle)
        cell.selectionStyle = .none
        
        if isAlbum {
            cell.accessoryType = .none
            
            let photo = photos[indexPath.row]
            cell.fwTempObject = photo.identifier
            photo.requestThumbnailImage(with: CGSize(width: 88, height: 88)) { image, info, finished in
                if cell.fwTempObject.fwAsString == photo.identifier {
                    cell.imageView?.image = image?.fwImage(withScale: CGSize(width: 88, height: 88), contentMode: .scaleAspectFill)
                } else {
                    cell.imageView?.image = nil
                }
            }
            photo.assetSize { size in
                if cell.fwTempObject.fwAsString == photo.identifier {
                    cell.textLabel?.text = NSString.fwSizeString(UInt(size))
                } else {
                    cell.textLabel?.text = nil
                }
            }
            
            if photo.assetType == .video {
                cell.detailTextLabel?.text = NSDate.fwFormatDuration(photo.duration(), hasHour: false)
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
            cell.imageView?.image = album.posterImage(with: CGSize(width: 88, height: 88))?.fwImage(withScale: CGSize(width: 88, height: 88), contentMode: .scaleAspectFill)
            cell.detailTextLabel?.text = "\(album.numberOfAssets())"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAlbum {
            fwShowImagePreview(withImageURLs: photos, currentIndex: indexPath.row) { [weak self] index in
                let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0))
                return cell?.imageView
            } placeholderImage: { index in
                return nil
            } renderBlock: { [weak self] view, index in
                guard let photo = self?.photos[index] else { return }
                if let zoomImageView = view as? FWZoomImageView {
                    if photo.assetSubType == .GIF {
                        zoomImageView.progress = 0.01
                        photo.requestImageData { data, info, _, _ in
                            zoomImageView.progress = 1
                            zoomImageView.image = UIImage.fwImage(with:data)
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
                } else if let photoView = view as? FWPhotoView {
                    if photo.assetSubType == .GIF {
                        photo.requestImageData { data, info, _, _ in
                            photoView.urlString = UIImage.fwImage(with:data)
                        }
                    } else if photo.assetSubType == .livePhoto {
                        photo.requestLivePhoto { livePhoto, info, finished in
                            photoView.urlString = livePhoto
                        } withProgressHandler: { progress, error, stop, info in
                            DispatchQueue.main.async {
                                photoView.progress = CGFloat(progress)
                            }
                        }
                    } else if photo.assetType == .video {
                        photo.requestPlayerItem { playerItem, info in
                            photoView.urlString = playerItem
                        } withProgressHandler: { progress, error, stop, info in
                            DispatchQueue.main.async {
                                photoView.progress = CGFloat(progress)
                            }
                        }
                    } else {
                        photoView.progress = 0.01
                        photo.requestPreviewImage { image, info, finished in
                            photoView.progress = 1
                            photoView.urlString = image
                        } withProgressHandler: { progress, error, stop, info in
                            DispatchQueue.main.async {
                                photoView.progress = CGFloat(progress)
                            }
                        }
                    }
                }
            } customBlock: { [weak self] preview in
                if let previewController = preview as? FWImagePreviewController {
                    // 注意此处需要weak引用previewController，否则会产生循环引用
                    previewController.pageIndexChanged = { [weak previewController] (index) in
                        guard let controller = previewController else { return }
                        var titleLabel: UILabel? = controller.view.viewWithTag(100) as? UILabel
                        if titleLabel == nil {
                            let label = UILabel.fwLabel(with: FWFontSize(16), textColor: UIColor.white)
                            label.tag = 100
                            titleLabel = label
                            controller.view.addSubview(label)
                            label.fwLayoutChain.centerX().topToSafeArea((44.0 - FWFontSize(16).lineHeight) / 2)
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
                } else if let photoBrowser = preview as? FWPhotoBrowser {
                    // 注意此处需要weak引用photoBrowser，否则会产生循环引用
                    photoBrowser.pageIndexChanged = { [weak photoBrowser] (index) in
                        guard let photoBrowser = photoBrowser else { return }
                        var titleLabel: UILabel? = photoBrowser.viewWithTag(100) as? UILabel
                        if titleLabel == nil {
                            let label = UILabel.fwLabel(with: FWFontSize(16), textColor: UIColor.white)
                            label.tag = 100
                            titleLabel = label
                            photoBrowser.addSubview(label)
                            label.fwLayoutChain.centerX().topToSafeArea((44.0 - FWFontSize(16).lineHeight) / 2)
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
            fwOpen(viewController, animated: true)
        }
    }
}
