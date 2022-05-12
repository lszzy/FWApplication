//
//  Wrapper.swift
//  Core
//
//  Created by wuyong on 2022/4/20.
//

import FWFramework

public typealias APP = FW

extension WrapperCompatible {
    public static var app: Wrapper<Self>.Type { fw }
    public var app: Wrapper<Self> { fw }
}
