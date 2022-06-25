//
//  UIDevice+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UIDevice {
    
    // MARK: - UUID

    /// 获取或设置设备UUID，自动keychain持久化。默认获取IDFV(未使用IDFA，避免额外权限)，失败则随机生成一个
    public static var deviceUUID: String {
        get { return Base.__fw_deviceUUID }
        set { Base.__fw_deviceUUID = newValue }
    }

    // MARK: - Jailbroken

    // 是否越狱
    public static var isJailbroken: Bool {
        return Base.__fw_isJailbroken
    }

    // MARK: - Network

    // 本地IP地址
    public static var ipAddress: String? {
        return Base.__fw_ipAddress
    }
    
    // 本地主机名称
    public static var hostName: String? {
        return Base.__fw_hostName
    }
    
    // 手机运营商名称
    public static var carrierName: String? {
        return Base.__fw_carrierName
    }
    
    // 手机蜂窝网络类型，仅区分2G|3G|4G|5G
    public static var networkType: String? {
        return Base.__fw_networkType
    }
    
}
