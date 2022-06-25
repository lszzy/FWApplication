//
//  UIButton+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/// 防重复点击可以手工控制enabled或userInteractionEnabled或loading，如request开始时禁用，结束时启用等
extension Wrapper where Base: UIControl {
    
    // 设置Touch事件触发间隔，防止短时间多次触发事件，默认0
    public var touchEventInterval: TimeInterval {
        get { return base.__fw_touchEventInterval }
        set { base.__fw_touchEventInterval = newValue }
    }
    
}

extension Wrapper where Base: UIButton {
    
    /// 设置背景色
    public func setBackgroundColor(_ backgroundColor: UIColor?, for state: UIControl.State) {
        base.__fw_setBackgroundColor(backgroundColor, for: state)
    }

    /// 设置按钮倒计时，从window移除时自动取消。等待时按钮disabled，非等待时enabled。时间支持格式化，示例：重新获取(%lds)
    @discardableResult
    public func startCountDown(_ seconds: Int, title: String, waitTitle: String) -> DispatchSource {
        return base.__fw_startCountDown(seconds, title: title, waitTitle: waitTitle)
    }
    
}

extension Wrapper where Base: UISwitch {
    
    /**
     切换开关状态
     */
    public func toggle(_ animated: Bool = true) {
        base.__fw_toggle(animated)
    }
    
}
