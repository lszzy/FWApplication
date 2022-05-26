//
//  UIScrollView+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 17/3/13.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWAppWrapper.h"

NS_ASSUME_NONNULL_BEGIN

/**
 添加顶部下拉图片时，只需将该子view添加到scrollView最底层(如frame方式添加inset视图)，再实现效果即可。
 */
@interface FWScrollViewWrapper (FWApplication)

#pragma mark - Content

/// 内容视图，子视图需添加到本视图，布局约束完整时可自动滚动
@property (nonatomic, strong, readonly) UIView *contentView;

#pragma mark - Frame

// contentSize.width
@property (nonatomic, assign) CGFloat contentWidth;

// contentSize.height
@property (nonatomic, assign) CGFloat contentHeight;

// contentOffset.x
@property (nonatomic, assign) CGFloat contentOffsetX;

// contentOffset.y
@property (nonatomic, assign) CGFloat contentOffsetY;

#pragma mark - Scroll

/// UIScrollView真正的inset，iOS11+使用adjustedContentInset，iOS11以下使用contentInset
@property (nonatomic, assign, readonly) UIEdgeInsets contentInset;

/// 当前滚动方向，如果多个方向滚动，取绝对值较大的一方，失败返回0
@property (nonatomic, assign, readonly) UISwipeGestureRecognizerDirection scrollDirection;

// 当前滚动进度，滚动绝对值相对于当前视图的宽或高
@property (nonatomic, assign, readonly) CGFloat scrollPercent;

// 计算指定方向的滚动进度
- (CGFloat)scrollPercentOfDirection:(UISwipeGestureRecognizerDirection)direction;

#pragma mark - Content

// 单独禁用内边距适应，同上。注意appearance设置时会影响到系统控制器如UIImagePickerController等
- (void)contentInsetAdjustmentNever UI_APPEARANCE_SELECTOR;

#pragma mark - Keyboard

// 是否滚动时收起键盘，默认NO
@property (nonatomic, assign) BOOL keyboardDismissOnDrag UI_APPEARANCE_SELECTOR;

#pragma mark - Gesture

// 是否开始识别pan手势
@property (nullable, nonatomic, copy) BOOL (^shouldBegin)(UIGestureRecognizer *gestureRecognizer);

// 是否允许同时识别多个手势
@property (nullable, nonatomic, copy) BOOL (^shouldRecognizeSimultaneously)(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer);

// 是否另一个手势识别失败后，才能识别pan手势
@property (nullable, nonatomic, copy) BOOL (^shouldRequireFailure)(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer);

// 是否pan手势识别失败后，才能识别另一个手势
@property (nullable, nonatomic, copy) BOOL (^shouldBeRequiredToFail)(UIGestureRecognizer *gestureRecognizer, UIGestureRecognizer *otherGestureRecognizer);

#pragma mark - Hover

/**
 设置自动布局视图悬停到指定父视图固定位置，在scrollViewDidScroll:中调用即可
 
 @param view 需要悬停的视图，须占满fromSuperview
 @param fromSuperview 起始的父视图，须是scrollView的子视图
 @param toSuperview 悬停的目标视图，须是scrollView的父级视图，一般控制器self.view
 @param toPosition 需要悬停的目标位置，相对于toSuperview的originY位置
 @return 相对于悬浮位置的距离，可用来设置导航栏透明度等
 */
- (CGFloat)hoverView:(UIView *)view
         fromSuperview:(UIView *)fromSuperview
           toSuperview:(UIView *)toSuperview
            toPosition:(CGFloat)toPosition;

@end

@interface FWScrollViewClassWrapper (FWApplication)

/// 快速创建通用配置滚动视图
- (__kindof UIScrollView *)scrollView;

@end

#pragma mark - FWGestureRecognizerWrapper+FWApplication

/**
 gestureRecognizerShouldBegin：是否继续进行手势识别，默认YES
 shouldRecognizeSimultaneouslyWithGestureRecognizer: 是否支持多手势触发。默认NO
 shouldRequireFailureOfGestureRecognizer：是否otherGestureRecognizer触发失败时，才开始触发gestureRecognizer。返回YES，第一个手势失败
 shouldBeRequiredToFailByGestureRecognizer：在otherGestureRecognizer识别其手势之前，是否gestureRecognizer必须触发失败。返回YES，第二个手势失败
 */
@interface FWGestureRecognizerWrapper (FWApplication)

// 获取手势直接作用的view，不同于view，此处是view的subview
@property (nullable, nonatomic, weak, readonly) UIView *targetView;

// 是否正在拖动中：Began || Changed
@property (nonatomic, assign, readonly) BOOL isTracking;

// 是否是激活状态: isEnabled && (Began || Changed)
@property (nonatomic, assign, readonly) BOOL isActive;

@end

@interface FWPanGestureRecognizerWrapper (FWApplication)

// 当前滑动方向，如果多个方向滑动，取绝对值较大的一方，失败返回0
@property (nonatomic, assign, readonly) UISwipeGestureRecognizerDirection swipeDirection;

// 当前滑动进度，滑动绝对值相对于手势视图的宽或高
@property (nonatomic, assign, readonly) CGFloat swipePercent;

// 计算指定方向的滑动进度
- (CGFloat)swipePercentOfDirection:(UISwipeGestureRecognizerDirection)direction;

@end

NS_ASSUME_NONNULL_END
