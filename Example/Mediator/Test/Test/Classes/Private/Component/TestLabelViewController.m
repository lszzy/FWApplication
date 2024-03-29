//
//  TestLabelViewController.m
//  Example
//
//  Created by wuyong on 2019/8/5.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

#import "TestLabelViewController.h"

@interface TestLabelViewController ()

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UILabel *label2;
@property (nonatomic, weak) FWAttributedLabel *attrLabel;
@property (nonatomic, weak) FWAttributedLabel *attrLabel2;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UITextView *textView2;
@property (nonatomic, weak) UILabel *resultLabel;
@property (nonatomic, assign) NSInteger count;

@end

@implementation TestLabelViewController

- (void)renderView
{
    UILabel *label = [UILabel new];
    _label = label;
    label.backgroundColor = [Theme cellColor];
    label.font = [UIFont systemFontOfSize:16];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    label.fw_layoutChain.leftWithInset(10).rightWithInset(10).topWithInset(10);
    
    UILabel *label2 = [UILabel new];
    _label2 = label2;
    label2.backgroundColor = [Theme cellColor];
    label2.font = [UIFont systemFontOfSize:16];
    label2.numberOfLines = 0;
    [self.view addSubview:label2];
    label2.fw_layoutChain.leftToView(label).rightToView(label).topToViewBottomWithOffset(label, 10);
    
    FWAttributedLabel *attrLabel = [FWAttributedLabel new];
    _attrLabel = attrLabel;
    attrLabel.backgroundColor = [Theme cellColor];
    attrLabel.font = [UIFont systemFontOfSize:16];
    attrLabel.textColor = Theme.textColor;
    [self.view addSubview:attrLabel];
    attrLabel.fw_layoutChain.leftToView(label).rightToView(label).topToViewBottomWithOffset(label2, 10);
    
    FWAttributedLabel *attrLabel2 = [FWAttributedLabel new];
    _attrLabel2 = attrLabel2;
    attrLabel2.backgroundColor = [Theme cellColor];
    attrLabel2.textColor = Theme.textColor;
    attrLabel2.numberOfLines = 0;
    attrLabel2.font = [UIFont systemFontOfSize:16];
    attrLabel2.lineBreakMode = kCTLineBreakByCharWrapping;
    attrLabel2.lineSpacing = 8 - attrLabel.font.fw_spaceHeight;
    [self.view addSubview:attrLabel2];
    attrLabel2.fw_layoutChain.leftToView(label).rightToView(label).topToViewBottomWithOffset(attrLabel, 10);
    
    UITextView *textView = [UITextView new];
    _textView = textView;
    textView.editable = NO;
    textView.backgroundColor = [Theme cellColor];
    textView.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView];
    textView.fw_layoutChain.leftToView(label).rightToView(label).topToViewBottomWithOffset(attrLabel2, 10).height(120);
    
    UITextView *textView2 = [UITextView new];
    _textView2 = textView2;
    textView2.editable = NO;
    textView2.backgroundColor = [Theme cellColor];
    textView2.textColor = Theme.textColor;
    textView2.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:textView2];
    textView2.fw_layoutChain.leftToView(label).rightToView(label).topToViewBottomWithOffset(textView, 10).height(120);
    
    UILabel *resultLabel = [UILabel new];
    _resultLabel = resultLabel;
    resultLabel.backgroundColor = [Theme cellColor];
    resultLabel.numberOfLines = 0;
    resultLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:resultLabel];
    resultLabel.fw_layoutChain.leftToView(label).rightToView(label).topToViewBottomWithOffset(textView2, 10);
}

- (NSString *)testText
{
    NSString *text = @"I am a very long text I am a very long text I veryverylongword bad I am a very long text finish!";
    return [NSString stringWithFormat:@"%@: %@", @(++self.count), text];
}

- (NSAttributedString *)testAttrText
{
    FWAttributedOption *option = [FWAttributedOption new];
    option.font = [UIFont systemFontOfSize:16];
    option.foregroundColor = Theme.textColor;
    option.lineSpacingMultiplier = 0.5;
    option.paragraphStyle = [NSMutableParagraphStyle new];
    option.paragraphStyle.alignment = NSTextAlignmentLeft;
    option.paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSAttributedString *attrText = [NSAttributedString fw_attributedString:[self testText] withOption:option];
    return attrText;
}

- (void)renderData
{
    CGSize size = CGSizeZero;
    NSMutableString *resultText = [NSMutableString new];
    
    self.label.text = [self testText];
    size = [self.label fw_textSize];
    [resultText appendFormat:@"label: %@\n", NSStringFromCGSize(size)];
    
    self.label2.attributedText = [self testAttrText];
    size = [self.label2 fw_attributedTextSize];
    [resultText appendFormat:@"label2: %@\n", NSStringFromCGSize(size)];
    
    self.attrLabel.text = [self testText];
    size = [self.attrLabel fw_fitSize];
    [resultText appendFormat:@"attrLabel: %@\n", NSStringFromCGSize(size)];
    
    self.attrLabel2.attributedText = [self testAttrText];
    size = [self.attrLabel2 fw_fitSize];
    [resultText appendFormat:@"attrLabel2: %@\n", NSStringFromCGSize(size)];
    
    self.textView.text = [self testText];
    size = [self.textView fw_textSize];
    [resultText appendFormat:@"textView: %@\n", NSStringFromCGSize(size)];
    self.textView.fw_layoutChain.height(size.height);
    
    self.textView2.attributedText = [self testAttrText];
    size = [self.textView2 fw_attributedTextSize];
    [resultText appendFormat:@"textView2: %@", NSStringFromCGSize(size)];
    self.textView2.fw_layoutChain.height(size.height);
    
    self.resultLabel.text = resultText;
}

@end
