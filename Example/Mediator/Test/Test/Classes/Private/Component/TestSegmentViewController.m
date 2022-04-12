//
//  TestSegmentViewController.m
//  Example
//
//  Created by wuyong on 2018/12/13.
//  Copyright © 2018 wuyong.site. All rights reserved.
//

#import "TestSegmentViewController.h"

@interface TestSegmentViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) FWTextTagCollectionView *tagCollectionView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FWSegmentedControl *segmentedControl;

@property (nonatomic, strong) UIImageView *gifImageView;

@end

@implementation TestSegmentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    FWWeakifySelf();
    [self fwSetRightBarItem:@"Save" block:^(id sender) {
        FWStrongifySelf();
        [self.gifImageView.image fwSaveImageWithBlock:nil];
    }];
}

- (void)renderView
{
    UIImageView *imageView = [UIImageView new];
    _gifImageView = imageView;
    imageView.backgroundColor = [Theme cellColor];
    [self.view addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [imageView.fw pinEdgesToSuperviewWithInsets:UIEdgeInsetsZero excludingEdge:NSLayoutAttributeBottom];
    [imageView.fw setDimension:NSLayoutAttributeHeight toSize:100];
    imageView.userInteractionEnabled = YES;
    
    FWProgressView *progressView = [FWProgressView new];
    [imageView addSubview:progressView];
    [progressView.fw setDimensionsToSize:CGSizeMake(40, 40)];
    [progressView.fw alignCenterToSuperview];
    
    BOOL useTimestamp = YES;
    NSString *timestampStr = useTimestamp ? [NSString stringWithFormat:@"?t=%@", @(NSDate.fw.currentTime)] : @"";
    NSString *gifImageUrl = [NSString stringWithFormat:@"http://ww2.sinaimg.cn/bmiddle/642beb18gw1ep3629gfm0g206o050b2a.gif%@", timestampStr];
    progressView.progress = 0;
    progressView.hidden = NO;
    [imageView fwSetImageWithURL:gifImageUrl placeholderImage:nil options:0 context:nil completion:^(UIImage * _Nullable image, NSError * _Nullable error) {
        progressView.hidden = YES;
        if (image) {
            imageView.image = image;
        }
    } progress:^(double progress) {
        progressView.progress = progress;
    }];
    
    CGSize activitySize = CGSizeMake(30, 30);
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.color = Theme.textColor;
    activityView.size = activitySize;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    [activityView.fw alignAxis:NSLayoutAttributeCenterX toView:self.view];
    [activityView.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:imageView withOffset:10];
    [activityView.fw setDimensionsToSize:activitySize];
    
    UILabel *textLabel = [UILabel.fw labelWithFont:[UIFont.fw fontOfSize:15] textColor:[Theme textColor]];
    textLabel.numberOfLines = 0;
    textLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textLabel];
    [textLabel.fw alignAxisToSuperview:NSLayoutAttributeCenterX];
    [textLabel.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:activityView withOffset:10];
    
    NSMutableAttributedString *attrStr = [NSMutableAttributedString new];
    UIFont *attrFont = FWFontLight(16);
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"细体16 " withFont:attrFont]];
    attrFont = FWFontRegular(16);
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"常规16 " withFont:attrFont]];
    attrFont = FWFontBold(16);
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"粗体16 " withFont:attrFont]];
    attrFont = [UIFont italicSystemFontOfSize:16];
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"斜体16 " withFont:attrFont]];
    attrFont = [[UIFont italicSystemFontOfSize:16] fwBoldFont];
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"粗斜体16 " withFont:attrFont]];
    
    attrFont = [UIFont.fw fontOfSize:16 weight:UIFontWeightLight];
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"\n细体16 " withFont:attrFont]];
    attrFont = [UIFont.fw fontOfSize:16 weight:UIFontWeightRegular];
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"常规16 " withFont:attrFont]];
    attrFont = [UIFont.fw fontOfSize:16 weight:UIFontWeightBold];
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"粗体16 " withFont:attrFont]];
    attrFont = [[UIFont.fw fontOfSize:16 weight:UIFontWeightRegular] fwItalicFont];
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"斜体16 " withFont:attrFont]];
    attrFont = [[[[[[UIFont.fw fontOfSize:16 weight:UIFontWeightBold] fwItalicFont] fwNonBoldFont] fwBoldFont] fwNonItalicFont] fwItalicFont];
    [attrStr appendAttributedString:[NSAttributedString fwAttributedString:@"粗斜体16 " withFont:attrFont]];
    textLabel.attributedText = attrStr;
    
    FWAttributedLabel *label = [FWAttributedLabel new];
    label.backgroundColor = Theme.cellColor;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [Theme textColor];
    label.textAlignment = kCTTextAlignmentCenter;
    [self.view addSubview:label];
    [label.fw pinEdgeToSuperview:NSLayoutAttributeLeft];
    [label.fw pinEdgeToSuperview:NSLayoutAttributeRight];
    [label.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:textLabel withOffset:10];
    [label.fw setDimension:NSLayoutAttributeHeight toSize:30];
    
    [label appendText:@"文本 "];
    UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    labelView.backgroundColor = [UIColor redColor];
    [labelView.fw setCornerRadius:15];
    [label appendView:labelView margin:UIEdgeInsetsZero alignment:FWAttributedAlignmentCenter];
    [label appendText:@" "];
    UIImage *image = [UIImage.fw imageWithColor:[UIColor blueColor] size:CGSizeMake(30, 30)];
    [label appendImage:image maxSize:image.size margin:UIEdgeInsetsZero alignment:FWAttributedAlignmentCenter];
    [label appendText:@" 结束"];
    
    FWTextTagCollectionView *tagCollectionView = [FWTextTagCollectionView new];
    _tagCollectionView = tagCollectionView;
    tagCollectionView.verticalSpacing = 5;
    tagCollectionView.horizontalSpacing = 5;
    [self.view addSubview:tagCollectionView];
    [tagCollectionView.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:10];
    [tagCollectionView.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:10];
    [tagCollectionView.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:label withOffset:10];
    
    [self.tagCollectionView removeAllTags];
    NSArray *testTags = @[@"80减12", @"首单减15", @"在线支付", @"支持自提", @"26减3", @"80减12", @"首单减15", @"在线支付", @"支持自提", @"26减3"];
    for (NSString *tagName in testTags) {
        [self.tagCollectionView addTag:tagName withConfig:self.textTagConfig];
    }
    
    FWMarqueeLabel *marqueeLabel = [FWMarqueeLabel.fw labelWithFont:FWFontRegular(16) textColor:[Theme textColor] text:@"FWMarqueeLabel 会在添加到界面上后，并且文字超过 label 宽度时自动滚动"];
    [self.view addSubview:marqueeLabel];
    [marqueeLabel.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:10];
    [marqueeLabel.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:10];
    [marqueeLabel.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:self.tagCollectionView withOffset:10];
    [marqueeLabel.fw setDimension:NSLayoutAttributeHeight toSize:20];
    // 自动布局需调用此方法初始化frame
    [marqueeLabel setNeedsLayout];
    [marqueeLabel layoutIfNeeded];
    
    NSArray *sectionTitles = @[@"菜单一", @"菜单二", @"长的菜单三", @"菜单四", @"菜单五", @"菜单六"];
    NSArray *sectionContents = @[@"我是内容一", @"我是内容二", @"我是长的内容三", @"我是内容四", @"我是内容五", @"我是内容六"];
    self.segmentedControl = [[FWSegmentedControl alloc] initWithSectionTitles:@[]];
    self.segmentedControl.backgroundColor = Theme.cellColor;
    self.segmentedControl.selectionStyle = FWSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.segmentWidthStyle = FWSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.selectionIndicatorLocation = FWSegmentedControlSelectionIndicatorLocationBottom;
    self.segmentedControl.selectionIndicatorCornerRadius = 2.5f;
    self.segmentedControl.titleTextAttributes = @{NSFontAttributeName: [UIFont.fw fontOfSize:16], NSForegroundColorAttributeName: Theme.textColor};
    self.segmentedControl.selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont.fw boldFontOfSize:16], NSForegroundColorAttributeName: Theme.textColor};
    [self.view addSubview:self.segmentedControl];
    [self.segmentedControl.fw pinEdgeToSuperview:NSLayoutAttributeLeft];
    [self.segmentedControl.fw pinEdgeToSuperview:NSLayoutAttributeRight];
    [self.segmentedControl.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:marqueeLabel withOffset:10];
    [self.segmentedControl.fw setDimension:NSLayoutAttributeHeight toSize:50];
    self.segmentedControl.sectionTitles = sectionTitles;
    self.segmentedControl.selectedSegmentIndex = 5;
    FWWeakifySelf();
    self.segmentedControl.indexChangeBlock = ^(NSUInteger index) {
        FWStrongifySelf();
        [self.scrollView scrollRectToVisible:CGRectMake(FWScreenWidth * index, 0, FWScreenWidth, 100) animated:YES];
    };
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(FWScreenWidth * sectionTitles.count, 100);
    self.scrollView.delegate = self;
    [self.scrollView scrollRectToVisible:CGRectMake(FWScreenWidth * self.segmentedControl.selectedSegmentIndex, 0, FWScreenWidth, 100) animated:NO];
    [self.view addSubview:self.scrollView];
    [self.scrollView.fw pinEdgeToSuperview:NSLayoutAttributeLeft];
    [self.scrollView.fw pinEdgeToSuperview:NSLayoutAttributeRight];
    [self.scrollView.fw pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:self.segmentedControl];
    [self.scrollView.fw setDimension:NSLayoutAttributeHeight toSize:100];
    
    for (NSInteger i = 0; i < sectionContents.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(FWScreenWidth * i, 0, FWScreenWidth, 100)];
        label.text = sectionContents[i];
        label.numberOfLines = 0;
        [self.scrollView addSubview:label];
    }
}

- (FWTextTagConfig *)textTagConfig
{
    FWTextTagConfig *tagConfig = [[FWTextTagConfig alloc] init];
    tagConfig.textFont = [UIFont systemFontOfSize:10];
    tagConfig.textColor = [Theme textColor];
    tagConfig.selectedTextColor = [Theme textColor];
    tagConfig.backgroundColor = [Theme cellColor];
    tagConfig.selectedBackgroundColor = [Theme cellColor];
    tagConfig.cornerRadius = 2;
    tagConfig.selectedCornerRadius = 2;
    tagConfig.borderWidth = 1;
    tagConfig.selectedBorderWidth = 1;
    tagConfig.borderColor = [UIColor.fw colorWithHex:0xF3B2AF];
    tagConfig.selectedBorderColor = [UIColor.fw colorWithHex:0xF3B2AF];
    tagConfig.extraSpace = CGSizeMake(10, 6);
    tagConfig.enableGradientBackground = NO;
    return tagConfig;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    
    [self.segmentedControl setSelectedSegmentIndex:page animated:YES];
}

@end
