//
//  NSFileManager+FWApplication.swift
//  FWApplication
//
//  Created by wuyong on 2019/6/28.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

import Foundation

extension FWWrapper {
    /// 搜索路径
    ///
    /// - Parameter directory: 搜索目录
    /// - Returns: 目标路径
    public static func pathSearch(_ directory: FileManager.SearchPathDirectory) -> String {
        return NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)[0]
    }

    /// 沙盒路径，常量
    public static var pathHome: String {
        return NSHomeDirectory()
    }

    /// 文档路径，iTunes会同步备份
    public static var pathDocument: String {
        return pathSearch(.documentDirectory)
    }

    /// 缓存路径，系统不会删除，iTunes会删除
    public static var pathCaches: String {
        return pathSearch(.cachesDirectory)
    }

    /// Library路径
    public static var pathLibrary: String {
        return pathSearch(.libraryDirectory)
    }

    /// 配置路径，配置文件保存位置
    public static var pathPreference: String {
        return (pathLibrary as NSString).appendingPathComponent("Preference")
    }

    /// 临时路径，App退出后可能会删除
    public static var pathTmp: String {
        return NSTemporaryDirectory()
    }

    /// bundle路径，不可写
    public static var pathBundle: String {
        return Bundle.main.bundlePath
    }

    /// 资源路径，不可写
    public static var pathResource: String {
        return Bundle.main.resourcePath ?? ""
    }
}
