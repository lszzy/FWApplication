//
//  UICollectionView+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2020/10/21.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import UIKit
import FWFramework
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

// MARK: - CollectionViewDelegate
/// 便捷集合视图代理
@objc(FWCollectionViewDelegate)
@objcMembers open class CollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    /// 集合数据，可选方式，必须按[section][item]二维数组格式
    open var collectionData: [[Any]] = []
    
    /// 集合section数，默认自动计算collectionData
    open var countForSection: (() -> Int)?
    /// 集合section数，默认0自动计算，优先级低
    open var sectionCount: Int = 0
    /// 集合item数句柄，默认自动计算collectionData
    open var countForItem: ((Int) -> Int)?
    /// 集合item数，默认0自动计算，优先级低
    open var itemCount: Int = 0
    
    /// 集合section边距句柄，默认nil
    open var insetForSection: ((Int) -> UIEdgeInsets)?
    /// 集合section边距，默认zero，优先级低
    open var sectionInset: UIEdgeInsets = .zero
    
    /// 集合section头视图句柄，支持UICollectionReusableView，默认nil
    open var viewForHeader: ((IndexPath) -> Any?)?
    /// 集合section头视图，支持UICollectionReusableView，默认nil，优先级低
    open var headerViewClass: Any?
    /// 集合section头视图配置句柄，参数为headerClass对象，默认为nil
    open var headerConfiguration: ReusableViewIndexPathBlock?
    /// 集合section头尺寸句柄，不指定时默认使用FWDynamicLayout自动计算并按section缓存
    open var sizeForHeader: ((Int) -> CGSize)?
    /// 集合section头尺寸，默认nil自动根据viewModel计算，可设置为automaticSize，优先级低
    open var headerSize: CGSize?
    
    /// 集合section尾视图句柄，支持UICollectionReusableView，默认nil
    open var viewForFooter: ((IndexPath) -> Any?)?
    /// 集合section尾视图，支持UICollectionReusableView，默认nil，优先级低
    open var footerViewClass: Any?
    /// 集合section头视图配置句柄，参数为headerClass对象，默认为nil
    open var footerConfiguration: ReusableViewIndexPathBlock?
    /// 集合section尾尺寸句柄，不指定时默认使用FWDynamicLayout自动计算并按section缓存
    open var sizeForFooter: ((Int) -> CGSize)?
    /// 集合section尾尺寸，默认nil自动根据viewModel计算，可设置为automaticSize，优先级低
    open var footerSize: CGSize?
    
    /// 集合cell类句柄，支持UICollectionViewCell，默认nil
    open var cellForItem: ((IndexPath) -> Any?)?
    /// 集合cell类，支持UICollectionViewCell，默认nil，优先级低
    open var cellClass: Any?
    /// 集合cell配置句柄，参数为对应cellClass对象，默认设置fwViewModel为collectionData对应数据
    open var cellConfiguration: CollectionCellIndexPathBlock?
    /// 集合cell尺寸句柄，不指定时默认使用FWDynamicLayout自动计算并按indexPath缓存
    open var sizeForItem: ((IndexPath) -> CGSize)?
    /// 集合cell尺寸，默认nil自动根据viewModel计算，可设置为automaticSize，优先级低
    open var itemSize: CGSize?
    
    /// 集合选中事件，默认nil
    open var didSelectItem: ((IndexPath) -> Void)?
    
    func sectionInset(_ section: Int, _ collectionView: UICollectionView) -> UIEdgeInsets {
        if let insetBlock = insetForSection {
            return insetBlock(section)
        }
        if sectionInset != .zero {
            return sectionInset
        }
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.sectionInset
        }
        return .zero
    }
    
    // MARK: - UICollectionView
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let countBlock = countForSection {
            return countBlock()
        }
        if sectionCount > 0 {
            return sectionCount
        }
        
        return collectionData.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let countBlock = countForItem {
            return countBlock(section)
        }
        if itemCount > 0 {
            return itemCount
        }
        
        return collectionData.count > section ? collectionData[section].count : 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = cellForItem?(indexPath) ?? cellClass
        if let cell = itemCell as? UICollectionViewCell {
            return cell
        }
        guard let clazz = itemCell as? UICollectionViewCell.Type else {
            return UICollectionViewCell(frame: .zero)
        }
        
        // 注意：此处必须使用.__fw_创建，否则返回的对象类型不对
        let cell = clazz.__fw_cell(with: collectionView, indexPath: indexPath)
        if let cellBlock = cellConfiguration {
            cellBlock(cell, indexPath)
            return cell
        }
        
        var viewModel: Any?
        if let sectionData = collectionData.count > indexPath.section ? collectionData[indexPath.section] : nil,
           sectionData.count > indexPath.item {
            viewModel = sectionData[indexPath.item]
        }
        cell.__fw_viewModel = viewModel
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let sizeBlock = sizeForItem {
            return sizeBlock(indexPath)
        }
        if let itemSize = itemSize {
            return itemSize
        }
        
        let itemCell = cellForItem?(indexPath) ?? cellClass
        if let cell = itemCell as? UICollectionViewCell {
            return cell.frame.size
        }
        guard let clazz = itemCell as? UICollectionViewCell.Type else {
            return .zero
        }
        
        if let cellBlock = cellConfiguration {
            let inset = sectionInset(indexPath.section, collectionView)
            var width: CGFloat = 0
            if inset != .zero && collectionView.frame.size.width > 0 {
                width = collectionView.frame.size.width - inset.left - inset.right
            }
            return collectionView.fw.size(cellClass: clazz, width: width, cacheBy: indexPath) { (cell) in
                cellBlock(cell, indexPath)
            }
        }
        
        var viewModel: Any?
        if let sectionData = collectionData.count > indexPath.section ? collectionData[indexPath.section] : nil,
           sectionData.count > indexPath.item {
            viewModel = sectionData[indexPath.item]
        }
        let inset = sectionInset(indexPath.section, collectionView)
        var width: CGFloat = 0
        if inset != .zero && collectionView.frame.size.width > 0 {
            width = collectionView.frame.size.width - inset.left - inset.right
        }
        return collectionView.fw.size(cellClass: clazz, width: width, cacheBy: indexPath) { (cell) in
            cell.__fw_viewModel = viewModel
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset(section, collectionView)
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let viewClass = viewForHeader?(indexPath) ?? headerViewClass
            if let view = viewClass as? UICollectionReusableView { return view }
            guard let clazz = viewClass as? UICollectionReusableView.Type else { return UICollectionReusableView() }
            
            // 注意：此处必须使用.__fw_创建，否则返回的对象类型不对
            let view = clazz.__fw_reusableView(with: collectionView, kind: kind, indexPath: indexPath)
            let viewBlock = headerConfiguration ?? { (header, indexPath) in header.__fw_viewModel = nil }
            viewBlock(view, indexPath)
            return view
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            let viewClass = viewForFooter?(indexPath) ?? footerViewClass
            if let view = viewClass as? UICollectionReusableView { return view }
            guard let clazz = viewClass as? UICollectionReusableView.Type else { return UICollectionReusableView() }
            
            // 注意：此处必须使用.__fw_创建，否则返回的对象类型不对
            let view = clazz.__fw_reusableView(with: collectionView, kind: kind, indexPath: indexPath)
            let viewBlock = footerConfiguration ?? { (footer, indexPath) in footer.__fw_viewModel = nil }
            viewBlock(view, indexPath)
            return view
        }
        
        return UICollectionReusableView()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if let sizeBlock = sizeForHeader {
            return sizeBlock(section)
        }
        if let headerSize = headerSize {
            return headerSize
        }
        
        let indexPath = IndexPath(item: 0, section: section)
        let viewClass = viewForHeader?(indexPath) ?? headerViewClass
        if let view = viewClass as? UICollectionReusableView { return view.frame.size }
        guard let clazz = viewClass as? UICollectionReusableView.Type else { return .zero }
        
        let viewBlock = headerConfiguration ?? { (header, indexPath) in header.__fw_viewModel = nil }
        return collectionView.fw.size(reusableViewClass: clazz, kind: UICollectionView.elementKindSectionHeader, cacheBy: section) { (reusableView) in
            viewBlock(reusableView, indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let sizeBlock = sizeForFooter {
            return sizeBlock(section)
        }
        if let footerSize = footerSize {
            return footerSize
        }
        
        let indexPath = IndexPath(item: 0, section: section)
        let viewClass = viewForFooter?(indexPath) ?? footerViewClass
        if let view = viewClass as? UICollectionReusableView { return view.frame.size }
        guard let clazz = viewClass as? UICollectionReusableView.Type else { return .zero }
        
        let viewBlock = footerConfiguration ?? { (footer, indexPath) in footer.__fw_viewModel = nil }
        return collectionView.fw.size(reusableViewClass: clazz, kind: UICollectionView.elementKindSectionFooter, cacheBy: section) { (reusableView) in
            viewBlock(reusableView, indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(indexPath)
    }
}

extension Wrapper where Base: UICollectionView {
    public var delegate: CollectionViewDelegate {
        if let result = base.fw.property(forName: "fwDelegate") as? CollectionViewDelegate {
            return result
        } else {
            let result = CollectionViewDelegate()
            base.fw.setProperty(result, forName: "fwDelegate")
            base.dataSource = result
            base.delegate = result
            return result
        }
    }
    
    public static func collectionView() -> Base {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        return collectionView(flowLayout)
    }
    
    public static func collectionView(_ collectionViewLayout: UICollectionViewLayout) -> Base {
        let collectionView = Base(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }
}

@objc extension UICollectionView {
    @objc(fw_delegate)
    public var __fw_delegate: CollectionViewDelegate {
        return fw.delegate
    }
    
    @objc(fw_collectionView)
    public static func __fw_collectionView() -> UICollectionView {
        return fw.collectionView()
    }
    
    @objc(fw_collectionView:)
    public static func __fw_collectionView(_ collectionViewLayout: UICollectionViewLayout) -> UICollectionView {
        return fw.collectionView(collectionViewLayout)
    }
}

extension Wrapper where Base: UICollectionView {
    
    /// reloadData完成回调
    public func reloadData(completion: (() -> Void)?) {
        base.__fw_reloadData(completion: completion)
    }

    /// reloadData清空尺寸缓存
    public func reloadDataWithoutCache() {
        base.__fw_reloadDataWithoutCache()
    }

    /// reloadData禁用动画
    public func reloadDataWithoutAnimation() {
        base.__fw_reloadDataWithoutAnimation()
    }

    /// reloadSections禁用动画
    public func reloadSectionsWithoutAnimation(_ sections: IndexSet) {
        base.__fw_reloadSectionsWithoutAnimation(sections)
    }

    /// reloadItems禁用动画
    public func reloadItemsWithoutAnimation(_ indexPaths: [IndexPath]) {
        base.__fw_reloadItemsWithoutAnimation(indexPaths)
    }

    /// 刷新高度等，不触发reload方式
    public func performUpdates(_ updates: (() -> Void)?) {
        base.__fw_performUpdates(updates)
    }
    
}

/// iOS9+可通过UICollectionViewFlowLayout调用sectionHeadersPinToVisibleBounds实现Header悬停效果
extension Wrapper where Base: UICollectionViewFlowLayout {
    
    /// 设置Header和Footer是否悬停，支持iOS9+
    public func hover(header: Bool, footer: Bool) {
        base.__fw_hover(withHeader: header, footer: footer)
    }
    
}
