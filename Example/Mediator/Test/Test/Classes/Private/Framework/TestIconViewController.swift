//
//  TestIconViewController.swift
//  Example
//
//  Created by wuyong on 2020/12/2.
//  Copyright © 2020 site.wuyong. All rights reserved.
//

import UIKit

class TestIconCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let result = UIImageView()
        return result
    }()
    
    lazy var nameLabel: UILabel = {
        let result = UILabel()
        result.textColor = Theme.textColor
        result.font = FW.font(10)
        result.textAlignment = .center
        result.numberOfLines = 0
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Theme.cellColor
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        imageView.fw.layoutChain.centerX().top().size(CGSize(width: 60, height: 60))
        nameLabel.fw.layoutChain.edges(.zero, excludingEdge: .top)
            .top(toViewBottom: imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objcMembers class TestIconViewController: TestViewController, CollectionViewControllerProtocol, UISearchBarDelegate {
    private var iconClass: Icon.Type = Octicons.self
        
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.tintColor = Theme.textColor
        searchBar.__fw.contentInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        searchBar.__fw.backgroundColor = Theme.barColor
        searchBar.__fw.textFieldBackgroundColor = Theme.tableColor
        searchBar.__fw.searchIconOffset = 16 - 6
        searchBar.__fw.searchTextOffset = 4
        searchBar.__fw.searchIconCenter = false
        
        let textField = searchBar.__fw.textField
        textField?.font = UIFont.systemFont(ofSize: 12)
        textField?.fw.setCornerRadius(16)
        textField?.fw.touchResign = true
        return searchBar
    }()
    
    override func renderView() {
        collectionView.backgroundColor = Theme.backgroundColor
        collectionView.__fw.keyboardDismissOnDrag = true
    }
    
    func renderCollectionViewLayout() -> UICollectionViewLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 60, height: 100)
        return flowLayout
    }
    
    func renderCollectionLayout() {
        view.addSubview(searchBar)
        searchBar.fw.layoutChain
            .edges(excludingEdge: .bottom)
            .height(FW.navigationBarHeight)
        collectionView.fw.layoutChain
            .edges(excludingEdge: .top)
            .top(toViewBottom: searchBar)
    }
    
    override func renderData() {
        fw.setRightBarItem(NSStringFromClass(iconClass)) { [weak self] sender in
            self?.__fw.showSheet(withTitle: nil, message: nil, cancel: "取消", actions: ["Octicons", "MaterialIcons", "FontAwesome", "FoundationIcons", "IonIcons"], actionBlock: { index in
                if index == 0 {
                    self?.iconClass = Octicons.self
                } else if index == 1 {
                    self?.iconClass = MaterialIcons.self
                } else if index == 2 {
                    self?.iconClass = FontAwesome.self
                } else if index == 3 {
                    self?.iconClass = FoundationIcons.self
                } else {
                    self?.iconClass = IonIcons.self
                }
                self?.renderData()
            })
        }
        
        var array = Array(iconClass.iconMapper().keys)
        let text = FW.safeString(searchBar.text?.fw.trimString)
        if text.count > 0 {
            array.removeAll { icon in
                return !icon.lowercased().contains(text.lowercased())
            }
        }
        collectionData.setArray(array)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = TestIconCell.fw.cell(collectionView: collectionView, indexPath: indexPath)
        let name = collectionData.object(at: indexPath.item) as? String
        cell.imageView.fw.themeImage = FW.iconImage(name.safeValue, 60)?.fw.themeImage
        cell.nameLabel.text = name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let name = collectionData.object(at: indexPath.item) as? String
        UIPasteboard.general.string = FW.safeString(name)
        __fw.showMessage(withText: name)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        renderData()
    }
}
