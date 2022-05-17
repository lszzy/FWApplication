//
//  ImagePlugin.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/17.
//

import UIKit

extension FW {
    /// 根据名称加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)
    public static func image(_ named: String, bundle: Bundle? = nil) -> UIImage? {
        return UIImage.__fw.imageNamed(named, bundle: bundle)
    }
}

extension Wrapper where Base: UIImage {
    
    /// 根据名称从指定bundle加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)
    public static func imageNamed(_ name: String, bundle: Bundle? = nil) -> UIImage? {
        return Base.__fw.imageNamed(name, bundle: bundle)
    }

    /// 根据名称从指定bundle加载UIImage，优先加载图片文件(无缓存)，文件不存在时尝试系统imageNamed方式(有缓存)。支持设置图片解码选项
    public static func imageNamed(_ name: String, bundle: Bundle?, options: [ImageCoderOptions: Any]?) -> UIImage? {
        return Base.__fw.imageNamed(name, bundle: bundle, options: options)
    }

    /// 从图片文件路径解码创建UIImage，自动识别scale，支持动图
    public static func image(contentsOfFile: String) -> UIImage? {
        return Base.__fw.image(withContentsOfFile: contentsOfFile)
    }

    /// 从图片数据解码创建UIImage，默认scale为1，支持动图
    public static func image(data: Data?, scale: CGFloat = 1) -> UIImage? {
        return Base.__fw.image(with: data, scale: scale)
    }

    /// 从图片数据解码创建UIImage，指定scale，支持动图。支持设置图片解码选项
    public static func image(data: Data?, scale: CGFloat, options: [ImageCoderOptions: Any]?) -> UIImage? {
        return Base.__fw.image(with: data, scale: scale, options: options)
    }

    /// 从UIImage编码创建图片数据，支持动图。支持设置图片编码选项
    public static func data(image: UIImage?, options: [ImageCoderOptions: Any]? = nil) -> Data? {
        return Base.__fw.data(with: image, options: options)
    }

    /// 下载网络图片并返回下载凭据
    @discardableResult
    public static func downloadImage(_ url: Any?, completion: @escaping (UIImage?, Error?) -> Void, progress: ((Double) -> Void)?) -> Any? {
        return Base.__fw.downloadImage(url, completion: completion, progress: progress)
    }

    /// 下载网络图片并返回下载凭据，指定option
    @discardableResult
    public static func downloadImage(_ url: Any?, options: WebImageOptions, context: [ImageCoderOptions: Any]?, completion: @escaping (UIImage?, Error?) -> Void, progress: ((Double) -> Void)?) -> Any? {
        return Base.__fw.downloadImage(url, options: options, context: context, completion: completion, progress: progress)
    }

    /// 指定下载凭据取消网络图片下载
    public static func cancelImageDownload(_ receipt: Any?) {
        Base.__fw.cancelImageDownload(receipt)
    }
    
}

extension Wrapper where Base: UIImageView {
    
    /// 自定义图片插件，未设置时自动从插件池加载
    public var imagePlugin: ImagePlugin? {
        get { return base.__fw.imagePlugin }
        set { base.__fw.imagePlugin = newValue }
    }

    /// 当前正在加载的网络图片URL
    public var imageURL: URL? {
        return base.__fw.imageURL
    }

    /// 加载网络图片，支持占位，优先加载插件，默认使用框架网络库
    public func setImage(url: Any?, placeholderImage: UIImage? = nil) {
        base.__fw.setImageWithURL(url, placeholderImage: placeholderImage)
    }

    /// 加载网络图片，支持占位和回调，优先加载插件，默认使用框架网络库
    public func setImage(url: Any?, placeholderImage: UIImage?, completion: ((UIImage?, Error?) -> Void)?) {
        base.__fw.setImageWithURL(url, placeholderImage: placeholderImage, completion: completion)
    }

    /// 加载网络图片，支持占位、选项、回调和进度，优先加载插件，默认使用框架网络库
    public func setImage(url: Any?, placeholderImage: UIImage?, options: WebImageOptions, context: [ImageCoderOptions: Any]?, completion: ((UIImage?, Error?) -> Void)?, progress: ((Double) -> Void)? = nil) {
        base.__fw.setImageWithURL(url, placeholderImage: placeholderImage, options: options, context: context, completion: completion, progress: progress)
    }

    /// 取消加载网络图片请求
    public func cancelImageRequest() {
        base.__fw.cancelImageRequest()
    }
    
    /// 动画ImageView视图类，优先加载插件，默认UIImageView
    public static var imageViewAnimatedClass: AnyClass {
        get { return Base.__fw.imageViewAnimatedClass }
        set { Base.__fw.imageViewAnimatedClass = newValue }
    }
    
}
