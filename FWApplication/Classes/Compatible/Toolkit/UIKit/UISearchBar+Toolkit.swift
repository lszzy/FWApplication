//
//  UISearchBar+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

extension Wrapper where Base: UISearchBar {
    
    // 自定义内容边距，可调整左右距离和TextField高度，未设置时为系统默认
    public var contentInset: UIEdgeInsets {
        get { return base.__fw_contentInset }
        set { base.__fw_contentInset = newValue }
    }

    // 自定义取消按钮边距，未设置时为系统默认
    public var cancelButtonInset: UIEdgeInsets {
        get { return base.__fw_cancelButtonInset }
        set { base.__fw_cancelButtonInset = newValue }
    }

    // 输入框内部视图
    public weak var textField: UITextField? {
        return base.__fw_textField
    }

    // 取消按钮内部视图，showsCancelButton开启后才存在
    public weak var cancelButton: UIButton? {
        return base.__fw_cancelButton
    }

    // 设置整体背景色
    public var backgroundColor: UIColor? {
        get { return base.__fw_backgroundColor }
        set { base.__fw_backgroundColor = newValue }
    }

    // 设置输入框背景色
    public var textFieldBackgroundColor: UIColor? {
        get { return base.__fw_textFieldBackgroundColor }
        set { base.__fw_textFieldBackgroundColor = newValue }
    }

    // 设置搜索图标离左侧的偏移位置，非居中时生效
    public var searchIconOffset: CGFloat {
        get { return base.__fw_searchIconOffset }
        set { base.__fw_searchIconOffset = newValue }
    }

    // 设置搜索文本离左侧图标的偏移位置
    public var searchTextOffset: CGFloat {
        get { return base.__fw_searchTextOffset }
        set { base.__fw_searchTextOffset = newValue }
    }

    // 设置TextField搜索图标(placeholder)是否居中，否则居左
    public var searchIconCenter: Bool {
        get { return base.__fw_searchIconCenter }
        set { base.__fw_searchIconCenter = newValue }
    }

    // 强制取消按钮一直可点击，需在showsCancelButton设置之后生效。默认SearchBar失去焦点之后取消按钮不可点击
    public var forceCancelButtonEnabled: Bool {
        get { return base.__fw_forceCancelButtonEnabled }
        set { base.__fw_forceCancelButtonEnabled = newValue }
    }
    
}
