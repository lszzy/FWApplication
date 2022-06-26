//
//  NSObject+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: NSObject {
    
    // MARK: - Archive

    /**
     使用NSKeyedArchiver和NSKeyedUnarchiver深拷对象
     
     @return 出错返回nil
     */
    public func archiveCopy() -> Any? {
        return base.__fw_archiveCopy()
    }

    // MARK: - Block

    /// 延迟delay秒后主线程执行，返回可取消的block，对象范围
    @discardableResult
    public func performBlock(
        _ block: @escaping (Any) -> Void,
        afterDelay delay: TimeInterval
    ) -> Any {
        return base.__fw_perform(block, afterDelay: delay)
    }

    /// 延迟delay秒后后台线程执行，返回可取消的block，对象范围
    @discardableResult
    public func performBlock(
        inBackground block: @escaping (Any) -> Void,
        afterDelay delay: TimeInterval
    ) -> Any {
        return base.__fw_performBlock(inBackground: block, afterDelay: delay)
    }

    /// 延迟delay秒后指定线程执行，返回可取消的block，对象范围
    @discardableResult
    public func performBlock(
        _ block: @escaping (Any) -> Void,
        on: DispatchQueue,
        afterDelay delay: TimeInterval
    ) -> Any {
        return base.__fw_perform(block, on: on, afterDelay: delay)
    }

    /// 同步方式执行异步block，阻塞当前线程(信号量)，异步block必须调用completionHandler，全局范围
    public func syncPerform(
        asyncBlock: @escaping (@escaping () -> Void) -> Void
    ) {
        base.__fw_syncPerformAsyncBlock(asyncBlock)
    }

    /// 同一个identifier仅执行一次block，对象范围
    public func performOnce(
        _ identifier: String,
        with block: @escaping () -> Void
    ) {
        base.__fw_performOnce(identifier, with: block)
    }

    /// 重试方式执行异步block，直至成功或者次数为0或者超时，完成后回调completion。block必须调用completionHandler，参数示例：重试4次|超时8秒|延迟2秒
    public func performBlock(
        _ block: @escaping (@escaping (Bool, Any?) -> Void) -> Void,
        completion: @escaping (Bool, Any?) -> Void,
        retryCount: UInt,
        timeoutInterval: TimeInterval,
        delayInterval: TimeInterval
    ) {
        base.__fw_perform(block, completion: completion, retryCount: retryCount, timeoutInterval: timeoutInterval, delayInterval: delayInterval)
    }

    /// 延迟delay秒后主线程执行，返回可取消的block，全局范围
    @discardableResult
    public static func performBlock(
        _ block: @escaping () -> Void,
        afterDelay delay: TimeInterval
    ) -> Any {
        return Base.__fw_perform(with: block, afterDelay: delay)
    }

    /// 延迟delay秒后后台线程执行，返回可取消的block，全局范围
    @discardableResult
    public static func performBlock(
        inBackground block: @escaping () -> Void,
        afterDelay delay: TimeInterval
    ) -> Any {
        return Base.__fw_perform(inBackground: block, afterDelay: delay)
    }

    /// 延迟delay秒后指定线程执行，返回可取消的block，全局范围
    @discardableResult
    public static func performBlock(
        _ block: @escaping () -> Void,
        on: DispatchQueue,
        afterDelay delay: TimeInterval
    ) -> Any {
        return Base.__fw_perform(with: block, on: on, afterDelay: delay)
    }

    /// 取消指定延迟block，全局范围
    public static func cancelBlock(_ block: Any) {
        Base.__fw_cancelBlock(block)
    }

    /// 同步方式执行异步block，阻塞当前线程(信号量)，异步block必须调用completionHandler，全局范围
    public static func syncPerform(
        asyncBlock: @escaping (@escaping () -> Void) -> Void
    ) {
        Base.__fw_syncPerformAsyncBlock(asyncBlock)
    }

    /// 同一个identifier仅执行一次block，全局范围
    public static func performOnce(
        _ identifier: String,
        with block: @escaping () -> Void
    ) {
        Base.__fw_performOnce(identifier, with: block)
    }

    /// 重试方式执行异步block，直至成功或者次数为0或者超时，完成后回调completion。block必须调用completionHandler，参数示例：重试4次|超时8秒|延迟2秒
    public static func performBlock(
        _ block: @escaping (@escaping (Bool, Any?) -> Void) -> Void,
        completion: @escaping (Bool, Any?) -> Void,
        retryCount: UInt,
        timeoutInterval: TimeInterval,
        delayInterval: TimeInterval
    ) {
        Base.__fw_perform(block, completion: completion, retryCount: retryCount, timeoutInterval: timeoutInterval, delayInterval: delayInterval)
    }

    /// 执行轮询block任务，返回任务Id可取消
    @discardableResult
    public static func performTask(_ task: @escaping () -> Void, start: TimeInterval, interval: TimeInterval, repeats: Bool, async: Bool) -> String {
        return Base.__fw_performTask(task, start: start, interval: interval, repeats: repeats, async: async)
    }

    /// 指定任务Id取消轮询任务
    public static func cancelTask(_ taskId: String) {
        Base.__fw_cancelTask(taskId)
    }
    
}
