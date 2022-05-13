//
//  AppConfig.swift
//  Example
//
//  Created by wuyong on 2021/1/17.
//  Copyright © 2021 site.wuyong. All rights reserved.
//

@_exported import FWApplication
@_exported import Core
@_exported import Mediator

class AppConfig: NSObject {
    @UserDefaultAnnotation("isRootNavigation", defaultValue: false)
    static var isRootNavigation: Bool
    
    @UserDefaultAnnotation("isRootCustom", defaultValue: false)
    static var isRootCustom: Bool
    
    @UserDefaultAnnotation("isRootLogin", defaultValue: false)
    static var isRootLogin: Bool
}
