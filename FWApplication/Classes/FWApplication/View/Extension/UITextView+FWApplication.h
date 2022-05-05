//
//  UITextView+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 17/3/29.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWTextViewWrapper+FWApplication

// 多行输入框分类
@interface FWTextViewWrapper (FWApplication)

#pragma mark - Menu

// 是否禁用长按菜单(拷贝、选择、粘贴等)，默认NO
@property (nonatomic, assign) BOOL menuDisabled;

#pragma mark - Select

// 自定义光标颜色
@property (nonatomic, strong, null_resettable) UIColor *cursorColor;

// 自定义光标大小，不为0才会生效，默认zero不生效
@property (nonatomic, assign) CGRect cursorRect;

// 获取及设置当前选中文字范围
@property (nonatomic, assign) NSRange selectedRange;

// 移动光标到最后
- (void)selectAllRange;

// 移动光标到指定位置，兼容动态text赋值
- (void)moveCursor:(NSInteger)offset;

#pragma mark - Size

// 计算当前文本所占尺寸，包含textContainerInset，需frame或者宽度布局完整
@property (nonatomic, assign, readonly) CGSize textSize;

// 计算当前属性文本所占尺寸，包含textContainerInset，需frame或者宽度布局完整，attributedText需指定字体
@property (nonatomic, assign, readonly) CGSize attributedTextSize;

@end

NS_ASSUME_NONNULL_END
