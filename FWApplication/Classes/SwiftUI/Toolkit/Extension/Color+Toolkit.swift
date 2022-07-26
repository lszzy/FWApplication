//
//  Color+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/26.
//

#if canImport(SwiftUI)
import SwiftUI
import FWFramework

@available(iOS 13.0, *)
extension Color: WrapperCompatible {}

@available(iOS 13.0, *)
extension Wrapper where Base == Color {
    
    /// 从16进制创建Color
    /// - Parameters:
    ///   - hex: 十六进制值，格式0xFFFFFF
    ///   - alpha: 透明度可选，默认1
    /// - Returns: Color
    public static func color(_ hex: Int, _ alpha: Double = 1) -> Color {
        return Color(red: Double((hex & 0xFF0000) >> 16) / 255.0, green: Double((hex & 0xFF00) >> 8) / 255.0, blue: Double(hex & 0xFF) / 255.0, opacity: alpha)
    }
    
    /// 从RGB创建Color
    /// - Parameters:
    ///   - red: 红色值
    ///   - green: 绿色值
    ///   - blue: 蓝色值
    ///   - alpha: 透明度可选，默认1
    /// - Returns: Color
    public static func color(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double = 1) -> Color {
        return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, opacity: alpha)
    }
    
    /// 从十六进制字符串初始化，支持RGB、RGBA|ARGB，格式："20B2AA", "#FFFFFF"，失败时返回clear
    /// - Parameters:
    ///   - hexString: 十六进制字符串
    ///   - alpha: 透明度可选，默认1
    /// - Returns: Color
    public static func color(_ hexString: String, _ alpha: Double = 1) -> Color {
        return Color(UIColor.fw.color(hexString: hexString, alpha: alpha))
    }
    
}

#endif
