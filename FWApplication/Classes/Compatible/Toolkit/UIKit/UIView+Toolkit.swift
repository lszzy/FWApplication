//
//  UIView+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/20.
//

import UIKit
#if FWMacroSPM
import FWFrameworkCompatible
import FWApplication
#endif

/// 事件穿透实现方法：重写-hitTest:withEvent:方法，当为指定视图(如self)时返回nil排除即可
extension Wrapper where Base: UIView {
    
    // MARK: - Transform

    /// 获取当前view的transform scale x
    public var scaleX: CGFloat {
        return base.__fw_scaleX
    }

    /// 获取当前view的transform scale y
    public var scaleY: CGFloat {
        return base.__fw_scaleY
    }

    /// 获取当前view的transform translation x
    public var translationX: CGFloat {
        return base.__fw_translationX
    }

    /// 获取当前view的transform translation y
    public var translationY: CGFloat {
        return base.__fw_translationY
    }

    // MARK: - Subview

    /// 移除所有子视图
    public func removeAllSubviews() {
        base.__fw_removeAllSubviews()
    }

    /// 递归查找指定子类的第一个视图
    public func subview(of clazz: AnyClass) -> UIView? {
        return base.__fw_subview(of: clazz)
    }

    /// 递归查找指定条件的第一个视图
    public func subview(of block: @escaping (UIView) -> Bool) -> UIView? {
        return base.__fw_subview(of: block)
    }

    /// 添加到父视图，nil时为从父视图移除
    public func move(toSuperview view: UIView?) {
        base.__fw_move(toSuperview: view)
    }

    // MARK: - Snapshot

    /// 图片截图
    public var snapshotImage: UIImage? {
        return base.__fw_snapshotImage
    }

    /// Pdf截图
    public var snapshotPdf: Data? {
        return base.__fw_snapshotPdf
    }

    // MARK: - Drag

    /// 是否启用拖动，默认NO
    public var dragEnabled: Bool {
        get { return base.__fw_dragEnabled }
        set { base.__fw_dragEnabled = newValue }
    }

    /// 拖动手势，延迟加载
    public var dragGesture: UIPanGestureRecognizer {
        return base.__fw_dragGesture
    }

    /// 设置拖动限制区域，默认CGRectZero，无限制
    public var dragLimit: CGRect {
        get { return base.__fw_dragLimit }
        set { base.__fw_dragLimit = newValue }
    }

    /// 设置拖动动作有效区域，默认self.frame
    public var dragArea: CGRect {
        get { return base.__fw_dragArea }
        set { base.__fw_dragArea = newValue }
    }

    /// 是否允许横向拖动(X)，默认YES
    public var dragHorizontal: Bool {
        get { return base.__fw_dragHorizontal }
        set { base.__fw_dragHorizontal = newValue }
    }

    /// 是否允许纵向拖动(Y)，默认YES
    public var dragVertical: Bool {
        get { return base.__fw_dragVertical }
        set { base.__fw_dragVertical = newValue }
    }

    /// 开始拖动回调
    public var dragStartedBlock: ((UIView) -> Void)? {
        get { return base.__fw_dragStartedBlock }
        set { base.__fw_dragStartedBlock = newValue }
    }

    /// 拖动移动回调
    public var dragMovedBlock: ((UIView) -> Void)? {
        get { return base.__fw_dragMovedBlock }
        set { base.__fw_dragMovedBlock = newValue }
    }

    /// 结束拖动回调
    public var dragEndedBlock: ((UIView) -> Void)? {
        get { return base.__fw_dragEndedBlock }
        set { base.__fw_dragEndedBlock = newValue }
    }
    
}

extension Wrapper where Base: UIView {
    
    // MARK: - Animation

    /**
     添加UIView动画，使用默认动画参数
     @note 如果动画过程中需要获取进度，可通过添加CADisplayLink访问self.layer.presentationLayer获取，下同
     
     @param block      动画代码块
     @param completion 完成事件
     */
    public func addAnimation(block: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        base.__fw_addAnimation(block, completion: completion)
    }

    /**
     添加UIView动画
     
     @param block      动画代码块
     @param duration   持续时间
     @param completion 完成事件
     */
    public func addAnimation(block: @escaping () -> Void, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_addAnimation(block, duration: duration, completion: completion)
    }

    /**
     添加UIView动画
     
     @param curve      动画速度
     @param transition 动画类型
     @param duration   持续时间，默认0.2
     @param completion 完成事件
     */
    public func addAnimation(curve: UIView.AnimationCurve, transition: UIView.AnimationTransition, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_addAnimation(with: curve, transition: transition, duration: duration, completion: completion)
    }

    /**
     添加CABasicAnimation动画
     
     @param keyPath    动画路径
     @param fromValue  开始值
     @param toValue    结束值
     @param duration   持续时间，0为默认(0.25秒)
     @param completion 完成事件
     @return CABasicAnimation
     */
    @discardableResult
    public func addAnimation(keyPath: String, fromValue: Any, toValue: Any, duration: CFTimeInterval, completion: ((Bool) -> Void)? = nil) -> CABasicAnimation {
        return base.__fw_addAnimation(withKeyPath: keyPath, fromValue: fromValue, toValue: toValue, duration: duration, completion: completion)
    }

    /**
     添加转场动画
     
     @param option     动画选项
     @param block      动画代码块
     @param duration   持续时间
     @param completion 完成事件
     */
    public func addTransition(option: UIView.AnimationOptions = [], block: @escaping () -> Void, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_addTransition(option: option, block: block, duration: duration, completion: completion)
    }

    /**
     添加转场动画，可指定animationsEnabled，一般用于window切换rootViewController
     
     @param option     动画选项
     @param block      动画代码块
     @param duration   持续时间
     @param animationsEnabled 是否启用动画
     @param completion 完成事件
     */
    public func addTransition(option: UIView.AnimationOptions = [], block: @escaping () -> Void, duration: TimeInterval, animationsEnabled: Bool, completion: ((Bool) -> Void)? = nil) {
        base.__fw_addTransition(option: option, block: block, duration: duration, animationsEnabled: animationsEnabled, completion: completion)
    }

    /**
     添加转场动画
     
     @param toView     目标视图
     @param option     动画选项
     @param duration   持续时间
     @param completion 完成事件
     */
    public func addTransition(toView: UIView, option: UIView.AnimationOptions = [], duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_addTransition(to: toView, withOption: option, duration: duration, completion: completion)
    }

    /**
     添加CATransition转场动画
     备注：移除动画可调用[self fwRemoveAnimation]
     
     @param type           动画类型
     @param subtype        子类型
     @param timingFunction 动画速度
     @param duration       持续时间，0为默认(0.25秒)
     @param completion     完成事件
     @return CATransition
     */
    @discardableResult
    public func addTransition(type: String, subtype: String?, timingFunction: String?, duration: CFTimeInterval, completion: ((Bool) -> Void)? = nil) -> CATransition {
        return base.__fw_addTransition(withType: type, subtype: subtype, timingFunction: timingFunction, duration: duration, completion: completion)
    }

    /**
     移除单个框架视图动画
     */
    public func removeAnimation() {
        base.__fw_removeAnimation()
    }

    /**
     移除所有视图动画
     */
    public func removeAllAnimations() {
        base.__fw_removeAllAnimations()
    }

    // MARK: - Custom

    /**
     *  绘制动画
     *
     *  @param layer      CAShapeLayer层
     *  @param duration   持续时间
     *  @param completion 完成回调
     *  @return CABasicAnimation
     */
    @discardableResult
    public func stroke(layer: CAShapeLayer, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) -> CABasicAnimation {
        return base.__fw_stroke(with: layer, duration: duration, completion: completion)
    }

    /**
     *  水平摇摆动画
     *
     *  @param times      摇摆次数，默认10
     *  @param delta      摇摆宽度，默认5
     *  @param duration   单次时间，默认0.03
     *  @param completion 完成回调
     */
    public func shake(times: Int, delta: CGFloat, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_shake(withTimes: times, delta: delta, duration: duration, completion: completion)
    }

    /**
     *  渐显隐动画
     *
     *  @param alpha      透明度
     *  @param duration   持续时长
     *  @param completion 完成回调
     */
    public func fade(alpha: Float, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_fade(withAlpha: alpha, duration: duration, completion: completion)
    }

    /**
     *  渐变代码块动画
     *
     *  @param block      动画代码块，比如调用imageView.setImage:方法
     *  @param duration   持续时长，建议0.5
     *  @param completion 完成回调
     */
    public func fade(block: @escaping () -> Void, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_fade(block, duration: duration, completion: completion)
    }

    /**
     *  旋转动画
     *
     *  @param degree     旋转度数，备注：逆时针需设置-179.99。使用CAAnimation无此问题
     *  @param duration   持续时长
     *  @param completion 完成回调
     */
    public func rotate(degree: CGFloat, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_rotate(withDegree: degree, duration: duration, completion: completion)
    }

    /**
     *  缩放动画
     *
     *  @param scaleX     X轴缩放率
     *  @param scaleY     Y轴缩放率
     *  @param duration   持续时长
     *  @param completion 完成回调
     */
    public func scale(scaleX: Float, scaleY: Float, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_scale(withScaleX: scaleX, scaleY: scaleY, duration: duration, completion: completion)
    }

    /**
     *  移动动画
     *
     *  @param point      目标点
     *  @param duration   持续时长
     *  @param completion 完成回调
     */
    public func move(point: CGPoint, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_move(with: point, duration: duration, completion: completion)
    }

    /**
     *  移动变化动画
     *
     *  @param frame      目标区域
     *  @param duration   持续时长
     *  @param completion 完成回调
     */
    public func move(frame: CGRect, duration: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        base.__fw_move(withFrame: frame, duration: duration, completion: completion)
    }
    
    // MARK: - Block

    /**
     取消动画效果执行block
     
     @param block 动画代码块
     @param completion 完成事件
     */
    public static func animateNone(block: () -> Void, completion: (() -> Void)? = nil) {
        Base.__fw_animateNone(block, completion: completion)
    }

    /**
     执行block动画完成后执行指定回调
     
     @param block 动画代码块
     @param completion 完成事件
     */
    public static func animate(block: () -> Void, completion: (() -> Void)? = nil) {
        Base.__fw_animate(block, completion: completion)
    }
    
}

extension Wrapper where Base: CALayer {
    
    // 设置阴影颜色、偏移和半径
    public func setShadowColor(_ color: UIColor?, offset: CGSize, radius: CGFloat) {
        base.__fw_setShadowColor(color, offset: offset, radius: radius)
    }
    
}

extension Wrapper where Base: CAGradientLayer {
    
    /**
     *  创建渐变层，需手工addLayer
     *
     *  @param frame      渐变区域
     *  @param colors     渐变颜色，CGColor数组，如[黑，白，黑]
     *  @param locations  渐变位置，0~1，如[0.25, 0.5, 0.75]对应颜色为[0-0.25黑,0.25-0.5黑渐变白,0.5-0.75白渐变黑,0.75-1黑]
     *  @param startPoint 渐变开始点，设置渐变方向，左上点为(0,0)，右下点为(1,1)
     *  @param endPoint   渐变结束点
     *  @return 渐变Layer
     */
    public static func gradientLayer(
        _ frame: CGRect,
        colors: [Any],
        locations: [NSNumber]?,
        startPoint: CGPoint,
        endPoint: CGPoint
    ) -> CAGradientLayer {
        return Base.__fw_gradientLayer(frame, colors: colors, locations: locations, start: startPoint, end: endPoint)
    }
    
}

extension Wrapper where Base: UIView {
    
    // MARK: - Effect

    /**
     *  设置毛玻璃效果，使用UIVisualEffectView。内容需要添加到UIVisualEffectView.contentView
     *
     *  @param style 毛玻璃效果样式
     */
    @discardableResult
    public func setBlurEffect(_ style: UIBlurEffect.Style) -> UIVisualEffectView? {
        return base.__fw_setBlurEffect(style)
    }

    // MARK: - Bezier

    /**
     绘制形状路径，需要在drawRect中调用
     
     @param bezierPath 绘制路径
     @param strokeWidth 绘制宽度
     @param strokeColor 绘制颜色
     @param fillColor 填充颜色
     */
    public func drawBezierPath(_ bezierPath: UIBezierPath, strokeWidth: CGFloat, strokeColor: UIColor, fillColor: UIColor?) {
        base.__fw_draw(bezierPath, strokeWidth: strokeWidth, stroke: strokeColor, fill: fillColor)
    }

    // MARK: - Gradient

    /**
     绘制渐变颜色，需要在drawRect中调用，支持四个方向，默认向下Down
     
     @param rect 绘制区域
     @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
     @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
     @param direction 渐变方向，自动计算startPoint和endPoint，支持四个方向，默认向下Down
     */
    public func drawLinearGradient(_ rect: CGRect, colors: [Any], locations: UnsafePointer<CGFloat>?, direction: UISwipeGestureRecognizer.Direction) {
        base.__fw_drawLinearGradient(rect, colors: colors, locations: locations, direction: direction)
    }

    /**
     绘制渐变颜色，需要在drawRect中调用
     
     @param rect 绘制区域
     @param colors 渐变颜色，CGColor数组，如：@[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor]
     @param locations 渐变位置，传NULL时均分，如：CGFloat locations[] = {0.0, 1.0};
     @param startPoint 渐变开始点，需要根据rect计算
     @param endPoint 渐变结束点，需要根据rect计算
     */
    public func drawLinearGradient(_ rect: CGRect, colors: [Any], locations: UnsafePointer<CGFloat>?, startPoint: CGPoint, endPoint: CGPoint) {
        base.__fw_drawLinearGradient(rect, colors: colors, locations: locations, start: startPoint, end: endPoint)
    }

    /**
     *  添加渐变Layer
     *
     *  @param frame      渐变区域
     *  @param colors     渐变颜色，CGColor数组，如[黑，白，黑]
     *  @param locations  渐变位置，0~1，如[0.25, 0.5, 0.75]对应颜色为[0-0.25黑,0.25-0.5黑渐变白,0.5-0.75白渐变黑,0.75-1黑]
     *  @param startPoint 渐变开始点，设置渐变方向，左上点为(0,0)，右下点为(1,1)
     *  @param endPoint   渐变结束点
     *  @return 渐变Layer
     */
    @discardableResult
    public func addGradientLayer(_ frame: CGRect, colors: [Any], locations: [NSNumber]?, startPoint: CGPoint, endPoint: CGPoint) -> CAGradientLayer {
        return base.__fw_addGradientLayer(frame, colors: colors, locations: locations, start: startPoint, end: endPoint)
    }

    // MARK: - Circle

    /// 添加进度圆形Layer，可设置绘制颜色和宽度，返回进度CAShapeLayer用于动画，degree为起始角度，如-90
    @discardableResult
    public func addCircleLayer(_ rect: CGRect, degree: CGFloat, progress: CGFloat, strokeColor: UIColor, strokeWidth: CGFloat) -> CAShapeLayer {
        return base.__fw_addCircleLayer(rect, degree: degree, progress: progress, stroke: strokeColor, strokeWidth: strokeWidth)
    }

    /// 添加进度圆形Layer，可设置绘制底色和进度颜色，返回进度CAShapeLayer用于动画，degree为起始角度，如-90
    @discardableResult
    public func addCircleLayer(_ rect: CGRect, degree: CGFloat, progress: CGFloat, progressColor: UIColor, strokeColor: UIColor, strokeWidth: CGFloat) -> CAShapeLayer {
        return base.__fw_addCircleLayer(rect, degree: degree, progress: progress, progressColor: progressColor, stroke: strokeColor, strokeWidth: strokeWidth)
    }

    /// 添加渐变进度圆形Layer，返回渐变Layer容器，添加strokeEnd动画请使用layer.mask即可
    @discardableResult
    public func addCircleLayer(_ rect: CGRect, degree: CGFloat, progress: CGFloat, gradientBlock: ((CALayer) -> Void)?, strokeColor: UIColor, strokeWidth: CGFloat) -> CALayer {
        return base.__fw_addCircleLayer(rect, degree: degree, progress: progress, gradientBlock: gradientBlock, stroke: strokeColor, strokeWidth: strokeWidth)
    }

    // MARK: - Dash

    /**
     添加虚线Layer
     
     @param rect 虚线区域，从中心绘制
     @param lineLength 虚线的宽度
     @param lineSpacing 虚线的间距
     @param lineColor 虚线的颜色
     @return 虚线Layer
     */
    @discardableResult
    public func addDashLayer(_ rect: CGRect, lineLength: CGFloat, lineSpacing: CGFloat, lineColor: UIColor) -> CALayer {
        return base.__fw_addDashLayer(rect, lineLength: lineLength, lineSpacing: lineSpacing, lineColor: lineColor)
    }
    
}

extension Wrapper where Base: UIView {
    
    /// 获取当前 UIView 层级树信息
    public var viewInfo: String {
        return base.__fw_viewInfo
    }

    /// 是否需要添加debug背景色，默认NO
    public var showDebugColor: Bool {
        get { return base.__fw_showDebugColor }
        set { base.__fw_showDebugColor = newValue }
    }

    /// 是否每个view的背景色随机，如果不随机则统一使用半透明红色，默认NO
    public var randomDebugColor: Bool {
        get { return base.__fw_randomDebugColor }
        set { base.__fw_randomDebugColor = newValue }
    }

    /// 是否需要添加debug边框，默认NO
    public var showDebugBorder: Bool {
        get { return base.__fw_showDebugBorder }
        set { base.__fw_showDebugBorder = newValue }
    }

    /// 指定debug边框的颜色，默认半透明红色
    public var debugBorderColor: UIColor {
        get { return base.__fw_debugBorderColor }
        set { base.__fw_debugBorderColor = newValue }
    }
    
}
