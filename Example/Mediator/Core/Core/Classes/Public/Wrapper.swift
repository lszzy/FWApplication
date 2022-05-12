//
//  Wrapper.swift
//  Core
//
//  Created by wuyong on 2022/4/20.
//

import FWFramework

public typealias APP = FWWrapper

extension FWWrapperExtended {
    public static var app: FWWrapperExtension<Self>.Type { fw }
    public var app: FWWrapperExtension<Self> { fw }
}
