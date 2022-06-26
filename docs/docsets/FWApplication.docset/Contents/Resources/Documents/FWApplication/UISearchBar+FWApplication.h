/**
 @header     UISearchBar+FWApplication.h
 @indexgroup FWApplication
      UISearchBar+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/10/15
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface UISearchBar (FWApplication)

// 自定义内容边距，可调整左右距离和TextField高度，未设置时为系统默认
@property (nonatomic, assign) UIEdgeInsets fw_contentInset NS_REFINED_FOR_SWIFT;

// 自定义取消按钮边距，未设置时为系统默认
@property (nonatomic, assign) UIEdgeInsets fw_cancelButtonInset NS_REFINED_FOR_SWIFT;

// 输入框内部视图
@property (nullable, nonatomic, weak, readonly) UITextField *fw_textField NS_REFINED_FOR_SWIFT;

// 取消按钮内部视图，showsCancelButton开启后才存在
@property (nullable, nonatomic, weak, readonly) UIButton *fw_cancelButton NS_REFINED_FOR_SWIFT;

// 设置整体背景色
@property (nonatomic, strong, nullable) UIColor *fw_backgroundColor NS_REFINED_FOR_SWIFT;

// 设置输入框背景色
@property (nonatomic, strong, nullable) UIColor *fw_textFieldBackgroundColor NS_REFINED_FOR_SWIFT;

// 设置搜索图标离左侧的偏移位置，非居中时生效
@property (nonatomic, assign) CGFloat fw_searchIconOffset NS_REFINED_FOR_SWIFT;

// 设置搜索文本离左侧图标的偏移位置
@property (nonatomic, assign) CGFloat fw_searchTextOffset NS_REFINED_FOR_SWIFT;

// 设置TextField搜索图标(placeholder)是否居中，否则居左
@property (nonatomic, assign) BOOL fw_searchIconCenter NS_REFINED_FOR_SWIFT;

// 强制取消按钮一直可点击，需在showsCancelButton设置之后生效。默认SearchBar失去焦点之后取消按钮不可点击
@property (nonatomic, assign) BOOL fw_forceCancelButtonEnabled NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
