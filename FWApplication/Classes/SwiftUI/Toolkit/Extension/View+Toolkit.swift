//
//  View+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/07/26.
//  Copyright © 2022 wuyong.site. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#if FWMacroSPM
import FWApplication
import FWApplicationCompatible
#endif

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

// MARK: - RemovableModifier
/// 视图移除性修改器
@available(iOS 13.0, *)
public struct RemovableModifier: ViewModifier {
    public let removable: Bool
    
    public init(removable: Bool) {
        self.removable = removable
    }
    
    public func body(content: Content) -> some View {
        if !removable {
            content
        }
    }
}

// MARK: - View+Toolkit
@available(iOS 13.0, *)
extension View {
    
    /// 设置不规则圆角效果
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
    
    /// 同时设置边框和圆角
    public func border<S: ShapeStyle>(_ content: S, width lineWidth: CGFloat = 1, cornerRadius: CGFloat) -> some View {
        self.cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .circular)
                    .stroke(content, lineWidth: lineWidth)
            )
            .padding(lineWidth / 2)
    }
    
    /// 切换视图移除性
    public func removable(_ removable: Bool) -> some View {
        modifier(RemovableModifier(removable: removable))
    }
    
    /// 切换视图隐藏性
    public func hidden(_ isHidden: Bool) -> some View {
        Group {
            if isHidden {
                hidden()
            } else {
                self
            }
        }
    }
    
    /// 切换视图可见性
    public func visible(_ isVisible: Bool = true) -> some View {
        opacity(isVisible ? 1 : 0)
    }
    
    /// 动态切换裁剪性
    public func clipped(_ value: Bool) -> some View {
        if value {
            return AnyView(self.clipped())
        } else {
            return AnyView(self)
        }
    }
    
    /// 配置当前对象
    public func configure(_ body: (inout Self) -> Void) -> Self {
        var result = self
        body(&result)
        return result
    }
    
    /// 转换为AnyView
    public func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
    
    // MARK: - NavigationBar
    /// 快捷应用导航栏配置
    public func navigationBarAppearance(_ block: @escaping () -> NavigationBarAppearance) -> some View {
        return introspectNavigationBar { navigationBar in
            navigationBar.fw.applyBarAppearance(block())
        }
    }
    
    /// 快捷应用导航栏样式
    public func navigationBarStyle(_ style: NavigationBarStyle) -> some View {
        return introspectNavigationBar { navigationBar in
            navigationBar.fw.applyBarStyle(style)
        }
    }
    
    /// 快捷设置导航栏左侧按钮，默认返回
    public func navigationBarButton<T: View>(@ViewBuilder leading: () -> T, action: (() -> Void)? = nil) -> some View {
        self.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                if let action = action {
                    action()
                } else {
                    UIWindow.fw.close()
                }
            }, label: {
                HStack {
                    Spacer()
                    leading()
                    Spacer()
                }
            }))
    }
    
    /// 快捷设置导航栏右侧按钮
    public func navigationBarButton<T: View>(@ViewBuilder trailing: () -> T, action: @escaping () -> Void) -> some View {
        self.navigationBarItems(trailing: Button(action: action, label: {
                HStack {
                    Spacer()
                    trailing()
                    Spacer()
                }
            }))
    }
    
}

#endif
