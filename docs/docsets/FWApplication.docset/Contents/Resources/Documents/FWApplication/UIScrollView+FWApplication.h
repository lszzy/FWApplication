//
//  UIScrollView+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 添加顶部下拉图片时，只需将该子view添加到scrollView最底层(如frame方式添加inset视图)，再实现效果即可。
 */
@interface UIScrollView (FWApplication)

#pragma mark - Content

/// 内容视图，子视图需添加到本视图，布局约束完整时可自动滚动
@property (nonatomic, strong, readonly) UIView *fw_contentView NS_REFINED_FOR_SWIFT;

#pragma mark - Frame

// contentSize.width
@property (nonatomic, assign) CGFloat fw_contentWidth NS_REFINED_FOR_SWIFT;

// contentSize.height
@property (nonatomic, assign) CGFloat fw_contentHeight NS_REFINED_FOR_SWIFT;

// contentOffset.x
@property (nonatomic, assign) CGFloat fw_contentOffsetX NS_REFINED_FOR_SWIFT;

// contentOffset.y
@property (nonatomic, assign) CGFloat fw_contentOffsetY NS_REFINED_FOR_SWIFT;

#pragma mark - Scroll

/// UIScrollView真正的inset，iOS11+使用adjustedContentInset，iOS11以下使用contentInset
@property (nonatomic, assign, readonly) UIEdgeInsets fw_contentInset NS_REFINED_FOR_SWIFT;

/// 当前滚动方向，如果多个方向滚动，取绝对值较大的一方，失败返回0
@property (nonatomic, assign, readonly) UISwipeGestureRecognizerDirection fw_scrollDirection NS_REFINED_FOR_SWIFT;

// 当前滚动进度，滚动绝对值相对于当前视图的宽或高
@property (nonatomic, assign, readonly) CGFloat fw_scrollPercent NS_REFINED_FOR_SWIFT;

// 计算指定方向的滚动进度
- (CGFloat)fw_scrollPercentOfDirection:(UISwipeGestureRecognizerDirection)direction NS_REFINED_FOR_SWIFT;

#pragma mark - Content

// 单独禁用内边距适应，同上。注意appearance设置时会影响到系统控制器如UIImagePickerController等
- (void)fw_contentInsetAdjustmentNever UI_APPEARANCE_SELECTOR NS_REFINED_FOR_SWIFT;

#pragma mark - Keyboard

// 是否滚动时收起键盘，默认NO
@property (nonatomic, assign) BOOL fw_keyboardDismissOnDrag UI_APPEARANCE_SELECTOR NS_REFINED_FOR_SWIFT;

#pragma mark - Gesture

// 是否开始识别pan手势
@property (nullable, nonatomic, copy) BOOL (^fw_shouldBegin)(UIGestureRecognizer *gestureRecognizer) NS_REFINED_FOR_SWIFT;

// 是否允许同时识别多个手势
@property (nullable, nonatomic, copy) BOOL (^fw_shouldRecognizeSimultaneously)(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer) NS_REFINED_FOR_SWIFT;

// 是否另一个手势识别失败后，才能识别pan手势
@property (nullable, nonatomic, copy) BOOL (^fw_shouldRequireFailure)(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer) NS_REFINED_FOR_SWIFT;

// 是否pan手势识别失败后，才能识别另一个手势
@property (nullable, nonatomic, copy) BOOL (^fw_shouldBeRequiredToFail)(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer) NS_REFINED_FOR_SWIFT;

#pragma mark - Hover

/**
 设置自动布局视图悬停到指定父视图固定位置，在scrollViewDidScroll:中调用即可
 
 @param view 需要悬停的视图，须占满fromSuperview
 @param fromSuperview 起始的父视图，须是scrollView的子视图
 @param toSuperview 悬停的目标视图，须是scrollView的父级视图，一般控制器self.view
 @param toPosition 需要悬停的目标位置，相对于toSuperview的originY位置
 @return 相对于悬浮位置的距离，可用来设置导航栏透明度等
 */
- (CGFloat)fw_hoverView:(UIView *)view
         fromSuperview:(UIView *)fromSuperview
           toSuperview:(UIView *)toSuperview
            toPosition:(CGFloat)toPosition NS_REFINED_FOR_SWIFT;

/// 快速创建通用配置滚动视图
+ (instancetype)fw_scrollView NS_SWIFT_NAME(__fw_scrollView()) NS_REFINED_FOR_SWIFT;

@end

#pragma mark - UIGestureRecognizer+FWApplication

/**
 gestureRecognizerShouldBegin：是否继续进行手势识别，默认YES
 shouldRecognizeSimultaneouslyWithGestureRecognizer: 是否支持多手势触发。默认NO
 shouldRequireFailureOfGestureRecognizer：是否otherGestureRecognizer触发失败时，才开始触发gestureRecognizer。返回YES，第一个手势失败
 shouldBeRequiredToFailByGestureRecognizer：在otherGestureRecognizer识别其手势之前，是否gestureRecognizer必须触发失败。返回YES，第二个手势失败
 */
@interface UIGestureRecognizer (FWApplication)

// 获取手势直接作用的view，不同于view，此处是view的subview
@property (nullable, nonatomic, weak, readonly) UIView *fw_targetView NS_REFINED_FOR_SWIFT;

// 是否正在拖动中：Began || Changed
@property (nonatomic, assign, readonly) BOOL fw_isTracking NS_REFINED_FOR_SWIFT;

// 是否是激活状态: isEnabled && (Began || Changed)
@property (nonatomic, assign, readonly) BOOL fw_isActive NS_REFINED_FOR_SWIFT;

@end

@interface UIPanGestureRecognizer (FWApplication)

// 当前滑动方向，如果多个方向滑动，取绝对值较大的一方，失败返回0
@property (nonatomic, assign, readonly) UISwipeGestureRecognizerDirection fw_swipeDirection NS_REFINED_FOR_SWIFT;

// 当前滑动进度，滑动绝对值相对于手势视图的宽或高
@property (nonatomic, assign, readonly) CGFloat fw_swipePercent NS_REFINED_FOR_SWIFT;

// 计算指定方向的滑动进度
- (CGFloat)fw_swipePercentOfDirection:(UISwipeGestureRecognizerDirection)direction NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
