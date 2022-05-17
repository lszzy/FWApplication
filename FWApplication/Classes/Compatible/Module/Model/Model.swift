//
//  Model.swift
//  FWApplication
//
//  Created by wuyong on 2020/6/5.
//  Copyright © 2020 wuyong.site. All rights reserved.
//

import UIKit

extension Wrapper where Base: NSObject {
    
    /// 从json创建对象，线程安全。NSDate会按照UTC时间解析，下同
    /// - Parameter json: json对象，支持NSDictionary、NSString、NSData
    /// - Returns: 实例对象，失败为nil
    public static func model(json: Any) -> Base? {
        return Base.__fw.model(withJson: json) as? Base
    }

    /// 从字典创建对象，线程安全
    /// - Parameter dictionary: 字典数据
    /// - Returns: 实例对象，失败为nil
    public static func model(dictionary: [AnyHashable: Any]) -> Base? {
        return Base.__fw.model(with: dictionary) as? Base
    }

    /// 从json创建Model数组
    /// - Parameter json: json对象，支持NSDictionary、NSString、NSData
    /// - Returns: Model数组
    public static func modelArray(json: Any) -> [Base]? {
        return Base.__fw.modelArray(withJson: json) as? [Base]
    }

    /// 从json创建Model字典
    /// - Parameter json: json对象，支持NSDictionary、NSString、NSData
    /// - Returns: Model字典
    public static func modelDictionary(json: Any) -> [String: Base]? {
        return Base.__fw.modelDictionary(withJson: json) as? [String: Base]
    }
    
    /// 从json对象设置对象属性
    /// - Parameter json: json对象，支持NSDictionary、NSString、NSData
    /// - Returns: 是否设置成功
    @discardableResult
    public func modelSet(json: Any) -> Bool {
        return base.__fw.modelSet(withJson: json)
    }

    /// 从字典设置对象属性
    /// - Parameter dictionary: 字典数据
    /// - Returns: 是否设置成功
    @discardableResult
    public func modelSet(dictionary: [AnyHashable: Any]) -> Bool {
        return base.__fw.modelSet(with: dictionary)
    }

    /// 转换为json对象
    /// - Returns: json对象，如NSDictionary、NSArray，失败为nil
    public func modelToJsonObject() -> Any? {
        return base.__fw.modelToJsonObject()
    }

    /// 转换为json字符串数据
    /// - Returns: NSData，失败为nil
    public func modelToJsonData() -> Data? {
        return base.__fw.modelToJsonData()
    }

    /// 转换为json字符串
    /// - Returns: NSString，失败为nil
    public func modelToJsonString() -> String? {
        return base.__fw.modelToJsonString()
    }

    /// 从属性拷贝当前对象
    /// - Returns: 拷贝对象，失败为nil
    public func modelCopy() -> Any? {
        return base.__fw.modelCopy()
    }

    /// 对象编码
    public func modelEncode(coder: NSCoder) {
        base.__fw.modelEncode(with: coder)
    }

    /// 对象解码
    public func modelInit(coder: NSCoder) -> Any {
        return base.__fw.modelInit(with: coder)
    }

    /// 对象的hash编码
    public func modelHash() -> UInt {
        return base.__fw.modelHash()
    }

    /// 比较Model
    public func modelIsEqual(_ model: Any) -> Bool {
        return base.__fw.modelIsEqual(model)
    }

    /// 对象描述
    public func modelDescription() -> String {
        return base.__fw.modelDescription()
    }
    
}
