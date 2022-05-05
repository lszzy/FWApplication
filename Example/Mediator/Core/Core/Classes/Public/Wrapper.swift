//
//  Wrapper.swift
//  Core
//
//  Created by wuyong on 2022/4/20.
//

import FWFramework

extension FWWrapperCompatible {
    public static var app: FWWrapper<Self>.Type { fw }
    public var app: FWWrapper<Self> { fw }
}
