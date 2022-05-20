//
//  UIApplication+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/4/29.
//

import UIKit
import Vision
import FWFramework
import AudioToolbox

// MARK: - OcrObject
/// OCR扫描结果对象
@objc(FWOcrObject)
@objcMembers public class OcrObject: NSObject {
    
    /// 识别文本
    public var text: String = ""
    /// 可信度，0到1
    public var confidence: Float = 0
    /// 图片大小
    public var imageSize: CGSize = .zero
    /// 识别区域
    public var rect: CGRect = .zero
    
}

// MARK: - UIApplication+Toolkit
extension Wrapper where Base: UIApplication {
    
    // MARK: - OcrObject
    /// 识别图片文字，可设置语言(zh-CN,en-US)等，完成时主线程回调结果
    @available(iOS 13.0, *)
    public static func recognizeText(in image: CGImage, configuration: ((VNRecognizeTextRequest) -> Void)?, completion: @escaping ([OcrObject]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            UIApplication.fw.performOcr(image: image, configuration: configuration) { results in
                DispatchQueue.main.async {
                    completion(results)
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    private static func performOcr(image: CGImage, configuration: ((VNRecognizeTextRequest) -> Void)?, completion: @escaping ([OcrObject]) -> Void) {
        let textRequest = VNRecognizeTextRequest() { request, error in
            let imageSize = CGSize(width: image.width, height: image.height)
            guard let results = request.results as? [VNRecognizedTextObservation], !results.isEmpty else {
                completion([])
                return
            }
            
            let outputObjects: [OcrObject] = results.compactMap { result in
                guard let candidate = result.topCandidates(1).first,
                      let box = try? candidate.boundingBox(for: candidate.string.startIndex..<candidate.string.endIndex) else {
                    return nil
                }
                
                let unwrappedBox: VNRectangleObservation = box
                let boxRect = UIApplication.fw.convertToImageRect(boundingBox: unwrappedBox, imageSize: imageSize)
                let confidence: Float = candidate.confidence
                
                let ocrObject = OcrObject()
                ocrObject.text = candidate.string
                ocrObject.confidence = confidence
                ocrObject.rect = boxRect
                ocrObject.imageSize = imageSize
                return ocrObject
            }
            completion(outputObjects)
        }
       
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = false
        configuration?(textRequest)
       
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([textRequest])
        } catch {
            completion([])
        }
    }
    
    @available(iOS 13.0, *)
    private static func convertToImageRect(boundingBox: VNRectangleObservation, imageSize: CGSize) -> CGRect {
        let topLeft = VNImagePointForNormalizedPoint(boundingBox.topLeft,
                                                     Int(imageSize.width),
                                                     Int(imageSize.height))
        let bottomRight = VNImagePointForNormalizedPoint(boundingBox.bottomRight,
                                                         Int(imageSize.width),
                                                         Int(imageSize.height))
        return CGRect(x: topLeft.x, y: imageSize.height - topLeft.y,
                      width: abs(bottomRight.x - topLeft.x),
                      height: abs(topLeft.y - bottomRight.y))
    }
    
    // MARK: - App
    /// 读取应用信息字典
    public static func appInfo(_ key: String) -> Any? {
        return Base.__fw.appInfo(key)
    }

    /// 读取应用名称
    public static var appName: String {
        return Base.__fw.appName
    }

    /// 读取应用显示名称，未配置时读取名称
    public static var appDisplayName: String {
        return Base.__fw.appDisplayName
    }

    /// 读取应用主版本号，示例：1.0.0
    public static var appVersion: String {
        return Base.__fw.appVersion
    }

    /// 读取应用构建版本号，示例：1.0.0.1
    public static var appBuildVersion: String {
        return Base.__fw.appBuildVersion
    }

    /// 读取应用标识
    public static var appIdentifier: String {
        return Base.__fw.appIdentifier
    }

    // MARK: - Debug
    /// 是否是盗版(不是从AppStore安装)
    public static var isPirated: Bool {
        return Base.__fw.isPirated
    }
    
    /// 是否是Testflight版本
    public static var isTestflight: Bool {
        return Base.__fw.isTestflight
    }
    
    // MARK: - URL
    /// 播放内置声音文件
    @discardableResult
    public static func playAlert(_ file: String) -> SystemSoundID {
        return Base.__fw.playAlert(file)
    }

    /// 停止播放内置声音文件
    public static func stopAlert(_ soundId: SystemSoundID) {
        return Base.__fw.stopAlert(soundId)
    }

    /// 播放内置震动
    public static func playVibrate() {
        return Base.__fw.playVibrate()
    }

    /// 语音朗读文字，可指定语言(如zh-CN)
    public static func readText(_ text: String, language: String?) {
        return Base.__fw.readText(text, withLanguage: language)
    }
    
}

// MARK: - FWApplicationClassWrapper+OcrObject
@objc extension __FWApplicationClassWrapper {
    
    /// 识别图片文字，可设置语言(zh-CN,en-US)等，完成时主线程回调结果
    @available(iOS 13.0, *)
    public func recognizeText(in image: CGImage, configuration: ((VNRecognizeTextRequest) -> Void)?, completion: @escaping ([OcrObject]) -> Void) {
        UIApplication.fw.recognizeText(in: image, configuration: configuration, completion: completion)
    }
    
}
