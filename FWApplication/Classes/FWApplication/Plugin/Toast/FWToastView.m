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
@property (nonatomic, assign) BOOL touchEnabled;

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
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (self.firstView && [self.firstView respondsToSelector:@selector(startAnimating)]) {
        [(UIView<FWIndicatorViewPlugin> *)self.firstView startAnimating];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // contentView默认垂直居中于toastView
    CGSize contentViewSize = [self contentViewSize];
    if (CGSizeEqualToSize(contentViewSize, CGSizeZero)) return;
    self.contentView.frame = CGRectMake((CGRectGetWidth(self.bounds) - self.contentMarginInsets.left - self.contentMarginInsets.right - contentViewSize.width) / 2.0 + self.contentMarginInsets.left, (CGRectGetHeight(self.bounds) - self.contentMarginInsets.top - self.contentMarginInsets.bottom - contentViewSize.height) / 2.0 + self.contentMarginInsets.top + self.verticalOffset, contentViewSize.width, contentViewSize.height);
    
    // 如果contentView要比toastView高，则置顶展示
    if (CGRectGetHeight(self.contentView.bounds) > CGRectGetHeight(self.bounds)) {
        CGRect frame = self.contentView.frame;
        frame.origin.y = 0;
        self.contentView.frame = frame;
    }
    
    CGFloat originY = self.contentInsets.top;
    if (self.firstView) {
        if (self.indicatorSize.width > 0 && self.indicatorSize.height > 0) {
            self.firstView.frame = CGRectMake(self.firstView.frame.origin.x, self.firstView.frame.origin.y, self.indicatorSize.width, self.indicatorSize.height);
        } else {
            [self.firstView sizeToFit];
        }
        CGRect frame = self.firstView.frame;
        frame.origin = CGPointMake((contentViewSize.width - self.contentInsets.left - self.contentInsets.right - frame.size.width) / 2.0 + self.contentInsets.left, originY);
        self.firstView.frame = frame;
        originY = CGRectGetMaxY(self.firstView.frame);
    }
    
    CGFloat maxTitleWidth = contentViewSize.width - self.contentInsets.left - self.contentInsets.right;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(maxTitleWidth, CGFLOAT_MAX)];
    self.titleLabel.frame = CGRectMake((maxTitleWidth - titleLabelSize.width) / 2.0 + self.contentInsets.left, originY + (self.firstView.frame.size.height > 0 && titleLabelSize.height > 0 ? self.contentSpacing : 0), titleLabelSize.width, titleLabelSize.height);
}

- (CGSize)contentViewSize
{
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) return CGSizeZero;
    
    CGFloat contentWidth = self.contentInsets.left + self.contentInsets.right;
    CGFloat contentHeight = self.contentInsets.top + self.contentInsets.bottom;
    CGFloat maxContentWidth = self.bounds.size.width - self.contentMarginInsets.left - self.contentMarginInsets.right - self.contentInsets.left - self.contentInsets.right;
    
    CGSize firstViewSize = CGSizeZero;
    if (self.firstView) firstViewSize = (self.indicatorSize.width > 0 && self.indicatorSize.height > 0) ? self.indicatorSize : [self.firstView sizeThatFits:CGSizeMake(maxContentWidth, CGFLOAT_MAX)];
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(maxContentWidth, CGFLOAT_MAX)];
    
    contentWidth += MAX(firstViewSize.width, titleLabelSize.width);
    contentHeight += firstViewSize.height + titleLabelSize.height;
    if (firstViewSize.height > 0 && titleLabelSize.height > 0) contentHeight += self.contentSpacing;
    return CGSizeMake(contentWidth, contentHeight);
}

#pragma mark - Accessor

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    _attributedTitle = attributedTitle;
    self.titleLabel.attributedText = attributedTitle;
    [self setNeedsLayout];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    UIView *progressView = self.progressView ?: self.customView;
    if (progressView && [progressView respondsToSelector:@selector(setProgress:)]) {
        [(UIView<FWProgressViewPlugin> *)progressView setProgress:progress];
    }
    [self setNeedsLayout];
}

- (void)setIndicatorView:(UIView<FWIndicatorViewPlugin> *)indicatorView
{
    if (self.type != FWToastViewTypeIndicator || !indicatorView) return;
    [_indicatorView removeFromSuperview];
    _indicatorView = indicatorView;
    _indicatorView.userInteractionEnabled = NO;
    [self.contentView addSubview:_indicatorView];
    [self setNeedsLayout];
}

- (void)setProgressView:(UIView<FWProgressViewPlugin> *)progressView
{
    if (self.type != FWToastViewTypeProgress || !progressView) return;
    [_progressView removeFromSuperview];
    _progressView = progressView;
    _progressView.userInteractionEnabled = NO;
    [self.contentView addSubview:_progressView];
    [self setNeedsLayout];
}

- (void)setCancelBlock:(void (^)(void))cancelBlock
{
    _cancelBlock = cancelBlock;
    if (cancelBlock && !self.touchEnabled) {
        self.touchEnabled = YES;
        
        __weak __typeof__(self) self_weak_ = self;
        self.contentView.userInteractionEnabled = YES;
        [self.contentView fw_addTapGestureWithBlock:^(id sender) {
            __typeof__(self) self = self_weak_;
            void (^cancelBlock)(void) = self.cancelBlock;
            if (cancelBlock) {
                [self hide];
                cancelBlock();
            }
        }];
    }
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
