//
//  WebImageView.swift
//  FWApplication
//
//  Created by wuyong on 2022/7/26.
//

#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
import Combine

/// 网络图片视图，仅支持静态图
@available(iOS 13.0, *)
public struct WebImageView: View {
    @ObservedObject public private(set) var binder: ImageBinder
    
    var placeholder: AnyView?
    var cancelOnDisappear: Bool = false
    var configurations: [(Image) -> Image]
    
    public init(_ url: Any?, isLoaded: Binding<Bool> = .constant(false)) {
        binder = ImageBinder(url: url, isLoaded: isLoaded)
        configurations = []
        binder.start()
    }
    
    public var body: some View {
        Group {
            if let uiImage = binder.image {
                configurations.reduce(Image(uiImage: uiImage)) { current, config in
                    config(current)
                }
            } else {
                Group {
                    if let placeholder = placeholder {
                        placeholder
                    } else {
                        Image(uiImage: .init())
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onDisappear { [weak binder = self.binder] in
                    if self.cancelOnDisappear {
                        binder?.cancel()
                    }
                }
            }
        }
        .onAppear { [weak binder] in
            guard let binder = binder else { return }
            if !binder.loadingSucceed {
                binder.start()
            }
        }
    }
    
    public func placeholder<Content: View>(@ViewBuilder _ builder: () -> Content) -> Self {
        var result = self
        result.placeholder = AnyView(builder())
        return result
    }
    
    public func cancelOnDisappear(_ flag: Bool) -> Self {
        var result = self
        result.cancelOnDisappear = flag
        return result
    }
    
    public func configure(_ block: @escaping (Image) -> Image) -> Self {
        var result = self
        result.configurations.append(block)
        return result
    }
    
    public func resizable(capInsets: EdgeInsets = EdgeInsets(), resizingMode: Image.ResizingMode = .stretch) -> Self {
        configure { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
    }
    
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode?) -> Self {
        configure { $0.renderingMode(renderingMode) }
    }
    
    public func interpolation(_ interpolation: Image.Interpolation) -> Self {
        configure { $0.interpolation(interpolation) }
    }
    
    public func antialiased(_ isAntialiased: Bool) -> Self {
        configure { $0.antialiased(isAntialiased) }
    }
    
    public func onCompletion(perform action: ((UIImage?, Error?) -> Void)?) -> Self {
        binder.onCompletion(perform: action)
        return self
    }
    
    public func onProgress(perform action: ((Double) -> Void)?) -> Self {
        binder.onProgress(perform: action)
        return self
    }
}

@available(iOS 13.0, *)
extension WebImageView {
    public class ImageBinder: ObservableObject {
        @Published var image: UIImage?
        
        let url: Any?
        var isLoaded: Binding<Bool>
        var loadingSucceed: Bool = false
        var receipt: Any?
        var completionBlock: ((UIImage?, Error?) -> Void)?
        var progressBlock: ((Double) -> Void)?
        
        init(url: Any?, isLoaded: Binding<Bool>) {
            self.url = url
            self.isLoaded = isLoaded
            self.image = nil
        }
        
        func start() {
            guard !loadingSucceed else { return }
            
            loadingSucceed = true
            receipt = UIImage.fw.downloadImage(url, completion: { [weak self] (image, error) in
                guard let self = self else { return }
                
                if let image = image {
                    self.image = image
                    self.isLoaded.wrappedValue = true
                    self.completionBlock?(image, error)
                } else {
                    self.loadingSucceed = false
                    self.completionBlock?(image, error)
                }
            }, progress: { [weak self] (progress) in
                self?.progressBlock?(progress)
            })
        }
        
        public func cancel() {
            UIImage.fw.cancelImageDownload(receipt)
        }
        
        func onCompletion(perform action: ((UIImage?, Error?) -> Void)?) {
            completionBlock = action
        }
        
        func onProgress(perform action: ((Double) -> Void)?) {
            progressBlock = action
        }
    }
}

#endif
