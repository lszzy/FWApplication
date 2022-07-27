//
//  ImageView.swift
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
import FWApplicationCompatible
#endif

/// 图片视图，支持网络图片和动图
@available(iOS 13.0, *)
public struct ImageView: UIViewRepresentable {
    
    var url: Any?
    var placeholder: UIImage?
    var options: WebImageOptions = []
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
    public func url(_ url: Any?) -> ImageView {
        var result = self
        result.url = url
        return result
    }
    
    /// 设置网络图片加载选项
    public func options(_ options: WebImageOptions) -> ImageView {
        var result = self
        result.options = options
        return result
    }
    
    /// 设置本地占位图片
    public func placeholder(_ placeholder: UIImage?) -> ImageView {
        var result = self
        result.placeholder = placeholder
        return result
    }
    
    /// 设置图片显示内容模式，默认scaleAspectFill
    public func contentMode(_ contentMode: UIView.ContentMode) -> ImageView {
        var result = self
        result.contentMode = contentMode
        return result
    }
    
    // MARK: - UIViewRepresentable
    public typealias UIViewType = ImageViewWrapper
    
    public func makeUIView(context: Context) -> ImageViewWrapper {
        let imageView = ImageViewWrapper()
        imageView.wrapped.contentMode = contentMode
        imageView.wrapped.fw.setImage(url: url, placeholderImage: placeholder, options: options, context: nil, completion: nil)
        return imageView
    }
    
    public func updateUIView(_ imageView: ImageViewWrapper, context: Context) {
        imageView.wrapped.contentMode = contentMode
    }
    
    public static func dismantleUIView(_ imageView: ImageViewWrapper, coordinator: ()) {
        imageView.wrapped.fw.cancelImageRequest()
    }
    
}

/// 图片视图包装器，解决frame尺寸变为图片尺寸问题
@available(iOS 13.0, *)
public class ImageViewWrapper : UIView {
    
    var wrapped = UIImageView.fw.animatedImageView()
    var resizable = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(wrapped)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(wrapped)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        wrapped.frame = self.bounds
    }
    
    public override var intrinsicContentSize: CGSize {
        if resizable {
            return super.intrinsicContentSize
        } else {
            return wrapped.intrinsicContentSize
        }
    }
    
}

#endif
