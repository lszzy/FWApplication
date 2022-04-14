/**
 @header     FWRefreshView.m
 @indexgroup FWApplication
      FWRefreshView
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/10/16
 */

#import "FWRefreshView.h"
#import "FWViewPlugin.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#pragma mark - FWPullRefreshArrowView

@interface FWPullRefreshArrowView : UIView

@property (nonatomic, strong) UIColor *arrowColor;

@end

@implementation FWPullRefreshArrowView

@synthesize arrowColor;

- (UIColor *)arrowColor {
    if (arrowColor) return arrowColor;
    return [UIColor grayColor]; // default Color
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    
    // the arrow
    CGContextMoveToPoint(c, 7.5, 8.5);
    CGContextAddLineToPoint(c, 7.5, 31.5);
    CGContextMoveToPoint(c, 0, 24);
    CGContextAddLineToPoint(c, 7.5, 31.5);
    CGContextAddLineToPoint(c, 15, 24);
    CGContextSetLineWidth(c, 1.5);
    [[self arrowColor] setStroke];
    CGContextStrokePath(c);
    
    CGContextRestoreGState(c);
}

@end

#pragma mark - FWPullRefreshView

static CGFloat FWPullRefreshViewHeight = 60;

@interface FWPullRefreshView ()

@property (nonatomic, copy) void (^pullRefreshBlock)(void);
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;

@property (nonatomic, strong) FWPullRefreshArrowView *arrowView;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UILabel *subtitleLabel;
@property (nonatomic, readwrite) FWPullRefreshState state;
@property (nonatomic, assign) BOOL userTriggered;

@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *subtitles;
@property (nonatomic, strong) NSMutableArray *viewForState;
@property (nonatomic, weak) UIView *currentCustomView;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalTopInset;
@property (nonatomic, readwrite) CGFloat pullingPercent;

@property (nonatomic, assign) BOOL showsPullToRefresh;
@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, assign) BOOL isActive;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForLoading;

@end

#pragma mark - FWInfiniteScrollView

static CGFloat FWInfiniteScrollViewHeight = 60;

@interface FWInfiniteScrollView ()

@property (nonatomic, copy) void (^infiniteScrollBlock)(void);
@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;

@property (nonatomic, readwrite) FWInfiniteScrollState state;
@property (nonatomic, assign) BOOL userTriggered;
@property (nonatomic, strong) NSMutableArray *viewForState;
@property (nonatomic, weak) UIView *currentCustomView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalBottomInset;
@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, assign) BOOL isActive;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForInfiniteScrolling;

@end

#pragma mark - FWPullRefreshView

@implementation FWPullRefreshView

// public properties
@synthesize pullRefreshBlock, arrowColor, textColor, indicatorColor;
@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize showsPullToRefresh = _showsPullToRefresh;
@synthesize arrowView = _arrowView;
@synthesize indicatorView = _indicatorView;
@synthesize titleLabel = _titleLabel;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.textColor = [UIColor darkGrayColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.showsTitleLabel = [self.indicatorView isKindOfClass:[UIActivityIndicatorView class]];
        self.showsArrowView = self.showsTitleLabel;
        self.shouldChangeAlpha = YES;
        self.state = FWPullRefreshStateStopped;
        self.pullingPercent = 0;
        
        self.titles = [NSMutableArray arrayWithObjects:NSLocalizedString(@"下拉可以刷新   ",),
                       NSLocalizedString(@"松开立即刷新   ",),
                       NSLocalizedString(@"正在刷新数据...",),
                       nil];
        self.subtitles = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
        self.viewForState = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.fw.showPullRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                [scrollView.panGestureRecognizer.fw unobserveProperty:@"state" target:self action:@selector(gestureRecognizer:stateChanged:)];
                self.isObserving = NO;
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    id customView = [self.viewForState objectAtIndex:self.state];
    BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
    BOOL customViewChanged = customView != self.currentCustomView;
    if (customViewChanged || !hasCustomView) {
        [self.currentCustomView removeFromSuperview];
        self.currentCustomView = nil;
    }
    
    self.titleLabel.hidden = hasCustomView || !self.showsTitleLabel;
    self.subtitleLabel.hidden = hasCustomView || !self.showsTitleLabel;
    self.arrowView.hidden = hasCustomView || !self.showsArrowView;
    
    if(hasCustomView) {
        if (customViewChanged) {
            self.currentCustomView = customView;
            [self addSubview:customView];
        }
        CGRect viewBounds = [customView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), self.indicatorPadding > 0 ? self.indicatorPadding : roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
    }
    else {
        switch (self.state) {
            case FWPullRefreshStateAll:
            case FWPullRefreshStateStopped: {
                [self.indicatorView stopAnimating];
                if (self.showsArrowView) {
                    [self rotateArrow:0 hide:NO];
                }
                break;
            }
            case FWPullRefreshStateTriggered: {
                if (self.showsArrowView) {
                    [self rotateArrow:(float)M_PI hide:NO];
                } else {
                    if (!self.indicatorView.isAnimating) {
                        [self.indicatorView startAnimating];
                    }
                }
                break;
            }
            case FWPullRefreshStateLoading: {
                [self.indicatorView startAnimating];
                if (self.showsArrowView) {
                    [self rotateArrow:0 hide:YES];
                }
                break;
            }
        }
        
        CGFloat leftViewWidth = MAX(self.arrowView.bounds.size.width, self.indicatorView.bounds.size.width);
        
        CGFloat margin = 10;
        CGFloat marginY = 2;
        CGFloat labelMaxWidth = self.bounds.size.width - margin - leftViewWidth;
        
        self.titleLabel.text = self.showsTitleLabel ? [self.titles objectAtIndex:self.state] : nil;
        
        NSString *subtitle = self.showsTitleLabel ? [self.subtitles objectAtIndex:self.state] : nil;
        self.subtitleLabel.text = subtitle.length > 0 ? subtitle : nil;
        
        CGSize titleSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(labelMaxWidth,self.titleLabel.font.lineHeight)
                                                              options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                                           attributes:@{NSFontAttributeName: self.titleLabel.font}
                                                              context:nil].size;
        
        CGSize subtitleSize = [self.subtitleLabel.text boundingRectWithSize:CGSizeMake(labelMaxWidth,self.subtitleLabel.font.lineHeight)
                                                                    options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
                                                                 attributes:@{NSFontAttributeName: self.subtitleLabel.font}
                                                                    context:nil].size;
        
        CGFloat maxLabelWidth = MAX(titleSize.width,subtitleSize.width);
        
        CGFloat totalMaxWidth;
        if (maxLabelWidth) {
            totalMaxWidth = leftViewWidth + margin + maxLabelWidth;
        } else {
            totalMaxWidth = leftViewWidth + maxLabelWidth;
        }
        
        CGFloat labelX = (self.bounds.size.width / 2) - (totalMaxWidth / 2) + leftViewWidth + margin;
        
        if(subtitleSize.height > 0){
            CGFloat totalHeight = titleSize.height + subtitleSize.height + marginY;
            CGFloat minY = (self.bounds.size.height / 2)  - (totalHeight / 2);
            
            CGFloat titleY = minY;
            self.titleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY, titleSize.width, titleSize.height));
            self.subtitleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY + titleSize.height + marginY, subtitleSize.width, subtitleSize.height));
        }else{
            CGFloat totalHeight = titleSize.height;
            CGFloat minY = (self.bounds.size.height / 2)  - (totalHeight / 2);
            
            CGFloat titleY = minY;
            self.titleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY, titleSize.width, titleSize.height));
            self.subtitleLabel.frame = CGRectIntegral(CGRectMake(labelX, titleY + titleSize.height + marginY, subtitleSize.width, subtitleSize.height));
        }
        
        CGFloat arrowX = (self.bounds.size.width / 2) - (totalMaxWidth / 2) + (leftViewWidth - self.arrowView.bounds.size.width) / 2;
        self.arrowView.frame = CGRectMake(arrowX,
                                      (self.bounds.size.height / 2) - (self.arrowView.bounds.size.height / 2),
                                      self.arrowView.bounds.size.width,
                                      self.arrowView.bounds.size.height);
        
        if (self.showsArrowView) {
            self.indicatorView.center = self.arrowView.center;
        } else {
            CGPoint indicatorOrigin = CGPointMake(self.bounds.size.width / 2 - self.indicatorView.bounds.size.width / 2, self.indicatorPadding > 0 ? self.indicatorPadding : (self.bounds.size.height / 2 - self.indicatorView.bounds.size.height / 2));
            self.indicatorView.frame = CGRectMake(indicatorOrigin.x, indicatorOrigin.y, self.indicatorView.bounds.size.width, self.indicatorView.bounds.size.height);
        }
    }
}

#pragma mark - Static

+ (CGFloat)height {
    return FWPullRefreshViewHeight;
}

+ (void)setHeight:(CGFloat)height {
    FWPullRefreshViewHeight = height;
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset;
    [self setScrollViewContentInset:currentInsets pullingPercent:0];
}

- (void)setScrollViewContentInsetForLoading {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.top = self.originalTopInset + self.bounds.size.height;
    [self setScrollViewContentInset:currentInsets pullingPercent:1];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset pullingPercent:(CGFloat)pullingPercent {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {
                         self.pullingPercent = pullingPercent;
                     }];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        if (self.scrollView.fw.infiniteScrollView.isActive || contentOffset.y > 0) {
            if (self.pullingPercent > 0) self.pullingPercent = 0;
            if (self.state != FWPullRefreshStateStopped) {
                self.state = FWPullRefreshStateStopped;
            }
        } else {
            [self scrollViewDidScroll:contentOffset];
        }
    }else if([keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        self.frame = CGRectMake(0, -self.scrollView.fw.pullRefreshHeight, self.bounds.size.width, self.scrollView.fw.pullRefreshHeight);
    }else if([keyPath isEqualToString:@"frame"]) {
        [self layoutSubviews];
    }
}

- (void)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer stateChanged:(NSDictionary *)change {
    UIGestureRecognizerState state = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
    if (state == UIGestureRecognizerStateBegan) {
        self.isActive = NO;
        self.scrollView.fw.infiniteScrollView.isActive = NO;
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != FWPullRefreshStateLoading) {
        CGFloat progress = 1.f - (self.scrollView.fw.pullRefreshHeight + contentOffset.y) / self.scrollView.fw.pullRefreshHeight;
        if(progress > 0) self.isActive = YES;
        if(self.progressBlock) {
            self.progressBlock(self, MAX(MIN(progress, 1.f), 0.f));
        }
        
        CGFloat scrollOffsetThreshold = self.frame.origin.y - self.originalTopInset;
        if(!self.scrollView.isDragging && self.state == FWPullRefreshStateTriggered)
            self.state = FWPullRefreshStateLoading;
        else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && self.state == FWPullRefreshStateStopped) {
            self.state = FWPullRefreshStateTriggered;
            self.userTriggered = YES;
        } else if(contentOffset.y >= scrollOffsetThreshold && self.state != FWPullRefreshStateStopped)
            self.state = FWPullRefreshStateStopped;
        else if(contentOffset.y >= scrollOffsetThreshold && self.state == FWPullRefreshStateStopped)
            self.pullingPercent = MAX(MIN(1.f - (self.scrollView.fw.pullRefreshHeight + contentOffset.y) / self.scrollView.fw.pullRefreshHeight, 1.f), 0.f);
    } else {
        UIEdgeInsets currentInset = self.scrollView.contentInset;
        currentInset.top = self.originalTopInset + self.bounds.size.height;
        self.scrollView.contentInset = currentInset;
    }
}

#pragma mark - Getters

- (FWPullRefreshArrowView *)arrowView {
    if(!_arrowView) {
        _arrowView = [[FWPullRefreshArrowView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-47, 15, 40)];
        _arrowView.backgroundColor = [UIColor clearColor];
        [self addSubview:_arrowView];
    }
    return _arrowView;
}

- (UIView<FWIndicatorViewPlugin> *)indicatorView {
    if(!_indicatorView) {
        _indicatorView = [UIView fwIndicatorViewWithStyle:FWIndicatorViewStyleRefresh];
        _indicatorView.color = UIColor.grayColor;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 210, 20)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = textColor;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel {
    if(!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 210, 20)];
        _subtitleLabel.font = [UIFont systemFontOfSize:12];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = textColor;
        [self addSubview:_subtitleLabel];
    }
    return _subtitleLabel;
}

- (UIColor *)arrowColor {
    return self.arrowView.arrowColor; // pass through
}

- (UIColor *)textColor {
    return self.titleLabel.textColor;
}

- (UIColor *)indicatorColor {
    return self.indicatorView.color;
}

#pragma mark - Setters

- (void)setArrowColor:(UIColor *)newArrowColor {
    self.arrowView.arrowColor = newArrowColor; // pass through
    [self.arrowView setNeedsDisplay];
}

- (void)setTitle:(NSString *)title forState:(FWPullRefreshState)state {
    if(!title)
        title = @"";
    
    if(state == FWPullRefreshStateAll)
        [self.titles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[title, title, title]];
    else
        [self.titles replaceObjectAtIndex:state withObject:title];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setSubtitle:(NSString *)subtitle forState:(FWPullRefreshState)state {
    if(!subtitle)
        subtitle = @"";
    
    if(state == FWPullRefreshStateAll)
        [self.subtitles replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[subtitle, subtitle, subtitle]];
    else
        [self.subtitles replaceObjectAtIndex:state withObject:subtitle];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setCustomView:(UIView *)view forState:(FWPullRefreshState)state {
    id viewPlaceholder = view;
    
    if(!viewPlaceholder)
        viewPlaceholder = @"";
    
    if(state == FWPullRefreshStateAll)
        [self.viewForState replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[viewPlaceholder, viewPlaceholder, viewPlaceholder]];
    else
        [self.viewForState replaceObjectAtIndex:state withObject:viewPlaceholder];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setShowsTitleLabel:(BOOL)showsTitleLabel {
    _showsTitleLabel = showsTitleLabel;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setShowsArrowView:(BOOL)showsArrowView {
    _showsArrowView = showsArrowView;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setTextColor:(UIColor *)newTextColor {
    textColor = newTextColor;
    self.titleLabel.textColor = newTextColor;
    self.subtitleLabel.textColor = newTextColor;
}

- (void)setIndicatorView:(UIView<FWIndicatorViewPlugin> *)indicatorView {
    UIColor *indicatorColor = self.indicatorView.color;
    [_indicatorView removeFromSuperview];
    _indicatorView = indicatorView;
    _indicatorView.color = indicatorColor;
    [self addSubview:_indicatorView];
    
    if (![_indicatorView isKindOfClass:[UIActivityIndicatorView class]]) {
        _showsTitleLabel = NO;
        _showsArrowView = NO;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    self.indicatorView.color = indicatorColor;
}

- (void)setIndicatorPadding:(CGFloat)indicatorPadding {
    _indicatorPadding = indicatorPadding;
    [self setNeedsLayout];
}

- (void)setPullingPercent:(CGFloat)pullingPercent {
    _pullingPercent = pullingPercent;
    self.alpha = self.shouldChangeAlpha ? pullingPercent : 1;
    
    if (pullingPercent > 0 && !self.showsArrowView) {
        id customView = [self.viewForState objectAtIndex:self.state];
        BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
        if (!hasCustomView && !self.indicatorView.isAnimating) {
            [self.indicatorView startAnimating];
        }
    }
}

#pragma mark -

- (void)startAnimating{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -(self.frame.size.height + self.originalTopInset)) animated:YES];
    
    self.state = FWPullRefreshStateLoading;
}

- (void)stopAnimating {
    if (!self.isAnimating) return;
    
    self.state = FWPullRefreshStateStopped;
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.originalTopInset) animated:YES];
}

- (BOOL)isAnimating {
    return self.state != FWPullRefreshStateStopped;
}

- (void)setState:(FWPullRefreshState)newState {
    
    if(_state == newState)
        return;
    
    FWPullRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    switch (newState) {
        case FWPullRefreshStateAll:
        case FWPullRefreshStateStopped:
            [self resetScrollViewContentInset];
            break;
            
        case FWPullRefreshStateTriggered:
            self.isActive = YES;
            break;
            
        case FWPullRefreshStateLoading:
            [self setScrollViewContentInsetForLoading];
            
            if(previousState == FWPullRefreshStateTriggered) {
                if(pullRefreshBlock) {
                    pullRefreshBlock();
                }else if(self.target && self.action && [self.target respondsToSelector:self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self.target performSelector:self.action];
#pragma clang diagnostic pop
                }
            }
            break;
    }
    
    if (self.stateBlock) {
        self.stateBlock(self, newState);
    }
}

- (void)rotateArrow:(float)degrees hide:(BOOL)hide {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.arrowView.layer.transform = CATransform3DMakeRotation(degrees, 0, 0, 1);
        self.arrowView.layer.opacity = !hide;
    } completion:NULL];
}

@end

#pragma mark - FWScrollViewWrapper+FWPullRefresh

static char UIScrollViewFWPullRefreshView;

@implementation FWScrollViewWrapper (FWPullRefresh)

- (void)addPullRefreshWithBlock:(void (^)(void))block {
    [self addPullRefreshWithBlock:block target:nil action:NULL];
}

- (void)addPullRefreshWithTarget:(id)target action:(SEL)action {
    [self addPullRefreshWithBlock:nil target:target action:action];
}

- (void)addPullRefreshWithBlock:(void (^)(void))block target:(id)target action:(SEL)action {
    [self.pullRefreshView removeFromSuperview];
    
    FWPullRefreshView *view = [[FWPullRefreshView alloc] initWithFrame:CGRectMake(0, -self.pullRefreshHeight, self.base.bounds.size.width, self.pullRefreshHeight)];
    view.pullRefreshBlock = block;
    view.target = target;
    view.action = action;
    view.scrollView = self.base;
    [self.base addSubview:view];
    
    view.originalTopInset = self.base.contentInset.top;
    self.pullRefreshView = view;
    self.showPullRefresh = YES;
}

- (void)triggerPullRefresh {
    if ([self.pullRefreshView isAnimating]) return;
    
    self.pullRefreshView.state = FWPullRefreshStateTriggered;
    self.pullRefreshView.userTriggered = NO;
    [self.pullRefreshView startAnimating];
}

- (void)setPullRefreshView:(FWPullRefreshView *)pullRefreshView {
    objc_setAssociatedObject(self.base, &UIScrollViewFWPullRefreshView,
                             pullRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (FWPullRefreshView *)pullRefreshView {
    return objc_getAssociatedObject(self.base, &UIScrollViewFWPullRefreshView);
}

- (void)setPullRefreshHeight:(CGFloat)pullRefreshHeight {
    objc_setAssociatedObject(self.base, @selector(pullRefreshHeight), @(pullRefreshHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)pullRefreshHeight {
#if CGFLOAT_IS_DOUBLE
    CGFloat height = [objc_getAssociatedObject(self.base, @selector(pullRefreshHeight)) doubleValue];
#else
    CGFloat height = [objc_getAssociatedObject(self.base, @selector(pullRefreshHeight)) floatValue];
#endif
    return height > 0 ? height : FWPullRefreshViewHeight;
}

- (void)setShowPullRefresh:(BOOL)showPullRefresh {
    if(!self.pullRefreshView)return;
    
    self.pullRefreshView.hidden = !showPullRefresh;
    if(!showPullRefresh) {
        if (self.pullRefreshView.isObserving) {
            [self.base removeObserver:self.pullRefreshView forKeyPath:@"contentOffset"];
            [self.base removeObserver:self.pullRefreshView forKeyPath:@"contentSize"];
            [self.base removeObserver:self.pullRefreshView forKeyPath:@"frame"];
            [self.base.panGestureRecognizer.fw unobserveProperty:@"state" target:self.pullRefreshView action:@selector(gestureRecognizer:stateChanged:)];
            [self.pullRefreshView resetScrollViewContentInset];
            self.pullRefreshView.isObserving = NO;
        }
    }
    else {
        if (!self.pullRefreshView.isObserving) {
            [self.base addObserver:self.pullRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self.base addObserver:self.pullRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self.base addObserver:self.pullRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            [self.base.panGestureRecognizer.fw observeProperty:@"state" target:self.pullRefreshView action:@selector(gestureRecognizer:stateChanged:)];
            self.pullRefreshView.isObserving = YES;
            
            [self.pullRefreshView setNeedsLayout];
            [self.pullRefreshView layoutIfNeeded];
            self.pullRefreshView.frame = CGRectMake(0, -self.pullRefreshHeight, self.base.bounds.size.width, self.pullRefreshHeight);
        }
    }
}

- (BOOL)showPullRefresh {
    return !self.pullRefreshView.hidden;
}

@end

#pragma mark - FWInfiniteScrollView

@implementation FWInfiniteScrollView

// public properties
@synthesize infiniteScrollBlock, indicatorColor;
@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize indicatorView = _indicatorView;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = FWInfiniteScrollStateStopped;
        self.enabled = YES;
        
        self.viewForState = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", nil];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.fw.showInfiniteScroll) {
            if (self.isObserving) {
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView.panGestureRecognizer.fw unobserveProperty:@"state" target:self action:@selector(gestureRecognizer:stateChanged:)];
                self.isObserving = NO;
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint indicatorOrigin = CGPointMake(self.bounds.size.width / 2 - self.indicatorView.bounds.size.width / 2, self.indicatorPadding > 0 ? self.indicatorPadding : (self.bounds.size.height / 2 - self.indicatorView.bounds.size.height / 2));
    self.indicatorView.frame = CGRectMake(indicatorOrigin.x, indicatorOrigin.y, self.indicatorView.bounds.size.width, self.indicatorView.bounds.size.height);
}

#pragma mark - Static

+ (CGFloat)height {
    return FWInfiniteScrollViewHeight;
}

+ (void)setHeight:(CGFloat)height {
    FWInfiniteScrollViewHeight = height;
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + self.scrollView.fw.infiniteScrollHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        if (self.scrollView.fw.pullRefreshView.isActive || contentOffset.y < 0) {
            if (self.state != FWInfiniteScrollStateStopped) {
                self.state = FWInfiniteScrollStateStopped;
            }
        } else {
            [self scrollViewDidScroll:contentOffset];
        }
    }else if([keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.bounds.size.width, self.scrollView.fw.infiniteScrollHeight);
    }
}

- (void)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer stateChanged:(NSDictionary *)change {
    UIGestureRecognizerState state = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
    if (state == UIGestureRecognizerStateBegan) {
        self.isActive = NO;
        self.scrollView.fw.pullRefreshView.isActive = NO;
    } else if (state == UIGestureRecognizerStateEnded && self.state == FWInfiniteScrollStateTriggered) {
        if (self.scrollView.contentOffset.y >= 0) {
            self.state = FWInfiniteScrollStateLoading;
        } else {
            self.state = FWInfiniteScrollStateStopped;
        }
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != FWInfiniteScrollStateLoading && self.enabled) {
        if(self.progressBlock) {
            CGFloat scrollHeight = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom, self.scrollView.fw.infiniteScrollHeight);
            CGFloat progress = (self.scrollView.fw.infiniteScrollHeight + contentOffset.y - scrollHeight) / self.scrollView.fw.infiniteScrollHeight;
            self.progressBlock(self, MAX(MIN(progress, 1.f), 0.f));
        }
        
        CGFloat scrollOffsetThreshold = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height - self.preloadHeight, 0);
        if(!self.scrollView.isDragging && self.state == FWInfiniteScrollStateTriggered)
            self.state = FWInfiniteScrollStateLoading;
        else if(contentOffset.y > scrollOffsetThreshold && self.state == FWInfiniteScrollStateStopped && self.scrollView.isDragging) {
            self.state = FWInfiniteScrollStateTriggered;
            self.userTriggered = YES;
        } else if(contentOffset.y < scrollOffsetThreshold && self.state != FWInfiniteScrollStateStopped)
            self.state = FWInfiniteScrollStateStopped;
    }
}

#pragma mark - Getters

- (UIView<FWIndicatorViewPlugin> *)indicatorView {
    if(!_indicatorView) {
        _indicatorView = [UIView fwIndicatorViewWithStyle:FWIndicatorViewStyleRefresh];
        _indicatorView.color = UIColor.grayColor;
        [self addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UIColor *)indicatorColor {
    return self.indicatorView.color;
}

#pragma mark - Setters

- (void)setCustomView:(UIView *)view forState:(FWInfiniteScrollState)state {
    id viewPlaceholder = view;
    
    if(!viewPlaceholder)
        viewPlaceholder = @"";
    
    if(state == FWInfiniteScrollStateAll)
        [self.viewForState replaceObjectsInRange:NSMakeRange(0, 3) withObjectsFromArray:@[viewPlaceholder, viewPlaceholder, viewPlaceholder]];
    else
        [self.viewForState replaceObjectAtIndex:state withObject:viewPlaceholder];
    
    self.state = self.state;
}

- (void)setIndicatorView:(UIView<FWIndicatorViewPlugin> *)indicatorView {
    UIColor *indicatorColor = self.indicatorView.color;
    [_indicatorView removeFromSuperview];
    _indicatorView = indicatorView;
    _indicatorView.color = indicatorColor;
    [self addSubview:_indicatorView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    self.indicatorView.color = indicatorColor;
}

- (void)setIndicatorPadding:(CGFloat)indicatorPadding {
    _indicatorPadding = indicatorPadding;
    [self setNeedsLayout];
}

#pragma mark -

- (void)startAnimating{
    self.state = FWInfiniteScrollStateLoading;
}

- (void)stopAnimating {
    self.state = FWInfiniteScrollStateStopped;
}

- (BOOL)isAnimating {
    return self.state != FWInfiniteScrollStateStopped;
}

- (void)setState:(FWInfiniteScrollState)newState {
    
    if(_state == newState)
        return;
    
    FWInfiniteScrollState previousState = _state;
    _state = newState;
    
    id customView = [self.viewForState objectAtIndex:newState];
    BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
    BOOL customViewChanged = customView != self.currentCustomView;
    if (customViewChanged || !hasCustomView) {
        [self.currentCustomView removeFromSuperview];
        self.currentCustomView = nil;
    }
    
    if(hasCustomView) {
        if (customViewChanged) {
            self.currentCustomView = customView;
            [self addSubview:customView];
        }
        CGRect viewBounds = [customView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), self.indicatorPadding > 0 ? self.indicatorPadding : roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
        
        switch (newState) {
            case FWInfiniteScrollStateStopped:
                // remove current custom view if not changed
                if (!customViewChanged) {
                    [self.currentCustomView removeFromSuperview];
                    self.currentCustomView = nil;
                }
                break;
            case FWInfiniteScrollStateTriggered:
                self.isActive = YES;
                break;
            case FWInfiniteScrollStateLoading:
            default:
                break;
        }
    }
    else {
        CGRect viewBounds = [self.indicatorView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2), self.indicatorPadding > 0 ? self.indicatorPadding : roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [self.indicatorView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
        
        switch (newState) {
            case FWInfiniteScrollStateStopped:
                [self.indicatorView stopAnimating];
                break;
                
            case FWInfiniteScrollStateTriggered:
                self.isActive = YES;
                [self.indicatorView startAnimating];
                break;
                
            case FWInfiniteScrollStateLoading:
                [self.indicatorView startAnimating];
                break;
                
            default:
                break;
        }
    }
    
    if(previousState == FWInfiniteScrollStateTriggered && newState == FWInfiniteScrollStateLoading && self.enabled) {
        if(self.infiniteScrollBlock) {
            self.infiniteScrollBlock();
        }
        else if(self.target && self.action && [self.target respondsToSelector:self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.target performSelector:self.action];
#pragma clang diagnostic pop
        }
    }
    
    if(self.stateBlock) {
        self.stateBlock(self, newState);
    }
}

@end

#pragma mark - FWScrollViewWrapper+FWInfiniteScroll

static char UIScrollViewFWInfiniteScrollView;

@implementation FWScrollViewWrapper (FWInfiniteScroll)

- (void)addInfiniteScrollWithBlock:(void (^)(void))block {
    [self addInfiniteScrollWithBlock:block target:nil action:NULL];
}

- (void)addInfiniteScrollWithTarget:(id)target action:(SEL)action {
    [self addInfiniteScrollWithBlock:nil target:target action:action];
}

- (void)addInfiniteScrollWithBlock:(void (^)(void))block target:(id)target action:(SEL)action {
    [self.infiniteScrollView removeFromSuperview];
    
    FWInfiniteScrollView *view = [[FWInfiniteScrollView alloc] initWithFrame:CGRectMake(0, self.base.contentSize.height, self.base.bounds.size.width, self.infiniteScrollHeight)];
    view.infiniteScrollBlock = block;
    view.target = target;
    view.action = action;
    view.scrollView = self.base;
    [self.base addSubview:view];
    
    view.originalBottomInset = self.base.contentInset.bottom;
    self.infiniteScrollView = view;
    self.showInfiniteScroll = YES;
}

- (void)triggerInfiniteScroll {
    if ([self.infiniteScrollView isAnimating]) return;
    
    self.infiniteScrollView.state = FWInfiniteScrollStateTriggered;
    self.infiniteScrollView.userTriggered = NO;
    [self.infiniteScrollView startAnimating];
}

- (void)setInfiniteScrollView:(FWInfiniteScrollView *)infiniteScrollView {
    objc_setAssociatedObject(self.base, &UIScrollViewFWInfiniteScrollView,
                             infiniteScrollView,
                             OBJC_ASSOCIATION_ASSIGN);
}

- (FWInfiniteScrollView *)infiniteScrollView {
    return objc_getAssociatedObject(self.base, &UIScrollViewFWInfiniteScrollView);
}

- (void)setInfiniteScrollHeight:(CGFloat)infiniteScrollHeight {
    objc_setAssociatedObject(self.base, @selector(infiniteScrollHeight), @(infiniteScrollHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)infiniteScrollHeight {
#if CGFLOAT_IS_DOUBLE
    CGFloat height = [objc_getAssociatedObject(self.base, @selector(infiniteScrollHeight)) doubleValue];
#else
    CGFloat height = [objc_getAssociatedObject(self.base, @selector(infiniteScrollHeight)) floatValue];
#endif
    return height > 0 ? height : FWInfiniteScrollViewHeight;
}

- (void)setShowInfiniteScroll:(BOOL)showInfiniteScroll {
    if(!self.infiniteScrollView)return;
    
    self.infiniteScrollView.hidden = !showInfiniteScroll;
    if(!showInfiniteScroll) {
        if (self.infiniteScrollView.isObserving) {
            [self.base removeObserver:self.infiniteScrollView forKeyPath:@"contentOffset"];
            [self.base removeObserver:self.infiniteScrollView forKeyPath:@"contentSize"];
            [self.base.panGestureRecognizer.fw unobserveProperty:@"state" target:self.infiniteScrollView action:@selector(gestureRecognizer:stateChanged:)];
            [self.infiniteScrollView resetScrollViewContentInset];
            self.infiniteScrollView.isObserving = NO;
        }
    }
    else {
        if (!self.infiniteScrollView.isObserving) {
            [self.base addObserver:self.infiniteScrollView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self.base addObserver:self.infiniteScrollView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self.base.panGestureRecognizer.fw observeProperty:@"state" target:self.infiniteScrollView action:@selector(gestureRecognizer:stateChanged:)];
            [self.infiniteScrollView setScrollViewContentInsetForInfiniteScrolling];
            self.infiniteScrollView.isObserving = YES;
            
            [self.infiniteScrollView setNeedsLayout];
            [self.infiniteScrollView layoutIfNeeded];
            self.infiniteScrollView.frame = CGRectMake(0, self.base.contentSize.height, self.infiniteScrollView.bounds.size.width, self.infiniteScrollHeight);
        }
    }
}

- (BOOL)showInfiniteScroll {
    return !self.infiniteScrollView.hidden;
}

@end
