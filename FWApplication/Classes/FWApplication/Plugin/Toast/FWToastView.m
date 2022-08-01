/**
 @header     FWToastView.m
 @indexgroup FWApplication
      FWToastView
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "FWToastView.h"
#import "FWViewPlugin.h"
@import FWFramework;

#pragma mark - FWToastView

@interface FWToastView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSTimer *hideTimer;

@end

@implementation FWToastView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _type = FWToastViewTypeCustom;
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithType:(FWToastViewType)type
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _type = type;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    _contentBackgroundColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
    _contentMarginInsets = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
    _contentInsets = UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f);
    _contentSpacing = 5.f;
    _contentCornerRadius = 5.f;
    _verticalOffset = -30;
    _indicatorColor = [UIColor whiteColor];
    if (self.type == FWToastViewTypeProgress) {
        _indicatorSize = CGSizeMake(37.f, 37.f);
    } else {
        _indicatorSize = CGSizeZero;
    }
    _titleFont = [UIFont systemFontOfSize:16];
    _titleColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    _contentView = [[UIView alloc] init];
    _contentView.userInteractionEnabled = NO;
    _contentView.layer.masksToBounds = YES;
    [self addSubview:_contentView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 0;
    [_contentView addSubview:_titleLabel];
    
    switch (self.type) {
        case FWToastViewTypeImage: {
            _imageView = [[UIImageView alloc] init];
            _imageView.userInteractionEnabled = NO;
            _imageView.backgroundColor = [UIColor clearColor];
            [_contentView addSubview:_imageView];
            break;
        }
        case FWToastViewTypeIndicator: {
            _indicatorView = [UIView fw_indicatorViewWithStyle:FWIndicatorViewStyleDefault];
            _indicatorView.userInteractionEnabled = NO;
            [_contentView addSubview:_indicatorView];
            break;
        }
        case FWToastViewTypeProgress: {
            _progressView = [UIView fw_progressViewWithStyle:FWProgressViewStyleDefault];
            _progressView.userInteractionEnabled = NO;
            [_contentView addSubview:_progressView];
            break;
        }
        case FWToastViewTypeText:
        case FWToastViewTypeCustom:
        default: {
            break;
        }
    }
}

- (void)updateLayout
{
    self.contentView.backgroundColor = self.contentBackgroundColor;
    self.contentView.layer.cornerRadius = self.contentCornerRadius;
    [self.contentView fw_alignAxisToSuperview:NSLayoutAttributeCenterX];
    [self.contentView fw_alignAxisToSuperview:NSLayoutAttributeCenterY withOffset:self.verticalOffset];
    [self.contentView fw_pinEdgeToSuperview:NSLayoutAttributeTop withInset:self.contentMarginInsets.top relation:NSLayoutRelationGreaterThanOrEqual];
    [self.contentView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:self.contentMarginInsets.left relation:NSLayoutRelationGreaterThanOrEqual];
    [self.contentView fw_pinEdgeToSuperview:NSLayoutAttributeBottom withInset:self.contentMarginInsets.bottom relation:NSLayoutRelationGreaterThanOrEqual];
    [self.contentView fw_pinEdgeToSuperview:NSLayoutAttributeRight withInset:self.contentMarginInsets.right relation:NSLayoutRelationGreaterThanOrEqual];
    
    self.titleLabel.font = self.titleFont;
    self.titleLabel.textColor = self.titleColor;
    self.titleLabel.attributedText = self.attributedTitle;
    
    switch (self.type) {
        case FWToastViewTypeCustom: {
            self.firstView = self.customView;
            if (self.customView && !self.customView.superview) {
                [self.contentView addSubview:self.customView];
            }
            break;
        }
        case FWToastViewTypeImage: {
            self.firstView = self.imageView;
            self.imageView.image = self.indicatorImage;
            break;
        }
        case FWToastViewTypeIndicator: {
            self.firstView = self.indicatorView;
            self.indicatorView.color = self.indicatorColor;
            break;
        }
        case FWToastViewTypeProgress: {
            self.firstView = self.progressView;
            self.progressView.color = self.indicatorColor;
            break;
        }
        case FWToastViewTypeText:
        default: {
            break;
        }
    }
    
    if (!self.firstView) {
        [self.titleLabel fw_pinEdgesToSuperviewWithInsets:self.contentInsets];
        return;
    }
    
    if (self.indicatorSize.width > 0 && self.indicatorSize.height > 0) {
        [self.firstView fw_setDimensionsToSize:self.indicatorSize];
    }
    if (self.firstView && [self.firstView respondsToSelector:@selector(startAnimating)]) {
        [(UIView<FWIndicatorViewPlugin> *)self.firstView startAnimating];
    }
    
    if (self.horizontalAlignment) {
        [self.firstView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:self.contentInsets.left];
        [self.firstView fw_alignAxisToSuperview:NSLayoutAttributeCenterY];
        [self.firstView fw_pinEdgeToSuperview:NSLayoutAttributeTop withInset:self.contentInsets.top relation:NSLayoutRelationGreaterThanOrEqual];
        [self.firstView fw_pinEdgeToSuperview:NSLayoutAttributeBottom withInset:self.contentInsets.bottom relation:NSLayoutRelationGreaterThanOrEqual];
        [self.titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeRight withInset:self.contentInsets.right];
        [self.titleLabel fw_alignAxisToSuperview:NSLayoutAttributeCenterY];
        [self.titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeTop withInset:self.contentInsets.top relation:NSLayoutRelationGreaterThanOrEqual];
        [self.titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeBottom withInset:self.contentInsets.bottom relation:NSLayoutRelationGreaterThanOrEqual];
        self.titleLabel.fw_autoCollapse = YES;
        NSLayoutConstraint *collapseConstraint = [self.titleLabel fw_pinEdge:NSLayoutAttributeLeft toEdge:NSLayoutAttributeRight ofView:self.firstView withOffset:self.contentSpacing];
        [self.titleLabel fw_addCollapseConstraint:collapseConstraint];
    // 上下布局
    } else {
        [self.firstView fw_pinEdgeToSuperview:NSLayoutAttributeTop withInset:self.contentInsets.top];
        [self.firstView fw_alignAxisToSuperview:NSLayoutAttributeCenterX];
        [self.firstView fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:self.contentInsets.left relation:NSLayoutRelationGreaterThanOrEqual];
        [self.firstView fw_pinEdgeToSuperview:NSLayoutAttributeRight withInset:self.contentInsets.right relation:NSLayoutRelationGreaterThanOrEqual];
        [self.titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeBottom withInset:self.contentInsets.bottom];
        [self.titleLabel fw_alignAxisToSuperview:NSLayoutAttributeCenterX];
        [self.titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeLeft withInset:self.contentInsets.left relation:NSLayoutRelationGreaterThanOrEqual];
        [self.titleLabel fw_pinEdgeToSuperview:NSLayoutAttributeRight withInset:self.contentInsets.right relation:NSLayoutRelationGreaterThanOrEqual];
        self.titleLabel.fw_autoCollapse = YES;
        NSLayoutConstraint *collapseConstraint = [self.titleLabel fw_pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofView:self.firstView withOffset:self.contentSpacing];
        [self.titleLabel fw_addCollapseConstraint:collapseConstraint];
    }
}

#pragma mark - Accessor

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    _attributedTitle = attributedTitle;
    self.titleLabel.attributedText = attributedTitle;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    UIView *progressView = self.progressView ?: self.customView;
    if (progressView && [progressView respondsToSelector:@selector(setProgress:)]) {
        [(UIView<FWProgressViewPlugin> *)progressView setProgress:progress];
    }
}

- (void)setIndicatorView:(UIView<FWIndicatorViewPlugin> *)indicatorView
{
    if (self.type != FWToastViewTypeIndicator || !indicatorView) return;
    [_indicatorView removeFromSuperview];
    _indicatorView = indicatorView;
    _indicatorView.userInteractionEnabled = NO;
    [self.contentView addSubview:_indicatorView];
}

- (void)setProgressView:(UIView<FWProgressViewPlugin> *)progressView
{
    if (self.type != FWToastViewTypeProgress || !progressView) return;
    [_progressView removeFromSuperview];
    _progressView = progressView;
    _progressView.userInteractionEnabled = NO;
    [self.contentView addSubview:_progressView];
}

#pragma mark - Public

- (void)show
{
    [self showAnimated:NO];
}

- (void)showAnimated:(BOOL)animated
{
    [self updateLayout];
    
    if (animated) {
        self.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0;
        } completion:NULL];
    }
}

- (BOOL)hide
{
    if (self.superview != nil) {
        if (self.firstView && [self.firstView respondsToSelector:@selector(stopAnimating)]) {
            [(UIView<FWIndicatorViewPlugin> *)self.firstView stopAnimating];
        }
        [self removeFromSuperview];
        [self invalidateTimer];
        
        return YES;
    }
    return NO;
}

- (BOOL)hideAfterDelay:(NSTimeInterval)delay completion:(void (^)(void))completion
{
    if (self.superview != nil) {
        [self invalidateTimer];
        __weak __typeof__(self) self_weak_ = self;
        self.hideTimer = [NSTimer fw_commonTimerWithTimeInterval:delay block:^(NSTimer *timer) {
            __typeof__(self) self = self_weak_;
            BOOL hideSuccess = [self hide];
            if (hideSuccess && completion) {
                completion();
            }
        } repeats:NO];
    }
    return NO;
}

- (void)invalidateTimer
{
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

@end
