//
//  ViewPreference.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/31.
//

#if canImport(SwiftUI)
import SwiftUI

/// 通用视图配置Key类
@available(iOS 13.0, *)
open class ViewPreferenceKey<T: Equatable>: PreferenceKey {
    public typealias Value = T?
    
    public static var defaultValue: Value {
        return nil
    }
    
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValue = nextValue() ?? value
        if value != newValue {
            value = newValue
        }
    }
}

@available(iOS 13.0, *)
private final class ViewSizePreferenceKey<T: View>: ViewPreferenceKey<CGSize> {}

@available(iOS 13.0, *)
extension View {
    
    /// 捕获当前视图大小
    public func captureSize(in binding: Binding<CGSize>) -> some View {
        overlay(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: ViewSizePreferenceKey<Self>.self,
                    value: proxy.size
                )
                .onAppear {
                    if binding.wrappedValue != proxy.size {
                        binding.wrappedValue = proxy.size
                    }
                }
            }
        )
        .onPreferenceChange(ViewSizePreferenceKey<Self>.self) { size in
            if let size = size, binding.wrappedValue != size {
                binding.wrappedValue = size
            }
        }
        .preference(key: ViewSizePreferenceKey<Self>.self, value: nil)
    }
    
}

#endif
