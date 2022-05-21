//
//  UITextField+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit

extension Wrapper where Base: UITextField {
    
    // MARK: - Menu

    /// 是否禁用长按菜单(拷贝、选择、粘贴等)，默认NO
    public var menuDisabled: Bool {
        get { return base.__fw.menuDisabled }
        set { base.__fw.menuDisabled = newValue }
    }

    // MARK: - Select

    /// 自定义光标颜色
    public var cursorColor: UIColor {
        get { return base.__fw.cursorColor }
        set { base.__fw.cursorColor = newValue }
    }

    /// 自定义光标大小，不为0才会生效，默认zero不生效
    public var cursorRect: CGRect {
        get { return base.__fw.cursorRect }
        set { base.__fw.cursorRect = newValue }
    }

    /// 获取及设置当前选中文字范围
    public var selectedRange: NSRange {
        get { return base.__fw.selectedRange }
        set { base.__fw.selectedRange = newValue }
    }

    /// 移动光标到最后
    public func selectAllRange() {
        base.__fw.selectAllRange()
    }

    /// 移动光标到指定位置，兼容动态text赋值
    public func moveCursor(_ offset: Int) {
        base.__fw.moveCursor(offset)
    }
    
}
