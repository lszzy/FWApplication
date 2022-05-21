//
//  UINavigationController+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit

extension Wrapper where Base: UINavigationBar {
    
    /// 导航栏内容视图，iOS11+才存在，显示item和titleView等
    public var contentView: UIView? {
        return base.__fw.contentView
    }

    /// 导航栏大标题视图，显示时才有值。如果要设置背景色，可使用fwBackgroundView.backgroundColor
    public var largeTitleView: UIView? {
        return base.__fw.largeTitleView
    }
    
    /// 导航栏大标题高度，与是否隐藏无关
    public static var largeTitleHeight: CGFloat {
        return Base.__fw.largeTitleHeight
    }
    
}

extension Wrapper where Base: UIToolbar {
    
    /// 工具栏内容视图，iOS11+才存在，显示item等
    public var contentView: UIView? {
        return base.__fw.contentView
    }

    /// 工具栏背景视图，显示背景色和背景图片等。如果标签栏同时显示，背景视图高度也会包含标签栏高度
    public var backgroundView: UIView? {
        return base.__fw.backgroundView
    }
    
}
