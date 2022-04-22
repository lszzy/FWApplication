//
//  TestKeyboardViewController.m
//  Example
//
//  Created by wuyong on 2017/4/6.
//  Copyright © 2017年 ocphp.com. All rights reserved.
//

#import "TestKeyboardViewController.h"

@interface TestKeyboardViewController () <FWScrollViewController, UITextFieldDelegate, UITextViewDelegate>

FWPropertyStrong(UITextField *, mobileField);

FWPropertyStrong(UITextField *, passwordField);

FWPropertyStrong(UITextView *, textView);

FWPropertyStrong(UITextView *, inputView);

FWPropertyStrong(UIButton *, submitButton);

FWPropertyStrong(FWPopupMenu *, popupMenu);

FWPropertyAssign(BOOL, canScroll);
FWPropertyAssign(BOOL, dismissOnDrag);
FWPropertyAssign(BOOL, useScrollView);

@end

@implementation TestKeyboardViewController

- (void)setCanScroll:(BOOL)canScroll
{
    _canScroll = canScroll;
    [self.view endEditing:YES];
    [self renderData];
}

- (void)setDismissOnDrag:(BOOL)dismissOnDrag
{
    _dismissOnDrag = dismissOnDrag;
    [self.view endEditing:YES];
    self.scrollView.fwKeyboardDismissOnDrag = dismissOnDrag;
}

- (void)setUseScrollView:(BOOL)useScrollView
{
    _useScrollView = useScrollView;
    [self.view endEditing:YES];
    self.navigationItem.title = useScrollView ? @"UIScrollView+FWKeyboard" : @"UITextField+FWKeyboard";
    NSArray<UIView *> *textInputs = @[self.mobileField, self.passwordField, self.textView, self.inputView];
    for (UIView *textInput in textInputs) {
        ((UITextField *)textInput).fw.keyboardScrollView = useScrollView ? self.scrollView : nil;
    }
}

- (void)renderView
{
    self.scrollView.backgroundColor = [Theme tableColor];
    
    UITextField *textFieldAppearance = [UITextField appearanceWhenContainedInInstancesOfClasses:@[[TestKeyboardViewController class]]];
    UITextView *textViewAppearance = [UITextView appearanceWhenContainedInInstancesOfClasses:@[[TestKeyboardViewController class]]];
    textFieldAppearance.fw.keyboardManager = YES;
    textFieldAppearance.fw.touchResign = YES;
    textFieldAppearance.fw.keyboardResign = YES;
    textFieldAppearance.fw.reboundDistance = 200;
    textViewAppearance.fw.keyboardManager = YES;
    textViewAppearance.fw.touchResign = YES;
    textViewAppearance.fw.keyboardResign = YES;
    textViewAppearance.fw.reboundDistance = 200;
    
    UITextField *mobileField = [self createTextField];
    self.mobileField = mobileField;
    mobileField.delegate = self;
    mobileField.fw.maxUnicodeLength = 10;
    mobileField.placeholder = @"昵称，最多10个中文";
    mobileField.keyboardType = UIKeyboardTypeDefault;
    mobileField.returnKeyType = UIReturnKeyNext;
    [self.contentView addSubview:mobileField];
    [mobileField.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:15];
    [mobileField.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:15];
    [mobileField.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    
    UITextField *passwordField = [self createTextField];
    self.passwordField = passwordField;
    passwordField.delegate = self;
    passwordField.fw.maxLength = 20;
    passwordField.fw.menuDisabled = YES;
    passwordField.placeholder = @"密码，最多20个英文";
    passwordField.keyboardType = UIKeyboardTypeDefault;
    passwordField.returnKeyType = UIReturnKeyNext;
    mobileField.fw.returnResponder = passwordField;
    mobileField.fw.nextResponder = passwordField;
    [mobileField.fw addToolbarWithTitle:[NSAttributedString.fw attributedString:mobileField.placeholder withFont:[UIFont systemFontOfSize:13.0]] doneBlock:nil];
    passwordField.secureTextEntry = YES;
    passwordField.delegate = self;
    [self.contentView addSubview:passwordField];
    [passwordField.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:mobileField];
    [passwordField.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    
    UITextView *textView = [self createTextView];
    self.textView = textView;
    textView.delegate = self;
    textView.backgroundColor = [Theme backgroundColor];
    textView.fw.maxUnicodeLength = 10;
    textView.fw.placeholder = @"问题，最多10个中文";
    textView.returnKeyType = UIReturnKeyNext;
    passwordField.fw.returnResponder = textView;
    passwordField.fw.previousResponder = mobileField;
    passwordField.fw.nextResponder = textView;
    [passwordField.fw addToolbarWithTitle:[NSAttributedString.fw attributedString:passwordField.placeholder withFont:[UIFont systemFontOfSize:13.0]] doneBlock:nil];
    [self.contentView addSubview:textView];
    [textView.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:passwordField withOffset:15];
    [textView.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    
    UITextView *inputView = [self createTextView];
    self.inputView = inputView;
    inputView.backgroundColor = [Theme backgroundColor];
    inputView.fw.maxLength = 20;
    inputView.fw.menuDisabled = YES;
    inputView.fw.placeholder = @"建议，最多20个英文";
    inputView.returnKeyType = UIReturnKeyDone;
    inputView.fw.returnResign = YES;
    inputView.fw.keyboardDistance = 80;
    textView.fw.returnResponder = inputView;
    textView.fw.previousResponder = passwordField;
    textView.fw.nextResponder = inputView;
    [textView.fw addToolbarWithTitle:[NSAttributedString.fw attributedString:textView.fw.placeholder withFont:[UIFont systemFontOfSize:13.0]] doneBlock:nil];
    inputView.fw.delegate = self;
    inputView.fw.previousResponder = textView;
    [inputView.fw addToolbarWithTitle:[NSAttributedString.fw attributedString:inputView.fw.placeholder withFont:[UIFont systemFontOfSize:13.0]] doneBlock:nil];
    [self.contentView addSubview:inputView];
    [inputView.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:textView withOffset:15];
    [inputView.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
    
    UIButton *submitButton = [Theme largeButton];
    self.submitButton = submitButton;
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [submitButton.fw addTouchTarget:self action:@selector(onSubmit)];
    [self.contentView addSubview:submitButton];
    [submitButton.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:inputView withOffset:15];
    [submitButton.fw pinEdgeToSuperview:NSLayoutAttributeBottom withInset:15];
    [submitButton.fw  alignAxisToSuperview:NSLayoutAttributeCenterX];
}

- (void)renderModel
{
    FWWeakifySelf();
    self.mobileField.fw.autoCompleteBlock = ^(NSString * _Nonnull text) {
        FWStrongifySelf();
        if (text.length < 1) {
            [self.popupMenu dismiss];
        } else {
            [self.popupMenu dismiss];
            self.popupMenu = [FWPopupMenu showRelyOnView:self.mobileField
                                                  titles:@[text]
                                                   icons:nil
                                               menuWidth:self.mobileField.fw.width
                                           otherSettings:^(FWPopupMenu * _Nonnull popupMenu) {
                popupMenu.showMaskView = NO;
            }];
        }
    };
    
    self.inputView.fw.autoCompleteBlock = ^(NSString * _Nonnull text) {
        FWStrongifySelf();
        if (text.length < 1) {
            [self.popupMenu dismiss];
        } else {
            [self.popupMenu dismiss];
            self.popupMenu = [FWPopupMenu showRelyOnView:self.inputView
                                                  titles:@[text]
                                                   icons:nil
                                               menuWidth:self.inputView.fw.width
                                           otherSettings:^(FWPopupMenu * _Nonnull popupMenu) {
                popupMenu.showMaskView = NO;
            }];
        }
    };
    
    [self.fw setRightBarItem:@"切换" block:^(id sender) {
        FWStrongifySelf();
        [self.fw showSheetWithTitle:nil message:nil cancel:@"取消" actions:@[@"切换滚动", @"切换滚动时收起键盘", @"切换滚动视图"] actionBlock:^(NSInteger index) {
            FWStrongifySelf();
            if (index == 0) {
                self.canScroll = !self.canScroll;
            } else if (index == 1) {
                self.dismissOnDrag = !self.dismissOnDrag;
            } else {
                self.useScrollView = !self.useScrollView;
            }
        }];
    }];
}

- (void)renderData
{
    CGFloat marginTop = FWScreenHeight - (390 + 15 + FWTopBarHeight + UIScreen.fw.safeAreaInsets.bottom);
    CGFloat topInset = self.canScroll ? FWScreenHeight : marginTop;
    [self.mobileField.fw pinEdgeToSuperview:NSLayoutAttributeTop withInset:topInset];
}

- (UITextView *)createTextView
{
    UITextView *textView = [UITextView new];
    textView.font = [UIFont.fw fontOfSize:15];
    textView.textColor = [Theme textColor];
    textView.fw.cursorColor = Theme.textColor;
    textView.fw.cursorRect = CGRectMake(0, 0, 2, 0);
    [textView.fw setBorderColor:[Theme borderColor] width:0.5 cornerRadius:5];
    [textView.fw setDimension:NSLayoutAttributeWidth toSize:FWScreenWidth - 15 * 2];
    [textView.fw setDimension:NSLayoutAttributeHeight toSize:100];
    return textView;
}

- (UITextField *)createTextField
{
    UITextField *textField = [UITextField new];
    textField.font = [UIFont.fw fontOfSize:15];
    textField.textColor = [Theme textColor];
    textField.fw.cursorColor = Theme.textColor;
    textField.fw.cursorRect = CGRectMake(0, 0, 2, 0);
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textField.fw setBorderView:UIRectEdgeBottom color:[Theme borderColor] width:0.5];
    [textField.fw setDimension:NSLayoutAttributeWidth toSize:FWScreenWidth - 15 * 2];
    [textField.fw setDimension:NSLayoutAttributeHeight toSize:50];
    return textField;
}

#pragma mark - Action

- (void)onSubmit
{
    NSLog(@"点击了提交");
}

@end
