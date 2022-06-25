/*!
 @header     TestChainViewController.m
 @indexgroup Example
 @brief      TestChainViewController
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/6/19
 */

#import "TestChainViewController.h"

@interface TestChainViewController ()

@property (nonatomic, strong) FWAttributedLabel *attributedLabel;
@property (nonatomic, assign) CGFloat buttonWidth;

@end

@implementation TestChainViewController

- (void)renderView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = Theme.textColor;
    [self.view addSubview:view];
    view.fw_layoutChain.remake().topWithInset(20).leftWithInset(20).size(CGSizeMake(100, 100)).width(50).height(50);
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"text";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = Theme.textColor;
    label.backgroundColor = Theme.backgroundColor;
    label.fw_contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [label fw_setCornerRadius:5];
    [self.view addSubview:label];
    [label fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
        make.widthToView(view).centerYToView(view).leftToViewRightWithOffset(view, 20);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:[Theme textColor] forState:UIControlStateNormal];
    [button setTitle:@"btn" forState:UIControlStateNormal];
    [self.view addSubview:button];
    button.fw_layoutChain.widthToView(view).heightToView(view).leftToViewRightWithOffset(label, 20).topToViewWithOffset(view, 0);
    
    UIImageView *image = [UIImageView new];
    image.image = [UIImage.fw imageWithAppIcon];
    [self.view addSubview:image];
    image.fw_layoutChain.attribute(NSLayoutAttributeWidth, NSLayoutAttributeWidth, view).heightToWidth(1.0).centerYToView(view).attributeWithOffset(NSLayoutAttributeLeft, NSLayoutAttributeRight, button, 20);
    
    CGFloat lineHeight = ceil(FWFontRegular(16).lineHeight);
    NSString *moreText = @"点击展开";
    self.buttonWidth = [moreText fw_sizeWithFont:FWFontRegular(16)].width + 20;
    FWAttributedLabel *attr = [[FWAttributedLabel alloc] init];
    _attributedLabel = attr;
    attr.clipsToBounds = YES;
    attr.numberOfLines = 2;
    attr.lineBreakMode = kCTLineBreakByTruncatingTail;
    attr.lineTruncatingSpacing = self.buttonWidth;
    attr.backgroundColor = Theme.backgroundColor;
    attr.font = FWFontRegular(16);
    attr.textColor = Theme.textColor;
    attr.textAlignment = kCTTextAlignmentLeft;
    [self.view addSubview:attr];
    attr.fw_layoutChain.leftWithInset(20).rightWithInset(20).topToViewBottomWithOffset(view, 20);
    
    [self.attributedLabel setText:@"我是非常长的文本，要多长有多长，我会自动截断，再附加视图，不信你看嘛，我是显示不下了的文本，我是更多文本，我是更多更多的文本，我又要换行了"];
    UILabel *collapseLabel = [UILabel fw_labelWithFont:FWFontRegular(16) textColor:UIColor.blueColor text:@"点击收起"];
    collapseLabel.textAlignment = NSTextAlignmentCenter;
    collapseLabel.frame = CGRectMake(0, 0, self.buttonWidth, ceil(FWFontRegular(16).lineHeight));
    collapseLabel.userInteractionEnabled = YES;
    FWWeakifySelf();
    [collapseLabel fw_addTapGestureWithBlock:^(id  _Nonnull sender) {
        FWStrongifySelf();
        self.attributedLabel.lineTruncatingSpacing = self.buttonWidth;
        self.attributedLabel.numberOfLines = 2;
        self.attributedLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
    }];
    [self.attributedLabel appendView:collapseLabel];
    
    UILabel *expandLabel = [UILabel fw_labelWithFont:FWFontRegular(16) textColor:UIColor.blueColor text:moreText];
    expandLabel.textAlignment = NSTextAlignmentCenter;
    expandLabel.frame = CGRectMake(0, 0, self.buttonWidth, lineHeight);
    expandLabel.userInteractionEnabled = YES;
    [expandLabel fw_addTapGestureWithBlock:^(id  _Nonnull sender) {
        FWStrongifySelf();
        self.attributedLabel.lineTruncatingSpacing = 0;
        self.attributedLabel.numberOfLines = 0;
        self.attributedLabel.lineBreakMode = kCTLineBreakByWordWrapping;
    }];
    self.attributedLabel.lineTruncatingAttachment = [FWAttributedLabelAttachment attachmentWith:expandLabel margin:UIEdgeInsetsZero alignment:FWAttributedAlignmentCenter maxSize:CGSizeZero];
    
    UILabel *emptyLabel = [[UILabel alloc] init];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = Theme.textColor;
    emptyLabel.backgroundColor = Theme.backgroundColor;
    [self.view addSubview:emptyLabel];
    [emptyLabel fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
        make.topToViewBottomWithOffset(attr, 20);
        make.leftWithInset(20);
    }];
    
    UILabel *emptyLabel2 = [[UILabel alloc] init];
    emptyLabel2.textAlignment = NSTextAlignmentCenter;
    emptyLabel2.textColor = Theme.textColor;
    emptyLabel2.backgroundColor = Theme.backgroundColor;
    emptyLabel2.fw_contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.view addSubview:emptyLabel2];
    [emptyLabel2 fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
        make.leftToViewRightWithOffset(emptyLabel, 20);
        make.centerYToView(emptyLabel);
    }];
    
    UILabel *resultLabel = [[UILabel alloc] init];
    CGSize emptySize = [emptyLabel sizeThatFits:CGSizeMake(1, 1)];
    CGSize emptySize2 = [emptyLabel2 sizeThatFits:CGSizeMake(1, 1)];
    resultLabel.text = [NSString stringWithFormat:@"%@ <=> %@", NSStringFromCGSize(emptySize), NSStringFromCGSize(emptySize2)];
    resultLabel.textAlignment = NSTextAlignmentCenter;
    resultLabel.textColor = Theme.textColor;
    [self.view addSubview:resultLabel];
    [resultLabel fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
        make.centerX();
        make.centerYToView(emptyLabel2);
    }];
    
    UILabel *numberLabel = [UILabel new];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.numberOfLines = 0;
    numberLabel.textColor = Theme.textColor;
    numberLabel.text = [self numberString];
    [self.view addSubview:numberLabel];
    [numberLabel fw_layoutMaker:^(FWLayoutChain * _Nonnull make) {
        make.leftWithInset(20).rightWithInset(20)
            .topToViewBottomWithOffset(attr, 50);
    }];
}

- (NSString *)numberString
{
    NSNumber *number = [NSNumber numberWithDouble:12345.6789];
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"number: %@\n\n", number];
    [string appendFormat:@"round: %@\n", [number fw_roundString:2]];
    [string appendFormat:@"ceil: %@\n", [number fw_ceilString:2]];
    [string appendFormat:@"floor: %@\n", [number fw_floorString:2]];
    [string appendFormat:@"round: %@\n", [number fw_roundNumber:2]];
    [string appendFormat:@"ceil: %@\n", [number fw_ceilNumber:2]];
    [string appendFormat:@"floor: %@\n\n", [number fw_floorNumber:2]];
    
    number = [NSNumber numberWithDouble:0.6049];
    [string appendFormat:@"number: %@\n\n", number];
    [string appendFormat:@"round: %@\n", [number fw_roundString:2]];
    [string appendFormat:@"ceil: %@\n", [number fw_ceilString:2]];
    [string appendFormat:@"floor: %@\n", [number fw_floorString:2]];
    [string appendFormat:@"round: %@\n", [number fw_roundNumber:2]];
    [string appendFormat:@"ceil: %@\n", [number fw_ceilNumber:2]];
    [string appendFormat:@"floor: %@\n", [number fw_floorNumber:2]];
    return string;
}

@end
