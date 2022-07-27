//
//  View+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/07/26.
//  Copyright © 2022 wuyong.site. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI

// MARK: - LineShape
/// 线条形状，用于分割线、虚线等。自定义路径形状：Path { (path) in ... }
@available(iOS 13.0, *)
public struct LineShape: Shape {
    public var axes: Axis.Set = .horizontal
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        if axes == .horizontal {
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        } else {
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        return path
    }
}

// MARK: - RoundedCornerShape
/// 不规则圆角形状
@available(iOS 13.0, *)
public struct RoundedCornerShape: Shape {
    public var radius: CGFloat = 0
    public var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - View+Toolkit
@available(iOS 13.0, *)
extension View {
    
    /// 设置不规则圆角效果
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
    
    /// 转换为AnyView
    public func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
}

#endif
