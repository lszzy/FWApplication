//
//  URL+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/// 第三方URL生成器，可先判断canOpenURL，再openURL，需添加对应URL SCHEME到LSApplicationQueriesSchemes配置数组
extension Wrapper where Base == URL {
    
    // MARK: - Map

    /**
     生成苹果地图地址外部URL
     
     @param addr 显示地址，格式latitude,longitude或搜索地址
     @param options 可选附加参数，如@{@"ll": @"latitude,longitude", @"z": @"14"}
     @return NSURL
     */
    public static func appleMapsURL(withAddr addr: String?, options: [AnyHashable : Any]? = nil) -> URL? {
        return NSURL.__fw.appleMapsURL(withAddr: addr, options: options)
    }

    /**
     生成苹果地图导航外部URL
     
     @param saddr 导航起始点，格式latitude,longitude或搜索地址
     @param daddr 导航结束点，格式latitude,longitude或搜索地址
     @param options 可选附加参数，如@{@"ll": @"latitude,longitude", @"z": @"14"}
     @return NSURL
     */
    public static func appleMapsURL(withSaddr saddr: String?, daddr: String?, options: [AnyHashable : Any]? = nil) -> URL? {
        return NSURL.__fw.appleMapsURL(withSaddr: saddr, daddr: daddr, options: options)
    }

    /**
     生成谷歌地图外部URL，URL SCHEME为：comgooglemaps
     
     @param addr 显示地址，格式latitude,longitude或搜索地址
     @param options 可选附加参数，如@{@"center": @"latitude,longitude", @"zoom": @"14"}
     @return NSURL
     */
    public static func googleMapsURL(withAddr addr: String?, options: [AnyHashable : Any]? = nil) -> URL? {
        return NSURL.__fw.googleMapsURL(withAddr: addr, options: options)
    }

    /**
     生成谷歌地图导航外部URL，URL SCHEME为：comgooglemaps
     
     @param saddr 导航起始点，格式latitude,longitude或搜索地址
     @param daddr 导航结束点，格式latitude,longitude或搜索地址
     @param mode 导航模式，支持driving|transit|bicycling|walking，默认driving
     @param options 可选附加参数，如@{@"center": @"latitude,longitude", @"zoom": @"14", @"dirflg": @"t,h"}
     @return NSURL
     */
    public static func googleMapsURL(withSaddr saddr: String?, daddr: String?, mode: String?, options: [AnyHashable : Any]? = nil) -> URL? {
        return NSURL.__fw.googleMapsURL(withSaddr: saddr, daddr: daddr, mode: mode, options: options)
    }

    /**
     生成百度地图外部URL，URL SCHEME为：baidumap
     
     @param addr 显示地址，格式latitude,longitude或搜索地址
     @param options 可选附加参数，如@{@"src": @"app", @"zoom": @"14", @"coord_type": @"默认gcj02|wgs84|bd09ll"}
     @return NSURL
     */
    public static func baiduMapsURL(withAddr addr: String?, options: [AnyHashable : Any]? = nil) -> URL? {
        return NSURL.__fw.baiduMapsURL(withAddr: addr, options: options)
    }

    /**
     生成百度地图导航外部URL，URL SCHEME为：baidumap
     
     @param saddr 导航起始点，格式latitude,longitude或搜索地址
     @param daddr 导航结束点，格式latitude,longitude或搜索地址
     @param mode 导航模式，支持driving|transit|navigation|riding|walking，默认driving
     @param options 可选附加参数，如@{@"src": @"app", @"zoom": @"14", @"coord_type": @"默认gcj02|wgs84|bd09ll"}
     @return NSURL
     */
    public static func baiduMapsURL(withSaddr saddr: String?, daddr: String?, mode: String?, options: [AnyHashable : Any]? = nil) -> URL? {
        return NSURL.__fw.baiduMapsURL(withSaddr: saddr, daddr: daddr, mode: mode, options: options)
    }
    
}

extension Wrapper where Base == URLRequest {
    
    /// 生成对应curl命令，方便调试和测试
    public func curlCommand() -> String {
        return (base as NSURLRequest).__fw.curlCommand()
    }
    
}
