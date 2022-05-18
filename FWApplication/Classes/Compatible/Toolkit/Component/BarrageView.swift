//
//  BarrageView.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/18.
//

import UIKit

extension Wrapper where Base: CALayer {
    
    public func convertContentToImage(size: CGSize) -> UIImage? {
        return base.__fw.convertContentToImage(with: size)
    }
    
}
