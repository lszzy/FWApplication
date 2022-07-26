//
//  ImageWrapper.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/26.
//

#if canImport(SwiftUI)
import SwiftUI
import FWFramework
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/// SwiftUI动图、网络图片包装器
@available(iOS 13.0, *)
public struct ImageWrapper: UIViewRepresentable {
    
    var url: Any?
    var placeholder: UIImage?
    var contentMode: UIView.ContentMode = .scaleAspectFill
    
    /// 指定本地占位图片初始化
    public init(_ placeholder: UIImage? = nil) {
        self.placeholder = placeholder
    }
    
    /// 指定网络图片URL初始化
    public init(url: Any?) {
        self.url = url
    }
    
    /// 设置网络图片URL
    public func url(_ url: Any?) -> ImageWrapper {
        var result = self
        result.url = url
        return result
    }
    
    /// 设置本地占位图片
    public func placeholder(_ placeholder: UIImage?) -> ImageWrapper {
        var result = self
        result.placeholder = placeholder
        return result
    }
    
    /// 设置图片显示内容模式，默认scaleAspectFill
    public func contentMode(_ contentMode: UIView.ContentMode) -> ImageWrapper {
        var result = self
        result.contentMode = contentMode
        return result
    }
    
    // MARK: - UIViewRepresentable
    
    public typealias UIViewType = UIImageView
    
    public func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView.fw.animatedImageView()
        imageView.contentMode = contentMode
        imageView.fw.setImage(url: url, placeholderImage: placeholder)
        return imageView
    }
    
    public func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.contentMode = contentMode
    }
    
    public static func dismantleUIView(_ imageView: UIImageView, coordinator: ()) {
        imageView.fw.cancelImageRequest()
    }
}

#endif
