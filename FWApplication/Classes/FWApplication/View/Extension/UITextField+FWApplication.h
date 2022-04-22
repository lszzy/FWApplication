//
//  UITextField+FWApplication.h
//  FWApplication
//
//  Created by wuyong on 17/3/29.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - FWTextFieldWrapper+FWApplication

// 文本输入框分类
@interface FWTextFieldWrapper (FWApplication)

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

// 选中所有文字
- (void)selectAllText;

@end

NS_ASSUME_NONNULL_END
