//
//  UIScrollView+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit

/// 添加顶部下拉图片时，只需将该子view添加到scrollView最底层(如frame方式添加inset视图)，再实现效果即可。
extension Wrapper where Base: UIScrollView {
    
    // MARK: - Content

    /// 内容视图，子视图需添加到本视图，布局约束完整时可自动滚动
    public var contentView: UIView {
        return base.__fw.contentView
    }

    // MARK: - Frame

    /// contentSize.width
    public var contentWidth: CGFloat {
        get { return base.__fw.contentWidth }
        set { base.__fw.contentWidth = newValue }
    }

    /// contentSize.height
    public var contentHeight: CGFloat {
        get { return base.__fw.contentHeight }
        set { base.__fw.contentHeight = newValue }
    }

    /// contentOffset.x
    public var contentOffsetX: CGFloat {
        get { return base.__fw.contentOffsetX }
        set { base.__fw.contentOffsetX = newValue }
    }

    /// contentOffset.y
    public var contentOffsetY: CGFloat {
        get { return base.__fw.contentOffsetY }
        set { base.__fw.contentOffsetY = newValue }
    }

    // MARK: - Scroll

    /// UIScrollView真正的inset，iOS11+使用adjustedContentInset，iOS11以下使用contentInset
    public var contentInset: UIEdgeInsets {
        return base.__fw.contentInset
    }

    /// 当前滚动方向，如果多个方向滚动，取绝对值较大的一方，失败返回0
    public var scrollDirection: UISwipeGestureRecognizer.Direction {
        return base.__fw.scrollDirection
    }

    /// 当前滚动进度，滚动绝对值相对于当前视图的宽或高
    public var scrollPercent: CGFloat {
        return base.__fw.scrollPercent
    }

    /// 计算指定方向的滚动进度
    public func scrollPercent(of direction: UISwipeGestureRecognizer.Direction) -> CGFloat {
        return base.__fw.scrollPercent(of: direction)
    }

    // MARK: - Content

    /// 单独禁用内边距适应，同上。注意appearance设置时会影响到系统控制器如UIImagePickerController等
    public func contentInsetAdjustmentNever() {
        base.__fw.contentInsetAdjustmentNever()
    }

    // MARK: - Keyboard

    /// 是否滚动时收起键盘，默认NO
    public var keyboardDismissOnDrag: Bool {
        get { return base.__fw.keyboardDismissOnDrag }
        set { base.__fw.keyboardDismissOnDrag = newValue }
    }

    // MARK: - Gesture

    /// 是否开始识别pan手势
    public var shouldBegin: ((UIGestureRecognizer) -> Bool)? {
        get { return base.__fw.shouldBegin }
        set { base.__fw.shouldBegin = newValue }
    }

    /// 是否允许同时识别多个手势
    public var shouldRecognizeSimultaneously: ((UIGestureRecognizer, UIGestureRecognizer) -> Bool)? {
        get { return base.__fw.shouldRecognizeSimultaneously }
        set { base.__fw.shouldRecognizeSimultaneously = newValue }
    }

    /// 是否另一个手势识别失败后，才能识别pan手势
    public var shouldRequireFailure: ((UIGestureRecognizer, UIGestureRecognizer) -> Bool)? {
        get { return base.__fw.shouldRequireFailure }
        set { base.__fw.shouldRequireFailure = newValue }
    }

    /// 是否pan手势识别失败后，才能识别另一个手势
    public var shouldBeRequiredToFail: ((UIGestureRecognizer, UIGestureRecognizer) -> Bool)? {
        get { return base.__fw.shouldBeRequiredToFail }
        set { base.__fw.shouldBeRequiredToFail = newValue }
    }

    // MARK: - Hover

    /**
     设置自动布局视图悬停到指定父视图固定位置，在scrollViewDidScroll:中调用即可
     
     @param view 需要悬停的视图，须占满fromSuperview
     @param fromSuperview 起始的父视图，须是scrollView的子视图
     @param toSuperview 悬停的目标视图，须是scrollView的父级视图，一般控制器self.view
     @param toPosition 需要悬停的目标位置，相对于toSuperview的originY位置
     @return 相对于悬浮位置的距离，可用来设置导航栏透明度等
     */
    @discardableResult
    public func hoverView(_ view: UIView, fromSuperview: UIView, toSuperview: UIView, toPosition: CGFloat) -> CGFloat {
        return base.__fw.hover(view, fromSuperview: fromSuperview, toSuperview: toSuperview, toPosition: toPosition)
    }
    
    // MARK: - Factory
    
    /// 快速创建通用配置滚动视图
    public static func scrollView() -> Base {
        return Base.__fw.scrollView() as! Base
    }
    
}

/// gestureRecognizerShouldBegin：是否继续进行手势识别，默认YES
/// shouldRecognizeSimultaneouslyWithGestureRecognizer: 是否支持多手势触发。默认NO
/// shouldRequireFailureOfGestureRecognizer：是否otherGestureRecognizer触发失败时，才开始触发gestureRecognizer。返回YES，第一个手势失败
/// shouldBeRequiredToFailByGestureRecognizer：在otherGestureRecognizer识别其手势之前，是否gestureRecognizer必须触发失败。返回YES，第二个手势失败
extension Wrapper where Base: UIGestureRecognizer {
    
    /// 获取手势直接作用的view，不同于view，此处是view的subview
    public weak var targetView: UIView? {
        return base.__fw.targetView
    }

    /// 是否正在拖动中：Began || Changed
    public var isTracking: Bool {
        return base.__fw.isTracking
    }

    /// 是否是激活状态: isEnabled && (Began || Changed)
    public var isActive: Bool {
        return base.__fw.isActive
    }
    
}

extension Wrapper where Base: UIPanGestureRecognizer {
    
    /// 当前滑动方向，如果多个方向滑动，取绝对值较大的一方，失败返回0
    public var swipeDirection: UISwipeGestureRecognizer.Direction {
        return base.__fw.swipeDirection
    }

    /// 当前滑动进度，滑动绝对值相对于手势视图的宽或高
    public var swipePercent: CGFloat {
        return base.__fw.swipePercent
    }

    /// 计算指定方向的滑动进度
    public func swipePercent(of direction: UISwipeGestureRecognizer.Direction) -> CGFloat {
        return base.__fw.swipePercent(of: direction)
    }
    
}
