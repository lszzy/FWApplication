//
//  TestAttributedStringViewController.m
//  Example
//
//  Created by wuyong on 2019/8/22.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

#import "TestAttributedStringViewController.h"

@interface TestAttributedStringViewController ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSInteger count;

@end

@implementation TestAttributedStringViewController

- (void)renderView
{
    UILabel *label = [UILabel fw_labelWithFont:[UIFont fw_fontOfSize:15] textColor:[Theme textColor]];
    _label = label;
    label.backgroundColor = [Theme cellColor];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    [label fw_pinEdgesToSuperviewWithInsets:UIEdgeInsetsMake(15, 15, 15, 15) excludingEdge:NSLayoutAttributeBottom];
}

- (void)renderData
{
    FWAttributedOption *appearance = [FWAttributedOption appearance];
    appearance.lineHeightMultiplier = 1.5;
    appearance.font = [UIFont fw_fontOfSize:16];
    appearance.paragraphStyle = [NSMutableParagraphStyle new];
    
    NSMutableAttributedString *attrString = [NSMutableAttributedString new];
    FWAttributedOption *option = [FWAttributedOption new];
    [attrString appendAttributedString:[self renderString:option]];
    
    option = [FWAttributedOption new];
    option.lineHeightMultiplier = 2;
    [attrString appendAttributedString:[self renderString:option]];
    
    option = [FWAttributedOption new];
    [attrString appendAttributedString:[self renderString:option]];
    
    option = [FWAttributedOption new];
    option.lineHeightMultiplier = 0;
    option.lineSpacingMultiplier = 1;
    [attrString appendAttributedString:[self renderString:option]];
    self.label.attributedText = attrString;
}

- (NSAttributedString *)renderString:(FWAttributedOption *)option
{
    NSString *string = @"我是很长很长很长很长很长很长很长很长的文本，我是很长很长很长很长很长很长很长很长的文本。";
    if (self.count ++ != 0) {
        string = [@"\n" stringByAppendingString:string];
    }
    return [NSAttributedString fw_attributedString:string withOption:option];
}

@end
