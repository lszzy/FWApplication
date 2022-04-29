//
//  UIApplication+FWApplication.swift
//  FWApplication
//
//  Created by wuyong on 2022/4/29.
//

import UIKit
import Vision
import FWFramework

/// OCR扫描结果对象
@objcMembers public class FWOcrObject: NSObject {
    
    /// 识别文本
    public var text: String = ""
    /// 可信度，0到1
    public var confidence: Float = 0
    /// 图片大小
    public var imageSize: CGSize = .zero
    /// 识别区域
    public var rect: CGRect = .zero
    
}

@objc extension FWApplicationClassWrapper {
    
    /// 识别图片文字，完成时主线程回调结果
    @available(iOS 13.0, *)
    public func recognizeText(in image: CGImage, completion: @escaping ([FWOcrObject]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            UIApplication.fw.performOcr(image: image) { results in
                DispatchQueue.main.async {
                    completion(results)
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    private func performOcr(image: CGImage, completion: @escaping ([FWOcrObject]) -> Void) {
        let textRequest = VNRecognizeTextRequest() { request, error in
            let imageSize = CGSize(width: image.width, height: image.height)
            guard let results = request.results as? [VNRecognizedTextObservation], !results.isEmpty else {
                completion([])
                return
            }
            
            let outputObjects: [FWOcrObject] = results.compactMap { result in
                guard let candidate = result.topCandidates(1).first,
                      let box = try? candidate.boundingBox(for: candidate.string.startIndex..<candidate.string.endIndex) else {
                    return nil
                }
                
                let unwrappedBox: VNRectangleObservation = box
                let boxRect = UIApplication.fw.convertToImageRect(boundingBox: unwrappedBox, imageSize: imageSize)
                let confidence: Float = candidate.confidence
                
                let ocrObject = FWOcrObject()
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
       
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([textRequest])
        } catch {
            completion([])
        }
    }
    
    @available(iOS 13.0, *)
    private func convertToImageRect(boundingBox: VNRectangleObservation, imageSize: CGSize) -> CGRect {
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
    
}
