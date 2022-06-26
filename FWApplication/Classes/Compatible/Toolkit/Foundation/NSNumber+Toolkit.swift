//
//  NSNumber+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2019/6/28.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

import Foundation
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension FW {
    
    /// 确保值在固定范围之内
    ///
    /// - Parameters:
    ///   - min: 最小值
    ///   - value: 当前值
    ///   - max: 最大值
    /// - Returns: 范围之内的值
    public static func clamp<T: Comparable>(_ min: T, _ value: T, _ max: T) -> T {
        return value < min ? min : (value > max ? max : value)
    }
    
}

extension Wrapper where Base: NSNumber {
    
    /// 转换为CGFloat
    public var CGFloatValue: CGFloat {
        return base.__fw_CGFloatValue
    }

    /// 四舍五入，去掉末尾0，最多digit位，小数分隔符为.，分组分隔符为空，示例：12345.6789 => 12345.68
    public func roundString(_ digit: Int) -> String {
        return base.__fw_roundString(digit)
    }

    /// 取上整，去掉末尾0，最多digit位，小数分隔符为.，分组分隔符为空，示例：12345.6789 => 12345.68
    public func ceilString(_ digit: Int) -> String {
        return base.__fw_ceilString(digit)
    }

    /// 取下整，去掉末尾0，最多digit位，小数分隔符为.，分组分隔符为空，示例：12345.6789 => 12345.67
    public func floorString(_ digit: Int) -> String {
        return base.__fw_floorString(digit)
    }

    /// 四舍五入，去掉末尾0，最多digit位，示例：12345.6789 => 12345.68
    public func roundNumber(_ digit: UInt) -> NSNumber {
        return base.__fw_roundNumber(digit)
    }

    /// 取上整，去掉末尾0，最多digit位，示例：12345.6789 => 12345.68
    public func ceilNumber(_ digit: UInt) -> NSNumber {
        return base.__fw_ceilNumber(digit)
    }

    /// 取下整，去掉末尾0，最多digit位，示例：12345.6789 => 12345.67
    public func floorNumber(_ digit: UInt) -> NSNumber {
        return base.__fw_floorNumber(digit)
    }
    
}
