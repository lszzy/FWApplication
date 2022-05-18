//
//  CollectionView.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/18.
//

import UIKit

extension Wrapper where Base: UICollectionViewFlowLayout {
    
    /// 初始化布局section配置，在prepareLayout调用即可
    public func sectionConfigPrepareLayout() {
        base.__fw.sectionConfigPrepareLayout()
    }

    /// 获取布局section属性，在layoutAttributesForElementsInRect:调用并添加即可
    public func sectionConfigLayoutAttributes(forElementsIn rect: CGRect) -> [UICollectionViewLayoutAttributes] {
        return base.__fw.sectionConfigLayoutAttributesForElements(in: rect)
    }
    
}
