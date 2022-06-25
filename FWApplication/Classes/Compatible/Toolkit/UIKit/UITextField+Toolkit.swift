//
//  UITextField+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UITextField {
    
    // MARK: - Menu

    /// 是否禁用长按菜单(拷贝、选择、粘贴等)，默认NO
    public var menuDisabled: Bool {
        get { return base.__fw_menuDisabled }
        set { base.__fw_menuDisabled = newValue }
    }

    // MARK: - Select

    /// 自定义光标颜色
    public var cursorColor: UIColor {
        get { return base.__fw_cursorColor }
        set { base.__fw_cursorColor = newValue }
    }

    /// 自定义光标大小，不为0才会生效，默认zero不生效
    public var cursorRect: CGRect {
        get { return base.__fw_cursorRect }
        set { base.__fw_cursorRect = newValue }
    }

    /// 获取及设置当前选中文字范围
    public var selectedRange: NSRange {
        get { return base.__fw_selectedRange }
        set { base.__fw_selectedRange = newValue }
    }

    /// 移动光标到最后
    public func selectAllRange() {
        base.__fw_selectAllRange()
    }

    /// 移动光标到指定位置，兼容动态text赋值
    public func moveCursor(_ offset: Int) {
        base.__fw_moveCursor(offset)
    }
    
}
